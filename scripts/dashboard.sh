#!/bin/bash

tput civis
trap "tput cnorm; tput clear; exit" EXIT INT TERM

draw() {
  tput cup 0 0

  bat=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
  bat_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)

  bright=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%')

  vol_raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
  vol=$(echo "$vol_raw" | awk '{printf "%d", $2 * 100}')
  muted=$(echo "$vol_raw" | grep -o "MUTED")
  [[ -n "$muted" ]] && vol_display="MUTED" || vol_display="${vol}%"

  net=$(nmcli -t -f NAME connection show --active 2>/dev/null | grep -v "lo" | head -1)
  [[ -z "$net" ]] && net="No Internet"

  ram=$(free -h --si 2>/dev/null | awk '/Mem/{print $3"/"$2}')

  storage=$(df -h / 2>/dev/null | awk 'NR==2{print $3"/"$2}')

  temp=$(awk '{printf "%.0f", $1/1000}' /sys/class/hwmon/hwmon4/temp1_input 2>/dev/null)

  time=$(date '+%H:%M:%S %A, %d %B %Y')

  uptime=$(uptime -p | sed 's/up //')

  song=$(playerctl metadata --format '{{title}}' 2>/dev/null | cut -c1-25)
  [[ -z "$song" ]] && song="Nothing is playing"

  printf "  TIME          %-35s\n" "$time"
  printf "  BATTERY       %-35s\n" "${bat}% (${bat_status})"
  printf "󰃞  BRIGHTNESS    %-35s\n" "${bright}%"
  printf "  VOLUME        %-35s\n" "${vol_display}"
  printf "  NETWORK       %-35s\n" "$net"
  printf "  RAM           %-35s\n" "$ram"
  printf "󰋊  STORAGE       %-35s\n" "$storage"
  printf "  CPU TEMP      %-35s\n" "${temp}°C"
  printf "󰔟  UPTIME        %-35s\n" "$uptime"
  printf "󰝚  NOW PLAYING   %-35s\n" "$song"
}

while true; do
  draw
  read -t 0.2 -n 1 key
  [[ "$key" == "q" ]] && break
done
