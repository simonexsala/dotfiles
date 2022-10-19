theme="~/.config/rofi/applets/style.rasi"

# Theme Elements
prompt='Screenshot'
mesg="~/pictures/screenshots/" 

option_1=" Capture Desktop"
option_2=" Capture Area"
option_3=" Capture Window"
option_4=" Capture in 3s"
option_5=" Capture in 5s"

rofi_cmd() {
	rofi -theme-str "listview {columns: 1; lines: 5;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "Screenshot" \
		-mesg "~/pictures/screenshots/" \
		-markup-rows \
		-theme ${theme}
}

run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

shotnow () {
  time=$(date +%Y-%m-%d_%H:%M:%S)
  scrot ~/pictures/screenshots/$time.png -d 1 && 
    notify-send "Screenshot taken!" "Copied to the clipboard and you can find it in your folder."

  xclip -selection clipboard -target image/png -i ~/pictures/screenshots/$time.png
}

shot1 () {
  time=$(date +%Y-%m-%d_%H:%M:%S)
  scrot ~/pictures/screenshots/$time.png -d 3 && 
    notify-send "Screenshot taken!" "Copied to the clipboard and you can find it in your folder."

  xclip -selection clipboard -target image/png -i ~/pictures/screenshots/$time.png
}

shot3 () {
  time=$(date +%Y-%m-%d_%H:%M:%S)
  scrot ~/pictures/screenshots/$time.png -d 5 && 
    notify-send "Screenshot taken!" "Copied to the clipboard and you can find it in your folder."

  xclip -selection clipboard -target image/png -i ~/pictures/screenshots/$time.png
}

shotwin () {
  time=$(date +%Y-%m-%d_%H:%M:%S)
  scrot ~/pictures/screenshots/$time.png -u -b && 
    notify-send "Screenshot taken!" "Copied to the clipboard and you can find it in your folder."

  xclip -selection clipboard -target image/png -i ~/pictures/screenshots/$time.png
}

shotarea () {
  time=$(date +%Y-%m-%d_%H:%M:%S)
  scrot ~/pictures/screenshots/$time.png -s && 
    notify-send "Screenshot taken!" "Copied to the clipboard and you can find it in your folder."

  xclip -selection clipboard -target image/png -i ~/pictures/screenshots/$time.png
}

run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		shotnow
	elif [[ "$1" == '--opt2' ]]; then
		shotarea
	elif [[ "$1" == '--opt3' ]]; then
		shotwin
	elif [[ "$1" == '--opt4' ]]; then
		shot1
	elif [[ "$1" == '--opt5' ]]; then
		shot3
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
esac
