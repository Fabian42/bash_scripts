#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane
file="/home/fabian/d/programs/bash_scripts/brightness.txt"
setting="/sys/class/backlight/nvidia_wmi_ec_backlight/brightness"
current=$(cat $setting)
# screen is off
if((current==0)); then
 # turn screen on, set brightness to minimum
 sudo su -c "echo -n 1 > $setting"
 echo -n 1 > $file
# brightness probably =minimum, definitely <1.5625%
elif((current<4)); then
 # set brightness to 1.5625%
 sudo su -c "echo -n 4 > $setting"
 echo -n 4 > $file
# brightness probably =1.5625, definitely >6.25%
elif((current<16)); then
 # set brightness to 6.25%
 sudo su -c "echo -n 16 > $setting"
 echo -n 16 > $file
# brightness probably =6.25%, definitely <25%
elif((current<64)); then
 # set brightness to 25%
 sudo su -c "echo -n 64 > $setting"
 echo -n 64 > $file
# brightness probably =25%, definitely <100%
elif((current<255)); then
 # set brightness to 100%
 sudo su -c "echo -n 255 > $setting"
 echo -n 255 > $file
# brightness =100%, if gamma inactive, enable
elif(($(cat $file)<9999)); then
 xcalib -gc .5 -a
 echo -n 9999 > $file
# if gamma already active, do nothing
fi