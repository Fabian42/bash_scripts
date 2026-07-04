#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane
file="/home/fabian/d/programs/bash_scripts/brightness.txt"
setting="/sys/class/backlight/nvidia_0/brightness"
current=$(cat $setting)
# brightness probably =100%, definitely >25%
if((current>25)); then
 # if gamma active, disable, but keep brightness at maximum
 if(($(cat $file)>100)); then
  xcalib -c
  echo -n 100 > $file
 # otherwise, reduce brightness to 25% (and keep gamma inactive)
 else
  sudo su -c "echo -n 25 > $setting"
  echo -n 25 > $file
 fi
# brightness probably =25%, definitely >6%
elif((current>6)); then
 # set brightness to 6%
 sudo su -c "echo -n 6 > $setting"
 echo -n 6 > $file
# brightness probably =6%, definitely above minimum
elif((current>0)); then
 # set brightness to minimum
 sudo su -c "echo -n 0 > $setting"
 echo -n 0 > $file
# brightness=minimum
elif((current>-1)); then
 # turn screen off
 xset dpms force off
 sudo su -c "echo -n 0 > $setting"
 echo -n -1 > $file
# if screen already off, do nothing
fi