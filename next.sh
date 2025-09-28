#!/bin/bash
#source /home/fabian/d/programs/bash_scripts/sane
# Triggered by next button on headphones. Mutes/unmutes microphone during voice chats, otherwise skips a track in VLC.
btname="bluez_source.46_B3_A8_41_E5_BB.handsfree_head_unit"

if pactl list | grep -q "bluez_source.46_B3_A8_41_E5_BB.handsfree_head_unit"; then
 if pactl get-source-mute "$btname" | grep "Mute: yes"; then
  # mic on
  pactl set-source-mute "$btname" 0
  ffplay -nodisp -autoexit /usr/share/sounds/Oxygen-Sys-App-Positive.ogg
 else
  # mic off
  pactl set-source-mute "$btname" 1
  ffplay -nodisp -autoexit /usr/share/sounds/Oxygen-Sys-App-Negative.ogg
 fi
else
 xdotool key Ctrl+Alt+End
fi