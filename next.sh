#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane
# Triggered by next button on headphones. Skips a track if VLC is running, otherwise mutes/unmutes microphone.

if wmctrl -l | grep -q " \\- VLC media player$"; then
 xdotool key Ctrl+Shift+Alt+n
else
 if pactl get-source-mute "bluez_input.00_02_3C_8E_81_63.0" | grep "Mute: yes"; then
  # mic on
  pactl set-source-mute "bluez_input.00_02_3C_8E_81_63.0" 0
  ffplay -nodisp -autoexit /usr/share/sounds/Oxygen-Sys-App-Positive.ogg
   else
  # mic off
  pactl set-source-mute "bluez_input.00_02_3C_8E_81_63.0" 1
  ffplay -nodisp -autoexit /usr/share/sounds/Oxygen-Sys-App-Negative.ogg
 fi
fi