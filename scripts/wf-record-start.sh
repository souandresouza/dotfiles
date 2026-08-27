#!/bin/sh

icon_path="/usr/share/icons/Adwaita/48x48/status/camera-photo-symbolic.symbolic.png"
notify_cmd_shot="notify-send -h string:x-canonical-private-synchronous:screeenrecord -u low -i ${icon_path}"

recordings="$HOME/Vídeos/Recordings"
tmp_dir="${recordings}/.tmp"
tmp_file="${tmp_dir}/.recording"

if [ -z $(pgrep wf-recorder) ]
then
    mkdir -p "${tmp_dir}"

    # Seleciona área com slurp (necessário instalar: sudo pacman -S slurp)
    area=$(slurp -d -b "#45858880" -c "#ffffff")
    
    if [ -z "$area" ]; then
        $notify_cmd_shot "Screen Record" "Selection cancelled."
        exit 1
    fi

    filepath="${tmp_dir}/$(date "+%s").mp4"
    echo "$filepath" > "${tmp_file}"

    # Inicia a gravação com a área selecionada
    wf-recorder --audio --geometry="$area" --file="${filepath}" & disown
    
    sleep 0.5
    $notify_cmd_shot "Screen Record" "Recording has started." 
    pkill -RTMIN+8 waybar
else
    $notify_cmd_shot "Screen Record" "Recording is already in progress."
fi