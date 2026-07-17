#!/bin/sh

COLORS_FILE="$HOME/.cache/wal/colors.css"
VESKTOP_FILE="$HOME/.config/vesktop/themes/colors.theme.css"

if [ ! -f "$COLORS_FILE" ]; then
    echo "ERRO: Arquivo $COLORS_FILE não encontrado!"
    exit 1
fi

# Extrair cores do formato Pywal/CSS (--color0: #xxx;)
extract_color() {
    grep "\-\-color$1:" "$COLORS_FILE" | head -1 | awk -F': ' '{print $2}' | tr -d '; '
}

# Extrair também background, foreground e cursor
background=$(grep "\-\-background:" "$COLORS_FILE" | head -1 | awk -F': ' '{print $2}' | tr -d '; ')
foreground=$(grep "\-\-foreground:" "$COLORS_FILE" | head -1 | awk -F': ' '{print $2}' | tr -d '; ')
cursor=$(grep "\-\-cursor:" "$COLORS_FILE" | head -1 | awk -F': ' '{print $2}' | tr -d '; ')

# Extrair cores 0-15
color0=$(extract_color 0)
color1=$(extract_color 1)
color2=$(extract_color 2)
color3=$(extract_color 3)
color4=$(extract_color 4)
color5=$(extract_color 5)
color6=$(extract_color 6)
color7=$(extract_color 7)
color8=$(extract_color 8)
color9=$(extract_color 9)
color10=$(extract_color 10)
color11=$(extract_color 11)
color12=$(extract_color 12)
color13=$(extract_color 13)
color14=$(extract_color 14)
color15=$(extract_color 15)

# DEBUG
echo "foreground = [$foreground]"
echo "background = [$background]"
echo "cursor = [$cursor]"
for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    eval "echo \"color$i = [\$color$i]\""
done

# Verificar se as cores foram extraídas
if [ -z "$color0" ]; then
    echo "ERRO: Nenhuma cor extraída."
    exit 1
fi

mkdir -p "$(dirname "$VESKTOP_FILE")"
rm -f "$VESKTOP_FILE"

# Criar configuração com alpha ff
cat > "$VESKTOP_FILE" << EOF
/* --- CUSTOMIZABLE --- */

:root {
  /* [[ DISCORD COLORS ]] */
  --modular-red: ${color0};
  --modular-yellow: ${color11};
  --modular-green: ${color4};
  --modular-orange: ${color8};
  --modular-teal: ${color5};
  --modular-blue: ${color15};

  /* [[ BASE COLORS ]] */
  --modular-bg0: ${color0}; /* Primary background color */
  --modular-bg1: ${color1}; /* Secondary background color */
  --modular-bg2: ${color2}; /* Tertiary background color */
  --modular-bg3: ${color3}; /* Quarterary background color */
  --modular-bg4: ${color4}; /* Modifier/hover/select background color */

  --modular-text0: ${color15}; /* Normal text color */
  --modular-text1: ${color14}; /* Brighter text color */
  --modular-text2: ${color11}; /* Darker text color */

  /* [[ BRAND COLORS ]] */
  --modular-accent: ${color8}; /* Accent color */
  --modular-flavor: "Rosebox"; /* Flavor name */

  /* [[ CHAT BUBBLES ]] */
  --modular-cb-width: max-content; /* 100% for chat bubbles spanning the entire screen / max-content for dynamic width, Default is max-content */

  /* [[ FONT CHANGE ]] */
  --font-main: "Inter";
  --font-code: "Roboto Mono";

  /* [[ CLIENT LAYOUT ]] */
  --client-border-color: var(--brand-500);
  --modular-sidebar-orientation: column;
  /* column-reverse for user panel on top */
  --modular-guild-orientation: row;
  /* row-reverse for guild bar on the right */
  --modular-memberlist-orientation: row;
  /* row-reverse for member list on the left */
  --modular-friendlist-orientation: row;
  /* row-reverse for now playing tab on the left */

  /* [[ SPOTIFY TRACK BACKGROUND ]] */
  --modular-spotify-bg-blur: 2px; /* higher px = stronger blur, 0 = no blur */
  --modular-spotify-darken: 0.5; /* 0 = album cover is not darkened, 1 = album cover is darkened fully (black) */
}

/* --- THIRD PARTY IMPORTS --- */
/* Should you want to use snippets, place them here */

EOF
pkill -SIGUSR1 -x vesktop