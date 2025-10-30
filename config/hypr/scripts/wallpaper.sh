#!/bin/bash                                                       
#   _ _ _ _____ __    __    _____ _____ _____ _____ _____ 
#  | | | |  _  |  |  |  |  |  _  |  _  |  _  |   __| __  |
#  | | | |     |  |__|  |__|   __|     |   __|   __|    -|
#  |_____|__|__|_____|_____|__|  |__|__|__|  |_____|__|__|
#

current_wp="$HOME/Imagens/wallpapers/"

# write path to wp into file
if [ ! -f $current_wp ]; then
    touch $current_wp
    echo "$HOME/Imagens/wallpapers/default.png" > "$current_wp"
fi

# current wallpaper path
current_wallpaper=$(cat "$current_wp")

# select new wallpaper
case $1 in
    "init")
        if [ -f $current_wp ]; then
            wal -q -i $current_wallpaper
        else
            wal -q -i ~/Imagens/wallpapers/
        fi
    ;;
    # random wallpaper
    *)
        wal -q -i ~/Imagens/wallpapers/
    ;;
esac

# new wallpaper name
new_wp=$(echo $wallpaper | sed "s|$HOME/Imagens/wallpapers/||g")

# launch waybar based on new wallpaper colors
source "$HOME/.cache/wal/colors.sh"

# update soft link to cava colors based on wallpaper colors
# (cava needs to manually be restarted)
ln -sf "$HOME/.cache/wal/cava-colors" "$HOME/.config/cava/config"

# switch to new wallpaper with swww
transition_type="grow"
#transition_type="wipe"
# transition_type="random"

swww img $wallpaper \
    --transition-type=$transition_type \
    --transition-pos top-right

# update current wallpaper file
echo "$wallpaper" > "$current_wp"
