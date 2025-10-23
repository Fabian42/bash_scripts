#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane
while clipnotify; do
 text="$(xsel -bo)"
 # remove trash from YouTube links
 if [[ "$text" == *"youtube.com/watch?v="* || "$text" == *"youtu.be/"* ]]; then
  echo -En "$text" | sed "s/\\&list\\=[a-zA-Z0-9\\_\\-]+\\&index\\=[0-9]+(\\&t\\=[0-9]+)?//g;s/\\&pp\\=[A-Za-z0-9\\_\\-]+//g;s/\\?si\\=[A-Za-z0-9\\_\\-]+$|\\&si\\=[A-Za-z0-9\\_\\-]+|si\\=[A-Za-z0-9\\_\\-]+\\&//g;s/(\\=|\\%3D)*$//g;s/\\&feature\\=[a-z\\_]+//g" | xsel -bi
  echo "edited YT link"
 # remove trash from Twitch links
 elif [[ "$text" == *"twitch.tv/"* ]]; then
  echo -En "$text" | sed "s/\\?filter\\=[a-z]+(\\&range\\=[a-z0-9]+)?\\&sort\\=[a-z]+//g" | xsel -bi
  echo "edited Twitch link"
 elif [[ "$text" == "https://www.google.com/imgres?q="* ]]; then
  echo -En "$text" | sed "s/\\&(imgrefurl|vet|ved)\\=[^\\&]+//g" | xsel -bi
  echo "edited Google image link"
# elif xsel -bo | file - | grep "ASCII text" >/dev/null; then
#  # ensure that clipboard doesn't get cleared when closing a program
#  echo -En "$text" | xsel -bi
 fi
done