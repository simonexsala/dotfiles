#!/bin/sh
weatherreport="${XDG_DATA_HOME:-$HOME/.local/share}/weather/weatherreport"

get_forecast() {
  curl -sf "wttr.in/Milan?format=%C" > "$weatherreport"
  printf "@" >> "$weatherreport"
  curl -sf "wttr.in/Milan?format=%t" >> "$weatherreport"
  printf "@" >> "$weatherreport"
  curl -sf "wttr.in/Milan?format=%l" >> "$weatherreport"
  printf "@" >> "$weatherreport"
  curl -sf "wttr.in/Milan?format=%S" >> "$weatherreport"
  printf "@" >> "$weatherreport"
  curl -sf "wttr.in/Milan?format=%s" >> "$weatherreport"
  printf "@" >> "$weatherreport"
  curl -sf "wttr.in/Milan?format=%M" >> "$weatherreport"
  printf "@" >> "$weatherreport"
  curl -sf "wttr.in/Milan?format=%h" >> "$weatherreport"
}

get_data() {
  weather=$(awk -F'@' '{print $1}' "$weatherreport")
  temperature=$(awk -F'@' '{print substr($2, 1, length($2)-2)}' "$weatherreport")
  if [ "${temperature:0:1}" == "+" ] ; then
    temperature=${temperature:1}
  fi
}

check_error() {
  error=$(cat "$weatherreport" | grep "Unknown location")

  if [[ ! -z "$error" ]]; then
    > $weatherreport
  fi
}

print_weather() {
  now=$(date +"%k%M")

  case $weather in
    *Sun* | *sun* | *Clear* | *clear*)
      night_or_day $now
      ;;
    *Rain* | *rain* | *showers* | *Sleet* | *sleet*)
      display+="%{F#04a5e5}煮"
      ;;
    *Snow* | *snow*)
      display+="%{F#89dceb}ﰕ" 
      ;;
    *Thunder* | *thunder* | *Wind* | *wind*)
      display+="%{F#74c7ec}煮"
      ;;
    *Fog* | *fog* | *Mist* | *mist*)
      display+="%{F#9399b2}"
      ;;
    *Cloud* | *cloud*)
      display+="%{F#04a5e5}" 
      ;;
    "Partly cloudy" | Overcast)
      display+="%{F#04a5e5}杖" 
      ;;
    *)
      display+="%{F#e78284} %{F#eff1f5}N/A"
      ;;
  esac

  display+=" %{F#eff1f5}$temperature"
  echo "$display"
}

night_or_day() {
  tempTime=$1
  if [ $tempTime -gt 700 -a $tempTime -lt 2100 ]; then 
    display+="%{F#eed49f}滛"
  else
    display+="%{F#f2d5cf}望"
  fi
}

get_forecast
get_data
check_error
print_weather
