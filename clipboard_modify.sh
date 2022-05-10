#!/bin/bash
source /home/fabian/hdd/d/programs/bash_scripts/sane
while clipnotify; do
 new="$(xsel -bo)"
 # remove trash from copied YouTube links
 if [[ "$new" == "https://www.youtube.com/watch?v="* ]]; then
  echo -n "$new" | sed "s/\\&list\\=[a-zA-Z0-9\\_\\-]+\\&index\\=[0-9]+//g" | xsel -bi
 # remove trash from copies Twitch clip links
 elif [[ "$new" == "https://www.twitch.tv/"*"/clip/"* ]]; then
  echo -n "$new" | sed "s/\\?filter\\=clips\\&range\\=all\\&sort\\=time//g" | xsel -bi
 else
  # ensure that clipboard doesn't get cleared when closing a program
  echo -n "$new" | xsel -bi
 fi
done