#!/bin/bash
source /home/fabian/hdd/d/programs/bash_scripts/sane
# Triggered by next button on headphones. Skips a track if VLC is running, otherwise mutes/unmutes microphone.

if wmctrl -l | grep -q " \\- VLC media player$"; then
 xdotool key Ctrl+Alt+End
else
 if pactl get-source-mute "bluez_source.00_02_3C_8E_81_63.handsfree_head_unit" | grep "Mute: yes"; then
  # mic on
  pactl set-source-mute "bluez_source.00_02_3C_8E_81_63.handsfree_head_unit" 0
  play /usr/share/sounds/Oxygen-Sys-App-Positive.ogg
   else
  # mic off
  pactl set-source-mute "bluez_source.00_02_3C_8E_81_63.handsfree_head_unit" 1
  play /usr/share/sounds/Oxygen-Sys-App-Negative.ogg
 fi
fi