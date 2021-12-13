#!/bin/bash
source /home/fabian/misc/sane
brightness=$(cat /sys/class/backlight/intel_backlight/brightness)
# screen is off
if((brightness==0)); then
 # turn screen on, set brightness to minimum
 sudo su -c "echo -n 1 > /sys/class/backlight/intel_backlight/brightness"
# brightness probably =minimum, definitely <25%
elif((brightness<104)); then
 # set brightness to 25%
 sudo su -c "echo -n 104 > /sys/class/backlight/intel_backlight/brightness"
# brightness probably =25%, definitely <100%
elif((brightness<416)); then
 # set brightness to 100%
 sudo su -c "echo -n 416 > /sys/class/backlight/intel_backlight/brightness"
# brightness =100%, if gamma inactive, enable
elif(($(cat /home/fabian/misc/gamma.txt)==0)); then
 echo -n 1 > /home/fabian/misc/gamma.txt
 xcalib -gc .5 -a
# if gamma already active, do nothing
fi