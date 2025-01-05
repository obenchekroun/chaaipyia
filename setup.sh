#! /usr/bin/bash
# Due to the similarity in projects, a lot of this is based on TomWhitwell's install script from SlowMovie
# https://github.com/TomWhitwell/SlowMovie/blob/main/Install/install.sh

GIT_REPO=https://github.com/obenchekroun/chaaipyia
GIT_BRANCH=main
SKIP_DEPS=false

# Set the local directory
LOCAL_DIR="$HOME/$(basename $GIT_REPO)"
PROMPTS_DIR="${LOCAL_DIR}/prompts"
IMAGES_DIR="${LOCAL_DIR}/images"

# File paths
SERVICE_DIR=/etc/systemd/system
SERVICE_FILE=chaaipyia.service
SERVICE_FILE_TEMPLATE=chaaipyia.service.template
KEY_SCRIPT=scripts/set_keys.py
CONFIG_SCRIPT=scripts/migrate_config.py
LED_SCRIPT=scripts/pijuice_disable_leds.py
SMB_DEFAULT_LOCATION=/etc/samba/smb.conf
SMB_CHAAPIYIA_LOCATION=/etc/samba/chaaipyia.conf

# Color code variables
RED="\e[0;91m"
YELLOW="\e[0;93m"
GREEN='\033[0;32m'
RESET="\e[0m"

function install_linux_packages(){
  sudo apt-get update
  sudo apt-get install -y git python3-pip libatlas-base-dev pass gnupg2 jq libopenjp2-7
}

function install_pijuice_package(){
  # Install pijuice.
  sudo apt-get install -y pijuice-base pijuice-gui
  echo -e "PiJuice installed"
}

function install_python_packages(){
  sudo pip3 install "git+https://github.com/obenchekroun/chaaipyia@$(curl -s https://api.github.com/repos/obenchekroun/chaaipyia/releases/latest | jq -r ".tag_name")" --break-system-packages
  sudo pip3 install stability-sdk @ git+https://github.com/Stability-AI/stability-sdk.git --break-system-packages
  sudo pip3 install openai @ git+https://github.com/openai/openai-python.git --break-system-packages
}

function install_python_minimal(){
  sudo pip3 install "git+https://github.com/obenchekroun/chaaipyia@$(curl -s https://api.github.com/repos/obenchekroun/chaaipyia/releases/latest | jq -r ".tag_name")" --no-dependencies --break-system-packages
}

function uninstall_python_packages(){
  sudo pip3 uninstall piblo -y
  echo -e "chaaipyia (piblo) package uninstalled"
}

function fix_grpcio(){
  echo -e "${YELLOW}This might take a while... Be patient...${RESET}"
  sudo pip3 uninstall grpcio grpcio-tools -y
  sudo pip3 install grpcio==1.44.0 --no-binary=grpcio grpcio-tools==1.44.0 --no-binary=grpcio-tools --break-system-packages
  echo -e "GRPCIO fix applied"
}

function update_grpcio(){
  sudo pip3 uninstall grpcio grpcio-tools -y
  sudo pip3 install grpcio grpcio-tools --upgrade --break-system-packages
  echo -e "GRPCIO update applied"
}

function set_key(){
  cd "${LOCAL_DIR}" || exit
  sudo dbus-run-session python3 "${LOCAL_DIR}/${KEY_SCRIPT}"
}

function migrate_config(){
  cd "${LOCAL_DIR}" || exit
  sudo python3 "${LOCAL_DIR}/${CONFIG_SCRIPT}"
}

function disable_leds(){
  cd "${LOCAL_DIR}" || exit
  sudo python3 "${LOCAL_DIR}/${LED_SCRIPT}"
  echo -e "PiJuice LEDS disabled"
}

