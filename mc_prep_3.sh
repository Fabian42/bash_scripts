#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane
source ~/.bashrc
# called from autostart_loop.sh

time=$(date "+%s")
window=$(xdotool getactivewindow)
prime-run prismlauncher -l SL2 -a FaRo3 &>/0 & # open console before MC, but execute commands in it afterwards
while [ -f "/home/fabian/d/minecraft/logs/latest.log" ] && (( $time > $(stat --printf "%W" "/home/fabian/d/minecraft/logs/latest.log") )); do sleep 1; done
tail -f "/home/fabian/d/minecraft/logs/latest.log" | grep -qm1 "Creating pipeline for dimension minecraft\\:overworld"
(
 sleep 1
 xdotool type --window $window "while true; do xdotool mousedown --window $(xdotool getactivewindow) 1 sleep 600; done"
 sleep 0.1
 wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
 xdotool sleep 1 key Tab sleep 0.1 key Tab sleep 0.1 key Return sleep 0.1 key Super+t sleep 0.1 getactivewindow windowminimize sleep 0.1 windowactivate $window sleep 0.1 # MP menu, thumbnail, minimise MC, focus console (in case it isn't already)
 wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
 xdotool sleep 0.1 key Super+Left sleep 0.1 getactivewindow windowminimize
) & disown