#!/bin/sh
BSSIDS="$(nmcli device wifi list |
    awk 'NR>1 {if ($1 != "*") {print $1}}' |
    tr -d ":" |
    tr "\n" ",")"

LOC="São_Joao_do_Rio_Vermelho"
REQUEST_GEO="$(wget -qO - http://openwifi.su/api/v1/bssids/"$BSSIDS")"
if [[ "$(jq ".count_results" <<< "$REQUEST_GEO")" -gt 0 ]] ; then
    LAT="$(jq ".lat" <<< "$REQUEST_GEO")"
    LON="$(jq ".lon" <<< "$REQUEST_GEO")"
    LOC="$LAT,$LON"
fi

# Forçando sempre São João do Rio Vermelho em português
LOC="São_Joao_do_Rio_Vermelho"

text="$(curl -s "https://wttr.in/$LOC?format=1&lang=pt" | sed 's/ //g')"
tooltip="$(curl -s "https://wttr.in/$LOC?0QT&lang=pt" |
    sed 's/\\/\\\\/g' |
    sed ':a;N;$!ba;s/\n/\\n/g' |
    sed 's/"/\\"/g')"

if ! grep -q "Unknown location" <<< "$text"; then
    echo "{\"text\": \"$text\", \"tooltip\": \"<tt>$tooltip</tt>\", \"class\": \"weather\"}"
fi
