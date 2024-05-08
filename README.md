# chaaipyia
System to send AI generated art to an E-Paper display through a Raspberry PI unit

| ![Chaaipyia at work](/img/chaapiyia.jpg?raw=true) | 
|:--:| 
| *Working hard !* |

## Acknowledgments

Based on Pycasso : [Jess Farber's Pycasso](https://github.com/jezs00/pycasso). This project has been largely based on pycasso with a few tweaks for my needs. All credit goes to them for making this awesome project.

An article has been published on pycasso's development by Jess Farber  [here](https://jezs00.medium.com/pycasso-how-to-build-a-picture-frame-to-show-you-random-ai-art-every-day-44a1d3d78237).

Inspiration for pycasso based on Tom Whitwell's [SlowMovie](https://github.com/TomWhitwell/SlowMovie) and the very helpful write-up available at https://debugger.medium.com/how-to-build-a-very-slow-movie-player-in-2020-c5745052e4e4 on setting up epaper to work with a Raspberry Pi unit. I also liberally reused a lot of the install.sh script from this project because of the similarities and because it's pretty good. I would also like to acknowledge [robweber](https://github.com/robweber) who not only created [omni-epd](https://github.com/robweber/omni-epd) which I implemented so that this can work dynamically with many displays, but also provided me with a lot of good code examples that I referred back to often to try to ensure I was following best practises.

Uses [stability-sdk](https://github.com/Stability-AI/stability-sdk) to interact with Stable Diffusion's API.

Uses [openai-python](https://github.com/openai/openai-python) to interact with DALL-E's API.

## Setup

### Get Raspberry Pi Ready
* Install Raspberry Pi OS from https://www.raspberrypi.com/software/operating-systems/ . Tested on Bullseye !

### (Optional) Plug in pijuice HAT
* If using, attach PiJuice HAT onto Raspberry Pi. See [pijuice documentation](https://github.com/PiSupply/PiJuice/blob/master/Software/README.md) for
more information. You can always do this later if you don't want to use PiJuice yet.

### Connect EPD to Pi
* CAREFULLY plug EPD into Raspberry Pi, or on top of pijuice HAT, following instructions from the vendor. chaaipyia implements omni-epd and should work with any EPD listed on this page: https://github.com/robweber/omni-epd/blob/main/README.md .

In the case of the Waveshare e-paper 5.65inch 7colors display used in this case, the connection is as follows :
![Pin connection to Raspberry Pi](/img/pin_waveshare_epd.epd5in65f.png?raw=true)
* Connect power directly to Raspberry Pi (or PiJuice unit) once done.

### Install chaapyia
* SSH into the raspberry pi unit, or plug monitor and keyboard in.
* (Optional) Run `sudo apt-get update` and `sudo apt-get upgrade` to update system
* Run the following code to install chaapyia in your home directory:
``` shell
bash <(curl https://raw.githubusercontent.com/obenchekroun/chaaipyia/main/setup.sh)
```

* Take note of the proposed installation directory
* Select `Option 1` - Install/Upgrade chaaipyia
* Select "Yes" to enable service on boot if that is what you want to do _(it is probably what you want to do)_
* (Optional) If you want to use pijuice, select "Yes" to install PiJuice
* GPRCIO fix : 
  *  issues with GPRCIO make the following options necessary : (Optional) Select `Option 5 - Apply GRPCIO Fix` _(There are issues with GLIBC on raspberry pi, and it was installed by the Stable Diffusion package. This fixes it up and does not appear to break Stable Diffusion. You'll probably have to do this, but fallback to the second option for RPi Zero 2W, as this one fails to build)_
  * **Need to do this** If this does not work, try `Option 6 - Apply GRPCIO Update`. _(GRPCIO can be a tough cookie and acts differently on different operating systems, which makes this bit a little complicated)_
* Select `Option 7 - Set an API key or connect website`, enter your provider and enter your key. Currently supporting [openai](https://beta.openai.com/account/api-keys), [Stable Diffusion](https://beta.dreamstudio.ai/membership?tab=apiKeys). You can run this multiple times to add multiple providers or update your keys. **Please note that these providers are a paid service, and after any free credits expire, you will need to pay for more credits to maintain functionality.** _(You don't have to do this if you are loading external images, but to request images from an AI image provider, you'll need to define your API key here. By default, this will be stored in a plaintext file in the application folder. This is not ideal, but it is the best I have figured out until I can get GRPCIO playing nicely.)_
* (Optional) Select `Option 9 - Disable pijuice LEDs`. If you have a PiJuice unit, you can run this to disable the constantly flashing LED on the device to save precious battery.
* (Optional) Select `Option 10 - Install SMB and default shares`. This will set up a full access share in prompts and images folders, useful for easy management over the network but risky as it shares the folders with full permissions. Only do this on a trusted network. 

### Configure chaapyia
* Make sure you are in your chaaipyia install directory.
* Run `nano .config` for all configuration options. There's a lot to play with here, and apart from file paths you should be able to play around and see what happens.
* The most important item of configuration is `[EPD]` - `type` . You should set this to the supported EPD you have plugged in, anything from [omni-epd's readme](https://github.com/robweber/omni-epd) should work, copy and paste the appropriate EPD string and paste it here instead of omni_epd.mock. Leaving type as omni_epd.mock will generate a png file in this folder instead of updating the display. 
 * The Waveshare 5.65 inch 7 colors is `waveshare_epd.epd5in65f`.
* Provider weights (determining the source of images for chaaipyia) have also to be configured : `nano .config`, and set the _Provider Weight_ section. for example `dalle_amount = 1`, to systematically go for a Dall-E image.
* Make sure that `use_keychain = False` is set to False, as keychain do not wok properly on RPi Zero2W.
* run `python3 examples/review_screen.py` and see if it works on your screen. _(If your screen is not displaying an image there's most likely a problem with your EPD, you can also check pycasso.log to troubleshoot)_

### Configure PiJuice
* Run `pijuice_cli` to configure your PiJuice unit.
* See [PiJuice documentation](https://github.com/PiSupply/PiJuice/blob/master/Software/README.md) for
more information. My preferred configuration is to set a wakeup timer to start at a preferred time daily, but you can set this as you see fit.
* You can configure the buttons on the PiJuice to perform different functions. I recommend leaving the first switch as power on device, as this is very useful for cycling the image or for turning the device on while powered to administer.


| ![PiJuice CLI Menu](/img/PiJuice_CLI_Menu.png) | 
|:--:| 
| *PiJuice CLI Menu* |


| ![PiJuice CLI Wakeup](/img/PiJuice_CLI_Wakeup.png) | 
|:--:| 
| PiJuice CLI Wakeup Configuration |

### Alternative to pijuice : Install and configure a DS3231 RTC and alarm
This project adds a DS3231 clock to set alarm in order to wake up the RPi Zero 2W

#### Step-by-Step for DS3231 as alarm : 
1. Enable I2C : `sudo raspi-config` and enable i2c in Interface Options > I5 I2C then reboot `sudo reboot`
2. Install required libraries and tools : `sudo apt install python3-smbus i2c-tools`
3. Connect the DS3231, following this pining :

| DS3231  | RPi connection | RPi pin | 
| --- | --- | --- |
| VCC  | 3V3 | Pin 1 |
| GND  | GND | Pin 6 e.g  |
| SDA  | GPIO 4 | Pin 7  |
| SCL  | GPIO 27 | Pin 13  |
| INT/SQW  | Reset Pin | pin 5 (RPi zero 2W) or pin 3 (RPi 4)  |

| ![RPi Zero 2W Pin out diagram](/img/Zero2W3.jpg.webp) |
|:--:| 
| *RPi Zero 2W Pin out diagram* |

4. Edit /boot/config.txt by adding dtoverlay config and reboot : 
 * `sudo nano /boot/config.txt`
 * Add the following : 
 ```
 #dtoverlay for RTC DS3231 on specific pin
 dtoverlay=i2c-rtc-gpio,ds3231,i2c_gpio_sda=4,i2c_gpio_scl=27,wakeup-source
 ```
Make sure that the GPIO pin in the dtoverlay code corresponds to the pinning of the DS3231 to the RPi.

5. To detect and list i2c hardware :
``` sh
 sudo i2cdetect -l # list devices
 sudo i2cdetect -y 11 # (replace 11 with bus, usually 11 for this dtoverlay with i2c-rtc-gpio )
```
Output :

``` sh
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:                         -- -- -- -- -- -- -- -- 
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
50: -- -- -- -- -- -- -- 57 -- -- -- -- -- -- -- -- 
60: -- -- -- -- -- -- -- -- 68 -- -- -- -- -- -- -- 
70: -- -- -- -- -- -- -- --   
```
68 is code of RTC clock
if UU appear, mean driver loaded. Otherwise, verify /boot/config.txt and reboot.

6. Now that we have successfully got the kernel driver activated for the RTC Chip and we know it’s communicating with the Raspberry Pi, we need to remove the “fake-hwclock“ package. This package acts as a placeholder for the real hardware clock when you don’t have one.

``` sh
sudo apt-get -y remove fake-hwclock
sudo update-rc.d -f fake-hwclock remove
sudo systemctl disable fake-hwclock
```

7. Now that we have disabled the “fake-hwclock” package we can proceed with getting the original hardware clock script that is included in Raspbian up and running again by commenting out a section of code.
Run the following command to begin editing the original RTC script.

``` sh
sudo nano /lib/udev/hwclock-set
```
and comment out : 

``` sh
#if [ -e /run/systemd/system ] ; then
# exit 0
#fi

```

8. Now, if we have to sync time of the RTC to the one of the RPi (obtained with internet connection) :

``` sh
sudo hwclock -r #get time from RTC clock
date #see if time is correct of RPi
sudo hwclock -w # write time to RTC
```

#### Usage
In order to boot, a short-to-ground of the _Pin 3_ (RPi 4) or _Pin 5_ (RPi Zero 2W) will reboot the chip.

Setting an alarm can be done like that
``` sh
# as root
echo 0 > /sys/class/rtc/rtc0/wakealarm #reset
echo "$(date -d 'now + 1 minutes' +%s)" > /sys/class/rtc/rtc0/wakealarm
echo `date +%s -d'10:00:00'` > /sys/class/rtc/rtc0/wakealarm
```

``` sh
# as user
echo "0" | sudo tee /sys/class/rtc/rtc0/wakealarm 
date '+%s' -d '+ 30 minutes' | sudo tee /sys/class/rtc/rtc0/wakealarm
```

We can check if the alarm is set as follows : 

``` sh
cat /proc/driver/rtc
```

with the following output : 

``` sh
rtc_time        : 11:42:35
rtc_date        : 2020-05-23
alrm_time       : 11:47:33 # <-- alarm time (UTC timezone)
alrm_date       : 2020-05-23
alarm_IRQ       : yes # <-- alarm set
alrm_pending    : no
update IRQ enabled      : no
periodic IRQ enabled    : no
periodic IRQ frequency  : 1
max user IRQ frequency  : 64
24hr            : yes
```

After the reboot the alarm is removed automatically. Note that the time-horizon of the DS3231 is about a month. Also note that not every cheap DS3231 breakout will provide the INT/SQW pin.

The magic is that GP03 will always start the system when pulled to GND. And the DS3231 will pull the INT to GND when the alarm fires. I have found no way to change the pin to something else, but there is a "run"-pin which is not populated which should also work (but I did not test that). GP03 is hardware I2C, if you need that, you could activate some alternate function for some other i2cX bus.

You don't even need a backup battery for this, because after shutting down your Pi it will still provide power on the 3V3 and 5V rails. So this is not a solution for battery based systems. If you really need to bring current consumption down to zero, you need a different solution, for example you can connect the INT of the rtc to a MCU which uses a mosfet to turn power on.

#### Configure chaapiyia to boot with DS3231 RTC
There are two options, either wake at regular interval, even at night, or do not wake during night.

Uncomment the choosen option lines from `run.sh` :

- Update at regular interval, regardless of time of the day :
``` bash
#### Option 1 : update even during the night
# echo "Going to sleep in 60 seconds, for 3 hours..."
# echo 0 > /sys/class/rtc/rtc0/wakealarm #reset
# echo "$(date -d 'now + 3 hours' +%s)" > /sys/class/rtc/rtc0/wakealarm
# shutdown -h +1 "ePaper-frame going to sleep in 60 seconds. Send sudo shutdown -c to cancel"
```

- Update at regular interval, except between 23h and 6h :

``` bash
#### Option 2 : do nothing during the night (from 23h to 6h)
# if [ "$hour" -ge 6 ] && [ "$hour" -lt 23 ]; then
#     echo "Going to sleep in 60 seconds, for 3 hours..."
#     echo 0 > /sys/class/rtc/rtc0/wakealarm #reset
#     echo "$(date -d 'now + 3 hours' +%s)" > /sys/class/rtc/rtc0/wakealarm
#     shutdown -h +1 "ePaper-frame going to sleep in 60 seconds. Send sudo shutdown -c to cancel"
# else
#     echo "Going to sleep in 60 seconds, until 6:00..."
#     echo 0 > /sys/class/rtc/rtc0/wakealarm #reset
#     echo `date +%s -d '06:00:00'` > /sys/class/rtc/rtc0/wakealarm
#     shutdown -h +1 "ePaper-frame going to sleep in 60 seconds. Send sudo shutdown -c to cancel"
# fi
```

You can adjust the frequency of waking up in the `echo "$(date -d 'now + 3 hours' +%s)" > /sys/class/rtc/rtc0/wakealarm` code, or the hours of sleep in `if [ "$hour" -ge 6 ] && [ "$hour" -lt 23 ]`


### Run chaaipyia
* Run `sudo systemctl restart chaaipyia` and see if it worked!

### Customise chaaipyia
* If you have run through the installation and chaaipyia is working, it will run on startup. Normal behaviour is to run once and close, if you have an always-on system, you may wish to disable the service and just run chaaipyia or start the service through cron.
* With a PiJuice, you can configure `shutdown_on_battery` to automatically shut down and remove power to the board when chaaipyia is done, to complete a headless fully battery driven process. Be a little careful with this as to save battery, it prefers to shut down above all else, even on exception. If you experience a program error you will only have `wait_to_run` (default 30) seconds to connect to the pi and disable the service to fix.
* Play around a bit with the `.config` options so that everything on the screen looks good to you and works for your implementation. There is a description of all configuration items in the file. While experimenting, I recommend setting the mode to only fetch images from historic backlog using `historic_amount`, so that you aren't spending credits on your API while setting it up.
* Configure your prompts to send to providers using /prompts/artists.txt, /prompts/subjects.txt and /prompts/prompts.txt
  * Review the markup of the example prompts to learn how to apply randomisation for interesting effect in your prompt
  * Have a play around with the prompts and see what works for you. See [Hierarchical bracket wildcards](#hierarchical-bracket-wildcards) for more information.

### Administration
* Access to the prompt generation files, configuration, and saved images may be complicated through your raspberry pi unit. I recommend setting up an SMB share for easy access to these folders.
* If you have set `shutdown_on_battery` to true, you should be able to plug your PiJuice into power to ensure it stays on when you start it.
* If a disaster occurs, and you have `shutdown_on_battery` and `shutdown_on_exception` both set to True and you cannot keep the device on long enough to log in, you might need to unplug the SD card and try to fix the config. If this option is not available to you, it's possible you might need to flash it and start from scratch.

### Hierarchical Bracket Wildcards
To enhance dynamic prompt generation within chaaipyia, many text files and strings in chaaipyia are parsed to replace wildcard text. This allows more flexibility when defining prompts.

By default, the three types of brackets used are:
1. ()
2. []
3. {}

These can be added to, removed, or customised in `.config`.

Different options are separated by a pipe, for example `(Option 1|Option 2|[Option {3|4|5|6}|Option 7])`. The parser will first look for the lowest level of brackets (in this example {}), choose only one random option of the text, and then proceed to the next levels. Unless otherwise specified, each option has an equal chance of being chosen from each bracket pair. This means with nested brackets, you should consider the way the parsing works when thinking about the likelihood of a certain item of text occurring. For example, `A (Good|[B|R]ad) Dog` could return `A Good Dog` `A Bad Dog` or `A Rad Dog`. The option will be picked randomly between each bracket pair, so you have 50% chance of `A Good Dog`, 25% chance of `A Bad Dog` and 25% chance of `A Rad Dog`.

At the start of any segment, you can also provide a weighting for a particular option. For example `(20:Option A|Option B|0:Option C)` should provide `Option A` about 20 times more often than `Option B`. `Option C` would never appear. These weightings can also be used at the start of every line in one of the prompt-building text files to specify the likelihood of that line being chosen.

Have a play around with the strings and see what works for you. You can leave the EPD in test mode with no provider modes selected, and the test display will show you what subject it would have fetched. 

Here are a few more examples of how one may use these to make simple prompts more complex:

`A (|Happy|Sad) (Dog|Cat|Bird)` could result in:
* `A Dog`, `A Happy Dog`, `A Sad Dog`, `A Cat`, `A Happy Cat`, `A Sad Cat`, `A Cat`, `A Happy Bird` or `A Sad Bird`. All options have the same probability of occurring.

`A (Dog|Cat) (|[Carrying|Stealing] A[n Apple| Banana])` could result in:
* **1/4** of the time `A Dog`, **1/4** of the time `A Cat`, **1/16** of the time `A Dog Carrying An Apple`, **1/16** of the time `A Dog Carrying A Banana`, **1/16** of the time `A Dog Stealing An Apple`, **1/16** of the time `A Dog Stealing A Banana`, **1/16** of the time `A Cat Carrying An Apple`, **1/16** of the time `A Cat Stealing An Apple`, **1/16** of the time `A Cat Stealing An Apple` or **1/16** of the time `A Cat Stealing A Banana`

`A(5: Friendly|2:n Uncommon| Rare) (3:Dog|Cat)` could result in:
* **15/32** of the time `A Friendly Dog`, **3/16** of the time `An Uncommon Dog`, **3/32** of the time `A Rare Dog`, **5/32** of the time `A Friendly Cat`, **1/16** of the time `An Uncommon Cat` or **1/32** of the time `A Rare Cat`

## Configuration
You can run `nano .config` in the chaaipyia install folder to configure the way chaaipyia runs. There are a lot of options to configure your experience, and it is highly recommended to play around with these options to find the settings that work best for your setup. If at any time you wish to roll back to the default configuration you can find it is `/examples/.config-example`, or you can delete .config and running chaaipyia will restore the defaults automatically. If you are running chaaipyia frequently to see what changes your updates make, it is recommended to either use the test mode by setting all providers to 0, or using external/generated modes so that you are not being charged by your provider for each time you run the program. Below you will find a full explanation of all configuration sections and items.

### File
Settings related to file operations within chaaipyia

* `save_image`: A boolean flag that instructs chaaipyia whether to save images retrieved from providers or not. If 'True', chaaipyia will always save images retrieved in a defined location. If 'False' chaaipyia will only display the image on the EPD, once the EPD is updated again this image will be lost. `(Boolean)`
* `save_date`: A boolean flag that instructs chaaipyia whether to append a datetime at the start of the saved filename. `(Boolean)`
* `external_image_location`: A file path relative to the chaaipyia working directory to load external images from, when using **external** mode. `(String)`
* `generated_image_location`: A file path relative to the chaaipyia working directory to save generated images to when using a provider, and load them from when using **generated** mode. `(String)`
* `image_format`: The file type to look for when loading images from external or generated image folders. Most of the time it will be "png". `(String)`
* `font_file`: A file path relative to the chaaipyia working directory to load a font file from. This supports drawing text on the EPD. `(String)`
* `subjects_file`: A file path relative to the chaaipyia working directory to load 'subjects' from when using prompt mode 1. `(String)`
* `artists_file`: A file path relative to the chaaipyia working directory to load 'artists' from when using prompt mode 1. `(String)`
* `subjects_file`: A file path relative to the chaaipyia working directory to load 'prompts' from when using prompt mode 2. `(String)`
* `resize_external`: A boolean flag that instructs chaaipyia whether to resize external images. If 'True', chaaipyia will resize images provided to it so that the whole image will fit in the EPD. If 'False', chaaipyia will fill the whole screen with the image by resizing to a smaller extent, and then cropping. `(Boolean)`

### EPD
These settings are consumed by omni-epd to customise the EPD information. See [omni-epd](https://github.com/robweber/omni-epd) for supported displays for more information on omni-epd options

* `type`: The type of EPD display being used. See [omni-epd](https://github.com/robweber/omni-epd#displays-implemented) for supported displays and their names. `(String)`
 * The Waveshare 5.65 inch 7 colors is `waveshare_epd.epd5in65f`.
* `mode`: The color mode to run the EPD with. See [omni-epd](https://github.com/robweber/omni-epd#displays-implemented) for supported modes of each display. `(String)`
* `palette_filter`: By default not required and commented out. Uncomment and configure based on information provided [here](https://github.com/robweber/omni-epd#virtualepd-object) if you wish to customise the palette. Required for dithering. `(Tuple)`

### Display
These settings are consumed by omni-epd to customise the display on the EPD. See [omni-epd](https://github.com/robweber/omni-epd) for more information on these options.

* `rotate`: Rotation of the image in degrees. You probably don't need to use this, use the other rotate option in Generation instead. `(Integer)`
* `flip_horizontal`: A boolean flag that instructs the EPD to flip the image horizontally or not `(Boolean)`
* `flip_vertical`: A boolean flag that instructs the EPD to flip the image vertically or not `(Boolean)`
* `dither`: By default commented out. Uncomment to set a dithering mode to use. See [the omni-epd wiki](https://github.com/robweber/omni-epd/wiki/Image-Dithering-Options) for supported modes and more information. `(String)`
* `dither_strength`: By default commented out. Uncomment if using `dither`. Sets the strength of the dithering algorithm. See [the omni-epd wiki](https://github.com/robweber/omni-epd/wiki/Image-Dithering-Options) for more information. `(Float)`
* `dither_serpentine`: By default commented out. Uncomment if using `dither`. A boolean flag that instructs the dithering algorithm to use serpentine dithering or not. See [the omni-epd wiki](https://github.com/robweber/omni-epd/wiki/Image-Dithering-Options) for more information. `(Boolean)`

### Image Enhancements
These settings are consumed by omni-epd to customise the display on the EPD. See [omni-epd](https://github.com/robweber/omni-epd) for more information on these options.

* `contrast`: Sets contrast amount for EPD. 1 is normal. `(Integer)`
* `brightness`: Sets brightness amount for EPD. 1 is normal. `(Integer)`
* `sharpness`: Sets sharpness amount for EPD. 1 is normal. `(Integer)`

### Prompt
Settings related to creation of prompts for submission and requests from AI art providers

* `mode`: The mode to use in prompt generation. `(Integer)` This currently supports 3 different types of modes:
  * `1` -  (`preamble` - **subjects.txt** - `connector` - **artists.txt** - `postscript`)
  * `2` -  (`preamble` - **prompts.txt** - `postscript`)
  * `0` -  Any of the above (randomly chooses one of the above options)
* `preamble`: Text that fills in the `preamble` part of the prompt construction above. [Hierarchical bracket wildcards](#hierarchical-bracket-wildcards) supported.`(String)`
* `connector`: Text that fills in the `connector` part of the prompt construction above. [Hierarchical bracket wildcards](#hierarchical-bracket-wildcards) supported.`(String)`
* `postscript`: Text that fills in the `postscript` part of the prompt construction above. [Hierarchical bracket wildcards](#hierarchical-bracket-wildcards) supported.`(String)`

### Text
Settings related to parsing text of filenames and strings, and text display on the EPD

* `add_text`: A boolean flag that instructs chaaipyia whether to display a textbox on the EPD or not. `(Boolean)`
* `parse_file_text`: A boolean flag that instructs chaaipyia whether to parse filenames in external image mode or not. `(Boolean)`
* `preamble_regex`: Normal regex to find the split point between the preamble and the main text in external image names. `(String)`
* `artist_regex`: Normal regex to find the split point between the subject and artist in external image names. `(String)`
* `remove_text`: A list of strings to find and completely remove from any file names to parse into chaaipyia. `(List)`
* `parse_random_text`: A boolean flag that instructs chaaipyia whether to interpret certain strings using [hierarchical bracket wildcards](#hierarchical-bracket-wildcards) or not. `(Boolean)`
* `parse_brackets`: A list of bracket pairs in order of the highest to the lowest level in hierarchy. `(List)`
* `box_to_floor`: A boolean flag that instructs chaaipyia whether to draw the text box all the way to the bottom of the image instead of just appearing around the text. `(Boolean)`
* `box_to_edge`: A boolean flag that instructs chaaipyia whether to draw the text box all the way to the edges of the image instead of just appearing around the text. `(Boolean)`
* `artist_loc`: Distance in pixels of the artist text away from the bottom of the image. `(Integer)`
* `artist_size`: Font size of the artist text. `(Integer)`
* `title_loc`: Distance in pixels of the title text away from the bottom of the image. `(Integer)`
* `title_size`: Font size of the title text. `(Integer)`
* `padding`: Padding of the text box containing title and artist text. `(Integer)`
* `opacity`: Opacity of the text box. 0 for fully transparent and 255 for fully opaque. `(Integer)`
* `override_text`: A boolean flag to indicate whether to override final text with other text from a file `(Boolean)`
* `override_path`: A file path relative to the chaaipyia working directory to load the override text from when override_text is enabled `(String)`

### Icon
Settings related to status icons to display on EPD

* `icon_color`: Color to show icon in. Set to `auto` to automatically detect white or black depending on shade of background `(String)` 
* `icon_padding`: Padding from the top left corner in pixels to place the icon `(Integer)`
* `icon_corner`: Which corner to place the icons in. Can be `nw`, `ne`, `sw` or `se`. `(String)`
* `icon_size`: Size of the status icon in pixels `(Integer)`
* `icon_width`: The width of the line of the status icon in pixels (currently unused due to new icon system) `(Integer)`
* `icon_gap`: Gap in pixels in between individual icons `(Integer)`
* `icon_opacity`: Opacity of the status icon. 0 for fully transparent and 255 for fully opaque. `(Integer)`
* `icon_path`: A file path relative to the chaaipyia working directory to find the icons in. `(String)`
* `show_battery_icon`: A boolean flag that instructs chaaipyia to show a battery status icon. `(Boolean)` 
* `show_provider_icon`: A boolean flag that instructs chaaipyia to show an icon based on provider used, and any provider failure. `(Boolean)` 
* `show_status_icon`: A boolean flag that instructs chaaipyia to show an icon on exception. `(Boolean)`

### Logging
Settings related to error and information logging from chaaipyia.
* `log_file`: A file path relative to the chaaipyia working directory to save log file `(String)`
* `log_level`: Minimum logging level to save to log file. Possible options - CRITICAL:50, ERROR:40, WARNING:30, INFO:20, DEBUG:10, NOTSET:0 `(Integer)`

### Providers
Settings related to image providers.

* The following items are integers providing the 'comparative chance' they will be chosen. This means you could choose multiple provider modes and chaaipyia will randomly choose one of them. The higher integer gives a higher chance of being picked. For example, `external_amount = 0`, `historic_amount = 1` and `stability_amount = 2` would result in **External** images never appearing, and approximately 1 **Historic** image appearing for every 2 **Stable Diffusion** images. If all options are set to 0, chaaipyia will either exit or run its test mode depending on the value of `test_enabled`.
  * `external_amount`: The comparative chance of chaaipyia running External mode (loading an image from the `external_image_location` folder). `(Integer)`
  * `historic_amount`: The comparative chance of chaaipyia running Historic mode (loading an image from the `generated_image_location` folder). `(Integer)`
  * `stability_amount`: The comparative chance of chaaipyia running Stable Diffusion mode (loading an image online from Stable Diffusion). `(Integer)`
  * `dalle_amount`: The comparative chance of chaaipyia running DALLE mode (loading an image online from DALLE). `(Integer)`
  * `automatic_amount`: The comparative chance of chaaipyia running Automatic1111 Stable Diffusion WebUI mode (loading an image from a valid Automatic1111 API). `(Integer)`
* `use_keychain`: A boolean flag that instructs chaaipyia whether to use keychain to manage keys. When set to false will just look for .creds file with credentials in it. This may or may not work depending on your board.. `(Boolean)`
* `credential_path`: A file path relative to the chaaipyia working directory to find API credentials. `(String)`
* `test_enabled`: A boolean flag that instructs chaaipyia to run a test mode when all other providers are set to 0. `(Boolean)`
* `stable_host`: A string that provides the API location to send the request to for Stable Diffusion online. `(String)`
* `automatic_host`: If using `automatic` mode, this is the IP address or host of the Automatic1111 WebUI API. `(String)`
* `automatic_port`: If using `automatic` mode, this is the port to use for the Automatic1111 WebUI API. `(Integer)`
* `provider_fallback`: A boolean flag that instructs chaaipyia to fall back to another random non-zero provider if originally chosen provider fails. `(Boolean)`

### Generation
Settings related to generation of images with AI image providers

* `image_rotate`: Rotation of the image PRIOR to sending to providers. This way you can get an image that fits well in portrait or landscape as per your preference. `(Integer)`
* `infill`: A boolean flag that instructs chaaipyia to request an image to be infilled again if original image does not fill out the whole frame. `(Boolean)`
* `infill_percent`: If infill is set to true, this will make the original image request smaller by this percentage, and then infill the rest of the image to fit the frame. `(Integer)`

### PiJuice
Settings related to PiJuice HAT configuration.

* `use_pijuice`: A boolean flag that instructs the run script whether to use PiJuice classes. `(Boolean)`
* `shutdown_on_battery`: A boolean flag that instructs the run script whether to shut down the raspberry pi if PiJuice is running on battery (not plugged in to power). `(Boolean)`
* `shutdown_on_exception`: A boolean flag that instructs the run script whether to shut down if program encounters an exception. Used to stop battery running down on error. **WARNING: Worst case scenario this could result in having to flash your device, if chaaipyia keeps restarting after failures you may not be able to SSH in even after a wait time**. `(Boolean)`
* `wait_to_run`: Time to wait in seconds before running chaaipyia. Can help in ensuring PiJuice class is ready, and gives a buffer to SSH into device if encountering issues. `(Integer)`
* `charge_display`: Battery percentage that chaaipyia should start showing low battery symbol. `(Integer)`

### Post
Settings related to posting and sharing chaaipyia output on the web. Use set_keys.py to set up.
* `post_connector`: A string to put between subject and artist if posting in this mode. `(String)`
* `post_to_mastodon`: A boolean flag that instructs chaaipyia to attempt to post image to Mastodon. `(Boolean)`
* `mastodon_app_name`: The app name to associate with your account. `(String)`
* `mastodon_base_url`: The url to the account's mastodon instance `(String)`
* `mastodon_client_cred_path`: A file path relative to the chaaipyia working directory to mastodon's client secret `(String)`
* `mastodon_user_cred_path`: A file path relative to the chaaipyia working directory to mastodon's user secret  `(String)`

### Debug
The following settings are only relevant for development. Only use them if you know what you're doing.
* `test_epd_width`: Width in pixels to set the mock EPD to. Mostly for testing purposes. `(Integer)`
* `test_epd_height`: Height in pixels to set the mock EPD to. Mostly for testing purposes. `(Integer)`

## Troubleshooting

### There is a symbol on the top left of the screen
By default, chaaipyia puts a faint symbol on the top left of the EPD to inform of system events. By default, these are:
* Square for low battery _(low battery warning level configurable in `.config`, default 15%)_
* Cross for exception _(likely PiJuice failing to load if you are using it, try a longer `wait_to_run`)_ .

### GLIBC_2.33 not found
I have experienced this error even with the most recent release of raspbian.
Following [this](https://stackoverflow.com/questions/71054519/glibc-2-33-not-found-in-raspberry-pi-python) appeared to work, however I haven't had any luck for a while. It might work for you:
```
sudo pip3 uninstall grpcio 
sudo pip3 uninstall grpcio-status 
sudo pip3 install grpcio==1.44.0 --no-binary=grpcio
sudo pip3 install grpcio-tools==1.44.0 --no-binary=grpcio-tools
```
If you can't store your credentials in keyring, you'll have to set the `use_keyring` option in `.config` to False, and provide your credentials using `setup.sh` option 5 or `set_keys.py`

### Module I2C Missing
I have found this might cause issues with PiJuice. This is possibly due to running a lite version of the operating system. I found success by:
* Updating the kernel with `sudo rpi-update`
* Rebooting
* Running `sudo raspi-config`
 * Selecting `Interface Options -> I2C -> Yes`

### Log an issue
If you're experiencing a bug or issue, relevant information is logged in `pycasso.log` and your current `.config`.
