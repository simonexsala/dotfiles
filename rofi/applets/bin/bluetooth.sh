#!/bin/bash
source "bluetooth-functions.sh"
theme="~/.config/rofi/applets/style.rasi"

prompt="Bluetooth"
mesg=$(bluetoothctl devices Connected | head -n 1 | cut -d' ' -f 3)

turn_on=" Turn on"
turn_off=" Turn off"
back=" Back"
urgent="-u 0"

device_prefix="﬌ "
device1="$device_prefix"
device1+=$(bluetoothctl devices | grep Device | cut -d ' ' -f 3- | head -n 1)
device2="$device_prefix"
device2+=$(bluetoothctl devices | grep Device | cut -d ' ' -f 3- | tail -n 1)

x_coord="-40px" 
if [ -z "$1" ]; then
  x=$(xdotool getmouselocation --shell | grep X | cut -d'=' -f 2)
  let "x_coord = $(( $x - 2560 + 230 / 2 ))"
fi

rofi_cmd() {
  rofi -theme-str "window { x-offset: $x_coord; }" \
    -theme-str "listview {columns: 1; lines: 5;}" \
    -theme-str 'textbox-prompt-colon {str: "";}' \
    -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    -markup-rows \
    -urgent ${urgent} \
    -theme ${theme}
}

power_on() {
  if bluetoothctl show | grep -q "Powered: yes"; then
    return 0
  else
    return 1
  fi
}

toggle_power() {
  if power_on; then
    bluetoothctl power off
    show_menu
  else
    if rfkill list bluetooth | grep -q 'blocked: yes'; then
      rfkill unblock bluetooth && sleep 3
    fi
    bluetoothctl power on
    show_menu
  fi
}

scan_on() {
  if bluetoothctl show | grep -q "Discovering: yes"; then
    echo " Scanning..."
    return 0
  else
    echo " Not scanning"
    return 1
  fi
}

toggle_scan() {
  if scan_on; then
    kill $(pgrep -f "bluetoothctl scan on")
    bluetoothctl scan off
    show_menu
  else
    bluetoothctl scan on &
    echo " Scanning..."
    sleep 2
    show_menu
  fi
}

pairable_on() {
  if bluetoothctl show | grep -q "Pairable: yes"; then
    echo " Pairable"
    return 0
  else
    echo " Not pairable"
    return 1
  fi
}

toggle_pairable() {
  if pairable_on; then
    bluetoothctl pairable off
    show_menu
  else
    bluetoothctl pairable on
    show_menu
  fi
}

discoverable_on() {
  if bluetoothctl show | grep -q "Discoverable: yes"; then
    echo " Discoverable"
    return 0
  else
    echo " Not discoverable"
    return 1
  fi
}

toggle_discoverable() {
  if discoverable_on; then
    bluetoothctl discoverable off
    show_menu
  else
    bluetoothctl discoverable on
    show_menu
  fi
}

device_connected() {
  device_info=$(bluetoothctl info "$1")
  if echo "$device_info" | grep -q "Connected: yes"; then
    return 0
  else
    return 1
  fi
}

toggle_connection() {
  if device_connected $1; then
    bluetoothctl disconnect $1
    device_menu "$device"
  else
    bluetoothctl connect $1
    device_menu "$device"
  fi
}

device_paired() {
  device_info=$(bluetoothctl info "$1")
  if echo "$device_info" | grep -q "Paired: yes"; then
    echo "Paired"
    return 0
  else
    echo "Not paired"
    return 1
  fi
}

toggle_paired() {
  if device_paired $1; then
    bluetoothctl remove $1
    device_menu "$device"
  else
    bluetoothctl pair $1
    device_menu "$device"
  fi
}

device_trusted() {
  device_info=$(bluetoothctl info "$1")
  if echo "$device_info" | grep -q "Trusted: yes"; then
    echo "Trusted"
    return 0
  else
    echo "Not trusted"
    return 1
  fi
}

toggle_trust() {
  if device_trusted $1; then
    bluetoothctl untrust $1
    device_menu "$device"
  else
    bluetoothctl trust $1
    device_menu "$device"
  fi
}

run_rofi_device_menu() {
  device=$1
  device_name=$(echo $device | cut -d ' ' -f 3-)
  device_mac=$(echo $device | cut -d ' ' -f 2)

  if device_connected $device_mac; then
    battery=$(bluetoothctl info "$device_mac" | grep "Battery Percentage" | cut -d'(' -f 2)
    connected="Connected\nBattery ${battery::-1}%"
  else
    connected="Not connected"
  fi

  paired=$(device_paired $device_mac)
  trusted=$(device_trusted $device_mac)
  options="$connected\n$paired\n$trusted\n$back"

  chosen="$(echo -e "$options" | rofi_cmd "$device_name")"

  case $chosen in
    $connected)
      toggle_connection $device_mac
      ;;
    $paired)
      toggle_paired $device_mac
      ;;
    $trusted)
      toggle_trust $device_mac
      ;;
    $back)
      run_rofi_general_menu
      ;;
    "")
      exit 0
      ;;
  esac
}

run_rofi_general_menu() {
  if power_on; then
    # Display only two devices 
    # uncomment this to display all of them
    # devices=$(bluetoothctl devices | grep Device | cut -d ' ' -f 3- | head -n 1)
    # options="$turn_off\n$devices\n$pairable\n$scan\n$discoverable"
    pairable=$(pairable_on)
    scan=$(scan_on)
    discoverable=$(discoverable_on)

    devices=""
    if [ $device1 == $device_prefix ]; then
      options="$turn_off\n$pairable\n$scan\n$discoverable"
    elif [ $device2 == $device_prefix ]; then
      options="$turn_off\n$device1\n$pairable\n$scan\n$discoverable"
    elif [ "$device1" == "$device2" ]; then
      options="$turn_off\n$device1\n$pairable\n$scan\n$discoverable"
    else
      options="$turn_off\n$device1\n$device2\n$pairable\n$scan\n$discoverable"
    fi
  else
    options="$turn_on"
  fi

  chosen="$(echo -e "$options" | rofi_cmd)"

  case ${chosen} in
      $turn_on)
        toggle_power
          ;;
      $turn_off)
        toggle_power
          ;;
      $scan)
        toggle_scan
          ;;
      $pairable)
        toggle_pairable
          ;;
      $discoverable)
        toggle_discoverable
          ;;
      "")
        exit 0
          ;;
      *)
        device_name=$(echo "$chosen" | cut -d' ' -f 2)
        device=$(bluetoothctl devices | grep "$device_name")
        if [[ $device ]]; then 
          run_rofi_device_menu "$device"
        fi
        ;;
  esac
}

run_rofi_general_menu
