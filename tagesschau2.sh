#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane

# general news
blacklist=("AAAAAFILLERAAAAA")
whitelist=("saporischschja" "akw" "atom" "nuklear" "nuclear" "piwdennoukrajinsk")
while sleep 60; do
 page="$(curl -s "https://www.tagesschau.de/infoservices/alle-meldungen-100~rss2.xml")"
 new_time="$(echo "$page" | grep "<pubDate>" | head -n 1)"
 if [[ "$new_time" != "$old_time" ]]; then
  old_time="$new_time"
  new_content="$(echo "$page" | head -n 21 | tail -n 3 | sed "s/(<|\\&lt\\;)[^>\\&]+(>|\\&gt\\;)//g;s/\\&lt\\;\\/?em>//g;s/^      //")"
  title="$(echo "$new_content" | head -n 1)"
  title_lower="$(echo "$title" | tr '[:upper:]' '[:lower:]')"
  link="$(echo "$new_content" | head -n 2 | tail -n 1)"
  text="$(echo "$new_content" | tail -n 1)"
  content_lower="$(echo "$title\n$text" | tr '[:upper:]' '[:lower:]')"
  found_whitelist="false"
  for regex in "${whitelist[@]}"; do
   if echo "$content_lower" | grep -qE ".*$regex.*"; then
    found_whitelist="true"
    break
   fi
  done
  if [[ "$found_whitelist" = "false" ]]; then
   for regex in "${blacklist[@]}"; do
    if echo "$title_lower" | grep -qE ".*$regex.*"; then
     echo "\e[90m"
     date "+%H:%M"
     wrap "\e[1m$title\e[0m\e[90m" "\e[4m$link\e[0m" "\e[90m$text" "Blacklist: $regex\e[0m" # grey, bold title, underlined linke
     echo
     continue 2 # don't notify, repeat main loop
    fi
   done
  fi
  date "+%H:%M"
  wrap "\e[1m$title\e[0m" "\e[4m$link\e[0m" "$text" # bold title, underlined link
  if [[ "$found_whitelist" = "true" ]]; then
   echo "\e[90mWhitelist: $regex\e[0m" # grey regex
  fi
  echo
  notify-send -u critical "$title"
 fi
done