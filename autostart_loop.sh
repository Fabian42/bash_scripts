#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane
source /home/fabian/d/programs/bash_scripts/.bashrc

# prevent some parts of energy saving
xset -dpms
xset s off
caffeine &

# confirmation prompt
zenity --question --title "Autostart" --text "Complex autostart will start in 10 seconds, taking over mouse and keyboard.\nEnter/click right to continue immediately, Escape/click left to abort and not start anything." --ok-label "Continue immediately" --cancel-label "STOP" --width=621 --timeout=10 &
while ! wmctrl -l | grep "Autostart$"; do :; done # wait until prompt is open
xdotool key Super+KP_5 key Num_Lock # move window to center, also enable NumLock again, because KP_5 disables it
wait $! # wait for timeout or choice
if (( $? == 1 )); then exit; fi # right button and Enter is 0, left button and Escape is 1, timeout is 5

waitstart(){
 while ! wmctrl -l | grep "$1\$"; do :; done
}

maximise(){
 wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
}

# move window to the left part of the window, covering the majority except for a slice on the right for window thumbnails
left(){
 xdotool sleep 0.1 key Super+Left sleep 0.1
}

minimise(){
 xdotool getactivewindow windowminimize
}

normal(){
 waitstart "$1"
 maximise # maximise first, in case it was already on the left
 left
 minimise
}

# power save blocking – WARNING: depends on no windows being open!
xdotool key Meta+Alt+p sleep 0.1 key Left sleep 0.1 key Left sleep 0.1 key Left sleep 0.1 key Return sleep 0.1 keydown Right sleep 1 keyup Right sleep 0.1 key Return sleep 0.1 key Alt+m sleep 0.1 key Escape

# background programs
$drive/programs/bash_scripts/clipboard_modify.sh & # remove parts of URLs from clipboard
copyq & # clipboard history
gazou & # Japanese OCR
insync start # Google Drive sync
screenkey & # key display

# task manager
plasma-systemmonitor &
waitstart "System monitor"; maximise
xdotool key Super+t # thumbnail

# start Firefox and set up tiling size, (don't minimise yet, to open history later)
firefox &
waitstart "Mozilla Firefox"; maximise
xdotool sleep 0.1 key Super+Left sleep 1 mousemove 1280 720 sleep 0.1 mousedown 1 sleep 0.1 mousemove 2176 720 sleep 1 mouseup 1

# Notepad++
WINEPREFIX=/home/fabian/.wine wine "/home/fabian/.wine/drive_c/ProgramData/Microsoft/Windows/Start Menu/Programs/Notepad++.lnk" & normal "Notepad\\+\\+ \\[Administrator\\]"

# Qalculate
$drive/programs/bash_scripts/fix_lang qalculate-qt &
waitstart "Qalculate\!" # single or double backslash works, but not triple
wmctrl -r :ACTIVE: -b add,above
minimise

keepass "$drive/data/misc/passwords.kdbx" -pw:"$(cat $drive/programs/bash_scripts/kp_pw.txt)" & normal "KeePass"

krita --nosplash & normal "Krita"

Telegram & normal "Telegram( \\([0-9]+\\))?"

signal-desktop & normal "Signal( \\([0-9]+\\))?"

# Discord
equibop &
waitstart "^0x[0-9a-f]{8}  [0-9] nova (\\(\d+\\)|\\•) .+"; maximise; minimise

# AnyDesk
anydesk &
waitstart "AnyDesk"
xdotool key Super+i # invert
left; minimise
ids_before="$(ech "$(xdotool search --onlyvisible --name "AnyDesk")" | tr "\n" "|")" # get list of window IDs before starting remote control, to later compare with new list
anydesk $(anydesk --get-id) &
sleep 10 # no good indicator for when connection works, also don't want to wait forever if it fails
# close/stop/kill controlling window
kill -s SIGQUIT $!
for i in {1..10}; do # wait for up to 10 seconds
 if (( $(wmctrl -l | grep "AnyDesk$" | wc -l) < 3 )); then
  break
 fi
 sleep 1
done
if (( $(wmctrl -l | grep "AnyDesk$" | wc -l) >= 3 )); then
 kill -s SIGTERM $!
 for i in {1..10}; do
  if (( $(wmctrl -l | grep "AnyDesk$" | wc -l) < 3 )); then
   break
  fi
  sleep 1
 done
 if (( $(wmctrl -l | grep "AnyDesk$" | wc -l) >= 3 )); then
  kill -s SIGKILL $!
  for i in {1..10}; do
   if (( $(wmctrl -l | grep "AnyDesk$" | wc -l) < 3 )); then
    break
   fi
   sleep 1
  done
 fi
