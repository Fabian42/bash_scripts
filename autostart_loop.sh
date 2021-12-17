#!/bin/bash
source /home/fabian/hdd/d/programs/bash_scripts/sane
# TODO: split up into multiple scripts, to allow killing and restarting separately
# maybe disable screen off after 10 minutes
xset -dpms
xset s off

while true; do
 for i in {1..60}; do
  sleep 1
  # disable caps
  if xset q | grep "Caps Lock:   on"; then
   xdotool key Caps_Lock;
  fi
  if((i==60)); then
   # notify if KDE connect can't reach phone
#   if ! kdeconnect-cli -l | grep "paired and reachable"; then
#    notify-send -t 59000 "KDE connect died"
#   fi
   # replace muted volume with volume 0 so that volume up keys work again
   if pulseaudio-ctl full-status | grep -E "[0-9]+ yes" >/dev/null; then
    pactl set-sink-volume @DEFAULT_SINK@ 0
    pulseaudio-ctl mute
   fi
  fi
 done
done