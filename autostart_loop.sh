#!/bin/bash
source /home/fabian/hdd/d/programs/bash_scripts/sane
# maybe disable screen off after 10 minutes
xset -dpms
xset s off

while true; do
 for i in {1..60}; do
  sleep 1
  # disable caps
  if xset q | grep "Caps Lock:   on"; then
   xdotool key Caps_Lock
  fi
  if((i==60)); then
   # notify if KDE connect can't reach phone
   if ! kdeconnect-cli -l | grep "paired and reachable"; then
    notify-send -t 59000 "KDE connect died"
   fi
   # replace muted volume with volume 0 so that volume up keys work again
   if pulseaudio-ctl full-status | grep -E "[0-9]+ yes" >/dev/null; then
    pactl set-sink-volume @DEFAULT_SINK@ 0
    pulseaudio-ctl mute
   fi
  fi
  if((i%10==0)); then
   notify-send -t 1000 "$(myip 2> /dev/null)"
   if [[ "" == "$(myip 2> /dev/null)" ]]; then
    ((net_down++))
    if ((net_down%6==1)); then
     # repair internet by re-establishing connection, then don't do anything anymore for at least one minute
     notify-send -t 1000 "$(myip 2> /dev/null)"
     #nmcli dev wifi connect Weelaan
    fi
   else
    net_down=0
   fi
  fi
 done
done