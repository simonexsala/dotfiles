#!/bin/sh
weatherreport="${XDG_DATA_HOME:-$HOME/.local/share}/weather/weatherreport"

is_online() {
  ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && return 0 || return 1
}

get_forecast() {
#  if [ is_online ] ; then
    curl -sf "wttr.in/Milan?format=%C" > "$weatherreport"
    printf "@" >> "$weatherreport"
    curl -sf "wttr.in/Milan?format=%t" >> "$weatherreport"
#  fi
}

get_data() {
  weather=$(awk -F'@' '{print $1}' "$weatherreport")
  temperature=$(awk -F'@' '{print substr($2, 1, length($2)-2)}' "$weatherreport")
  if [ "${temperature:0:1}" == "+" ] ; then
    temperature=${temperature:1}
  fi
}

print_weather() {
  display=""
  now=$(date +"%k%M")

  case $weather in
    *Sun* | *sun* | *Clear* | *clear*)
      night_or_day $now
      ;;
    *Rain* | *rain* | *showers* | *Sleet* | *sleet*)
      display+="%{F#04a5e5}歹"
      ;;
    *Snow* | *snow*)
      display+="%{F#89dceb}ﰕ" 
      ;;
    *Thunder* | *thunder* | *Wind* | *wind*)
      display+="%{F#74c7ec}煮"
      ;;
    *Fog* | *fog*)
      display+="%{F#9399b2}敖"
      ;;
    *Cloud* | *cloud*)
      display+="%{F#04a5e5}" 
      ;;
    "Partly cloudy" | Overcast)
      display+="%{F#04a5e5}杖" 
      ;;
    *)
      display+="%{F#e78284}" 
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

# if [ "$(stat -c %y "$weatherreport" 2>/dev/null | cut -d' ' -f 2 | cut -d'.' -f 1)" -lt "$(date -d '20 minutes ago' '+%T')" ] ; then
#  get_forecast
# fi
get_forecast
get_data
print_weather
