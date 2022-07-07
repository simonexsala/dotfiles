#!/bin/sh
night_or_day() {
    tempTime=$1
    if [ $tempTime -gt 700 -a $tempTime -lt 2100 ]; then 
      display+="%{F#eed49f}滛"
    else
      display+="%{F#f2d5cf}望"
    fi
}

weatherreport="${XDG_DATA_HOME:-$HOME/.local/share}/weather/weatherreport"
curl -sf "wttr.in/Milan?format=%C" > "$weatherreport"
printf "@" >> "$weatherreport"
curl -sf "wttr.in/Milan?format=%t" >> "$weatherreport"

weather=$(awk -F'@' '{print $1}' "$weatherreport")
temperature=$(awk -F'@' '{print substr($2, 1, length($2)-2)}' "$weatherreport")
if [ "${temperature:0:1}" == "+" ] ; then
  temperature=${temperature:1}
fi

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
    display+="%{F#04a5e5}摒" 
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
