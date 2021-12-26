#!/bin/bash
source /home/fabian/hdd/d/programs/bash_scripts/sane
gsettings set org.mate.font-rendering antialiasing 'none'
env WINEPREFIX="/home/fabian/.wine" wine C:\\windows\\command\\start.exe /Unix /home/fabian/.wine/dosdevices/c:/ProgramData/Microsoft/Windows/Start\ Menu/Programs/Notepad++.lnk "$1"
sleep 1
gsettings set org.mate.font-rendering antialiasing 'rgba'
wmctrl -ia $(wmctrl -l | grep " - Notepad++ \\[Administrator\\]" | tail -n 1 | sed "s/ .+//")