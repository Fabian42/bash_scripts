#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane
source ~/.bashrc
invmove_temp(){  xdotool key r sleep 0.1;  for x in 1304 1376 1449 1516 1594 1663 1736 1810 1881; do   ((i++));   for y in 1018 932 858 786 1018; do    xdotool mousemove $x $y click --delay 5 1;   done;  done;  xdotool key r sleep 0.1 key Escape sleep 0.1 key Escape sleep 0.1; }
echo "mn; crop; invmove_temp \"\$1\"; crop; invmove_temp \"\$1\"; crop; invmove_temp \"\$1\"; crop; xdotool sleep 0.1 click 3 sleep 1 click 1"