#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane
if (( $(COLUMNS=1000 top -bn1 | grep drain_water | wc -l) > 4 )); then
 notify-send -t 2000 off
 killall drain_water.sh
else
 notify-send -t 2000 on
 sleep 0.1
 while true; do
  xdotool key --delay 0 e click --delay 0 1
 done
fi