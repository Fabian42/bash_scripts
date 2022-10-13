#!/bin/bash
source /home/fabian/hdd/d/programs/bash_scripts/sane
file="/home/fabian/hdd/d/programs/bash_scripts/brightness.txt"
setting="/sys/class/backlight/intel_backlight/brightness"
current=$(cat $setting)
# brightness probably =100%, definitely >25%
if((current>104)); then
 # if gamma active, disable, but keep brightness at maximum
 if(($(cat $file)>416)); then
  xcalib -c
  echo -n 416 > $file
 # otherwise, reduce brightness to 25% (and keep gamma inactive)
 else
  sudo su -c "echo -n 104 > $setting"
  echo -n 104 > $file
 fi
# brightness probably =25%, definitely above minimum
elif((current>1)); then
 # set brightness to minimum
 sudo su -c "echo -n 1 > $setting"
 echo -n 1 > $file
# brightness probably =minimum, definitely screen on
elif((current>0)); then
 # turn screen off
 sudo su -c "echo -n 0 > $setting"
 echo -n 0 > $file
# if screen already off, do nothing
fi