#!/bin/bash

theme="~/.config/rofi/applets/style.rasi"
updates="$HOME/.local/share/updates/updates"          

x_coord="-40px" 
if [ -z "$1" ]; then
  x=$(xdotool getmouselocation --shell | grep X | cut -d'=' -f 2)
  let "x_coord = $(( $x - 2560 + 230 / 2 ))"
fi

arch=$(head -n 1 $updates)
aur=$(tail -n 1 $updates)
prompt="Updates"
mesg="$((arch + aur)) pending"

rofi_cmd() {
	rofi -theme-str "window { x-offset: $x_coord; }" \
    -theme-str "listview {columns: 1; lines: 2;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		${active} \
		-markup-rows \
		-theme ${theme}
}

run_rofi() {
	echo -e " $arch in Core\n $aur in AUR" | rofi_cmd
}

run_rofi
