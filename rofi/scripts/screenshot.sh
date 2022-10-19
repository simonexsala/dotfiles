#!/bin/bash

opt1=" Fullscreen"
opt2="类 Focused window"
opt3=" Selected area"

rofi_cmd() {
  rofi -dmenu \
    -mesg "<b>Screenshot</b>" \
    -theme ~/.config/rofi/powermenu/style.rasi
}

run_rofi() {
	echo -e "$opt1\n$opt2\n$opt3" | rofi_cmd
}

screen() {
  scrot ~/pictures/screenshots/'%Y-%m-%d-%s.png' -d 0.1 && notify-send "Screenshot taken!" "You can find it in your folder."
}

window() {
  scrot ~/pictures/screenshots/'%Y-%m-%d-%s.png' -u -b && notify-send "Screenshot taken!" "You can find it in your folder."
}

area() {
  scrot ~/pictures/screenshots/'%Y-%m-%d-%s.png' -s && notify-send "Screenshot taken!" "You can find it in your folder."
}

options="$(run_rofi)"
if [[ "$options" == "$opt1" ]]; then
  screen
elif [[ "$options" == "$opt2" ]]; then
  window
elif [[ "$options" == "$opt3" ]]; then
  area
fi