fi
xdotool windowactivate "$(xdotool search --onlyvisible --name "AnyDesk" | grep -v "^($ids_before)$")" sleep 0.1 key Super+i
left; minimise

# tuxedo
tuxedo-control-center &
waitstart "Tuxedo control center"; maximise; left
xdotool mousemove 1357 696 sleep 0.1 click 1
minimise
xdotool mousemove 60 0 sleep 0.1 click 1 sleep 0.1 key Escape sleep 0.1 click 1 sleep 0.1 mousemove 60 164 sleep 0.1 click 1 # maybe open and close notifications to hide and get Tuxedo to predictable location, then activate power save blocking

# emoji selector
plasma-emojier
normal "Emoji selector"

# Firefox history
xdotool search --onlyvisible --name "Firefox" windowactivate sleep 0.1 key Ctrl+Shift+h # focus Firefox (in case it isn't already), then open history
normal "Library"

# MC click script prep FaRo1: currently disabled, gold farm doesn't need inputs
# konsole -e "bash --rcfile \"$drive/programs/bash_scripts/mc_prep_1.sh\""

# MC FaRo1
del $drive/minecraft/replay_recordings/*.mcpr.del $drive/minecraft/replay_recordings/*.mcpr.tmp # delete broken ReplayMod recordings to prevent prompts
time=$(date "+%s")
prime-run prismlauncher -l SL1 -a FaRo1 &
while (( $time > $(stat --printf "%W" "$drive/minecraft/logs/latest.log") )); do sleep 1; done # wait for log to get reset (creation time > system time before starting MC), to avoid false positives in next wait command
tail -f "$drive/minecraft/logs/latest.log" | grep -m 1 "Creating pipeline for dimension minecraft\\:overworld" # wait for loading to almost finish
xdotool sleep 1 key Tab sleep 0.1 key Tab sleep 0.1 key Return sleep 0.1 key Super+t
maximise; minimise

# MC click script prep FaRo3 (fishing) and start MC FaRo3
konsole -e "bash --rcfile \"$drive/programs/bash_scripts/mc_prep_3.sh\"" &
while [ -f "$drive/minecraft/logs/latest.log" ] && (( $time > $(stat --printf "%W" "$drive/minecraft/logs/latest.log") )); do sleep 1; done
tail -f "$drive/minecraft/logs/latest.log" | grep -m 1 "Creating pipeline for dimension minecraft\\:overworld"

# VLC music
fix_lang prime-run vlc --play-and-exit -Z --loop --no-repeat $(find $drive/music/a1 $drive/music/a2 $drive/music/a3 $drive/music/a4 $drive/temp_music/a0_keep) &
waitstart "VLC media player"
maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space
minimise

# Dolphin calm MC music
\dolphin --new-window "$drive/temp_music/mc" &
waitstart "Dolphin"
xdotool type "mc_calm"
xdotool sleep 0.1 key Right sleep 0.1 key Up sleep 0.1 key Right sleep 0.1 key Down
maximise; left; minimise

# VLC calm MC music
fix_lang prime-run vlc --play-and-exit -Z --loop --no-repeat $(find $drive/temp_music/mc $drive/temp_music/mc_calm) &
while (( $(wmctrl -l | grep "VLC media player$" | wc -l) < 2 )); do :; done
maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space
minimise

# Dolphin temp music
\dolphin --new-window "$drive/temp_music" &
while (( $(wmctrl -l | grep "Dolphin$" | wc -l) < 2 )); do :; done
xdotool key "0"
maximise; left; minimise

# VLC temp music
fix_lang prime-run vlc --play-and-exit --no-random --loop --no-repeat $(find $drive/temp_music | grep -v -e "$drive/temp_music/a0_keep" -e "$drive/temp_music/a1_compare" | sort -u) &
while (( $(wmctrl -l | grep "VLC media player$" | wc -l) < 3 )); do :; done
maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space
minimise

# Dolphin podcast nobrain
\dolphin --new-window "$drive/podcast" &
while (( $(wmctrl -l | grep "Dolphin$" | wc -l) < 3 )); do :; done
xdotool type "future"
xdotool sleep 0.1 key Right sleep 0.1 key Down
maximise; left; minimise

# VLC podcast nobrain
fix_lang prime-run vlc --play-and-exit --no-random --loop --no-repeat $(find $drive/podcast/misc $drive/podcast/detail $drive/podcast/neytirix $drive/podcast/lateral $drive/podcast/future $drive/podcast/castoff) &
while (( $(wmctrl -l | grep "VLC media player$" | wc -l) < 4 )); do :; done
maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space
minimise

# Dolphin podcast brain
\dolphin --new-window "$drive/podcast" &
while (( $(wmctrl -l | grep "Dolphin$" | wc -l) < 4 )); do :; done
xdotool type "mit"
xdotool sleep 0.1 key Right sleep 0.1 key Down sleep 0.1 key Right sleep 0.1 key Down
maximise; left; minimise

# VLC podcast brain
fix_lang prime-run vlc --play-and-exit --no-random --loop --no-repeat $(find $drive/podcast/numberphile $drive/podcast/ri $drive/podcast/belle $drive/podcast/robert_miles $drive/podcast/becky $drive/podcast/mit $drive/podcast/taboo $drive/podcast/maix $drive/podcast/soph $drive/podcast/q217) &
while (( $(wmctrl -l | grep "VLC media player$" | wc -l) < 5 )); do :; done
maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space
minimise

# Dolphin nobrain: empty

# VLC nobrain: empyty

# Dolphin brain
\dolphin --new-window "/home/fabian/videos" &
while (( $(wmctrl -l | grep "Dolphin$" | wc -l) < 5 )); do :; done
xdotool type "c29mit"
xdotool sleep 0.1 key Right sleep 0.1 key Down sleep 0.1 key Right sleep 0.1 key Down
maximise; left; minimise

# VLC brain
fix_lang prime-run vlc --play-and-exit --no-random --loop --no-repeat $(find /home/fabian/videos/c29mit /home/fabian/videos/v55theramin /home/fabian/videos/e70right /home/fabian/videos/v39worlds) &
while (( $(wmctrl -l | grep "VLC media player$" | wc -l) < 6 )); do :; done
xdotool sleep 0.1 Ctrl+l
maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space sleep 0.1 Ctrl+l
maximise; left; minimise

# Dolphin watch
\dolphin --new-window "/home/fabian/videos" &
while (( $(wmctrl -l | grep "Dolphin$" | wc -l) < 6 )); do :; done
xdotool type "v40knot"
xdotool sleep 0.1 key Right sleep 0.1 key Down
maximise; left; minimise

# VLC watch
fix_lang prime-run vlc --play-and-exit --no-random --loop --no-repeat $(find /home/fabian/videos/v40knot) &
while (( $(wmctrl -l | grep "VLC media player$" | wc -l) < 7 )); do :; done
xdotool sleep 0.1 Ctrl+l
maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space sleep 0.1 Ctrl+l
maximise; left; minimise

# Dolphin wl
\dolphin --new-window "/home/fabian/videos/wl" &
while (( $(wmctrl -l | grep "Dolphin$" | wc -l) < 7 )); do :; done
xdotool sleep 0.1 key Alt+v sleep 0.1 key s sleep 0.1 key c sleep 0.1 key Down sleep 0.1 key Up
maximise; left; minimise

# VLC wl
fix_lang prime-run vlc --play-and-exit --no-random --loop --no-repeat $(ls -1 --sort=time --time=creation -r "/home/fabian/videos/wl") &
while (( $(wmctrl -l | grep "VLC media player$" | wc -l) < 8 )); do :; done
xdotool sleep 0.1 Ctrl+l
maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space sleep 0.1 Ctrl+l
maximise; left; minimise

# Dolphin reset sort order
\dolphin
while (( $(wmctrl -l | grep "Dolphin$" | wc -l) < 8 )); do :; done
xdotool sleep 0.1 key Alt+v sleep 0.1 key s sleep 0.1 key n sleep 0.1 key Ctrl+q

# OBS

while sleep 1; do
 # disable caps
 if xset q | grep -q "Caps Lock:   on"; then
  xdotool key Caps_Lock
 fi
 # enable numlock
 if xset q | grep -q "Num Lock:    off"; then
  xdotool key Num_Lock
 fi
 # stop middle click from pasting random garbage
 xsel -pc
 # temperature log
 echo "$(now) $(sen)" >> temperature_log
done