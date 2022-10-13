#!/bin/bash
source /home/fabian/hdd/d/programs/bash_scripts/.bashrc
brightness_file="/home/fabian/hdd/d/programs/bash_scripts/brightness.txt"
brightness_setting="/sys/class/backlight/intel_backlight/brightness"

# maybe disable screen off after 10 minutes
xset -dpms
xset s off

#copyq &

while true; do
 for i in {1..60}; do
  sleep 1
  # disable caps
  if xset q | grep -q "Caps Lock:   on"; then
   xdotool key Caps_Lock
  fi
  # check if screen randomly turned itself on
  if(($(cat $brightness_file)<417 && $(cat $brightness_file)!=$(cat $brightness_setting))); then
   sudo su -c "cat $brightness_file > $brightness_setting"
  fi
  if((i==60)); then
   # notify if KDE connect can't reach phone
   #if ! kdeconnect-cli -l | grep -q "paired and reachable"; then
    #notify-send -t 59000 "KDE connect died"
    #killall kdeconnectd; /usr/lib/kdeconnectd &> /dev/null & disown
   #fi
   # replace muted volume with volume 0 so that volume up keys work again
   if pulseaudio-ctl full-status | grep -qE "[0-9]+ yes"; then
    pactl set-sink-volume @DEFAULT_SINK@ 0
    pulseaudio-ctl mute
   fi
  fi
  if((i%10==0)); then
   #notify-send -t 10000 "$(myip 2>/dev/null)"
   if [[ "" == "$(myip 2>/dev/null)" ]]; then
    ((net_down++))
    if ((net_down%6==1)); then
     # repair internet by re-establishing connection, then don't do anything anymore for at least one minute
     notify-send -t 1000 "$(myip 2>/dev/null)"
     nmcli dev wifi connect Weelaan
    fi
   else
    net_down=0
   fi
  fi
 done
done