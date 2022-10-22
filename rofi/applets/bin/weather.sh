#!/bin/bash

theme="~/.config/rofi/applets/style.rasi"
weatherreport="${XDG_DATA_HOME:-$HOME/.local/share}/weather/weatherreport"

x_coord="-40px" 
if [ -z "$1" ]; then
  x=$(xdotool getmouselocation --shell | grep X | cut -d'=' -f 2)
  let "x_coord = $(( $x - 2560 + 230 / 2 ))"
fi

weather=""
sunrise="▴ Sunrise "
sunset="▾ Sunset "
humidity=" Humidity "
moon_day=" Day "

weather+=$(awk -F'@' '{print $1}' "$weatherreport")
temperature=$(awk -F'@' '{print $2}' "$weatherreport")
location=$(awk -F'@' '{print $3}' "$weatherreport")
sunrise+=$(awk -F'@' '{print $4}' "$weatherreport")
sunset+=$(awk -F'@' '{print $5}' "$weatherreport")
moon_day+=$(awk -F'@' '{print $6}' "$weatherreport")
humidity+=$(awk -F'@' '{print $7}' "$weatherreport")

if [ "${temperature:0:1}" == "+" ] ; then
  temperature=${temperature:1}
fi

prompt='Weather'
mesg+="$location, $temperature"

rofi_cmd() {
  rofi -theme-str "window { x-offset: $x_coord; }" \
    -theme-str "listview { columns: 1; lines: 5; }" \
    -theme-str 'textbox-prompt-colon { str: ""; }' \
    -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    -markup-rows \
    -theme ${theme}
}

run_rofi() {
	echo -e "$weather\n${sunrise::-3}\n${sunset::-3}\n$moon_day\n$humidity" | rofi_cmd
}

run_rofi 
