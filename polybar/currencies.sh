#!/bin/bash

coinreport="${XDG_DATA_HOME:-$HOME/.local/share}/crypto/crypto-prices"
btcreport="${XDG_DATA_HOME:-$HOME/.local/share}/crypto/btc-prices"

name_1="btc"
name_2="eth"
name_3="atom" 
name_4="sol" 
name_5="avax"

get_coin_price() {
  price=$(curl -sf "http://rate.sx/1$1?qTF")

  printf "$1" >> "$coinreport"
  printf "@" >> "$coinreport"
  printf "$price" >> "$coinreport"
  printf "@" >> "$coinreport"
}

get_coin_change() {
  change=$(curl -sf "http://rate.sx/$1?qTF" | grep change | sed "s/.*(//" | cut -d")" -f 1)
  printf "%s\n" "$change" >> "$coinreport"
}

get_data() {
  get_coin_price "$1"
  get_coin_change "$1"
}

> "$coinreport"
get_data "$name_1"
get_data "$name_2"
get_data "$name_3"
get_data "$name_4"
get_data "$name_5"

print_change_btc() {
  cat $coinreport | grep btc > "$btcreport"
  change=$(awk -F'@' '{print $3}' "$btcreport")
  if [[ -z "$change" ]]; then
    return
  fi
  display_higher=$(echo "${change:1:${#string}-2} > 0.5" | bc)
  display_lower=$(echo "${change:1:${#string}-2} < -2" | bc)
  if [[ display_higher -eq 1 || display_lower -eq 1 ]]; then
    if [[ $change =~ "-" ]]; then
      # echo "%{F#e78284}$change"
      echo "$change"
    else
      # echo "%{F#70F8AD}${change:1}"
      echo "${change:1}"
    fi
  fi
}

print_change_btc