function setup_hardware(){
  echo "Setting up SPI"
  if ls /dev/spi* &> /dev/null; then
      echo -e "SPI already enabled"
  else
      if command -v raspi-config > /dev/null && sudo raspi-config nonint get_spi | grep -q "1"; then
          sudo raspi-config nonint do_spi 0
          echo -e "SPI is now enabled"
      else
          echo -e "${RED}There was an error enabling SPI, enable manually with sudo raspi-config${RESET}"
      fi
  fi
}

function service_installed(){
  # return 0 if the service is installed, 1 if no
  if [ -f "$SERVICE_DIR/$SERVICE_FILE" ]; then
    return 0
  else
    return 1
  fi
}

function copy_service_file(){
  sudo mv $SERVICE_FILE $SERVICE_DIR
  sudo systemctl daemon-reload
}

function install_service(){
  if [ -d "${LOCAL_DIR}" ]; then
    cd "$LOCAL_DIR" || return

    # generate the service file
    envsubst <$SERVICE_FILE_TEMPLATE > $SERVICE_FILE

    if ! (service_installed); then
      # install the service files and enable
      copy_service_file
      sudo systemctl enable chaaipyia

      echo -e "chaaipyia service installed! Use '${GREEN}sudo systemctl restart chaaipyia${RESET}' to test"
    else
      echo -e "${YELLOW}chaaipyia service is installed, checking if it needs an update${RESET}"
      if ! (cmp -s "chaaipyia.service" "/etc/systemd/system/chaaipyia.service"); then
        copy_service_file
        echo -e "Updating chaaipyia service file"
      else
        # remove the generated service file
        echo -e "No update needed"
        rm $SERVICE_FILE
      fi
    fi
  else
    echo -e "${RED}chaaipyia repo does not exist! Use option 1 - Install/Upgrade chaaipyia first${RESET}"
  fi

  # go back to home
  cd "$HOME" || return
}

function uninstall_service(){
  if (service_installed); then
    # stop if running and remove service files
    sudo systemctl stop chaaipyia
    sudo systemctl disable chaaipyia
    sudo rm "${SERVICE_DIR}/${SERVICE_FILE}"
    sudo systemctl daemon-reload

    echo -e "chaaipyia service was successfully uninstalled"
  else
    echo -e "${RED}chaaipyia service is already uninstalled.${RESET}"
  fi
}

function setup_smb(){
  sudo apt update
  sudo apt install samba -y

  echo "
    [prompts]
    comment = Prompts folder for chaaipyia
    path = ${PROMPTS_DIR}
    public = yes
    writable = yes
    guest ok = yes
    security = SHARE

    [images]
    comment = Images folder for chaaipyia
    path = ${IMAGES_DIR}
    public = yes
    writable = yes
    guest ok = yes
    security = SHARE
    " | sudo tee "${SMB_CHAAIPYIA_LOCATION}"

    sudo chmod -R 777 "${PROMPTS_DIR}"
    sudo chmod -R 777 "${IMAGES_DIR}"

  if grep -Fq "${SMB_CHAAIPYIA_LOCATION}" ${SMB_DEFAULT_LOCATION}
  then
        echo "${YELLOW}'${SMB_CHAAIPYIA_LOCATION}' already exists in ${SMB_DEFAULT_LOCATION}${RESET}"
  else
        echo "Adding '${SMB_CHAAIPYIA_LOCATION}' to ${SMB_DEFAULT_LOCATION}"
        echo "include = ${SMB_CHAAIPYIA_LOCATION}" | sudo tee -a /etc/samba/smb.conf
  fi

  sudo systemctl enable smbd
  sudo systemctl restart smbd
  echo "SMB installed and folders '${PROMPTS_DIR}' and '${IMAGES_DIR}' shared with ${YELLOW}full permissions${RESET}"
}

