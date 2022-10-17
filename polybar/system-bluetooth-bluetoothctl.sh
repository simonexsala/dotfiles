#!/bin/sh

bluetooth_print() {
  bluetoothctl | while read -r; do
    if [ "$(systemctl is-active "bluetooth.service")" = "active" ]; then

      devices_paired=$(bluetoothctl devices | grep Device | cut -d ' ' -f 2)
      counter=0
      low_battery=false
      notification_sent=false

      for device in $devices_paired; do
        device_info=$(bluetoothctl info "$device")

        if echo "$device_info" | grep -q "Connected: yes"; then
          device_alias=$(echo "$device_info" | grep "Alias" | cut -d ' ' -f 2-)
          device_battery=$(upower --dump | grep "percentage" | head -n 1 | cut -d ' ' -f 15)

          if ! $notification_sent ; then
            if [ ${device_battery::-1} -lt 20 ]; then
              low_battery=true
            fi
          fi

          if $low_battery ; then
            notification_sent=1
            low_battery_notify "$device_alias"
          fi

          if [ $counter -gt 0 ]; then
            printf ", %s" "$device_alias"
          else
            printf "%s" "$device_alias"
          fi

          counter=$((counter + 1))
        fi
      done
      if [ $counter -eq 0 ]; then
        printf "Inactive"
      fi
    fi
  printf '\n'
  done
}

low_battery_notify() {
  notify-send "$1" "Battery running low"
}

bluetooth_toggle() {
  if bluetoothctl show | grep -q "Powered: no"; then
    bluetoothctl power on >> /dev/null
    sleep 1

    devices_paired = $(bluetoothctl devices | grep Device | cut -d ' ' -f 2)
    echo "$devices_paired" | while read -r line; do
      bluetoothctl connect "$line" >> /dev/null
    done
  else
    devices_paired = $(bluetoothctl devices | grep Device | cut -d ' ' -f 2)
    echo "$devices_paired" | while read -r line; do
      bluetoothctl disconnect "$line" >> /dev/null
    done
    
    bluetoothctl power off >> /dev/null
    printf " \n"
  fi
}

case "$1" in
  --toggle)
    bluetooth_toggle
    ;;
  *)
    bluetooth_print
    ;;
esac
