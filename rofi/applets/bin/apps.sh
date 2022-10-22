#!/usr/bin/env bash
theme="~/.config/rofi/applets/style.rasi"

prompt='Programs'
mesg="Packages: `pacman -Q | wc -l`" 

term_cmd='alacritty'
web_cmd='firefox'
file_cmd='thunar'
text_cmd='alacritty -e lvim /home/simone/documents/scritti/'
music_cmd='alacritty -e ncmpcpp'
setting_cmd='alacritty -e lvim /home/simone/.config/polybar/config.ini'

option_1=" Terminal"
option_2=" Explorer" 
option_3=" Editor"
option_4=" Browser"
option_5=" Music"
option_6=" Settings"

rofi_cmd() {
  rofi -theme-str "listview {columns: 1; lines: 6;}" \
    -theme-str 'textbox-prompt-colon {str: "";}' \
    -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    -markup-rows \
    -theme ${theme}
}

run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		${term_cmd}
	elif [[ "$1" == '--opt2' ]]; then
		${file_cmd}
	elif [[ "$1" == '--opt3' ]]; then
		${text_cmd}
	elif [[ "$1" == '--opt4' ]]; then
		${web_cmd}
	elif [[ "$1" == '--opt5' ]]; then
		${music_cmd}
	elif [[ "$1" == '--opt6' ]]; then
		${setting_cmd}
	fi
}

chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
        ;;
    $option_2)
		run_cmd --opt2
        ;;
    $option_3)
		run_cmd --opt3
        ;;
    $option_4)
		run_cmd --opt4
        ;;
    $option_5)
		run_cmd --opt5
        ;;
    $option_6)
		run_cmd --opt6
        ;;
esac
