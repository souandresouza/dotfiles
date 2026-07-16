#!/bin/bash
source ~/.cache/wal/colors.sh

cat > "$HOME"/.config/qt5/colors/mauve.conf << EOF
[ColorScheme]
active_colors=  $color0,     $color8, $color9, $color10, $color11, $color12, $color0,     $color0,  $color0,     $color1, $color12, $color11, $color5, $color11,    $color4,     $color7,   $color12, $color15, $color1, $color0, $color8, $color5
inactive_colors=$color8, $color1,     $color9, $color10, $color11, $color12, $color8, $color0,  $color8, $color1, $color12, $color11, $color10,              $color8, $color8, $color8,   $color12, $color15, $color1, $color0, $color8, $color10
disabled_colors=$color8, $color10, $color9, $color10, $color11, $color12, $color8, $color0,  $color8, $color1, $color12, $color11, $color12,                $color8, $color7,   $color7, $color12, $color15, $color1, $color0, $color8, $color12
EOF