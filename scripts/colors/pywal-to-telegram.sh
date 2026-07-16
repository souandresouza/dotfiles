#!/bin/bash
# pywal-to-telegram.sh

source ~/.cache/wal/colors.sh

cat > ~/.local/share/TelegramDesktop/tdata/pywal.tdesktop-palette << EOF
colorWindow: $color0;
colorWindowText: $color15;
colorWindowBg: $color0;
colorWindowBgOver: $color8;
colorWindowSubText: $color7;
colorWindowFg: $color15;
colorWindowFgOver: $color15;
colorActive: $color4;
colorActiveText: $color15;
colorAttention: $color1;
colorAttentionText: $color15;
colorLink: $color4;
colorIcon: $color7;
colorIconAttention: $color1;
colorWindowBubbleBg: $color0;
colorWindowBubbleBgOver: $color8;
colorWindowBubbleFg: $color15;
colorWindowBubbleFgOver: $color15;
colorShadow: $color0;
colorShadowFg: $color0;
colorHistoryText: $color7;
colorHistoryTextOver: $color15;
colorHistoryIcon: $color7;
colorHistoryIconOver: $color15;
colorMsgText: $color15;
colorMsgTextOver: $color15;
colorMsgBg: $color8;
colorMsgBgOver: $color7;
colorScrollBar: $color8;
colorScrollBarBg: $color0;
colorScrollBarBgOver: $color0;
colorSeekBar: $color4;
colorSeekBarFill: $color7;
colorSeekBarBg: $color8;
EOF