function install_chaaipyia(){

  # check if service is currently running and stop if it is
  RESTART_SERVICE="FALSE"

  if (systemctl is-active --quiet chaaipyia); then
    sudo systemctl stop chaaipyia
    RESTART_SERVICE="TRUE"
  fi

  FIRST_TIME=1  # if this is a first time install

  if [ "${SKIP_DEPS}" = false ]; then
    # install from apt
    install_linux_packages

    # configure the hardware
    setup_hardware
  else
    echo -e "Skipping dependency installs, updating chaaipyia code only"
  fi

  if [ -d "${LOCAL_DIR}" ]; then
    echo -e "Existing Install Found - Updating Repo"
    cd "${LOCAL_DIR}" || exit
    git fetch
    git checkout $GIT_BRANCH
    git pull
  else
    echo -e "No Install Found - Cloning Repo"
    git clone -b "${GIT_BRANCH}" "${GIT_REPO}" "${LOCAL_DIR}"
    FIRST_TIME=0
  fi

  # generate default config files and prompts
  if [ ! -f "${LOCAL_DIR}/.config" ]; then
    cp "${LOCAL_DIR}/examples/.config-example" "${LOCAL_DIR}/.config"
  fi

  if [ ! -f "${LOCAL_DIR}/.creds" ]; then
    cp "${LOCAL_DIR}/examples/.creds-example" "${LOCAL_DIR}/.creds"
  fi

  if [ ! -d "${LOCAL_DIR}/prompts" ]; then
    mkdir "${LOCAL_DIR}/prompts"
  fi

  if [ ! -d "${LOCAL_DIR}/images" ]; then
    mkdir "${LOCAL_DIR}/images"
  fi

  if [ ! -d "${LOCAL_DIR}/images/generated" ]; then
    mkdir "${LOCAL_DIR}/images/generated"
  fi

  if [ ! -d "${LOCAL_DIR}/images/external" ]; then
    mkdir "${LOCAL_DIR}/images/external"
  fi

  if [ ! -f "${LOCAL_DIR}/prompts/artists.txt" ]; then

    cp "${LOCAL_DIR}/examples/prompts/artists-example.txt" "${PROMPTS_DIR}/artists.txt"
  fi

  if [ ! -f "${LOCAL_DIR}/prompts/subjects.txt" ]; then
    cp "${LOCAL_DIR}/examples/prompts/subjects-example.txt" "${PROMPTS_DIR}/subjects.txt"
  fi

  if [ ! -f "${LOCAL_DIR}/prompts/prompts.txt" ]; then
    cp "${LOCAL_DIR}/examples/prompts/prompts-example.txt" "${PROMPTS_DIR}/prompts.txt"
  fi

  if [ "$SKIP_DEPS" = false ]; then
    # install any needed python packages
    if [ "$1" = true ]; then
      install_python_minimal
    else
      install_python_packages
    fi
  fi

  cd "${LOCAL_DIR}" || exit

  echo -e "chaaipyia install/update complete. To test, run '${GREEN}python3 ${LOCAL_DIR}/examples/review_screen.py${RESET}'"

  return $FIRST_TIME
}

INSTALL_OPTION=999

