#!/bin/bash
source /home/fabian/hdd/d/programs/bash_scripts/sane
while clipnotify; do
 new="$(xsel -bo)"
 # remove trash from YouTube links
 if [[ "$new" == *"youtube.com/watch?v="* ]]; then
  echo -En "$new" | sed "s/\\&list\\=[a-zA-Z0-9\\_\\-]+\\&index\\=[0-9]+//g" | xsel -bi
 # remove trash from Twitch clip links
 elif [[ "$new" == "https://www.twitch.tv/"*"/clip/"* ]]; then
  echo -En "$new" | sed "s/\\?filter\\=clips\\&range\\=all\\&sort\\=time//g" | xsel -bi
# elif xsel -bo | file - | grep "ASCII text" >/dev/null; then
#  # ensure that clipboard doesn't get cleared when closing a program
#  echo -En "$new" | xsel -bi
 fi
done