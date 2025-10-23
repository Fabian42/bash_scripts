# This file gets sourced by my actual .bashrc file that exists in both /home/fabian and /root and has the following content:
# HISTSIZE=
# HISTFILESIZE=
# export EDITOR="/usr/bin/nano"
# export VISUAL="/usr/bin/nano"
# The purpose of that is to always have these applied, even if I horribly mess up this file.

source /home/fabian/d/programs/bash_scripts/sane

## variables
export drive="/home/fabian/d"
wl_id=$(cat /home/fabian/d/programs/bash_scripts/wl_id.txt)
tm_id=$(cat /home/fabian/d/programs/bash_scripts/tm_id.txt) # so far unused

# easier to remember command for editing this file, also apply changes from file
alias aka="nano -Ll +119 /home/fabian/d/programs/bash_scripts/.bashrc; source /home/fabian/d/programs/bash_scripts/.bashrc"
# just refresh
alias ak="source /home/fabian/d/programs/bash_scripts/.bashrc"
# increase console history size from 500 to unlimited
HISTSIZE=
HISTFILESIZE=
# fix language warnings and Konsole language
source /etc/default/locale; export LC_ALL="en_GB.UTF-8"; export LANG="en_GB.UTF-8"; export LANGUAGE="en_GB.UTF-8"
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
alias e="echo -n"
# don't append useless newline, show line numbers
alias nano="nano -Ll"
# always list all files that actually exist, in better order
alias ls="ls -A --group-directories-first"
# change shutdown default duration to 0 instead of 1 minute
shutdown(){ if [[ "$1" == "" ]]; then /usr/bin/shutdown --no-wall 0; else /usr/bin/shutdown --no-wall "$@"; fi;}
# properly sync history between consoles (still requires pressing Enter to retrieve)
PROMPT_COMMAND="history -a; history -n"
# "pwd" is a stupid name for "show current path" (also expand links to full path from now on and underlines the path)
path(){ cd "$(readlink -f "$(pwd)")"; echo "\e[4m$(pwd)\e[0m";}
# all newly created files and folders have all permissions, except execution (in some way, but not another?)
umask 000
# open Dolphin in the right location, with dark theme and not as a tab
alias dolphin="dolphin . & disown"
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
 yay -Syy archlinux-keyring manjaro-keyring
 echo "y\nn\ny\n" | yay -Scc
 yay -Syyu
 to_rebuild=$(checkrebuild | sed "s/[^\\t]+\\t//" | tr "\n" " ")
 echo "REBUILDING: $to_rebuild"
 yay -S $to_rebuild
 echo "FILE ISSUES:"
 search "\\.pacnew"
 search "\\.pacsave"
}
# only the cleaning part of the above
alias space="echo \"y\nn\ny\n\" | yay -Scc"
# fix iMage "unable to write pixel cache" on large images
export TMPDIR="/var/tmp"
# restart KDE and KDE connect
alias kde="echo \"killing KDE…\"; killall -s SIGKILL plasmashell; waitfor plasmashell; echo \"restarting KDE…\"; kstart5 plasmashell & disown"
# restart the window manager when the Windows key doesn't open the start menu
alias win="kwin_x11 --replace &> /dev/null & disown; exit"
# grep ignores case and knows regex, also another copy of "stray backslash" suppression from "sane", required against conflicts between sane and .bashrc
grep(){ if [[ "$@" == *-P* ]]; then /usr/bin/grep -i --colour=auto "$@" 2>/dev/null; else /usr/bin/grep -i --colour=auto -E "$@" 2>/dev/null; fi;}
# repairs secondary Bluetooth tray icon and restarts Bluetooth
alias blu="echo \"Restarting service…\"; systemctl restart bluetooth; sleep 1; echo \"Enabling Bluetooth…\"; bluetoothctl power on; echo \"Stopping tray icon…\"; killall blueman-applet; echo \"Starting tray icon…\"; blueman-applet &> /dev/null & disown; echo \"Done!\"; exit"
# fixes more issues, but might need restart
alias blu2="echo \"Removing kernel module\"; sudo rmmod btusb; echo \"Adding kernel module\"; sudo modprobe btusb"
# restart Pulseaudio
alias pulse="systemctl --user restart pulseaudio; exit"
# stop microphone volume from changing randomly
alias mic="for i in {0..9999}; do pactl set-source-volume @DEFAULT_SOURCE@ 50%; sleep 10; done"
# create a new script file here
scr(){
 if [ -e "$1.sh" ]; then
  echo "File already exists!"
  perm "$1.sh"
  if [[ ! "$(cat "$1.sh" | head -n 1)" =~ ^\#!" "*\/bin\/bash$ ]]; then
   echo "Adding #!/bin/bash and source /home/fabian/d/programs/bash_scripts/sane"
   (echo "#!/bin/bash\nsource /home/fabian/d/programs/bash_scripts/sane"; cat "$1.sh") | sponge "$1.sh"
  fi
  sleep 1
 else
  touch "$1.sh"
  sudo chmod -R 777 "$1.sh"
  echo "#!/bin/bash\nsource /home/fabian/d/programs/bash_scripts/sane" > "$1.sh"
 fi
 nano -lL +3 "$1.sh"
}
# execute scripts with aliases and functions in .bashrc
#alias e="source"
# visudo with nano
export EDITOR="nano"
export VISUAL="nano"
# diff including subfolders
alias diff="diff -r"
# allow downgrades
#export DOWNGRADE_FROM_ALA=1
# ask before overwriting files instead of moving them
alias mv="mv -i"
# make FFMPEG not react to keyboard input, no header, use GPU
alias ffmpeg="prime-run ffmpeg -nostdin -hide_banner"
# ffprobe outputs to stdout, no banner
ffprobe(){ /usr/bin/ffprobe -hide_banner "$@" 2>&1;}
# no pager
alias journalctl="journalctl --no-pager"
alias systemctl="systemctl --no-pager"
alias coredumpctl="coredumpctl --no-pager"
# make help pages actually print to STDOUT properly
alias man="yes \"\" | man -a -P cat"
# original quality and correct colours for PNGs
alias convert="convert -quality 100 -strip -auto-orient"
# don't interrupt tasks with Ctrl+C
stty intr ^- 2>/dev/null
# restore it when necessary, in command-only mode of the system
alias linemode="stty intr ^C"
# don't suspend tasks with Ctrl+S
stty -ixon 2>/dev/null
# skip non-issues in shellcheck, list all links at bottom
alias shellcheck="shellcheck --exclude=SC2164,SC2181,SC2028,SC2010,2002,SC2162 -W 9999"
# fix mouse speed
#alias mouse="for device in \$(xinput --list | grep \"ARESON Wireless Mouse\" | grep -o \"id\\=[0-9]+\" | sed \"s/id\\=//\"); do xinput --set-prop \"\$device\" \"libinput Accel Speed\" -0.5; done; q"
# release all modifier keys and buttons, in case keys or buttons are not doing what they should be doing
alias release="sleep 1; xdotool keyup Shift keyup Alt keyup Super keyup Ctrl keyup Shift_L keyup Shift_R mouseup 1 mouseup 2 mouseup 3 mouseup 4 mouseup 5; exit"
# process uptime
alias process_uptime="ps -eo pid,lstart,cmd | grep"
# system log, $1 reboots ago
syslog(){ journalctl -o short-precise -b -"$1"; }
# disable microphone echo
alias loop="pactl unload-module module-loopback"

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
alias akac="cat /home/fabian/d/programs/bash_scripts/.bashrc | grep"
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
formathelp(){ for i in {0..123}; do echo "\e[$i""m\\\e[$i""m\e[0m"; done;}
# lowercase a string
alias lower="tr '[:upper:]' '[:lower:]'"
# yesn't
alias no="yes 'n'" #t
# unlink from a child process without having to add something after the command
#unown(){ $@ & disown;}
# insert the scaffolding of a quick function for testing
alias func="func_assist(){ xdotool type \"a(){ ; }\"; xdotool key Left key Left key Left; }; { func_assist & } 2>/dev/null; disown &>/dev/null"

## files
# create folder, ignore if already exists, create all necessary parent folders, immediately switch to it and list files
mk(){ mkdir -p "$1"; cd "$1"; path; ls;}
# "up" goes one folder up, "up n" goes n folders up
up(){ if [ "$1" == "" ]; then cd ..; else for((a=0;a<$1;a++)) do cd ..; done; fi; path; ls;}
# go to the previous directory
back(){ cd "$OLDPWD"; path; ls;}
# give all permissions to everyone for a file/folder, including subfolders
perm(){ sudo chown -R "$(whoami)" "$1"; sudo chmod -R 777 "$1"; sudo chattr -Rai "$1";}
# quick switching to "Downloads", "music", etc.
export CDPATH=".:/home/fabian:$drive"

# Go to folders and subfolders, print path and list files. Folder names do not have to be typed fully if the beginnings make a unique combination, regex also possible.
c(){
 if [[ "$1" == "" ]]; then
  cd ~ # restore ~ switching without arguments, which is broken by CDPATH containing "."
  path
  ls
  return
 fi # implied "else"
 list=("$(pwd)" "/home/fabian" "/home/fabian/d" "/")
 nl
 for arg in $(for a in $@; do echo "$a" | sed "s/\\//\\n/g"; done); do # ridiculous way to split arguments by space or slash, but not quoted space
  nl
  newlist=($(for path in "${list[@]}"; do for match in $(ls -1 "$path" | grep "^$arg$"); do if [ -d "$path/$match" ]; then echo "$path/$match"; fi; done; done) $( for path in "${list[@]}"; do for match in $(ls -1 "$path" | grep "^$arg."); do if [ -d "$path/$match" ]; then echo "$path/$match"; fi; done; done))
  if [[ "${#newlist[@]}" == 0 ]]; then
   echo "Warning: No match found, staying here!"
   cd "${list[0]}"
   path
   ls
   return
  fi # implied "else"
  list=(${newlist[@]})
 done
 if (( ${#list[@]} > 1 )); then
  echo "multiple matches: ${list[@]}"
 fi
 cd "${list[0]}"
 path
 ls
}

# quickly switch to "bash_scripts" repository
alias g="c /home/fabian/d/programs/bash_scripts"

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
 path
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
#   if [[ "new" == "" ]]; then echo "set to 0"; new=0; fi
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
 if [[ "$1" == "keep" ]]; then keep=1; shift; fi
 for file in "$@"; do
  # expand links to full path
  file="$(readlink -f "$file")"
  # filename without path
  name="$(basename "$file")"
  if [[ "$(echo "$file" | grep -E ".mp3$")" == "" ]]; then
   ffmpeg -i "$file" -nostdin -map 0:a:0 -map_metadata -1 -v 16 -acodec libmp3lame -q:a 0 "${name%.*}.mp3"
   if(($?==0&&keep!=1)); then
    del "$file"
   else
    echo "Error encountered, $file kept." 1>&2
   fi
  else
   # path without filename
   path="${file%$name}"
   mv "$file" "$path""old_$name"
   ffmpeg -i "$path""old_$name" -nostdin -map 0:a -map_metadata -1 -v 16 -c:a copy "$name"
   if(($?==0&&keep!=1)); then
    del "$path""old_$name"
   else
    echo "Error encountered, $path""old_$name kept." 1>&2
   fi
  fi
 done
}

# usual Git workflow to upload local changes
alias commit="git diff; git add -A .; git status; read -p \"Press Enter to continue.\"; git commit --no-status; git push"
# print subtitles from video
subs(){
 stream=0
 for lang in $(ffprobe "$1" 2>&1 | grep "Subtitle" | grep -Eo "  Stream \\#0\\:[0-9]+(\\[[0-9]x[0-9]\\])?\\([a-z]+" | sed "s/  Stream \\#0\\:[0-9]+\\(//"); do
  echo "\nSubtitles #"$stream", language: "$lang
  ffmpeg -i "$1" -map 0:s:$stream -f srt - -v 16 | grep -v -E -e "^[0-9\\:\\,]{12} \-\-> [0-9\\:\\,]{12}$" -e "^[0-9]+$" -e "^$" | sed "s/\\\\h//g"
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
alias vlc="fix_lang prime-run vlc --play-and-exit --no-random --no-loop --no-repeat"
# util function for ff4 to divide a given timestamp by 4
div_time4(){
 sec_in="$(echo "$1" | grep -o "[0-9\\.]+$")"
 rest="$(echo "$1" | sed "s/\\:?[0-9\\.]+$//")"
 min_in="$(echo "$rest" | grep -o "[0-9]+$")"
 hour_in="$(echo "$rest" | sed "s/\\:?[0-9]+$//")"
 hour="$((hour_in/4))"
 min="$((min_in/4+(hour_in%4*15)))"
 sec="$(qalc -t "$sec_in/4+(0$min_in%4*15)")"
 echo "$hour:$min:$sec" # everything works out to be "0:0:x" if input is shorter format
}
# speed up video 4×
ff4(){
 # splitting off options and option parameters fixed quoting issues, otherwise FFMPEG would see "-ss 0:0:0" as a single argument
 start_prefix=""
 end_prefix=""
 if [[ "$2" != "" ]]; then
  start_prefix="-ss"
  start="$(div_time4 "$2")"
  if [[ "$3" != "" ]]; then
   end_prefix="-to"
   end="$(div_time4 "$3")"
  fi
 fi
 ffmpeg -i "$1" $start_prefix $start $end_prefix $end -vf "setpts=PTS/4" -af "atempo=2,atempo=2" -map_metadata -1 -map_chapters -1 "a4_$1"
 unset start end
}

# pack files in most compatible way: zip, no compression, file size <2000MiB for Telegram, test afterwards
zp(){
 # First argument is archive name without ".zip" or ".zip.001" etc., second is limit (t=Telegram, d=discord), others are files to be packed. If omitted, name is folder name and files are auto-selected: all files in current folder that are not subfolders or already archives
 if [[ "$1" == "" ]]; then
  out_name="$(basename "$(readlink -f .)")"
 else
  out_name="$1"
 fi
 shift
 if [[ "$1" == "t" || "$1" == "" ]]; then
  limit=2097152000
 elif [[ "$1" == "d" ]]; then
  limit=10485760
 else
  limit="$1"
 fi
 shift
 if [[ "$@" == "" ]]; then
  if [ -d "$out_name" ]; then
   files="$out_name"
  else
   files=()
   for file in *; do
    type="$(file "$file")"
    # exclude already packed files, subfolders and symlinks
    if ! [[ "$file" =~ .+\.(zip|7t)\.[0-9][0-9][0-9] || "$type" =~ .+" "(directory|"archive data").* || "$type" =~ .+" symbolic link to ".+ ]]; then
     files+=("$file")
    fi
   done
  fi
 else
  files=("$@")
 fi
 # split archive into Telegram-compatible files, if necessary
 size=0
 for file in "${files[@]}"; do
  ((size+=$(du -PsB1 "$file" | sed "s/[ \\t].+//")))
 done
 # conditional parameters: split archive into Telegram-compatible files if necessary, delete original files if it's a DVD backup and packing succeeded
 7z a -mx0 $(if (( size > limit )); then echo "-v""$limit""b"; fi) $(if [[ "$(readlink -f .)" == "/home/fabian/Desktop/DVD" ]]; then echo "-sdel"; fi) "$out_name".zip "${files[@]}"
}
# Make a huge image out of text, to see all the details. First argument is text, second can be "order" for the "Kanji stroke orders" font
render_kanji(){ if [[ "$2" == "order" ]]; then font="/usr/share/fonts/TTF/KanjiStrokeOrders_v4.004.ttf"; else font="/usr/share/fonts/TTF/Cica-Regular.ttf"; fi; convert -monitor -define registry:temporary-path=/home/fabian/temp -limit memory 8gb -background black -fill white -pointsize 4096 -font "$font" label:"$1" render_kanji.png;}
# concatenate videos with identical encoding settings, last argument is output
concat(){ out="${@:$#:$#}"; files="/tmp/$(date "+%Y-%m-%dT%H:%M:%S")"; touch "$files"; for file in ${@:1:$#-1}; do echo "file '$(readlink -f "$file")'" >> "$files"; done; ffmpeg -f concat -safe 0 -i "$files" -c copy "$out"; rm "$files";}
# phone alarm replacement
alarm(){ sleep "$1"; cd /home/fabian/d/music; xdotool key Ctrl+Alt+Shift+i; sleep 60; fix_lang prime-run vlc --play-and-exit -Z --loop --no-repeat --extraintf=rc --rc-host 192.168.2.55:9999 animusic/a_retro.mp3 animadrop/ad_escapism.mp3 animadrop/ad_mach.mp3 animadrop/ad_thursday.mp3 audiomachine/am_penumbra.mp3 acuticnotes/an_antares.mp3 acuticnotes/an_dark.mp3 acuticnotes/an_way.mp3 arkana/arkana_chronosphere.mp3 arkana/arkana_iskatallith.mp3 arkana/arkana_nihilum.mp3 arkana/arkana_sof.mp3 arkana/arkana_vector.mp3 arkasia/arkasia_analogic.mp3 arkasia/arkasia_born.mp3 arkasia/arkasia_bullet.mp3 arkasia/arkasia_cloud.mp3 arkasia/arkasia_clouds.mp3 arkasia/arkasia_ethereality.mp3 arkasia/arkasia_extinction.mp3 arkasia/arkasia_fight.mp3 arkasia/arkasia_haruspex.mp3 arkasia/arkasia_heads.mp3 arkasia/arkasia_intravenous.mp3 arkasia/arkasia_kraken.mp3 arkasia/arkasia_open.mp3 arkasia/arkasia_out_of_reach.mp3 arkasia/arkasia_phantasia.mp3 arkasia/arkasia_phoenix_1.mp3 arkasia/arkasia_polymorph.mp3 arkasia/arkasia_revelation.mp3 arkasia/arkasia_shatter.mp3 arkasia/arkasia_shieldren.mp3 arkasia/arkasia_space.mp3 arkasia/arkasia_time.mp3 arkasia/arkasia_without.mp3 au5/au5_sweet.mp3 big_giant_circles/bgc_cumulo_nimblers.mp3 big_giant_circles/bgc_legacy.mp3 big_giant_circles/bgc_muppet.mp3 big_giant_circles/bgc_sevcon.mp3 big_giant_circles/bgc_throwing.mp3 big_giant_circles/bgc_yeah.mp3 ben_moon/bm_empire.mp3 ben_moon/bm_turning_point.mp3 blue_stahli/bs_metamorphosis.mp3 blue_stahli/bs_over.mp3 caspro/caspro_halloween.mp3 caspro/caspro_reset.mp3 carpenter_brut/cb_hang.mp3 carpenter_brut/cb_le.mp3 carpenter_brut/cb_mine.mp3 carpenter_brut/cb_paradise.mp3 chris_haigh/ch_vindicator.mp3 crinkles/crinkles_fervor.mp3 doctor_who/dw_doctor_5.mp3 doctor_who/dw_grave.mp3 dance_with_the_dead/dwtd_andromeda.mp3 dance_with_the_dead/dwtd_diabolic.mp3 dance_with_the_dead/dwtd_dream.mp3 dance_with_the_dead/dwtd_madness.mp3 dance_with_the_dead/dwtd_riot.mp3 dance_with_the_dead/dwtd_screams_whispers.mp3 dance_with_the_dead/dwtd_snap.mp3 dance_with_the_dead/dwtd_war.mp3 dance_with_the_dead/dwtd_watching.mp3 eric_skiff/es_find.mp3 feint/feint_clockwork.mp3 feint/feint_eyes.mp3 feint/feint_formless.mp3 faux_tales/ft_shadows.mp3 geometry/gd_base.mp3 geometry/gd_geometrical.mp3 hans_zimmer/hz_dream.mp3 lukhash/lh_giana.mp3 lukhash/lh_highland.mp3 lukhash/lh_museum.mp3 lukhash/lh_requiem.mp3 linkin_park/lp_session.mp3 lena_raine/lr_summit.mp3 electronic/mux_mool_get_better_john.mp3 punch_deck/pd_more.mp3 plini/plini_cascade.mp3 plini/plini_cloudburst.mp3 nintendo/pokemon_cynthia.mp3 pacific_rim/pr_pacific_rim.mp3 really_slow_motion/rsm_era.mp3 really_slow_motion/rsm_fruit.mp3 really_slow_motion/rsm_mechanical.mp3 sizzlebird/sb_clarus.mp3 sizzlebird/sb_nebula.mp3 sizzlebird/sb_origins.mp3 sizzlebird/sb_sol.mp3 sizzlebird/sb_swing.mp3 nintendo/smg_buoy.mp3 nintendo/smg_credits_2.mp3 nintendo/smg_fleet.mp3 nintendo/smg_generator.mp3 nintendo/smg_melt.mp3 nintendo/smg_station.mp3 sentient_pulse/sp_climb.mp3 sentient_pulse/sp_echoes.mp3 star_trek/st_enterprise.mp3 two_steps_from_hell/tb_highway.mp3 toby_fox/tf_asgore.mp3 toby_fox/tf_dummy.mp3 toby_fox/tf_field.mp3 toby_fox/tf_give.mp3 toby_fox/tf_hero.mp3 toby_fox/tf_hopes.mp3 tiasu/tiasu_fault.mp3 tiasu/tiasu_phantom.mp3 tiasu/tiasu_pulse.mp3 venator/venator_elapse.mp3 xi/xi_anima.mp3 xi/xi_freedom.mp3 xi/xi_galaxies.mp3 xi/xi_heaven.mp3 xi/xi_siva.mp3 xi/xi_tiferet.mp3 xi/xi_transmission.mp3 xi/xi_world_fragments_1.mp3 xi/xi_world_fragments_2.mp3 zircon/zircon_baroque.mp3 zircon/zircon_necromancy.mp3 zircon/zircon_prism.mp3 &> /dev/null & disown; sleep 1; { vol=0; while ((vol<512)); do echo "volume ""$((vol+=4))"; sleep 1; done } | telnet 192.168.2.55 9999; }

## searches
# search files everywhere, ignoring case, partial file name, avoid most of the usual "permission denied" error messages and hide the rest
search(){ sudo find / -iwholename "*$1*" 2> /dev/null | sort | grep -i "$1";}
# same as above, but only in the current folder and subfolders and not as root and not hiding errors
here(){ if [[ "$1" == "" ]]; then find . | sort; else find . -regextype grep -iwholename "*$1*" | sort | grep -i "$1"; fi; }
# same as above, but as root
shere(){ sudo find . -iwholename "*$1*" | grep -i "$1";}
# trash all files for search term
delhere(){ nl; del $(here "$1");}
# Play all tracks from my music collection randomly with VLC that match the search terms and close the console. If no search term is entered, randomise the entire collection, but not a0.
p(){
 if [[ "$1" == "" ]]; then
  files="$(find $drive/music/a1 $drive/music/a2 $drive/music/a3 $drive/music/a4 $drive/temp_music/a0_keep | sort -u)"
 else
  files="$(find $drive/music/a0 $drive/music/a1 $drive/music/a2 $drive/music/a3 $drive/music/a4 $drive/temp_music/a0_keep -iname "*$1*" | sort -u)"
 fi
 (fix_lang prime-run vlc --play-and-exit -Z --loop --no-repeat $files &> /dev/null & disown)
 exit
}

## Minecraft
# get a window ID for a multiplayer Minecraft window
mc(){
 for id in $(xdotool search --name "Minecraft\\* [0-9\\.]+ \\- マルチプレイ\\（サードパーティーのサーバー\\）")$(xdotool search --name "Minecraft\\* [0-9\\.]+ \\- Multiplayer \\(3rd\\-party [Ss]erver\\)")$(xdotool search --name "Minecraft\\* [0-9\\.]+ \\- Playing with yer mates \\(3rd\\-party [Ii]sland\\)")$(xdotool search --name "FaRo[13] on SL"); do
  if [[ ! "$(xdotool getwindowname "$id")" =~ .*CopyQ.* ]]; then
   echo "$id"
  fi
 done | tail -n 1
}
# minimize the console window before doing anything else
alias mn="xdotool getactivewindow windowminimize; sleep 1; xdotool key Escape"
# filter latest Minecraft log
log2(){ cat /home/fabian/d/minecraft/logs/latest.log | grep -i "$1";}
# same, but only relevant chat messages
log(){ cat /home/fabian/d/minecraft/logs/latest.log | grep -E "^\\[[0-9][0-9]\\:[0-9][0-9]\\:[0-9][0-9]\\] \\[(main|Render thread|Client thread)\\/INFO\\]\\: \\[CHAT\\] " | grep -v -e "o/" -e "tartare" -e "hello" -e "\\bhi\\b" -e "☻/" -e "\\\\o" -e "heyo" -e "i'm off" -e "gtg" -e "bye" -e "cya" -e "Good morning! If you'd like to be awake through the coming night, click here." -e "left the game" -e "joined the game" -e "just got in bed." -e "Unknown or incomplete command\\, see below for error" -e "\\/<\\-\\-\\[HERE\\]" -e "\\[Debug\\]: " -e "がゲームに参加しました" -e "がゲームを退出しました" -e "［デバッグ］： " -e "スクリーンショットを" -e "Now leaving " -e "Now entering " | grep -i "$1" | sed "s/^\\[([0-9][0-9]\\:[0-9][0-9]\\:[0-9][0-9])\\] \\[(main|Render thread)\\/INFO\\]\: \\[CHAT\\] <([^>]+)>/\\1 \\3:/;s/^\\[[0-9][0-9]\\:[0-9][0-9]\\:[0-9][0-9]\\] \\[(main|Render thread)\\/INFO\\]\\: \\[CHAT\\] //" | grep -vE "^[0-9\\:]+ <[A-Za-z0-9\\_\\-]+> (io|oi|hey|wb)$" | grep -i "$1";}
# annual compression:
# nl; for file in 2023*; do date="$(echo "$file" | grep -o "^[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]")"; for line in $(cat $file | grep -E "^\\[[0-9][0-9]\\:[0-9][0-9]\\:[0-9][0-9]\\] \\[(main|Render thread|Client thread)\\/INFO\\]\\: \\[CHAT\\] " | grep -v -e "o/" -e "tartare" -e "hello" -e "\\bhi\\b" -e "☻/" -e "\\\\o" -e "heyo" -e "i'm off" -e "gtg" -e "bye" -e "cya" -e "Good morning! If you'd like to be awake through the coming night, click here." -e "left the game" -e "joined the game" -e "just got in bed." -e "Unknown or incomplete command\\, see below for error" -e "\\/<\\-\\-\\[HERE\\]" -e "\\[Debug\\]: " -e "がゲームに参加しました" -e "がゲームを退出しました" -e "［デバッグ］： " -e "スクリーンショットを" -e "Now leaving " -e "Now entering " | sed "s/^\\[([0-9][0-9]\\:[0-9][0-9]\\:[0-9][0-9])\\] \\[(main|Render thread)\\/INFO\\]\: \\[CHAT\\] <([^>]+)>/\\1 \\3:/;s/^\\[[0-9][0-9]\\:[0-9][0-9]\\:[0-9][0-9]\\] \\[(main|Render thread)\\/INFO\\]\\: \\[CHAT\\] //" | grep -vE "^[0-9\\:]+ <[A-Za-z0-9\\_\\-]+> (io|oi|hey|wb)$"); do echo "$date $line"; done; done > chat2023.txt
# use all items on a full hotbar, optional argument of clicks per slot
hotbar(){ max=70; if [[ "$1" =~ ^[0-9]+$ ]]; then max=$1; fi; for slot in {1..9}; do i=0; while ((i++<max)); do xdotool click --delay 50 1; done; xdotool click 5; done;}
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
  pos="$(xdotool getwindowgeometry $(mc) | grep Position | sed "s/  Position\\: //;s/ \\(screen\\: 0\\)//")"
  if [[ "$pos" == "0,412" ]]; then
   export screen="left"
  elif [[ "$pos" == "1920,58" || "$pos" == "1920,29" || "$pos" == "1920,28" ]]; then
   export screen="right"
  elif [[ "$pos" == "0,58" ]]; then
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
 elif [[ "$screen" == "single" ]]; then # already adjusted for nova single
  x_list="1304 1376 1449 1516 1594 1663 1736 1810 1881"
  y_list="1018 932 858 786 1018"
  offhand="1577 694"
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
 xdotool key r sleep 0.1 key Escape sleep 0.1 key Escape sleep 0.1
}
# same as above, but the offhand replaces one given slot, args: x list, y list, x to skip, y to skip, x of offhand, y of offhand
invmove_skip(){ xdotool key r sleep 0.1; for x in $1; do for y in $2; do if (( x==$3 && y==$4 )); then xdotool mousemove $5 $6 click 1; else xdotool mousemove $x $y click 1; fi; done; done; xdotool key r sleep 0.1;}
# move inventory, replace offhand instead of second hotbar slot (for gravel)
alias invmove_2_left="invmove_skip \"980 1057 1123 1198 1267 1340 1411 1484 1554\" \"1193 1104 1037 964 1193\" 1057 1193 1255 871"
alias invmove_2_right="invmove_skip \"2913 2985 3057 3128 3200 3273 3344 3416 3487\" \"1011 924 850 780 1011\" 2985 924 3496 692"
alias invmove_2_single="invmove_skip \"980 1057 1123 1198 1267 1340 1411 1484 1554\" \"830 747 671 598 830\" 1057 830 1260 516"
# break an entire inventory of gravel into flint (start with full Unbreaking 3 shovel)
allgravel(){ mn; gravel; invmove "$1" 1; gravel; invmove "$1" 1; gravel; invmove "$1" 1; gravel;}
# farm kelp with an entire inventory of bonemeal
allkelp(){ mn; hotbar 102; invmove "$1"; hotbar 102; invmove "$1"; hotbar 102; invmove "$1"; hotbar 102;}
# farm crops with an entire inventory of bonemeal
allcrop(){ mn; crop; invmove "$1"; crop; invmove "$1"; crop; invmove "$1"; crop; xdotool sleep 0.1 click 3 sleep 1 click 1; firstcraft;}
# use stacks 2..9 of bonemeal on cocoa beans
alias cocoa="mn; for s in {2..9}; do for i in {1..40}; do xdotool key \$s click 1 click 1 click 1 click 1 sleep 0.1 key 1 mousedown 3 sleep 0.3 mouseup 3; done; done"
# drink 27 water bottles from the main inventory
alias drink="mn; invmove; for j in {1..3}; do for i in {1..9}; do xdotool mousedown 1 sleep 2 mouseup 1 click 5; done; invmove; done"
# play Slicedlime stream in VLC
sl(){ fix_lang prime-run vlc --rate 1.01 --play-and-exit --no-random --no-loop --no-repeat "$(yt-dlp -f "best.2/best" -g --cookies-from-browser "firefox" "https://www.twitch.tv/$(if [[ "$1" == "" ]]; then echo "slicedlime"; else echo "$1"; fi)")" & true; sleep 10; exit;}
# launch Minecraft
m(){ (
#  rm /home/fabian/d/minecraft/options.txt
#  cp /home/fabian/d/minecraft/options_max.txt /home/fabian/d/minecraft/options.txt
  if [[ "$1" == "1" ]]; then
   shift
   prime-run prismlauncher -l SL1 -s "mc.slicedlime.tv" -a FaRo1 $@
  else
   prime-run prismlauncher -l SL2 -s "mc.slicedlime.tv" -a FaRo3 $@
  fi
 ) & xdotool key q sleep 0.1 key return
}

## internet
# print public IP addresses
alias myip="wget -T5 -q -O - \"v4.kescher.at\" \"v6.kescher.at\""
# test downloaded DVD archive
#7t(){ IFS=$'\n'; c "/home/fabian/Downloads/Telegram Desktop"; for file in $(ls -1 | grep -e "\\.zip$" -e "\\.zip\\.001$"); do 7z t "$file"; done;}
# Jisho search with (almost) no limit
alias ji="jisho" # -n999"
# temporary download commands until dl is done
alias dlp="yt-dlp -f \"bv*[height<=?1440]+ba/b[height<=?1440]/22/18\" --sub-lang \"en-GB,en,en-US,de-DE,de,ja-JP,ja,ja-orig\" --embed-subs --use-postprocessor \"DeArrow:when=pre_process\""
dlm(){ yt-dlp -o "%(playlist_index|0001)04i_%(uploader).31s_-_%(title).63s_%(id)s.%(ext)s_temp" -f bestaudio/best --no-embed-chapters --no-exec --exec "file=\"{}\"; if [[ \"\$(echo \"\$file\" | grep -E \".mp3_temp\$\")\" == \"\" ]]; then ffmpeg -i \"\$file\" -nostdin -map 0:a -map_metadata -1 -v 16 -q:a 0 -y \"\${file%.*}.mp3\"; else ffmpeg -i \"\$file\" -nostdin -map 0:a -map_metadata -1 -v 16 -c:a copy -y \"\${file%_temp}\"; fi; if (( \"\$?\" == 0 )); then rm \"\$file\"; echo \"\$(date \"+%H:%M:%S\") \${file%.*}.mp3\"; else echo \"WARNING: Problem encountered while converting \$file, downloaded file was left unchanged.\"; fi" "$@";}
alias d="c v wl; dlp"
# fix internet
#alias net="nmcli dev wifi connect Weelaan; q"

## packages
# get packages by command name, also include the entered term, remove duplicates
pack_by_command(){
 for pack in $(ech "$* $(pacman -Qoq $(whereis $@ | sed "s/\\://" | tr ' ' '\n') 2>/dev/null)" | tr " " "\n" | sort -u); do # no idea why tr is necessary
  if [[ "$(pacman -Qi "$pack" 2>/dev/null | grep "Name            \\: " | sed "s/Name            \\: //")" == "$pack" ]]; then
   echo "$pack"
  fi
 done
}
# Info about packages and commands: location, package+info, dependencies, (wait for enter,) owned files and all occurrences of search term
about(){
 # In the simplest case, this already shows the location.
 whereis "$@"
 # package that owns given command
 pacman -Qo "$@"
 packs="$(pack_by_command $*)"
 if [[ "$packs" == "" ]]; then return; fi
 for i in $packs; do echo $i; done
 # a big section of general package information
 pacman -Qii $packs | grep -E -e "" -e "Description     \\: .+" -e "Required By     \\: .+"
 for pack in $packs; do
  echo "\nPackages that depend on $pack: $(pactree -lr $pack | sort -u | tr "\n" " ")"
 done
 echo "\nEnter \"q\" or press Ctrl+Esc to exit, anything else for owned files and search"
 # wait for Enter
 read a
 if [[ "$a" == "q" ]]; then return; fi
 for pack in $packs; do
  # List files owned by package. This should include all commands coming from that package.
  pacman -Ql $pack | grep ".*[^/]$"
  done
 for term in "$@"; do
  echo "\nResults for $term:"
  search "$term"
 done
}
# Uninstallation by package or command name, also deletes files
un(){ sudo pacman -Rn $(pack_by_command $*);}
# move Discord config files to new location after package upgrade, because updater is disabled via mod, because it often refuses to start otherwise
#fixdiscord(){ cd /home/fabian/.config/discord; version="$(ls -1 | grep "^0\\.0\\.")"; mv "$version" "0.0.$(($(echo "$version" | sed "s/0\\.0\\.//")+1))"; un openasar-git; yay -S discord; yay -S openasar-git;}

## misc
# Prints the current time. Useful for scripts.
alias now="date \"+%H:%M:%S\""
# package history
pachist_helper(){ cat /var/log/pacman.log | grep -e "\\[ALPM\\] installed" -e "\\[ALPM\\] upgraded" -e "\\[ALPM\\] removed" -e "\\[ALPM\\] reinstalled" | grep -v -e yuzu-mainline-bin -e geckodriver-hg -e themix-icons-papirus-git | sed "s/ \\[ALPM\\]//";}
pachist(){ if [[ "$1" == "" ]]; then pachist_helper | tail -n 1000 | grep -P " (installed|upgraded|removed|reinstalled) \K[A-Za-z0-9\\_\\-]+"; else pachist_helper | grep "$1" | tail -n 100 | grep "$1"; fi;}
# maximum temperature of any component
sen(){ sensors coretemp-isa-0000 iwlwifi_1-virtual-0 nvme-pci-6c00 acpitz-acpi-0 | grep -oE "  \\+[0-9\\.]+" | grep -oE "[0-9\\.]+" | sed "s/\\.[0-9]//" | sort -n | tail -1;}
# watch maximum temperature
sens(){
  for i in {1..23}; do
  xdotool key Ctrl+plus
 done
 watch -tn1 "/usr/bin/bash -c \"source \"\"$drive\"\"/programs/bash_scripts/.bashrc; sen\""
}
# wait for a process to finish (e.g. VLC)
waitfor(){ while top -bn1 -w512 | grep -v "grep" | grep -q "$1"; do sleep 1; done;}
# show top GPU usage processes
alias gtop="nvidia-smi"
# generate a random pronouncable name
random_name(){
 if [[ "$1" =~ ^[0-9]+$ ]]; then syllables=$1; else syllables=3; fi
 while ((syllables--)); do
  c="$(($RANDOM%20))"
  v="$(($RANDOM%5))"
  if [ $c = 0 ]; then e b; elif [ $c = 1 ]; then e c; elif [ $c = 2 ]; then e d; elif [ $c = 3 ]; then e f; elif [ $c = 4 ]; then e g; elif [ $c = 5 ]; then e h; elif [ $c = 6 ]; then e j; elif [ $c = 7 ]; then e k; elif [ $c = 8 ]; then e l; elif [ $c = 9 ]; then e m; elif [ $c = 10 ]; then e n; elif [ $c = 11 ]; then e p; elif [ $c = 12 ]; then e r; elif [ $c = 13 ]; then e s; elif [ $c = 14 ]; then e t; elif [ $c = 15 ]; then e v; elif [ $c = 16 ]; then e w; elif [ $c = 17 ]; then e x; elif [ $c = 18 ]; then e y; elif [ $c = 19 ]; then e z; fi
  if [ $v = 0 ]; then e a; elif [ $v = 1 ]; then e e; elif [ $v = 2 ]; then e i; elif [ $v = 3 ]; then e o; elif [ $v = 4 ]; then e u; fi
 done
 echo
}

## output uptime and boot time on console start (and for some reason randomly during package installations)
if [[ $- == *i* ]]; then echo "$(uptime -p) since $(uptime -s), time: $(date "+%H:%M:%S")"; fi