while [ $INSTALL_OPTION -ne 0 ]
do
 INSTALL_OPTION=$(whiptail --menu "\

  ░█████╗░██╗░░██╗░█████╗░░█████╗░██╗██████╗░██╗░░░██╗██╗░█████╗░
  ██╔══██╗██║░░██║██╔══██╗██╔══██╗██║██╔══██╗╚██╗░██╔╝██║██╔══██╗
  ██║░░╚═╝███████║███████║███████║██║██████╔╝░╚████╔╝░██║███████║
  ██║░░██╗██╔══██║██╔══██║██╔══██║██║██╔═══╝░░░╚██╔╝░░██║██╔══██║
  ╚█████╔╝██║░░██║██║░░██║██║░░██║██║██║░░░░░░░░██║░░░██║██║░░██║
  ░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░░░░░░░╚═╝░░░╚═╝╚═╝░░╚═╝

  Repo set to '${GIT_REPO}/${GIT_BRANCH}'
  Setting up in local directory '${LOCAL_DIR}'

  Choose what you want to do." 0 0 0 \
 1 "Install/Upgrade chaaipyia (Full)" \
 2 "Upgrade chaaipyia minimally (Do not update requirements)" \
 3 "Install chaaipyia Service" \
 4 "Install pijuice" \
 5 "Apply GRPCIO Fix (Rollback to versions 1.44)" \
 6 "Apply GRPCIO Update (Update to most recent version)" \
 7 "Set an API key or connect website" \
 8 "Migrate config file" \
 9 "Disable pijuice LEDs" \
 10 "Install SMB and default shares" \
 11 "Uninstall chaaipyia" \
 12 "Uninstall chaaipyia Service" \
 0 "Exit Setup" \
 3>&1 1>&2 2>&3)

 : "${INSTALL_OPTION:=0}"

 if [ $INSTALL_OPTION -eq 1 ]; then

   # Prompt for service install if the first time being run (whiptail 1=No)
   INSTALL_SERVICE=1
   if [ ! -d "${LOCAL_DIR}" ]; then
     if whiptail --yesno "Would you like to install the chaaipyia service to start on boot?" 0 0; then
       INSTALL_SERVICE=1
     else
       INSTALL_SERVICE=0
     fi
   fi

   if whiptail --yesno "Would you like to install pijuice?" 0 0; then
     INSTALL_PIJUICE=1
   else
     INSTALL_PIJUICE=0
   fi

   # Install or update
   install_chaaipyia false

   # Install service, if desired
   if [ $INSTALL_SERVICE -eq 1 ]; then
     install_service
   fi

   if [ $INSTALL_PIJUICE -eq 1 ]; then
     install_pijuice_package
   fi
 elif [ $INSTALL_OPTION -eq 2 ]; then
   # Install chaaipyia min
   install_chaaipyia true
 elif [ $INSTALL_OPTION -eq 3 ]; then
   # Install the service
   install_service
 elif [ $INSTALL_OPTION -eq 4 ]; then
   # Install pijuice
   install_pijuice_package
 elif [ $INSTALL_OPTION -eq 5 ]; then
   # Fix GRPCIO with old version
   if whiptail --yesno "This option uninstalls grpcio and grpcio-tools and instead installs versions 1.44. Takes a while to do, use this option if you want to use keychain to manage API keys. Proceed?" 0 0; then
     fix_grpcio
   fi
 elif [ $INSTALL_OPTION -eq 6 ]; then
   # Fix GRPCIO with updated version
   if whiptail --yesno "This option uninstalls grpcio and grpcio-tools and instead installs the most recent version. May be unpredictable, but could give better results if chaaipyia is failing to start due to GLIBC issues. Proceed?" 0 0; then
     update_grpcio
   fi
 elif [ $INSTALL_OPTION -eq 7 ]; then
   # Run python3 script to set key
   set_key
 elif [ $INSTALL_OPTION -eq 8 ]; then
   # Run python3 script to migrate old config to updated configuration
   if whiptail --yesno "This option will migrate your old config into a new config file containing any new variables or options. This will remove any comments from the configuration file. Proceed?" 0 0; then
     migrate_config
   fi
 elif [ $INSTALL_OPTION -eq 9 ]; then
   # Run python script to disable leds on pijuice
   disable_leds
 elif [ $INSTALL_OPTION -eq 10 ]; then
   # Set up SMB
   setup_smb
 elif [ $INSTALL_OPTION -eq 11 ]; then
   # Uninstall chaaipyia
   uninstall_python_packages
   uninstall_service
 elif [ $INSTALL_OPTION -eq 12 ]; then
   # Uninstall the service
   uninstall_service
 fi
done


if [ "${RESTART_SERVICE}" = "TRUE" ] && (service_installed); then
  sudo systemctl start chaaipyia
fi
