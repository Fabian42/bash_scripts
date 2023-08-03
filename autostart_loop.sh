#!/bin/bash
source /home/fabian/hdd/d/programs/bash_scripts/.bashrc
brightness_file="/home/fabian/hdd/d/programs/bash_scripts/brightness.txt"
brightness_setting="/sys/class/backlight/intel_backlight/brightness"

# disable screen off after 10 minutes
xset -dpms
xset s off
caffeine &

while true; do
 for i in {1..60}; do
  sleep 1
  # disable caps
  if xset q | grep -q "Caps Lock:   on"; then
   xdotool key Caps_Lock
  fi
  # enable numlock
  if xset q | grep -q "Num Lock:    off"; then
   xdotool key Num_Lock
  fi
  # check if screen randomly turned itself on, also apply remote brightness changes from phone
  if(($(cat $brightness_file)<417 && $(cat $brightness_file)!=$(cat $brightness_setting))); then
   sudo su -c "cat $brightness_file > $brightness_setting"
  fi
  if((i==60)); then
   # retry KDE Connect notification (and notify if it connect can't reach phone?)
   if ! kdeconnect-cli -l | grep -q "paired and reachable"; then
    true
    kdeconnect-cli --refresh
    #notify-send -t 59000 "KDE connect died"
    #killall kdeconnectd; /usr/lib/kdeconnectd &> /dev/null & disown
   fi
   # replace muted volume with volume 0 so that volume up keys work again
   if pulseaudio-ctl full-status | grep -qE "[0-9]+ yes"; then
    pactl set-sink-volume @DEFAULT_SINK@ 0
    pulseaudio-ctl mute
   fi
  fi
  if((i%10==0)); then
   #notify-send -t 10000 "$(myip 2>/dev/null)"
   net="$(myip 2>/dev/null)"
   if [[ "" == "$net" ]]; then
    ((net_down++))
    if ((net_down==6)); then
     # repair internet by re-establishing connection, then don't do anything anymore for at least one minute
     notify-send -t 2000 "IP: $net"
     nmcli dev wifi connect Weelaan
     net_down=0
    fi
   else
    net_down=0
   fi
  fi
 done
done