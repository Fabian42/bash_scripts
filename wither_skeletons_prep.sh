#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane
source ~/.bashrc
while [[ "$mc" == "" ]]; do mc="$(mc)"; sleep 1; done
echo "while true; do xdotool click --window $mc 3 sleep 1; done"