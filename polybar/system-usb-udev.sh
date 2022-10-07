#!/bin/sh

device_print() {
  devices=$(lsblk -p -S -o VENDOR)
  if ! [ "$devices" == "" ]; then
    vendor=$(echo "$devices" | tail -n1 | tr -d '[:space:]')
    name=$(lsblk -p -S -o NAME | tail -n1 | tr -d '[:space:]')
    echo "%{F#04a5e5}隷 %{F#eff1f5}$vendor %{F#babbf1}$name"
  else
    echo ""
  fi
}

device_eject() {
  device=$(lsblk -p -S -o NAME | tail -n1 | tr -d '[:space:]')
  $(eject $device)
}

case "$1" in 
  --eject)
    device_eject
    ;;
  *)
    device_print
    ;;
esac
