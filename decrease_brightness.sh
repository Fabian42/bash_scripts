#!/bin/bash
source /home/fabian/hdd/d/programs/bash_scripts/sane
brightness=$(cat /sys/class/backlight/intel_backlight/brightness)
# brightness probably =100%, definitely >25%
if((brightness>104)); then
 # if gamma active, disable, but keep brightness at maximum
 if(($(cat /home/fabian/misc/gamma.txt)==1)); then
  xcalib -c
  echo -n 0 > /home/fabian/misc/gamma.txt
 # otherwise, reduce brightness to 25% (and keep gamma inactive)
 else
  sudo su -c "echo -n 104 > /sys/class/backlight/intel_backlight/brightness"
 fi
# brightness probably =25%, definitely above minimum
elif((brightness>1)); then
 # set brightness to minimum
 sudo su -c "echo -n 1 > /sys/class/backlight/intel_backlight/brightness"
# brightness probably =minimum, definitely screen on
elif((brightness>0)); then
 # turn screen off
 sudo su -c "echo -n 0 > /sys/class/backlight/intel_backlight/brightness"
# if screen already off, do nothing
fi