# bash_scripts
Contains various bash scripts that I have written mainly for myself.

Contents so far:
* `sane`: Fixes issues with Bash that would make me go insane if I had to do them in every script separately. This short script is imported by most of the others. Since I create all new Bash scripts using my "`scr`" console shortcut, that gets done for me automatically.
* `.bashrc`: Many console shortcuts, fixes for annoying behaviour of various programs and other improvements and tools. This file has grown a lot over time.
* `.inputrc`: Some tweaks to console autocomplete.
* `co`: Parses various sources and copies the resulting Corona vaccination and case numbers to clipboard for my spreadsheets: https://docs.google.com/spreadsheets/d/1uDTghO_ZYBs5nfs2kDc0Ms6e9bbx7clx_QgkWii7OMY
  * If anyone wants other regions to be added to spreadsheet, just tell me and I'll see what I can do.
  * old version: https://pastebin.com/uHzzMeac
* `dl`: A wrapper script around `yt-dlp` that has many defaults and tries to guess what the user means, therefore allowing easy usage by default, but also much power with more complex arguments.
* `shrink`: Shrinks a video below a given maximum size, while preserving as much quality as possible.
* Text:
  * `len`: Returns how long a string actually visibly is (with monospace), not counting escape sequences.
  * `wrap`: Wraps a text on spaces.
  * `tablewrap`: Aligns two columns of text and wraps the right side on spaces.
  * Warning: These only handle few escape sequences so far and also not fullwidth characters.
* Autostart:
  * `autostart_loop.sh`: Tries to disable screen off after 10 minutes, disables capslock whenever it is pressed (setting to disable button is ignored FSR, but this way at least it also works with VMs, remote, etc.), notifies if the KDE Connect link to the phone was dropped and turns muted volume into volume 0.
  * `yt_clipb.sh`: Removes "`&list=…&index=…`" from copied YouTube URLs, because it messes with pasting into `dl` and I never want that anyway. Separate from `autostart_loop.sh` because it waits on `clipnotify`, which makes it respond faster and take up less resources.
* Buttons:
  * `decrease_brightness.sh` and `increase_brightness.sh`: Change screen brightness, but only using the brightness steps off, min, ¼, max and max+increased gamma
  * `volume_down.sh` and `volume_up.sh`: Change volume, ignoring any upper limits, and show new volume in notification.
* `notepad.sh`: Opens Notepad++ without Windows' awful font blurring and focuses the window.

These are all executable files, despite most missing the "`.sh`" extension. The file names are kept short so that they can be used just like regular commands in a console or script, by having my `programs/bash_scripts` folder in the `PATH` environment variable.

Dependencies for some features: caffeine, clipnotify, gazou-git, iotop, jisho, kimtoy, moreutils, mpris-proxy, Notepad++, rebuild-detector, ttf-cica, ttf-kanjistrokeorders, wmctrl, xcalib, xdotool
Everything is made to work on my computers and may need adjustments for any other system.