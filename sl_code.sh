#!/bin/bash
label="regional_compliancies.json"
file="a.png"
convert "$file" -trim "$file"; convert -size 2560x1440 xc:none -fill "#1e1e1e" -stroke white -strokewidth 2 -draw "roundrectangle 115.5,283.5,$(magick identify -format "%[fx:w+195.5],%[fx:h+369.5]" "$file"),10,10" -draw "roundrectangle 125.5,260.5,$(convert -pointsize 34 -font "Courier" label:"$label" png:- | magick identify -format "%[fx:w+156.5]" -),308.5,10,10" -pointsize 34 -font "Courier" -fill white -stroke none -annotate +142+295 "$label" \( "$file" -background none -splice 156x334 \) -composite "$file"