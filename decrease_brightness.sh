#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane
file="/home/fabian/d/programs/bash_scripts/brightness.txt"
setting="/sys/class/backlight/nvidia_wmi_ec_backlight/brightness"
current=$(cat $setting)
# brightness probably =100%, definitely >25%
if((current>64)); then
 # if gamma active, disable, but keep brightness at maximum
 if(($(cat $file)>255)); then
  xcalib -c
  echo -n 255 > $file
 # otherwise, reduce brightness to 25% (and keep gamma inactive)
 else
  sudo su -c "echo -n 64 > $setting"
  echo -n 64 > $file
 fi
# brightness probably =25%, definitely >6.25%
elif((current>16)); then
 # set brightness to 6.25%
 sudo su -c "echo -n 16 > $setting"
 echo -n 16 > $file
# brightness probably =6.25%, definitely >1.5625%
elif((current>4)); then
 # set brightness to 1.5625%
 sudo su -c "echo -n 4 > $setting"
 echo -n 4 > $file
# brightness probably =1.5625%, definitely above minimum
elif((current>1)); then
 # set brightness to minimum
 sudo su -c "echo -n 1 > $setting"
 echo -n 1 > $file
# brightness=minimum
elif((current>0)); then
 # turn screen off
 sudo su -c "echo -n 0 > $setting"
 echo -n 0 > $file
# if screen already off, do nothing
fi