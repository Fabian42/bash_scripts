#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane
pactl set-sink-volume @DEFAULT_SINK@ -20%
notify-send -t 500 $(amixer get Master | grep -o -m 1 "[0-9]*%")