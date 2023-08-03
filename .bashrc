# This file gets sourced by my actual .bashrc file that exists in both /home/fabian and /root and has the following content:
# HISTSIZE=
# HISTFILESIZE=
# export EDITOR="/usr/bin/nano"
# export VISUAL="/usr/bin/nano"
# The purpose of that is to always have these applied, even if I horribly mess up this file.

source /home/fabian/hdd/d/programs/bash_scripts/sane

## variables
export drive="/home/fabian/hdd/d"
wl_id=$(cat /home/fabian/hdd/d/programs/bash_scripts/wl_id.txt)
tm_id=$(cat /home/fabian/hdd/d/programs/bash_scripts/tm_id.txt) # so far unused
yt_pw=$(cat /home/fabian/hdd/d/programs/bash_scripts/yt_pw.txt)

# easier to remember command for editing this file
alias aka="nano -Ll +119 /home/fabian/hdd/d/programs/bash_scripts/.bashrc; source /home/fabian/hdd/d/programs/bash_scripts/.bashrc"
# increase console history size from 500 to unlimited
HISTSIZE=
HISTFILESIZE=

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -en "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -en "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
	else
		PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
	fi

	alias ls='ls --color=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

unset use_color safe_term match_lhs sh

alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias np='nano -w PKGBUILD'
alias more=less

xhost +local:root > /dev/null 2>&1

complete -cf sudo

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

# manually edited
# Adding the kdesrc-build directory to the path
export PATH="$HOME/kde/src/kdesrc-build:$PATH"

# Creating alias for running software built with kdesrc-build
kdesrc-run ()
{
  source "$HOME/kde/build/$1/prefix.sh" && "$HOME/kde/usr/bin/$1"
}

### MANUALLY ADDED ###

