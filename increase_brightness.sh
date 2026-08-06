#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane
file="/home/fabian/d/programs/bash_scripts/brightness.txt"
setting="/sys/class/backlight/nvidia_0/brightness"
current=$(cat $setting)
# screen is off
if((current==-1)); then
 # turn screen on, set brightness to minimum
 xset dpms force on
 sudo su -c "echo -n 0 > $setting"
 echo -n 0 > $file
# brightness probably =minimum, definitely <25%
elif((current<25)); then
 # set brightness to 25%
 sudo su -c "echo -n 25 > $setting"
 echo -n 25 > $file
# brightness probably =25%, definitely <100%
elif((current<100)); then
 # set brightness to 100%
 sudo su -c "echo -n 100 > $setting"
 echo -n 100 > $file
# brightness =100%, if gamma inactive, enable
elif(($(cat $file)<9999)); then
 xcalib -g .5 -a
 echo -n 9999 > $file
# if gamma already active, do nothing
fi