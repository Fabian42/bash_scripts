#!/bin/bash
source /home/fabian/d/programs/bash_scripts/sane

# output live Ukraine newsticker and notify for filtered entries
blacklist=("fordert" "fordern" "verurteil" "\\bwarnt" "warnen" "empfängt" "empfangen" "angeblich" "^russland\\: " "^putin\\: " "\\bweis".*" zurück" "signal" "drängt auf" "berät" "\\bbiete" "\\bwill " "^kreml\\: " "befürworte" "getreide" "\\bkriti" "disku" "erwarte" "besorgt" "wirbt" "werben" "begrüß" "könnte" "wirft .+ vor" "werfen .+ vor" "\\bplan" "warn" "besuch" "gespräch" "\\bbitte" "\\bsorg" "zivil" "prüf" "schule" "kündig.* an" "zweifel" "dank" "optimist" "\\breis" "beklag" "sieh" "spr[ei]ch" "gratul" "erwäg" "betont" "papst" "bekräftig" "zusammen(ge)?kommen" "\\bnenn" "erklär" "in kürze" "zeichen" "ruft .+ auf" "\\bsehen " "\\?$" "\\bdroht" "drohen" "^moskau\\: " "^wohl " "verweis" "kirche" "\\bwohl " "\\btote" "folter" "\\bgrab " "gräber" "zivilist" "räumt .+ ein" "würdig" "\\brät " "\\braten " "grab" "leiche" "sicher[ent].* zu" "pocht auf" "pochen auf" "prognos" "frag" "tode" "wünsch" "wunsch" "opfer" "wollen" "gesteh" "geständnis" "werte" "möglich" "laut russland" "kirill" "aufruf" "\\bwäre" "verspr" "beschuldig" "\\bsoll" "fürchte" "\\bvorw(u|ü)rf" "\\blob" "\\bhoff" "bezeichne" "^lawrow\\: " "\\bmahn" "so lange wie nötig" "empör" "unbefristet" "entsetz" "rufe" "\\behr" "olymp" "gedenk" "jahrestag" "inform" "aufgebrochen" "erinner" "athlet" "olymp" "sport" "pipe" "nord[ \\-]?stream" "unterstütz" "blogger" "schweig" "trump" "\\bwill" "\\bwohl " "mach.+ verantwortlich" "berat" "verletzt" "tele(f|ph)on" "einlad" "eingelad" "getötet" " ernte" " brauch" "darf" "dürfen" "muss" "müssen" "besicht" "geht von .+ aus" "spiel" "weis.+ aus" "luftalarm")
whitelist=("saporischschja" "akw" "atom" "nuklear" "nuclear" "piwdennoukrajinsk")
clear
url=$(curl -s "https://www.tagesschau.de/thema/ukraine" | grep -e "/newsticker/liveblog-" -e "/ausland/europa/liveblog-ukraine-" | head -n 1 | grep -Eo "(https\\:)?\\/[a-z0-9\\/\\-]+")
if [[ "url" =~ /* ]]; then
 url="https://www.tagesschau.de$url""~rss2.xml"
else
 url="$url""~rss2.xml"
fi
# print content from earlier today
page="$(curl -s "$url")"
if [[ "$page" = "" ]]; then echo "Article not found!"; exit; fi
# Konsole likes to open on my second screen, messing up the wrap when moved back, so wait until I've corrected it
sleep 30
wrap "$(echo "$page" | grep -v -e "<pubDate>" -e "<guid>" -e "<item>" -e "<dcDate/>" | tail -n +15 | sed "s/(<|\\&lt\\;)[^>\\&]+(>|\\&gt\\;)//g;s/\\&lt\\;\\/?em>//g;s/^      //")" # same regexes as in the "new_content=…" line
old_time="$(echo "$page" | grep "<pubDate>" | head -n 1)"
while sleep 60; do
 page="$(curl -s "$url")"
 new_time="$(echo "$page" | grep "<pubDate>" | head -n 1)"
 if [[ "$new_time" != "$old_time" ]]; then
  old_time="$new_time"
  new_content="$(echo "$page" | head -n 18 | tail -n 3 | grep -v "pubDate" | sed "s/(<|\\&lt\\;)[^>\\&]+(>|\\&gt\\;)//g;s/\\&lt\\;\\/?em>//g;s/^      //")" # same regexes as in the earlier content print line
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
  if [[ "$title" = "Ende des Liveblogs" || "$title" = "Ende des heutigen Liveblogs" || "$title" = "Ende des Liveblog" || "$title" = "Liveblog endet" ]]; then exit; fi
 fi
done