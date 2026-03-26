#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane
source /home/fabian/d/programs/bash_scripts/bashrc
while clipnotify; do
 ech "."
 text="$(xsel -bo)"
 if [[ "$text" != "$old" ]]; then
  # remove trash from YouTube links
  if [[ "$text" == *"youtube.com/watch?v="* || "$text" == *"youtu.be/"* ]]; then
   echo -En "$text" | sed "s/\\&list\\=[a-zA-Z0-9\\_\\-]+\\&index\\=[0-9]+(\\&t\\=[0-9]+)?//g;s/\\&pp\\=[A-Za-z0-9\\_\\-]+//g;s/\\?si\\=[A-Za-z0-9\\_\\-]+$|\\&si\\=[A-Za-z0-9\\_\\-]+|si\\=[A-Za-z0-9\\_\\-]+\\&//g;s/(\\=|\\%3D)*$//g;s/\\&feature\\=[a-z\\_]+//g" | xsel -bi
   echo "edited YT link"
   sleep 1
  # remove trash from Twitch links
  elif [[ "$text" == *"twitch.tv/"* ]]; then
   echo -En "$text" | sed "s/\\?filter\\=[a-z]+(\\&range\\=[a-z0-9]+)?\\&sort\\=[a-z]+//g" | xsel -bi
   echo "edited Twitch link"
   sleep 1
  elif [[ "$text" == "https://www.google.com/imgres?q="* ]]; then
   echo -En "$text" | sed "s/\\&(imgrefurl|vet|ved)\\=[^\\&]+//g" | xsel -bi
   echo "edited Google image link"
   sleep 1
#  elif [[ "$text" == "" ]]; then
#   echo "$old" | xsel -bi
#   echo "re-filled clipboard"
#   sleep 1
 # elif xsel -bo | file - | grep "ASCII text" >/dev/null; then
 #  # ensure that clipboard doesn't get cleared when closing a program
 #  echo -En "$text" | xsel -bi
  fi
  echo "storing clipboard"
  old="$text"
 fi
done