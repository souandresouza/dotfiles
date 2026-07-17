#!/bin/sh

# Ícone (adicione o caminho do ícone)
icon_path="/usr/share/icons/Adwaita/48x48/status/camera-photo-symbolic.symbolic.png"
notify_cmd_shot="notify-send -h string:x-canonical-private-synchronous:screeenrecord -u low -i ${icon_path}"

recordings="$HOME/Vídeos/Recordings"
tmp_dir="${recordings}/.tmp"
tmp_file="${tmp_dir}/.recording"

if [ ! -z $(pgrep wf-recorder) ];
then
    # Para o wf-recorder no Niri (SIGINT funciona)
    killall -s SIGINT wf-recorder
    
    # Aguarda o processo terminar (importante no Niri)
    while [ ! -z $(pgrep -x wf-recorder) ]; do 
        sleep 0.1
    done
    
    # Atualiza o waybar (se estiver usando)
    pkill -RTMIN+8 waybar

    # Verifica se o arquivo temporário existe
    if [ -f "${tmp_file}" ]; then
        # Lê o caminho do arquivo temporário
        tmp_file_path="$(cat ${tmp_file})"
        filename="Record_$(date "+%Y-%m-%d_%H-%M-%S").mp4"
        filepath="${recordings}/${filename}"
        saved_to="~/Vídeos/Recordings/${filename}"

        # Move o arquivo para a pasta final
        mv "${tmp_file_path}" "${filepath}"
        
        # Remove o arquivo temporário de referência
        rm -f "${tmp_file}"

        # Notifica com ação para abrir a pasta
        action=$($notify_cmd_shot "Screen Record" "Saved to ${saved_to}" --action " Open containing folder")

        # Abre o gerenciador de arquivos (para Niri, use o que você tem instalado)
        if [[ "${action}" == "0" ]]; then
            # Para Niri, você pode usar vários gerenciadores:
            # thunar, nautilus, dolphin, pcmanfm, etc.
            if command -v thunar &> /dev/null; then
                thunar "${recordings}"
            elif command -v nautilus &> /dev/null; then
                nautilus "${recordings}"
            elif command -v dolphin &> /dev/null; then
                dolphin "${recordings}"
            elif command -v pcmanfm &> /dev/null; then
                pcmanfm "${recordings}"
            else
                # Fallback: abre com o gerenciador padrão do sistema
                xdg-open "${recordings}"
            fi
        fi
    else
        $notify_cmd_shot "Screen Record" "Error: Temporary file not found!"
    fi
else
    ${notify_cmd_shot} "Screen Record" "Not recording!"
fi
