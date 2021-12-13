#!/bin/bash
source /home/fabian/misc/sane
# remove trash from copied YouTube links
while clipnotify; do
 new="$(xsel -bo)"
 if [[ "$new" == "https://www.youtube.com/watch?v="* ]]; then
  echo -n "$new" | sed "s/\\&list\\=[a-zA-Z0-9\\_\\-]+\\&index\\=[0-9]+//g" | xsel -bi
 fi
done