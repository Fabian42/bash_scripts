#!/bin/bash
source /home/fabian/hdd/d/programs/bash_scripts/sane
file="/home/fabian/hdd/d/programs/bash_scripts/brightness.txt"
setting="/sys/class/backlight/intel_backlight/brightness"
current=$(cat $setting)
# screen is off
if((current==0)); then
 # turn screen on, set brightness to minimum
 echo -n 1 > $file
 sudo su -c "echo -n 1 > $setting"
# brightness probably =minimum, definitely <25%
elif((current<104)); then
 # set brightness to 25%
 echo -n 104 > $file
 sudo su -c "echo -n 104 > $setting"
# brightness probably =25%, definitely <100%
elif((current<416)); then
 # set brightness to 100%
 echo -n 416 > $file
 sudo su -c "echo -n 416 > $setting"
# brightness =100%, if gamma inactive, enable
elif(($(cat $file)<999)); then
 echo -n 999 > $file
 xcalib -gc .5 -a
# if gamma already active, do nothing
fi