## improvements
# echo without newline
alias ech="echo -n"
# don't append useless newline, show line numbers
alias nano="nano -Ll"
# change shutdown default duration to 0 instead of 1 minute
shutdown(){ if [[ "$1" == "" ]]; then /usr/bin/shutdown --no-wall 0; else /usr/bin/shutdown --no-wall "$@"; fi;}
# properly sync history between consoles (still requires pressing Enter to retrieve)
PROMPT_COMMAND="history -a; history -n"
# "pwd" is a stupid name for "show current path" (also expand links to full path from now on)
path(){ cd "$(readlink -f "$(pwd)")"; pwd;}
# all newly created files and folders have all permissions, except execution (in some way, but not another?)
umask 000
# open Dolphin in the right location, with dark theme and not as a tab (geometry gets ignored, but makes "--new-window" actually work)
alias dolphin="dolphin -stylesheet /home/fabian/hdd/d/programs/bash_scripts/dolphin_dark.qss --new-window --geometry 0x0 . & disown"
# don't ask for password for "su"
alias su="sudo su"
# sudo make me an iotop sandwhich
alias iotop="sudo iotop"
# sudo make me a bandwhich sandwhich
alias bandwhich="sudo bandwhich"
# sudo make me a downgrade sandwhich
alias downgrade="sudo downgrade"
# fix broken updates
magic(){
 sudo pacman-mirrors --continent --api --protocols https http ftp --set-branch stable
 sudo pacman-key --refresh-keys
 echo "y\nn\ny\n" | yay -Scc
 yay -Syyu
 to_rebuild=$(checkrebuild | sed "s/[^\\t]+\\t//" | tr "\n" " ")
 echo "REBUILDING: $to_rebuild"
 yay -S $to_rebuild
 echo "FILE ISSUES:"
 search pacnew
 search pacsave
# sudo find /usr/lib -size 0
}
# only the cleaning part of the above
alias space="echo \"y\nn\ny\n\" | yay -Scc"
# fix iMage "unable to write pixel cache" on large images
export TMPDIR="/var/tmp"
# restart KDE and KDE connect
alias kde="killall plasmashell; killall kdeconnectd; kstart5 plasmashell &> /dev/null & disown; /usr/lib/kdeconnectd &> /dev/null & disown; exit"
# restart the window manager when the Windows key doesn't open the start menu
alias win="kwin_x11 --replace &> /dev/null & disown; exit"
# grep ignores case and knows regex, also another copy of "stray backslash" suppression from "sane", required against conflicts between sane and .bashrc
grep(){ if [[ "$@" == *-P* ]]; then /usr/bin/grep -i --colour=auto "$@" 2>/dev/null; else /usr/bin/grep -i --colour=auto -E "$@" 2>/dev/null; fi; }
# repairs secondary Bluetooth tray icon and restarts Bluetooth
alias blu="systemctl restart bluetooth; sleep 1; killall blueman-applet; (blueman-applet &> /dev/null & disown); exit"
# restart PulseAudio
alias pulse="systemctl --user restart pulseaudio.service; exit"
# stop microphone volume from changing randomly
alias mic="for i in {0..9999}; do pactl set-source-volume @DEFAULT_SOURCE@ 100%; sleep 10; done"
# create a new script file here
scr(){
 if [ -e "$1.sh" ]; then
  echo "File already exists!"
  perm "$1.sh"
  if [[ ! "$(cat "$1.sh" | head -n 1)" =~ ^\#!" "*\/bin\/bash$ ]]; then
   echo "Adding #!/bin/bash and source /home/fabian/hdd/d/programs/bash_scripts/sane"
   (echo "#!/bin/bash\nsource /home/fabian/hdd/d/programs/bash_scripts/sane"; cat "$1.sh") | sponge "$1.sh"
  fi
  sleep 1
 else
  touch "$1.sh"
  sudo chmod -R 777 "$1.sh"
  echo "#!/bin/bash\nsource /home/fabian/hdd/d/programs/bash_scripts/sane" > "$1.sh"
 fi
 nano -lL +3 "$1.sh"
}
# execute scripts with aliases and functions in .bashrc
alias e="source"
# visudo with nano
export EDITOR="nano"
export VISUAL="nano"
# diff including subfolders
alias diff="diff -r"
# allow downgrades
export DOWNGRADE_FROM_ALA=1
# ask before overwriting files instead of moving them
alias mv="mv -i"
# make FFMPEG not react to keyboard input, no header, use GPU
alias ffmpeg="prime-run ffmpeg -nostdin -hide_banner"
# ffprobe outputs to stdout, no banner
ffprobe(){ /usr/bin/ffprobe  -hide_banner $@ 2>&1; }
# print syslog properly
alias journalctl="journalctl --no-pager"
# normal output of systemctl
alias systemctl="systemctl --no-pager"
# make help pages actually print to STDOUT properly
alias man="echo \"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\" | man -a -P cat"
# original quality and correct colours for PNGs
alias convert="convert -quality 100 -strip -auto-orient"
# don't interrupt tasks with Ctrl+C
stty intr ^- 2>/dev/null
# don't suspend tasks with Ctrl+S
stty -ixon 2>/dev/null
# skip non-issues in shellcheck, list all links at bottom
alias shellcheck="shellcheck --exclude=SC2164,SC2181,SC2028,SC2010,2002,SC2162 -W 9999"

## console
# forget commands starting with a space
HISTCONTROL=ignorespace
# show time in history
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
# directory name autocorrect
shopt -s cdspell
# switching to directories without "cd"
shopt -s autocd
# ignore consecutive duplicate commands, anything that starts with a space and some specific commands in history and up-arrow list
HISTIGNORE="&: :q:q *:h:hi:aka:kde:win:pulse:blu:shutdown:pachist"
# quit
alias q="exit"
# search console history
h(){ if [[ "$1" == "" ]]; then history | tail -n 100; else history | grep -i "$@" | tail -n 101 | head -n -1 | grep -i "$@"; fi;}
# search console history, no 100 entries limit
hi(){ if [[ "$1" == "" ]]; then history; else history | grep -i "$@" | grep -i "$@"; fi;}
# Only split on newlines for "for" loops, not on spaces from now on.
alias nl="IFS=$'\n'"
# output matching lines from this file
alias akac="cat /home/fabian/hdd/d/programs/bash_scripts/.bashrc | grep"
# highlight parts of an output
hl(){
 cmd="echo \"\$line\" | grep -e \"\""
 for arg in $@; do
  cmd="$cmd -e \"$arg\""
 done
 while read line; do
  eval "$cmd"
 done
}
# output help for formatting codes
formathelp(){ for i in {0..123}; do echo "\e[$i""m\\\e[$i""m\e[0m"; done; }
# lowercase a string
alias lower="tr '[:upper:]' '[:lower:]'"
# yesn't
alias no="yes 'n' #t"

## files
# always list all files that actually exist, in better order
alias ls="ls -A --group-directories-first"
# create folder, ignore if already exists, create all necessary parent folders, immediately switch to it and list files
mk(){ mkdir -p "$1"; cd "$1"; pwd; ls -A --group-directories-first;}
# "up" goes one folder up, "up n" goes n folders up
up(){ if [ "$1" == "" ]; then cd ..; else for((a=0;a<$1;a++)) do cd ..; done; fi; pwd; ls -A --group-directories-first;}
# go to the previous directory
alias back="cd \$OLDPWD; pwd; ls -A --group-directories-first;"
# give all permissions to everyone for a file/folder, including subfolders
perm(){ sudo chown -R $(whoami) "$1"; sudo chmod -R 777 "$1"; sudo chattr -Rai "$1";}
# quick switching to "Downloads", "music", etc.
export CDPATH=".:/home/fabian:$drive"

# go to folder (and subfolder starting with second input), print path and list files
c(){
 if [[ "$1" == "" ]]; then
  cd ~ # restore ~ switching without arguments, which is broken by CDPATH containing "."
 else
  cd "$1" > /dev/null;
  if (( $? != 0 )); then
   # error message already printed by cd
   return;
  fi
  if [ "$2" != "" ]; then
   cd "./$2"* &> /dev/null; # ./ to disable /home/fabian/* switching, which is not wanted here
   if (($? != 0 )); then
    echo "Second argument not found or not unique!";
   fi
  fi
 fi
 pwd
 ls -A --group-directories-first
}

# quickly switch to "bash_scripts" repository
alias g="c /home/fabian/hdd/d/programs/bash_scripts"

# visually confirmed deletion to trash
del(){
 IFS=$'\n'
 for file in $@; do
  if [ -e "/home/fabian/.local/share/Trash/files/$(basename "$file")" ]; then
   a=1
   while [ -e "/home/fabian/.local/share/Trash/files/$(basename "$file") ($a)" ]; do
    ((a++))
   done
   mv "$file" "/home/fabian/.local/share/Trash/files/$(basename "$file") ($a)"
   echo "[Trash Info]\nPath=$(readlink -f "$file")\nDeletionDate=$(date "+%Y-%m-%dT%H:%M:%S")" > "/home/fabian/.local/share/Trash/info/$(basename "$file") ($a).trashinfo"
  else
   mv "$file" "/home/fabian/.local/share/Trash/files/"
   echo "[Trash Info]\nPath=$(readlink -f "$file")\nDeletionDate=$(date "+%Y-%m-%dT%H:%M:%S")" > "/home/fabian/.local/share/Trash/info/$(basename "$file").trashinfo"
  fi
 done
 pwd
 ls
}

# find duplicate files
alldiff(){
 for file1 in *; do
  for file2 in $(ls -1 | grep --after-context=9999 "^$file1\$" | tail -n +2); do
   diff "$file1" "$file2" &> /dev/null
   if [[ $? == 0 ]]; then
    echo "$file1\n$file2\n"
   fi
  done
 done
}

# compare amount of files starting with indices (for example to check progress in sorting out multi-playlist downloads)
num(){
 max=$(ls -1 | grep -E "^[0-9]{4}\\_" | tail -n 1 | grep -E -o "^[0-9]{4}" | sed "s/^0*//")
 if [[ "$max" != "" ]]; then
  old=$(ls -1 | grep "^0000\\_" | wc -l)
  echo "0000 $old"
  for ((i=1; i<=$max; i++)); do
   new=$(ls | grep "^$(printf "%04d" $i)" | wc -l)
   if [[ "new" == "" ]]; then echo "set to 0"; new=0; fi
   diff=$(($new-$old))
   case $diff in
    (1)
     echo "$i $new \e[93m$diff\e[0m"
     ;;
    (2)
     echo "$i $new \e[33m$diff\e[0m"
     ;;
    ([1-9]*)
     echo "$i $new \e[31m$diff\e[0m"
     ;;
    (0 | -*)
     echo "$i $new \e[32m$diff\e[0m"
     ;;
   esac
   old=$new
  done
 fi
 na=$(ls -1 | grep -E "^NA\\_" | wc -l)
 if (( $na != 0 )); then
  echo "NA $na"
 fi
}

# convert to MP3 with best quality and remove metadata (from anywhere to current working directory)
mp3(){
 for file in "$@"; do
  # expand links to full path
  file="$(readlink -f "$file")"
  # filename without path
  name="$(basename "$file")"
  if [[ "$(echo "$file" | grep -E ".mp3$")" == "" ]]; then
   ffmpeg -i "$file" -nostdin -map 0:a -map_metadata -1 -v 16 -q:a 0 "${name%.*}.mp3"
   if(($?==0)); then
    rm "$file"
   else
    echo "Error encountered, $file kept."
   fi
  else
   # path without filename
   path="${file%$name}"
   mv "$file" "$path""old_$name"
   ffmpeg -i "$path""old_$name" -nostdin -map 0:a -map_metadata -1 -v 16 -c:a copy "$name"
   if(($?==0)); then
    rm "$path""old_$name"
   else
    echo "Error encountered, $path""old_$name kept."
   fi
  fi
 done
}

# usual Git workflow to upload local changes
alias commit="git diff; git add .; git status; read -p \"Press Enter to continue.\"; git commit --no-status; git push"
# print subtitles from video
subs(){
 stream=0
 for lang in $(ffprobe "$1" 2>&1 | grep "Subtitle" | grep -Eo "  Stream \\#0\\:[0-9]+(\\[[0-9]x[0-9]\\])?\\([a-z]+" | sed "s/  Stream \\#0\\:[0-9]+\\(//"); do
  echo "\nSubtitles #"$stream", language: "$lang
  ffmpeg -i "$1" -map 0:s:$stream -f srt - -v 16 | grep -v -E -e "^[0-9\:\,]{12} \-\-> [0-9\:\,]{12}$" -e "^[0-9]+$" -e "^$" | sed "s/\\\\h//g"
  ((stream++))
 done
}
# print rm commands for all duplicate YouTube downloads in a folder
#ytdup(){
# nl
# for line in $(cat temp.txt); do
#  if [[ "$(echo $line | grep -Eo "^.{11}")" == "$prev" ]]; then
#   echo "$line" | sed "s/^.{11}/rm/"
#  else
#   prev=$(echo $line | grep -Eo "^.{11}")
#  fi
# done
#}

# exit VLC after playing media
alias vlc="vlc --play-and-exit"
# util function for ff4 to divide a given timestamp by 4
div_time4(){
 sec_in="$(echo $1 | grep -o "[0-9\\.]+$")"
 rest="$(echo $1 | sed "s/\\:?[0-9\\.]+$//")"
 min_in="$(echo $rest | grep -o "[0-9]+$")"
 hour_in="$(echo $rest | sed "s/\\:?[0-9]+$//")"
 hour=$((hour_in/4))
 min=$((min_in/4+(hour_in%4*15)))
 sec="$(qalc -t "$sec_in/4+(0$min_in%4*15)")"
 echo "$hour:$min:$sec" # everything works out to be "0:0:x" if input is shorter format
}
# speed up video 4×
ff4(){
 if [[ "$2" != "" ]]; then
  start="-ss $(div_time4 "$2")"
  if [[ "$3" != "" ]]; then
   end="-t $(div_time4 "$3")"
  fi
 fi
 ffmpeg -i "$1" -crf 1 $start $end -filter_complex "[0:v]setpts=0.25*PTS[v];[0:a]atempo=4.0[a]" -map "[v]" -map "[a]" "a4_$1"
}

# pack files in most compatible way: zip, no compression, file size <2000MiB for Telegram, test afterwards
zp(){
 # First argument is archive name without ".zip" or ".zip.001" etc., others are files to be packed. If omitted, name is folder name and files are auto-selected: all files in current folder that are not subfolders or already archives
 if [[ "$1" == "" ]]; then
  out_name="$(basename "$(readlink -f .)")"
 else
  out_name="$1"
 fi
 shift
 if [[ "$@" == "" ]]; then
  files=()
  for file in *; do
   type="$(file "$file")"
   if ! [[ "$file" =~ .+\.(zip|7t)\.[0-9][0-9][0-9] || "$type" =~ .+" "(directory|"archive data").+ ]]; then
    files+=("$file")
   fi
  done
 else
  files=("$@")
 fi
 # split archive into Telegram-compatible files, if necessary
 size=0
 for file in "${files[@]}"; do
  ((size+=$(du -PsB1 "$file" | sed "s/[ \\t].+//")))
 done
 # conditional parameters: split archive into Telegram-compatible files if necessary, delete original files if it's a DVD backup and packing succeeded
 7z a -mx0 $(if (( size > 2097152000 )); then echo "-v2097152000b"; fi) $(if [[ "$(readlink -f .)" == "/home/fabian/Desktop/DVD" ]]; then echo "-sdel"; fi) "$out_name".zip "${files[@]}"
}
render_kanji(){ convert -monitor -define registry:temporary-path=/home/fabian/hdd/temp -limit memory 8gb -background black -fill white -pointsize 4096 -font "/usr/share/fonts/TTF/Cica-Regular.ttf" label:"$1" render_kanji.png; }

## searches
# search files everywhere, ignoring case, partial file name, avoid most of the usual "permission denied" error messages and hide the rest
search(){ sudo find / -iwholename "*$1*" 2> /dev/null | sort | grep -i "$1";}
# same as above, but only in the current folder and subfolders and not as root and not hiding errors
here(){ find . -regextype grep -iwholename "*$1*" | sort | grep -i "$1";}
# same as above, but as root
shere(){ sudo find . -iwholename "*$1*" | grep -i "$1";}
# trash all files for search term
delhere(){ del $(here "$1");}
# Play all tracks from my music collection randomly with VLC that match the search terms and close the console. If no search term is entered, randomise the entire collection, but not a0.
p(){
 if [[ "$1" == "" ]]; then
  files="$(find $drive/m/a1/* $drive/m/a2/* $drive/m/a3/* $drive/m/a4/* | sort -u)"
 else
  files="$(find $drive/m/a0/* $drive/m/a1/* $drive/m/a2/* $drive/m/a3/* $drive/m/a4/* -iname "*$1*" | sort -u)"
 fi
 (prime-run vlc --play-and-exit -Z $files &> /dev/null & disown)
 exit
}

## Minecraft
# get a window ID for a multiplayer Minecraft window
mc(){
 for id in $(xdotool search --name "Minecraft\\* [0-9\\.]+ \\- マルチプレイ\\（サードパーティーのサーバー\\）")$(xdotool search --name "Minecraft\\* [0-9\\.]+ \\- Multiplayer \\(3rd\\-party [Ss]erver\\)")$(xdotool search --name "Minecraft\\* [0-9\\.]+ \\- Playing with yer mates \\(3rd\\-party [Ii]sland\\)")$(xdotool search --name "FaRo[13] on SL"); do
  if [[ ! "$(xdotool getwindowname "$id")" =~ .*CopyQ.* ]]; then
   echo "$id"
   break
  fi
 done
}
# minimize the console window before doing anything else
alias mn="xdotool getactivewindow windowminimize; sleep 1"
# filter latest Minecraft log
log2(){ cat /home/fabian/.local/share/PrismLauncher/instances/SL/.minecraft/logs/latest.log | grep -i "$1";}
# same, but only relevant chat messages
log(){ cat /home/fabian/.local/share/PrismLauncher/instances/SL/.minecraft/logs/latest.log | grep -E "^\\[[0-9][0-9]\\:[0-9][0-9]\\:[0-9][0-9]\\] \\[(main|Render thread)\\/INFO\\]\\: \\[CHAT\\] " | grep -v -e "o/" -e "tartare" -e "hello" -e "\\bhi\\b" -e "☻/" -e "\\\\o" -e "heyo" -e "i'm off" -e "gtg" -e "bye" -e "cya" -e "Good morning! If you'd like to be awake through the coming night, click here." -e "left the game" -e "joined the game" -e "just got in bed." -e "Unknown or incomplete command\\, see below for error" -e "\\/<\\-\\-\\[HERE\\]" -e "\\[Debug\\]: " -e "がゲームに参加しました" -e "がゲームを退出しました" -e "［デバッグ］： " -e "スクリーンショットを" -e "Now leaving " -e "Now entering " | grep -i "$1" | sed "s/^\\[//;s/\\] \\[(main|Render thread)\\/INFO\\]\\: \\[CHAT\\]//" | grep -vE "^[0-9\\:]+ <[A-Za-z0-9\\_\\-]+> (io|oi|hey|wb)$" | grep -i "$1";}
# use all items on a full hotbar, optional argument of clicks per slot
hotbar(){ max=70; if [[ "$1" =~ ^[0-9]+$ ]]; then max=$1; fi; for slot in {1..9}; do i=0; while ((i++<max)); do xdotool click --delay 50 1; done; xdotool click 5; done; }
# craft the rightmost 7×3 inventory slots of bones into bone blocks, assuming no other available recipes
alias bones="mn; xdotool keydown Shift keydown y mousemove 1081 586 click 1 mousemove 1325 446 click 1 mousemove 1086 642 click 1 mousemove 1325 446 click 1 mousemove 1082 695 click 1 mousemove 1325 446 click 1 mousemove 554 442 click 1 mousemove 1325 446 click 1 mousemove 1145 594 click 1 mousemove 1325 446 click 1 mousemove 1140 641 click 1 mousemove 1325 446 click 1 mousemove 1133 708 click 1 mousemove 1325 446 click 1 mousemove 554 442 click 1 mousemove 1325 446 click 1 mousemove 1196 585 click 1 mousemove 1325 446 click 1 mousemove 1196 648 click 1 mousemove 1325 446 click 1 mousemove 1195 711 click 1 mousemove 1325 446 click 1 mousemove 554 442 click 1 mousemove 1325 446 click 1 mousemove 1243 591 click 1 mousemove 1325 446 click 1 mousemove 1250 644 click 1 mousemove 1325 446 click 1 mousemove 1247 701 click 1 mousemove 1325 446 click 1 mousemove 554 442 click 1 mousemove 1325 446 click 1 mousemove 1301 600 click 1 mousemove 1325 446 click 1 mousemove 1301 663 click 1 mousemove 1325 446 click 1 mousemove 1313 707 click 1 mousemove 1325 446 click 1 mousemove 554 442 click 1 mousemove 1325 446 click 1 mousemove 1366 591 click 1 mousemove 1325 446 click 1 mousemove 1358 645 click 1 mousemove 1325 446 click 1 mousemove 1354 687 click 1 mousemove 1325 446 click 1 mousemove 554 442 click 1 mousemove 1325 446 click 1 mousemove 1399 600 click 1 mousemove 1325 446 click 1 mousemove 1410 637 click 1 mousemove 1325 446 click 1 mousemove 1410 710 click 1 mousemove 1325 446 click 1 mousemove 554 442 click 1 mousemove 1325 446 click 1 keyup Shift keyup y"
# craft 9×3 mineral items into blocks
alias coal="mn; xdotool keydown Shift keydown y mousemove 554 442 click 1 mousemove 1325 446 click 1 mousemove 554 442 click 1 mousemove 1325 446 click 1 mousemove 554 442 click 1 mousemove 1325 446 click 1 keyup Shift keyup y"
# break stacks of gravel in slots 2-9 and offhand with a shovel in slot 1
alias gravel="for slot in {2..9}; do for i in {1..80}; do xdotool key --delay 100 \$slot click --delay 100 1 key --delay 100 1 click --delay 100 3; done; done"
# farm crops
alias crop="xdotool keydown Shift sleep 0.1; for slot in {1..9}; do for i in {1..64}; do xdotool click --delay 8 --repeat 5 1 click --delay 1 3; done; xdotool click --delay 1 5 mouseup 1; done; xdotool sleep 0.1 click 3 sleep 0.1 keyup Shift"
# figure out which screen Minecraft is on
mcscreen(){
 export screen="$1"
 if [[ "$screen" == "" ]]; then
  pos=$(xdotool getwindowgeometry $(mc) | grep Position | sed "s/  Position\\: //;s/ \\(screen\\: 0\\)//")
  if [[ "$pos" == "0,413" ]]; then
   export screen="left"
  elif [[ "$pos" == "1920,53" || "$pos" == "1920,29" ]]; then
   export screen="right"
  elif [[ "$pos" == "0,53" ]]; then
   export screen="single"
  else
   echo "Screen not provided and couldn't be figured out! Whatever called this will probably mess up now."
   return
  fi
 fi
}
# craft the first available recipe in a crafting table's recipe book
firstcraft(){
 mcscreen "$1"
 if [[ "$screen" == "left" ]]; then
  recipe="412 763"
  output="1445 763"
 elif [[ "$screen" == "right" ]]; then
  recipe="2653 573"
  output="3685 583"
 elif [[ "$screen" == "single" ]]; then
  recipe="413 404"
  output="1445 402"
 else
  echo "Invalid screen argument! Whatever called this will probably mess up now."
  return
 fi
 xdotool keydown Shift sleep 0.1 mousemove $recipe click 1 mousemove $output sleep 0.1 click 1 keyup Shift sleep 0.1
}
# move all inventory slot 1 up (wrapping), args: "left"|"right"|"single" (screen), slot number to skip (switch with offhand instead)
invmove(){
 mcscreen "$1"
 if [[ "$screen" == "left" ]]; then
  x_list="980 1057 1123 1198 1267 1340 1411 1484 1554"
  y_list="1193 1104 1037 964 1193"
  offhand="1255 871"
 elif [[ "$screen" == "right" ]]; then
  x_list="3221 3292 3365 3436 3509 3580 3653 3725 3797"
  y_list="1011 924 850 780 1011"
  offhand="3496 692"
 elif [[ "$screen" == "single" ]]; then
  x_list="980 1057 1123 1198 1267 1340 1411 1484 1554"
  y_list="830 747 671 598 830"
  offhand="1260 516"
 else
  echo "Invalid screen argument! Whatever called this will probably mess up now."
  return
 fi
 if ! [[ "$2" == "" || "$2" =~ ^[1-9]$ ]]; then
  echo "Invalid slot number! Nothing will be skipped."
 fi
 xdotool key r sleep 0.1
 i=0
 for x in $x_list; do
  ((i++))
  for y in $y_list; do
   if ((i==0$2&&(y==1193||y==1011||y==830))); then # leading 0 against syntax error when there is no skipped slot
    xdotool mousemove $offhand click --delay 5 1
   else
    xdotool mousemove $x $y click --delay 5 1
   fi
  done
 done
 xdotool key r sleep 0.1
}
# same as above, but the offhand replaces one given slot, args: x list, y list, x to skip, y to skip, x of offhand, y of offhand
invmove_skip(){ xdotool key r sleep 0.1; for x in $1; do for y in $2; do if (( x==$3 && y==$4 )); then xdotool mousemove $5 $6 click 1; else xdotool mousemove $x $y click 1; fi; done; done; xdotool key r sleep 0.1; }
# move inventory, replace offhand instead of second hotbar slot (for gravel)
alias invmove_2_left="invmove_skip \"980 1057 1123 1198 1267 1340 1411 1484 1554\" \"1193 1104 1037 964 1193\" 1057 1193 1255 871"
alias invmove_2_right="invmove_skip \"2913 2985 3057 3128 3200 3273 3344 3416 3487\" \"1011 924 850 780 1011\" 2985 924 3496 692"
alias invmove_2_single="invmove_skip \"980 1057 1123 1198 1267 1340 1411 1484 1554\" \"830 747 671 598 830\" 1057 830 1260 516"
# break an entire inventory of gravel into flint (start with full Unbreaking 3 shovel)
allgravel(){ mn; gravel; invmove "$1" 1; gravel; invmove "$1" 1; gravel; invmove "$1" 1; gravel; }
# farm kelp with an entire inventory of bonemeal
allkelp(){ mn; hotbar 102; invmove "$1"; hotbar 102; invmove "$1"; hotbar 102; invmove "$1"; hotbar 102; }
# farm crops with an entire inventory of bonemeal
allcrop(){ mn; crop; invmove "$1"; crop; invmove "$1"; crop; invmove "$1"; crop; xdotool sleep 0.1 click 3 sleep 1 click 1; firstcraft; }
# use stacks 2..9 of bonemeal on cocoa beans
alias cocoa="mn; for s in {2..9}; do for i in {1..40}; do xdotool key \$s click 1 click 1 click 1 click 1 sleep 0.1 key 1 mousedown 3 sleep 0.3 mouseup 3; done; done"
# play Slicedlime stream in VLC
sl(){ prime-run vlc --rate 1.01 --play-and-exit $(yt-dlp -f 720p -g https://www.twitch.tv/slicedlime) & true; sleep 10; exit;}
# launch Minecraft with maximum settings
m(){ (
  rm /home/fabian/hdd/d/minecraft/options.txt
  cp /home/fabian/hdd/d/minecraft/options_max.txt /home/fabian/hdd/d/minecraft/options.txt
  if [[ "$1" == "1" ]]; then
   shift
   prime-run prismlauncher -l SL -s "mc.slicedlime.tv" -a FaRo1 $@
  else
   prime-run prismlauncher -l SL -s "mc.slicedlime.tv" -a FaRo3 $@
  fi
 ) & xdotool key q sleep 0.1 key return
}

## internet
# print public IP addresses
alias myip="wget -T5 -q -O - \"v4.kescher.at\" \"v6.kescher.at\""
# test downloaded DVD archive
7t(){ IFS=$'\n'; c "Downloads/Telegram Desktop"; for file in $(ls -1 | grep -e "\.zip$" -e "\.zip\.001$"); do 7z t "$file"; done;}
# Jisho search with (almost) no limit
alias ji="jisho -n999"
# temporary download commands until dl is done
alias dlp="yt-dlp -f \"bv*[height<=?1440]+ba/b[height<=?1440]/22/18\" --check-formats --sub-lang \"en-GB,en,en-US,de-DE,de,ja-JP,ja,ja-orig\" --embed-subs"
dlm(){ yt-dlp -q --no-warnings -i --retries infinite --fragment-retries infinite -o "%(playlist_index)04i_%(uploader)s_-_%(title)s_%(id)s.%(ext)s_temp" --restrict-filenames -f bestaudio/best --exec "file=\"{}\"; if [[ \"\$(echo \"\$file\" | grep -E \".mp3_temp\$\")\" == \"\" ]]; then ffmpeg -i \"\$file\" -nostdin -map 0:a -map_metadata -1 -v 16 -q:a 0 -y \"\${file%.*}.mp3\"; else ffmpeg -i \"\$file\" -nostdin -map 0:a -map_metadata -1 -v 16 -c:a copy -y \"\${file%_temp}\"; fi; if (( \"\$?\" == 0 )); then rm \"\$file\"; echo \"\$(date \"+%H:%M:%S\") \${file%.*}.mp3\"; else echo \"WARNING: Problem encountered while converting \$file, downloaded file was left unchanged.\"; fi" "$@"; }
# fix internet
alias net="nmcli dev wifi connect Weelaan; q"

## packages
# get packages by command name, also include the entered term, remove duplicates
pack_by_command(){
 for pack in $(ech "$* $(pacman -Qoq $@ 2>/dev/null)" | tr " " "\n" | sort -u); do
  if [[ "$(pacman -Qi "$pack" 2>/dev/null | grep "Name            \\: " | sed "s/Name            \\: //")" == "$pack" ]]; then
   echo $pack
  fi
 done
}
# Info about packages and commands: location, package+info, dependencies, (wait for enter,) owned files and all occurrences of search term
about(){
 # In the simplest case, this already shows the location.
 whereis "$@";
 # package that owns given command
 pacman -Qo "$@";
 packs="$(pack_by_command $*)";
 for i in $packs; do echo $i; done
 # a big section of general package information
 pacman -Qii $packs | grep -E -e "" -e "Description     \\: .+" -e "Required By     \\: .+";
 for pack in $packs; do
  echo "\nPackages that depend on $pack: $(pactree -lr $pack | sort -u | tr "\n" " ")";
 done;
 echo "\nEnter \"q\" or press Ctrl+Esc to exit, anything else for owned files and search";
 # wait for Enter
 read a;
 if [[ "$a" == "q" ]]; then return; fi
 for pack in $packs; do
  # List files owned by package. This should include all commands coming from that package.
  pacman -Ql $pack | grep ".*[^/]$";
  done;
 for term in "$@"; do
  echo "\nResults for $term:";
  search "$term";
 done;
}
# Uninstallation by package or command name, also deletes files
un(){ sudo pacman -Rn $(pack_by_command $*); }

## misc
# Prints the current time. Useful for scripts.
alias now="date \"+%H:%M:%S\""
# package history
pachist_helper_method_do_not_use(){ cat /var/log/pacman.log | grep -e "\\[ALPM\\] installed" -e "\\[ALPM\\] upgraded" -e "\\[ALPM\\] removed" -e "\\[ALPM\\] reinstalled" | grep -v -e yuzu-mainline-bin -e geckodriver-hg -e themix-icons-papirus-git | sed "s/ \\[ALPM\\]//";}
pachist(){ if [[ "$1" == "" ]]; then pachist_helper_method_do_not_use | tail -n 1000 | grep -P " (installed|upgraded|removed|reinstalled) \K[A-Za-z0-9\\_\\-]+"; else pachist_helper_method_do_not_use | grep "$1" | tail -n 100 | grep "$1"; fi;}
# maximum temperature of any component
alias sen="sensors coretemp-isa-0000 pch_skylake-virtual-0 acpitz-acpi-0 | grep -oE \"  \\\\+[0-9\\.]+ C\" | grep -oE \"[0-90-9\\\\.]+\" | sed \"s/\\\\.[0-9]//\" | sort -n | tail -1"
# watch maximum temperature
sens(){
  for i in {1..23}; do
  xdotool key Ctrl+plus
 done
 watch -tn1 "sensors coretemp-isa-0000 pch_skylake-virtual-0 acpitz-acpi-0 | grep -oE \"  \\+[0-9\.]+ C\" | grep -oE \"[0-9\\.]+\" | sed \"s/\\.[0-9]//\" | sort -n | tail -1"
}
# wait for a process to finish (e.g. VLC)
waitfor(){ while top -bn1 | grep -q "$1"; do sleep 1; done; }

## output uptime and boot time on console start (and for some reason randomly during package installations)
if [[ $- == *i* ]]; then echo "$(uptime -p) since $(uptime -s)", time: $(date "+%H:%M:%S"); fi