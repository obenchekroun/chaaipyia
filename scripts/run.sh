#! /usr/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
hour=$(date +%H)
echo -n 'db' | gnome-keyring-daemon --unlock
python3 "${SCRIPT_DIR}/run.py"

#### Option 1 : update even during the night
# echo "Going to sleep in 60 seconds, for 3 hours..."
# echo 0 > /sys/class/rtc/rtc0/wakealarm #reset
# echo "$(date -d 'now + 3 hours' +%s)" > /sys/class/rtc/rtc0/wakealarm
# shutdown -h +1 "ePaper-frame going to sleep in 60 seconds. Send sudo shutdown -c to cancel"

#### Option 2 : do nothing during the night (from 23h to 6h)
# if [ "$hour" -ge 6 ] && [ "$hour" -lt 23 ]; then
#     echo "Going to sleep in 60 seconds, for 3 hours..."
#     echo 0 > /sys/class/rtc/rtc0/wakealarm #reset
#     echo "$(date -d 'now + 3 hours' +%s)" > /sys/class/rtc/rtc0/wakealarm
#     shutdown -h +1 "ePaper-frame going to sleep in 60 seconds. Send sudo shutdown -c to cancel"
# else
#     echo "Going to sleep in 60 seconds, until 6:00..."
#     echo 0 > /sys/class/rtc/rtc0/wakealarm #reset
#     echo `date +%s -d 'tomorrow 06:00:00'` > /sys/class/rtc/rtc0/wakealarm
#     shutdown -h +1 "ePaper-frame going to sleep in 60 seconds. Send sudo shutdown -c to cancel"
# fi
