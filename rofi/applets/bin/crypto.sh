#!/bin/bash

theme="~/.config/rofi/applets/style.rasi"
coinreport="${XDG_DATA_HOME:-$HOME/.local/share}/crypto/crypto-prices"

prompt='Markets'
mesg="Cryptocurrency" 

x_coord="-40px" 
if [ -z "$1" ]; then
  x=$(xdotool getmouselocation --shell | grep X | cut -d'=' -f 2)
  let "x_coord = $(( $x - 2560 + 230 / 2 ))"
fi

option_1="B"
option_2="E"
option_3="C" 
option_4="S" 
option_5="A" 

name_1="btc"
name_2="eth"
name_3="atom" 
name_4="sol" 
name_5="avax" 

# name_1="bitcoin"
# name_2="ethereum"
# name_3="cosmos" 
# name_4="osmosis" 
# name_5="juno-network" 

get_coin_price() {
  price=$(cat "$coinreport" | grep $1 | cut -d'@' -f 2 | cut -c 1-6)
  if [ ${price:0-1} = "." ]; then
    price=${price::-1}
  fi
  echo $price
}

get_coin_change() {
  change=$(cat "$coinreport" | grep $1 | cut -d'@' -f 3)
  echo $change
}

append_data() {
  display=$1
  display+=" "
  display+=$(get_coin_change "$2") 
  display+=" "
  display+=$(get_coin_price "$2") 

  echo $display
}

rofi_cmd() {
  rofi -theme-str "window { x-offset: $x_coord; }" \
    -theme-str "listview { columns: 1; lines: 5; }" \
    -theme-str 'textbox-prompt-colon { str: ""; }' \
    -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    -markup-rows \
    -theme ${theme}
}

run_rofi() {
  option_1=$(append_data "$option_1" "$name_1")
  option_2=$(append_data "$option_2" "$name_2")
  option_3=$(append_data "$option_3" "$name_3")
  option_4=$(append_data "$option_4" "$name_4")
  option_5=$(append_data "$option_5" "$name_5")
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

run_rofi 
