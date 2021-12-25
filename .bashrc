source /home/fabian/hdd/d/programs/bash_scripts/sane
# This file gets sourced by my actual .bashrc file that exists in both /home/fabian and /root and has the following content:
# # increase console history size from 500 to unlimited
# HISTSIZE=
# HISTFILESIZE=
# # visudo etc. with nano
# export EDITOR="/usr/bin/nano"
# export VISUAL="/usr/bin/nano"
# # everything else
# source /home/fabian/hdd/d/programs/bash_scripts/.bashrc
# The purpose of that is to always have these applied, even if I horribly mess up this file.

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

# TODO: extract longer functions into separate scripts
# TODO: understand and customise this preinstalled default section

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
shutdown(){ if [ "$1" == "" ]; then /usr/bin/shutdown --no-wall 0; else /usr/bin/shutdown --no-wall "$@"; fi;}
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
alias magic="sudo pacman-mirrors --continent --api --protocols https http ftp --set-branch stable && sudo pacman-key --refresh-keys; yay -Scc && yay -Syyu"
# only the cleaning part of the above
alias space="echo \"y\nn\ny\n\" | yay -Scc"
# fix iMage "unable to write pixel cache" on large images
export TMPDIR="/var/tmp"
# restart KDE and KDE connect
alias kde="killall plasmashell; killall kdeconnectd; kstart5 plasmashell &> /dev/null & disown; /usr/lib/kdeconnectd &> /dev/null & disown; exit"
# restart the window manager when the Windows key doesn't open the start menu
alias win="kwin_x11 --replace &> /dev/null & disown; exit"
# grep ignores case
alias grep="grep -i --colour=auto"
# repairs secondary Bluetooth tray icon
alias blu="killall blueman-applet; (blueman-applet &> /dev/null & disown); exit"
# restart PulseAudio
alias pulse="systemctl --user restart pulseaudio.service; exit"
# stop microphone volume from changing randomly
alias mic="for i in {0..9999}; do pactl set-source-volume @DEFAULT_SOURCE@ 100%; sleep 10; done"
# create a new script file here
scr(){
 if [ -e "$1.sh" ]; then
  echo "File already exists!"
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
 nano -lL +2 "$1.sh"
}
# execute scripts with aliases and functions in .bashrc
alias e="source"
# visudo with nano
export EDITOR="nano"
# diff including subfolders
alias diff="diff -r"
# allow downgrades
export DOWNGRADE_FROM_ALA=1
# ask before overwriting files instead of moving them
alias mv="mv -i"
# no header in ffprobe
alias ffprobe="ffprobe -hide_banner"
# make FFMPEG not react to keyboard input, also no header
alias ffmpeg="ffmpeg -nostdin -hide_banner"
# print syslog properly
alias journalctl="journalctl --no-pager"
# normal output of systemctl
alias systemctl="systemctl --no-pager"
# make help pages actually print to STDOUT properly
alias man="man -P cat"
# original quality and correct colours for PNGs
alias convert="convert -quality 0 -strip"
# don't interrupt tasks with Ctrl+C
stty intr ^-
# don't suspend tasks with Ctrl+S
stty -ixon
# skip non-issues in shellcheck, list all links at bottom
alias shellcheck="shellcheck --exclude=SC2164,SC2181,SC2028,SC2010,2002,SC2162 -W 9999"

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
# TODO: move to correct folder for files on HDD
# TODO: delete older/big files if maximum trash size reached, but prefer deleting newer gigantic files in extreme cases, find proper balance
# TODO: cause Dolphin to not grey out "empty bin" anymore (how?)
del(){
 for file in "$@"; do
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
# TODO: proper ffprobe check instead of ".mp3"  
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
alias commit="git diff; git add .; git status; read -p \"Press Enter to continue.\"; git commit; git push"

## searches
# search console history
h(){ if [[ "$1" == "" ]]; then history | tail -n 100; else history | grep -i "$@" | tail -n 100 | grep -i "$@"; fi;}
# search console history, no 100 entries limit
hi(){ if [[ "$1" == "" ]]; then history; else history | grep -i "$@" | grep -i "$@"; fi;}
# TODO: replace "find" aliases with "locate"
# search files everywhere, ignoring case, partial file name, avoid most of the usual "permission denied" error messages and hide the rest
search(){ sudo find / -iwholename "*$1*" 2> /dev/null | sort | grep -i "$1";}
# same as above, but only in the current folder and subfolders and not as root and not hiding errors
here(){ find . -iwholename "*$1*" | sort | grep -i "$1";}
# same as above, but as root
shere(){ sudo find . -iwholename "*$1*" | grep -i "$1";}
# plays all track from my music collection randomly with VLC that match the search term and exits the console
p(){ (vlc --play-and-exit -Z $(find $drive/music/a1/* $drive/music/a2/* $drive/music/a3/* $drive/music/a4/* -iname "*$1*") &> /dev/null & disown); exit;}
# trash all files for search term
delhere(){ IFS=$'\n'; del "$(here "$1")";}

## Minecraft
# filter latest Minecraft log
log(){ cat $drive/minecraft/logs/latest.log | grep -i "$1";}
# same, but only relevant chat messages
log2(){ cat $drive/minecraft/logs/latest.log | grep -E "^\\[[0-9][0-9]\\:[0-9][0-9]\\:[0-9][0-9]\\] \\[(main|Render thread)\\/INFO\\]\\: \\[CHAT\\] " | grep -v -e "o/" -e "tartare" -e "hello" -e "\\bhi\\b" -e "☻/" -e "\\\\o" -e "heyo" -e "i'm off" -e "gtg" -e "bye" -e "Good morning! If you'd like to be awake through the coming night, click here." -e "left the game" -e "joined the game" -e "just got in bed." -e "Unknown or incomplete command\\, see below for error" -e "\\/<\\-\\-\\[HERE\\]" -e "\\[Debug\\]: " -e "がゲームに参加しました" -e "がゲームを退出しました" -e "［デバッグ］： " | grep -i "$1" | sed "s/^\\[[0-9][0-9]\\:[0-9][0-9]\\:[0-9][0-9]\\] \\[(main|Render thread)\\/INFO\\]\\: \\[CHAT\\] //" | grep -v -E -e "^<[A-Za-z0-9\\_\\-]+> (io|oi)$" -e "^Now leaving " -e "^Now entering " | grep -i "$1";}
# use all items on a full hotbar
alias hotbar="xdotool getactivewindow windowminimize; for slot in {1..9}; do for i in {1..64}; do xdotool click 1; done; xdotool click 5; done; q"
# play Slicedlime stream in VLC
sl(){ vlc --play-and-exit $(youtube-dl -f 720p -g https://www.twitch.tv/slicedlime) & true; sleep 10; exit;}
# get a window ID for a multiplayer Minecraft window
mc(){
 for id in $(xdotool search --name "Minecraft\\* [0-9\\.]+ \\- マルチプレイ\\（サードパーティーのサーバー\\）")$(xdotool search --name "Minecraft\\* [0-9\\.]+ \\- Multiplayer \\(3rd\\-party [Ss]erver\\)"); do
  if [[ ! "$(xdotool getwindowname "$id")" =~ .*CopyQ.* ]]; then
   echo "$id"
   break
  fi
 done
 }

## miscellaneous
# print public IP addresses
alias myip="wget -q -O - \"v4.kescher.at\" \"v6.kescher.at\""
# quit
alias q="exit"
# forget commands starting with a space
HISTCONTROL=ignorespace
# show time in history
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
# directory name autocorrect
shopt -s cdspell
# switching to directories without "cd"
shopt -s autocd
# ignore consecutive duplicate commands, anything that starts with a space and some specific commands in history and up-arrow list
HISTIGNORE="&: :q:q *:aka:kde:win:pulse:blu"
# Only split on newlines for "for" loops, not on spaces from now on.
alias nl="IFS=$'\n'"
# Uninstallation by package or command name, also deletes files
un(){ sudo pacman -Rn $(for pack in $(ech "$* $(pacman -Qoq $@ &> /dev/null)" | tr " " "\n" | sort -u); do if pacman -Qi "$pack" &> /dev/null; then echo $pack; fi; done);}
# Prints the current time. Useful for scripts.
alias now="date \"+%H:%M:%S\""
# test downloaded DVD archive
7t(){ IFS=$'\n'; c "Downloads/Telegram Desktop"; for file in $(ls -1 | grep -e "\.zip$" -e "\.zip\.001$"); do 7z t "$file"; done;}
# output matching lines from this file
# TODO: output entire function
alias akac="cat /home/fabian/hdd/d/programs/bash_scripts/.bashrc | grep"
# package history
pachist_helper_method_do_not_use(){ cat /var/log/pacman.log | grep -e "\\[ALPM\\] installed" -e "\\[ALPM\\] upgraded" -e "\\[ALPM\\] removed" -e "\\[ALPM\\] reinstalled" | grep -v -e yuzu-mainline-bin -e geckodriver-hg;}
pachist(){ if [[ "$1" == "" ]]; then pachist_helper_method_do_not_use | tail -n 1000; else pachist_helper_method_do_not_use | grep "$1" | tail -n 100 | grep "$1"; fi;}
# maximum temperature of any component
alias sen="sensors iwlwifi_1-virtual-0 coretemp-isa-0000 pch_skylake-virtual-0 acpitz-acpi-0 | grep -oE \"  \\\\+[0-9\\.]+\\\\°C\" | grep -oE \"[0-9\\\\.]+\" | sed \"s/\\\\.[0-9]//\" | sort -n | tail -1"
# watch maximum temperature
alias sens="for i in {1..23}; do xdotool key Ctrl+plus; done; watch -tdn1 \"sensors -u iwlwifi_1-virtual-0 coretemp-isa-0000 pch_skylake-virtual-0 acpitz-acpi-0 | grep \\\"\\\\\\\\_input\\\" | sed -E \\\"s/.+\\\\\\\\_input\\\\\\\\: //;s/\\\\\\\\..+//\\\" | sort -n | tail -1\""

# highlight parts of an output
# TODO: use a loop and build a string that then gets executed with $() instead of this mess
hl(){ 
 if [ "$2" == "" ]; then
  grep -e "" -e "$1";
 else
  if [ "$3" == "" ]; then
   grep -e "" -e "$1" -e "$2";
  else
   if [ "$4" == "" ]; then
    grep -e "" -e "$1" -e "$2" -e "$3";
   else
    grep -e "" -e "$1" -e "$2" -e "$3" -e "$4";
   fi;
  fi;
 fi;
}

# Info about commands: Location, package+info, dependencies, (wait for enter,) owned files and all occurrences of search term
# TODO: exclude the package itself from dependants list
# TODO: hide errors at the beginning, generally make similar to/integrate into un
# TODO: if no results, use "pacman -Q" for a "did you mean", maybe even correct typos
# TODO: list executable files before Enter
about(){
 # In the simplest case, this already shows the location.
 whereis "$@";
 # package that owns given command
 pacman -Qo "$@";
 # Make a list of given packages and the packages for all given commands, removing duplicates (like the package "bash" owning the command "bash").
 packs="$(ech "$* $(pacman -Qoq "$@")" | tr " " "\n" | sort -u)";
 for i in $packs; do echo $i; done
 # a big section of general package information
 pacman -Qii $packs | grep -e "" -e "Version         : " -e "Depends On      : ";
 for pack in $packs; do
  echo "\nPackages that depend on $pack: $(pactree -lr $pack | sort -u | tr "\n" " ")";
 done;
 echo "\nEnter \"q\" or press Ctrl+Shift+Esc to exit, anything else for owned files and search";
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

# Shortcut for youtube-dlp. For more info, run "dl --help".
# TODO: get working in Termux
# TODO: only number files if argument is actually a playlist: youtube-dl -s <URL> | grep -c ".*Downloading video [0-9]* of [0-9]*"
#       alternative: "--flat-playlist"
# TODO: expand playlists recursively (0001_0001_a.mp4), announce lengths
# TODO: automatically --playlist-reverse for channels+users
# TODO: preview command to simulate (print filenames): --get-filename -o "%(whatever)s"
# TODO: warn for 360°, 3D and multiple cameras
dl(){
 if [[ "$1" =~ ^(\-\-?|\/)?(h(elp)?|\?)$ ]]; then
  /home/fabian/hdd/d/programs/bash_scripts/dl --help
 else
  date "+%H:%M:%S"
  if [ "$1" == "" ]; then
   youtube-dl --add-header 'Cookie:' -q --no-warnings -i --retries infinite --fragment-retries infinite -u "fabianroeling@googlemail.com" -p "$yt_pw" -o "/home/fabian/Downloads/%(playlist_index)04i_%(uploader)s_-_%(title)s_%(id)s.%(ext)s" --restrict-filenames --mark-watched --sub-lang "ja,ja-JP,de,de-DE,en-US,en,en-GB" --write-sub --embed-subs --exec "echo \"\$(date "+%H:%M:%S") {}\"" https://www.youtube.com/playlist?list=$wl_id
  else
   if [[ "$1" =~ ^[0-9]+$ ]]; then
    youtube-dl --add-header 'Cookie:' -q --no-warnings -i --retries infinite --fragment-retries infinite -u "fabianroeling@googlemail.com" -p "$yt_pw" -o "/home/fabian/Downloads/%(playlist_index)04i_%(uploader)s_-_%(title)s_%(id)s.%(ext)s" --restrict-filenames --mark-watched --sub-lang "ja,ja-JP,de,de-DE,en-US,en,en-GB" --write-sub --embed-subs --playlist-start $1 --exec "echo \"\$(date "+%H:%M:%S") {}\"" https://www.youtube.com/playlist?list=$wl_id
   else
    if [ "$2" == "" ]; then
     youtube-dl --add-header 'Cookie:' -q --no-warnings -i --retries infinite --fragment-retries infinite -o "%(playlist_index)04i_%(uploader)s_-_%(title)s_%(id)s.%(ext)s" --restrict-filenames --sub-lang "ja,ja-JP,de,de-DE,en-US,en,en-GB" --write-sub --embed-subs --exec "echo \"\$(date "+%H:%M:%S") {}\"" $1
    else
     if [[ "$2" =~ ^[0-9]+$ ]]; then
      youtube-dl --add-header 'Cookie:' -q --no-warnings -i --retries infinite --fragment-retries infinite -o "%(playlist_index)04i_%(uploader)s_-_%(title)s_%(id)s.%(ext)s" --restrict-filenames --sub-lang "ja,ja-JP,de,de-DE,en-US,en,en-GB" --write-sub --embed-subs --playlist-start $2 --exec "echo \"\$(date "+%H:%M:%S") {}\"" $1
     else
      if [ "$1" == "m" ]; then
       if [[ "$3" =~ ^[0-9]+$ ]]; then
        youtube-dl --add-header 'Cookie:' -q --no-warnings -i --retries infinite --fragment-retries infinite -o "%(playlist_index)04i_%(uploader)s_-_%(title)s_%(id)s.%(ext)s_temp" --restrict-filenames --playlist-start $3 -f bestaudio/best --exec "file=\"{}\"; if [[ \"\$(echo \"\$file\" | grep -E \".mp3_temp\$\")\" == \"\" ]]; then ffmpeg -i \"\$file\" -nostdin -map 0:a -map_metadata -1 -v 16 -q:a 0 -y \"\${file%.*}.mp3\"; else ffmpeg -i \"\$file\" -nostdin -map 0:a -map_metadata -1 -v 16 -c:a copy -y \"\${file%_temp}\"; fi; if (( \"\$?\" == 0 )); then rm \"\$file\"; echo \"\$(date \"+%H:%M:%S\") \${file%.*}.mp3\"; else echo \"WARNING: Problem encountered while converting \$file, downloaded file was left unchanged.\"; fi" $2
       else
        shift
        youtube-dl --add-header 'Cookie:' -q --no-warnings -i --retries infinite --fragment-retries infinite -o "%(playlist_index)04i_%(uploader)s_-_%(title)s_%(id)s.%(ext)s_temp" --restrict-filenames -f bestaudio/best --exec "file=\"{}\"; if [[ \"\$(echo \"\$file\" | grep -E \".mp3_temp\$\")\" == \"\" ]]; then ffmpeg -i \"\$file\" -nostdin -map 0:a -map_metadata -1 -v 16 -q:a 0 -y \"\${file%.*}.mp3\"; else ffmpeg -i \"\$file\" -nostdin -map 0:a -map_metadata -1 -v 16 -c:a copy -y \"\${file%_temp}\"; fi; if (( \"\$?\" == 0 )); then rm \"\$file\"; echo \"\$(date \"+%H:%M:%S\") \${file%.*}.mp3\"; else echo \"WARNING: Problem encountered while converting \$file, downloaded file was left unchanged.\"; fi" "$@"
       fi
      else
       youtube-dl --add-header 'Cookie:' -q --no-warnings -i --retries infinite --fragment-retries infinite -o "%(playlist_index)04i_%(uploader)s_-_%(title)s_%(id)s.%(ext)s" --restrict-filenames --sub-lang "en-GB,en,en-US,de,de-DE,ja,ja-JP" --write-sub --embed-subs --exec "echo \"\$(date "+%H:%M:%S") {}\"" "$@"
      fi
     fi
    fi
   fi
  fi
  if (( "$?" != 0 )); then
   echo "There were errors while downloading!"
  fi
 fi
}

# temporary download command
alias dlp="yt-dlp -f \"bv*[height<=?1080]+ba/b[height<=?1080]/22/18\" --check-formats --sub-lang \"ja,ja-JP,de,de-DE,en-US,en,en-GB\" --embed-subs"


## output uptime and boot time on console start (and for some reason randomly during package installations)
echo "$(uptime -p) since $(uptime -s)", time: $(date "+%H:%M:%S")