#!/bin/bash
source /home/fabian/hdd/d/programs/bash_scripts/sane
file="/home/fabian/hdd/d/programs/bash_scripts/brightness.txt"
setting="/sys/class/backlight/intel_backlight/brightness"
current=$(cat $setting)
# brightness probably =100%, definitely >25%
if((current>104)); then
#if((current>833)); then
 # if gamma active, disable, but keep brightness at maximum
 if(($(cat $file)>416)); then
# if(($(cat $file)>3333)); then
  echo -n 416 > $file
#  echo -n 3333 > $file
  xcalib -c
 # otherwise, reduce brightness to 25% (and keep gamma inactive)
 else
  echo -n 104 > $file
#  echo -n 833 > $file
  sudo su -c "echo -n 104 > $setting"
#  sudo su -c "echo -n 833 > $setting"
 fi
# brightness probably =25%, definitely above minimum
elif((current>1)); then
 # set brightness to minimum
 echo -n 1 > $file
 sudo su -c "echo -n 1 > $setting"
# brightness probably =minimum, definitely screen on
elif((current>0)); then
 # turn screen off
 echo -n 0 > $file
 sudo su -c "echo -n 0 > $setting"
# if screen already off, do nothing
fi