updates="$HOME/.local/share/updates/updates"          

if ! updates_arch=$(checkupdates 2> /dev/null | wc -l); then
  updates_arch=0
fi

if ! updates_aur=$(paru -Qum 2> /dev/null | wc -l); then
  updates_aur=0
fi

echo "$updates_arch" > $updates
echo "$updates_aur" >> $updates

if [ "$updates_arch" -gt 0 ]; then
  echo "%{F#40a02b} %{F#eff1f5}$updates_arch"
elif [ "$updates_aur" -gt 0 ]; then
  echo "%{F#40a02b} %{F#eff1f5}$updates_aur"
else
  # echo "%{F#a6d189} %{F#eff1f5}0"
  echo ""
fi

