#!/bin/bash

theme="~/.config/rofi/applets/style.rasi"

prompt="Projects"
mesg="To clipboard"

options=$(ls -1 ~/development/keys | grep ".txt" | cut -d'.' -f 1)

rofi_cmd() {
	rofi -theme-str "listview {columns: 1; lines: 5;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme ${theme}
}

run_rofi() {
	echo -e "$options" | rofi_cmd
}

run_cmd() {
  if [ "$1" == "" ]; then
    exit 0
  fi
  echo "$1.txt"
  cd ~/development/keys
  xclip -selection clipboard -i < "$1.txt" 
  notify-send "Rofi" "Copied $1.txt to clipboard"
}

chosen="$(run_rofi)"
run_cmd "$chosen"
