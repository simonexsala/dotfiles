#!/bin/bash

theme="~/.config/rofi/applets/style.rasi"

turn_on=" Turn on"
turn_off=" Turn off"
disconnect=" Disconnect"

x_coord="-40px" 
if [ -z "$1" ]; then
  x=$(xdotool getmouselocation --shell | grep X | cut -d'=' -f 2)
  let "x_coord = $(( $x - 2560 + 230 / 2 ))"
fi

# If wi-fi is inactive shows only turn-on 
rofi_cmd_inactive() {
	rofi -theme-str "window { x-offset: $x_coord; }" \
    -theme-str "listview {columns: 1; lines: 2;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "Network" \
		-mesg "$1" \
		-markup-rows \
		-theme ${theme}
}

rofi_cmd_on() {
	rofi -theme-str "window { x-offset: $x_coord; }" \
    -theme-str "listview {columns: 1; lines: 5;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "Network" \
		-mesg "$1" \
		-markup-rows \
		-theme ${theme}
}

run_rofi() {
  connected=$(nmcli -fields WIFI g)
  mesg=$(iwconfig wlp2s0 | cut -d '"' -f 2 -s)
  if [[ "$connected" =~ "enabled" ]]; then
    if [[ -z "$mesg" ]]; then
      # Wifi active but disconnected
      mesg="Select network"
      wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S//g" | sed "s/^--//g" | sed "s/ //g" | sed "/--/d")
      chosen_network=$(echo -e "$turn_off\n$wifi_list" | uniq -u | rofi_cmd_on "$mesg")

      toggle_option "$chosen_network"
    else
      # get network data
      # bps=$(iwlist wlp2s0 bitrate | grep = | cut -d "=" -f 2)
      bps=$(cat /proc/net/dev | grep wlp2s0 | awk '{print$3}')
      let "temp = $(( bps / 100024))"
      down="▾  Down $temp MB/s"

      bps=$(cat /proc/net/dev | grep wlp2s0 | awk '{print$11}')
      let "temp = $(( bps / 1024))"
      up="▴  Up $temp KB/s"

      bps=$(iwconfig wlp2s0 | grep "Link Quality" | cut -d '=' -f 2 -s | cut -d ' ' -f 1 | cut -d '/' -f 1)
      let "temp = $(( bps * 100 / 70 ))"
      strength="▸  Strength $temp%"

      chosen_option=$(echo -e "$turn_off\n$up\n$down\n$strength\n$disconnect" | rofi_cmd_on "$mesg")
      toggle_option "$chosen_option"
    fi
  elif [[ "$connected" =~ "disabled" ]]; then
    mesg="Wi-Fi disabled"
    chosen_option=$(echo -e "$turn_on" | rofi_cmd_inactive "$mesg")
    toggle_option "$chosen_option"
  fi
}

toggle_option() {
  if [ "$1" = "" ]; then
    exit
  elif [ "$1" = "$turn_on" ]; then
    nmcli radio wifi on
  elif [ "$1" = "$turn_off" ]; then
    nmcli radio wifi off
  elif [ "$1" = "$disconnect" ]; then
    connection=$(nmcli d | grep "connected" -w | tr -d " " | sed 's/.*connected//')
    nmcli con down id $connection
	elif [[ "$1" = $(nmcli -g NAME connection | grep -w "$1") ]]; then
    $success_mesg="You are now connected to \"$1\"."
		nmcli connection up id "$1" | grep "successfully" \
      && notify-send "Connection Established" "$success_mesg"
  else
    wifi_password=""
    if [[ "$1" =~ "" ]]; then
      wifi_password=$(rofi -dmenu -p "Password: " )
		fi
    $success_mesg="You are now connected to ${1:2}"
		nmcli device wifi connect ${1:2} password $wifi_password | grep "successfully" \
      && notify-send "Connection Established" "$success_mesg"
	fi
  exit
}

run_rofi
