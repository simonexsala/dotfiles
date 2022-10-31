#!/bin/bash

theme="~/.config/rofi/applets/style.rasi"
calendar="$HOME/.local/share/calendar/calendar"          
schedule="$HOME/.local/share/calendar/schedule"
urgent_days="$HOME/.local/share/calendar/urgent"

today=$(date +%d)
month=$(date +%m)
year=$(date +%Y)
mesg=$(LANG=en_En date +"%A, %d %B %T")
month_name=$(LANG=en_EN date +%B)
prompt="$month_name's calendar"

add_to_dates="Add to urgent dates"
remove_from_dates="Remove from urgent dates"
events="Events scheduled"
add_event=" Add event"
back=" Back"

active=""
urgent=""
lines="6"
x_coord="-40px" 
if [ -z "$1" ]; then
  x=$(xdotool getmouselocation --shell | grep X | cut -d'=' -f 2)
  let "x_coord = $(( $x - 2560 + 400 / 2 ))"
fi

format_file() {
  if [ $lines = 6 ]; then
    echo "$(awk '{while(length<17) $0=$0 " "}1' "$calendar")" > "$calendar"
  elif [ $lines = 7 ]; then
    echo "$(awk '{while(length<20) $0=$0 " "}1' "$calendar")" > "$calendar"
  fi
}

find_current_day() {
  $(LANG=en_EN cal -v -m "$month" "$year" | sed '1d;' > "$calendar")

  sed -i 's/\s*$//' "$calendar"
  length=$(sed -n '1p' < "$calendar")
  if [[ "${#length}" == 20 ]]; then
    lines="7"
  fi

  format_file
  mapfile -t urgent_dates < "$urgent_days" 
  
  i=0
  while IFS= read -r -n3 char
  do
    day=$(echo ${char//[[:blank:]]/})
    if [ "$day" == "$today" ]; then
      active="-a $i"
    fi

    date_exists=$(grep -F "D$day;" "$schedule" | cut -d';' -f1)
    if [[ ! -z "$date_exists" ]]; then
      if [[ -z "$urgent" ]]; then
        urgent="-u $i"
      else
        urgent+=",$i" 
      fi
    fi

    ((i++))
  done < "$calendar"
}

find_current_day

generate_calendar() {
  i=0
  while IFS= read -r -n3 char
  do
    echo ${char//[[:blank:]]/}
  done < "$calendar"
}

rofi_cmd() {
  rofi -theme-str "window { x-offset: $x_coord; width: 400px; }" \
    -theme-str "listview {columns: 7; lines: $lines;}" \
    -theme-str 'textbox-prompt-colon {str: "";}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
    -dmenu \
    -p "$prompt" \
    -mesg "$1" \
    ${active} \
    ${urgent} \
    -markup-rows \
    -theme ${theme}
}

rofi_cmd_event() {
  rofi -theme-str "window { x-offset: $x_coord; width: 400px; }" \
    -theme-str "listview {columns: 1; lines: 7; }" \
    -theme-str 'textbox-prompt-colon {str: "";}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
    -dmenu \
    -p "$prompt" \
    -mesg "$1" \
    -sep '\x0f' \
    -markup-rows \
    -theme ${theme}
}

run_rofi() {        
  options=$(generate_calendar) 
  echo -e "$options" | rofi_cmd "$mesg"
}

run_rofi_add_event_to_file() {
  rofi -theme-str "window { x-offset: $x_coord; width: 400px; }" \
    -theme-str 'textbox-prompt-colon {str: "";}' \
    -dmenu \
    -i \
    -no-fixed-num-lines \
    -p "Add event " \
    -markup-rows \
    -theme "~/.config/rofi/applets/prompt.rasi" 
}

add_event_to_file() {
  input=$(run_rofi_add_event_to_file)
  echo "$input"
  date=""
  event="$input"
  ending="${input: -3}"
  if [[ ${ending:0:1} =~ [:punct:]+$ ]]; then
    date="${input: -5}"
    event="${input::-5}"
  else
    date="${input: -2}"
    event="${input::-2}"
  fi

  echo "D$1;${event::-1};$date" >> "$schedule"
}

populate_events() {
  entries=""

  while read p; do
    day=${p%;*;*}
    if [ "$day" == "D$1" ] || [ "$day" == "D$1;" ]; then
      activity=${p#*;}
      activity=${activity%;*}
      time=${p##*;}
      entries+="${activity}\n<span font-style=\"italic\" color=\"#cdd6f4\">${time}</span>\x0f"  
    fi
  done < "$schedule"

  echo "$entries"
}

add_to_urgent() {
  echo "D$1;" >> "$schedule"
}

remove_from_urgent() {
  sed -i "/D$1;/d" "$schedule"
}

get_date_menu_options() {
  date_exists=$(grep -F "D$1;" "$schedule" | cut -d';' -f1)
  if [[ -z "$date_exists" ]]; then
    echo "$add_to_dates\x0f$add_event"
  else
    events=$(populate_events "$1")
    echo "$remove_from_dates\x0f$events$add_event"
  fi
}

run_rofi_date_menu() {
  let difference=$((today-$1))
  message=$(LANG=en_EN date --date="$difference days ago" +"%A, %d %B %Y")
  action_option=$(get_date_menu_options "$1")
  action=$(echo -e "$action_option\x0f\n$back" | rofi_cmd_event "$message")

  case ${action} in
    "")
      exit 0
      ;;
    "$add_to_dates")
      add_to_urgent $1  
      main_menu_rofi
      ;;
    "$remove_from_dates")
      remove_from_urgent $1
      main_menu_rofi
      ;;
    "$add_event")
      add_event_to_file $1
      ;;
    *)
  main_menu_rofi
  ;;

  esac

}

main_menu_rofi() {
  chosen="$(run_rofi)"
  case ${chosen} in
    "")
      exit 0
      ;;
    "Mo" | "Tu" | "We" | "Th" | "Fr" | "Sa" | "Su")
      exit 0
      ;;
    *)
      run_rofi_date_menu "$chosen"
      ;;
  esac
}

main_menu_rofi
