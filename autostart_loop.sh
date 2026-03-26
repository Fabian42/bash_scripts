#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane
source /home/fabian/d/programs/bash_scripts/.bashrc

# prevent some parts of energy saving
echo "start"
# xset -dpms
xset s off
caffeine & disown
systemd-inhibit --what="sleep:idle:handle-suspend-key:handle-hibernate-key:handle-lid-switch" --who="manual" --why="stop annoying me" --mode=block sleep 2147483647 & disown

# confirmation prompt
echo "prompt"
zenity --question --title "Autostart" --text "Complex autostart will start in 10 seconds, taking over mouse and keyboard.\nEnter/click right to continue immediately, Escape/click left to abort and not start anything." --ok-label "Continue immediately" --cancel-label "STOP" --width=621 --timeout=10 &
while ! wmctrl -l | grep "Autostart$"; do :; done # wait until prompt is open
xdotool key Super+KP_5 key Num_Lock # move window to center, also enable NumLock again, because KP_5 disables it
wait $! # wait for timeout or choice
if (( $? == 1 )); then exit; fi # right button and Enter is 0, left button and Escape is 1, timeout is 5

echo "functions"
waitstart(){
 num="$2"
 if ! [[ "$num" =~ ^[0-9]+$ ]]; then num=1; fi
 i=0
 while (( $(wmctrl -l | grep "$1\$" | wc -l) < $num )); do
  ((i++))
  if (( i > 60 )); then return 1; fi # probably failed to start, return with error status
  sleep 1
 done
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

checkkde(){
 if (( "$(ps -eo etimes,cmd | grep "^ +[0-9]+ /usr/bin/plasmashell" | grep -o "[0-9]+")"-0 < 10 )); then # (5-0<10) if KDE running for 5s, (-0<10) if not
  sleep 10 # maybe it starts on its own
  if ! ps -eo etimes,cmd | grep "^ +[0-9]+ /usr/bin/plasmashell"; then
   kstart5 plasmashell & disown
   sleep 10
  fi
 fi
}

normal(){
 if waitstart "$1" 1; then
  checkkde
  maximise # maximise first, in case it was already on the left
  left
  minimise
 fi
}

# background programs
echo "clipboard_modify"
$drive/programs/bash_scripts/clipboard_modify.sh & disown # remove parts of URLs from clipboard
echo "copyq"
copyq & disown # clipboard history
echo "gazou"
gazou & disown # Japanese OCR
echo "insync"
insync start # Google Drive sync
echo "screenkey"
screenkey & disown # key display
echo "KDE Connect"
kdeconnectd & disown
echo "focus"
xdotool key Ctrl+Super+m # disable focus strip

# task manager
echo "task manager"
plasma-systemmonitor & disown
waitstart "System monitor"; maximise
checkkde
xdotool sleep 1 mousemove 2479 209 sleep 0.1 click 1 sleep 0.1 key Tab sleep 0.1 key space sleep 0.1 mousemove 500 500 sleep 0.1 click 5 sleep 0.1 key Super+t # hide HDD temperature warning, scroll down, enable thumbnail

# task manager:
# x:2479 y:209 screen:0 window:94371863
# tab space

# start Firefox and set up tiling size, (don't minimise yet, to open history later)
echo "Firefox"
firefox & disown
waitstart "Mozilla Firefox"
sleep 1
checkkde
maximise
xdotool sleep 0.1 key Super+Left sleep 1 mousemove 1280 720 sleep 0.1 mousedown 1 sleep 0.1 mousemove 2176 720 sleep 1 mouseup 1

# Notepad++
echo "Notepad++"
WINEPREFIX=/home/fabian/.wine wine "/home/fabian/.wine/drive_c/ProgramData/Microsoft/Windows/Start Menu/Programs/Notepad++.lnk" & disown
normal "Notepad\\+\\+ \\[Administrator\\]"

# Qalculate
echo "Qalculate"
$drive/programs/bash_scripts/fix_lang qalculate-qt & disown
waitstart "Qalculate\!" # single or double backslash works, but not triple
checkkde
wmctrl -r :ACTIVE: -b add,above
minimise

echo "KeePass"
keepass "$drive/data/misc/passwords.kdbx" -pw:"$(cat $drive/programs/bash_scripts/kp_pw.txt)" & disown
normal "KeePass"

echo "Krita"
krita --nosplash & disown
normal "Krita"

echo "Telegram"
Telegram & disown
normal "Telegram( \\([0-9]+\\))?"

echo "Signal"
signal-desktop & disown
normal "Signal( \\([0-9]+\\))?"

# Discord
echo "Discord"
equibop & disown
waitstart "^0x[0-9a-f]{8}  [0-9] nova (\\([0-9]+\\)|\\•) .+"; checkkde; maximise; minimise

# AnyDesk
echo "AnyDesk"
anydesk & disown
waitstart "AnyDesk"
checkkde
xdotool key Super+i # invert
left; minimise
ids_before="$(ech "$(xdotool search --onlyvisible --name "AnyDesk")" | tr "\n" "|")" # get list of window IDs before starting remote control, to later compare with new list
anydesk $(anydesk --get-id) & disown
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
rustdesk & disown
normal "RustDesk"

# tuxedo
echo "Tuxedo"
tuxedo-control-center & disown
waitstart "Tuxedo control center"; checkkde; maximise; left
xdotool mousemove 1357 696 sleep 0.1 click 1
minimise
xdotool mousemove 60 50 sleep 0.1 click 1 sleep 0.1 mousemove 60 181 sleep 0.1 click 1 # activate power save blocking

# emoji selector
echo "Emoji"
plasma-emojier & disown
normal "Emoji selector"

# Firefox history
echo "Firefox history"
xdotool search --onlyvisible --name "Firefox" windowactivate sleep 0.1 key Ctrl+Shift+h # focus Firefox (in case it isn't already), then open history
normal "Library"

# MC click script prep FaRo1: currently disabled, gold farm doesn't need inputs
# konsole -e "bash --rcfile \"$drive/programs/bash_scripts/mc_prep_1.sh\""

# MC FaRo1
echo "MC 1"
del $drive/minecraft/replay_recordings/*.mcpr.del $drive/minecraft/replay_recordings/*.mcpr.tmp # delete broken ReplayMod recordings to prevent prompts
time=$(date "+%s")
prime-run prismlauncher -l SL1 -a FaRo1 & disown
i=0
while (( $time > $(stat --printf "%W" "$drive/minecraft/logs/latest.log") )); do # wait for log to get reset (creation time > system time before starting MC), to avoid false positives in next wait command
 sleep 1
 ((i++))
 if (( i > 60 )); then break; fi # timeout
done
if timeout 60 tail -f "$drive/minecraft/logs/latest.log" | grep -m 1; then "Creating pipeline for dimension minecraft\\:overworld" # wait for loading to almost finish
 checkkde
 xdotool sleep 1 key Tab sleep 0.1 key Tab sleep 0.1 key Return sleep 0.1 key Super+t
 maximise; minimise
fi

# MC click script prep FaRo3 (fishing) and start MC FaRo3
echo "MC 3"
konsole -e "bash --rcfile \"$drive/programs/bash_scripts/mc_prep_3.sh\"" & disown
i=0
while [ -f "$drive/minecraft/logs/latest.log" ] && (( $time > $(stat --printf "%W" "$drive/minecraft/logs/latest.log") )); do
 sleep 1
 ((i++))
 if (( i > 60 )); then break; fi # timeout
done
timeout 60 tail -f "$drive/minecraft/logs/latest.log" | grep -m 1 "Creating pipeline for dimension minecraft\\:overworld"
checkkde

# VLC music
echo "VLC+Dolphin"
fix_lang prime-run vlc --play-and-exit -Z --loop --no-repeat $(find "$drive/music/a1" "$drive/music/a2" "$drive/music/a3" "$drive/music/a4" "$drive/temp_music/a0_keep" -type f | sort -u) & disown
waitstart "VLC media player"; checkkde; maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space sleep 0.1 keydown Down sleep 1 keyup Down sleep 0.1 key Up sleep 0.1 key Up sleep 0.1 key Up # correct keyboard focus, volume 60%
minimise

# VLC calm MC music
fix_lang prime-run vlc --play-and-exit -Z --loop --no-repeat $(find "$drive/temp_music/mc" "$drive/temp_music/mc_calm" -type f | sort -u) & disown
waitstart "VLC media player" 2
checkkde; maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space
minimise

# Dolphin temp music
\dolphin --new-window "$drive/temp_music" & disown
waitstart "Dolphin"; checkkde
xdotool key "0"
maximise; left; minimise

# VLC temp music
fix_lang prime-run vlc --play-and-exit --no-random --loop --no-repeat $(find "$drive/temp_music" -type f | grep -v -e "a0_keep" -e "a1_compare" -e "mc_calm" | sort -u) & disown
waitstart "VLC media player" 3
checkkde; maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space
minimise

# Dolphin podcast nobrain
\dolphin --new-window "$drive/podcast" & disown
waitstart "Dolphin" 2
checkkde
xdotool type "future"
xdotool sleep 0.1 key Right sleep 0.1 key Down
maximise; left; minimise

# VLC podcast nobrain
fix_lang prime-run vlc --play-and-exit --no-random --no-loop --no-repeat $(find "$drive/podcast/misc" "$drive/podcast/detail" "$drive/podcast/neytirix" "$drive/podcast/lateral" "$drive/podcast/carlin" "/home/fabian/videos/e18future" "/home/fabian/videos/h85future2" "/home/fabian/videos/e53castoff" "/home/fabian/videos/h88thought" -type f | sort -u) & disown
waitstart "VLC media player" 4
checkkde; maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space sleep 0.1 key Up sleep 0.1 key Up
minimise

# Dolphin podcast brain
\dolphin --new-window "$drive/podcast" & disown
waitstart "Dolphin" 3
checkkde
xdotool type "mit"
xdotool sleep 0.1 key Right sleep 0.1 key Down sleep 0.1 key Right sleep 0.1 key Down
maximise; left; minimise

# VLC podcast brain
fix_lang prime-run vlc --play-and-exit --no-random --no-loop --no-repeat $(find "$drive/podcast/numberphile" "$drive/podcast/ri" "/home/fabian/videos/e66belle" "$drive/podcast/robert_miles" "$drive/podcast/becky" "$drive/podcast/mit" "$drive/podcast/taboo" "$drive/podcast/mai" "$drive/podcast/q217" "/home/fabian/videos/h87frysauce" -type f | sort -u) & disown
waitstart "VLC media player" 5
checkkde; maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space
minimise

# Dolphin brain
\dolphin --new-window "/home/fabian/videos" & disown
waitstart "Dolphin" 4
checkkde
xdotool type "c29mit"
xdotool sleep 0.1 key Right sleep 0.1 key Down sleep 0.1 key Right sleep 0.1 key Down
maximise; left; minimise

# VLC brain
fix_lang prime-run vlc --play-and-exit --no-random --no-loop --no-repeat $(find "/home/fabian/videos/c29mit" "/home/fabian/videos/u55theramin" "/home/fabian/videos/u39worlds" "/home/fabian/videos/e32brain" "/home/fabian/videos/e31scienceclic" "/home/fabian/videos/e24code" "/home/fabian/videos/e58music" "/home/fabian/videos/e14gneiss" "/home/fabian/videos/h82clark" "/home/fabian/videos/h77series" "/home/fabian/videos/h83traffic" "/home/fabian/videos/h79trope" "/home/fabian/videos/h81brain" -type f | sort -u) & disown
waitstart "VLC media player" 6
checkkde
xdotool sleep 0.1 key Ctrl+l
maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space sleep 0.1 key Ctrl+l
maximise; left; minimise

# Dolphin nobrain
\dolphin --new-window "/home/fabian/videos" & disown
waitstart "Dolphin" 5
checkkde
xdotool type "e02obses"
xdotool sleep 0.1 key Right sleep 0.1 key Down sleep 0.1 key Right sleep 0.1 key Down
maximise; left; minimise

# VLC nobrain
fix_lang prime-run vlc --play-and-exit --no-random --no-loop --no-repeat $(find "/home/fabian/videos/e02obses" "/home/fabian/videos/e41object" "/home/fabian/videos/e63phoenix" "/home/fabian/videos/h74welonz_deltarune" "/home/fabian/videos/h84mc_blind" "/home/fabian/videos/h76coin" "/home/fabian/videos/h78eelis" "/home/fabian/videos/h86j_ander" -type f | sort -u) & disown
waitstart "VLC media player" 7
checkkde
xdotool sleep 0.1 key Ctrl+l
maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space sleep 0.1 key Ctrl+l
maximise; left; minimise

# Dolphin watch
\dolphin --new-window "/home/fabian/videos" & disown
waitstart "Dolphin" 6
checkkde
xdotool type "z40knot"
xdotool sleep 0.1 key Right sleep 0.1
xdotool type "u40knot"
xdotool sleep 0.1 key Right sleep 0.1 key Down
maximise; left; minimise

# VLC look
fix_lang prime-run vlc --play-and-exit --no-random --no-loop --no-repeat $(find "/home/fabian/videos/u40knot" "/home/fabian/videos/e57kuvina" "/home/fabian/videos/e59things" "/home/fabian/videos/e65xkcd" "/home/fabian/videos/h75wolf" "/home/fabian/videos/h80meme" -type f | sort -u) & disown
waitstart "VLC media player" 8
checkkde
xdotool sleep 0.1 key Ctrl+l
maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space sleep 0.1 key Ctrl+l
maximise; left; minimise

# Dolphin wl
\dolphin --new-window "/home/fabian/videos/wl" & disown
waitstart "Dolphin" 7
checkkde
xdotool sleep 0.1 key Alt+v sleep 0.1 key s sleep 0.1 key c sleep 0.1 key Down sleep 0.1 key Up
maximise; left; minimise

# VLC wl
fix_lang prime-run vlc --play-and-exit --no-random --no-loop --no-repeat $(ls -1 --sort=time --time=creation -r "/home/fabian/videos/wl" | sed "s/^/\\/home\\/fabian\\/videos\\/wl\\//") & disown
waitstart "VLC media player" 9
checkkde
xdotool sleep 0.1 key Ctrl+l
maximise; left
xdotool sleep 0.1 mousemove 1408 257 sleep 0.1 click 1 sleep 0.1 mousemove 351 879 sleep 0.1 click 1 sleep 0.1 key space sleep 0.1 key Ctrl+l
maximise; left; minimise

# Dolphin reset sort order
\dolphin & disown
waitstart "Dolphin" 8
checkkde
xdotool sleep 0.1 key Alt+v sleep 0.1 key s sleep 0.1 key n sleep 0.1 key Ctrl+q

# OBS

# reminder for manual actions
notify-send "Tux+KDE power save block, all linemode, fix replay rec, task error"

# background loop
echo "loop"
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
# echo "$(now) $(sen)" >> temperature_log
done