#!/bin/sh
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

case $weather in
  *Sun* | *sun*)
    display+="%{F#eed49f}滛"
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
