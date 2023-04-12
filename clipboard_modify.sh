#!/bin/bash
source /home/fabian/hdd/d/programs/bash_scripts/sane
while clipnotify; do
 text="$(xsel -bo)"
 # remove trash from YouTube links
 if [[ "$text" == *"youtube.com/watch?v="* ]]; then
  echo -En "$text" | sed "s/\\&list\\=[a-zA-Z0-9\\_\\-]+\\&index\\=[0-9]+//g;s/\\&pp\\=gAQBiAQB//g" | xsel -bi
 # remove trash from Twitch links
 elif [[ "$text" == "https://www.twitch.tv/"* ]]; then
  echo -En "$text" | sed "s/\\?filter\\=[a-z]+(\\&range\\=[a-z]+)?\\&sort\\=[a-z]+//g" | xsel -bi
# elif xsel -bo | file - | grep "ASCII text" >/dev/null; then
#  # ensure that clipboard doesn't get cleared when closing a program
#  echo -En "$text" | xsel -bi
 fi
done