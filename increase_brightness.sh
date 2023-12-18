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
#elif((current<833)); then
 # set brightness to 25%
 echo -n 104 > $file
# echo -n 833 > $file
 sudo su -c "echo -n 104 > $setting"
# sudo su -c "echo -n 833 > $setting"
# brightness probably =25%, definitely <100%
elif((current<416)); then
#elif((current<3333)); then
 # set brightness to 100%
 echo -n 416 > $file
# echo -n 3333 > $file
 sudo su -c "echo -n 416 > $setting"
# sudo su -c "echo -n 3333 > $setting"
# brightness =100%, if gamma inactive, enable
elif(($(cat $file)<9999)); then
 echo -n 9999 > $file
 xcalib -gc .5 -a
# if gamma already active, do nothing
fi