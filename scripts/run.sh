#! /usr/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo -n 'db' | gnome-keyring-daemon --unlock
python3 "${SCRIPT_DIR}/run.py"
# echo "Going to sleep in 60 seconds, for 24 hours..."
# sleep 60
# echo 0 > /sys/class/rtc/rtc0/wakealarm #reset
# echo "$(date -d 'now + 24 hours' +%s)" > /sys/class/rtc/rtc0/wakealarm
# halt
