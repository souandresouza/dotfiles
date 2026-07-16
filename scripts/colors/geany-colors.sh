#!/bin/bash

WAL_COLORS="/home/andre/.cache/cadroc/colors.css"
GEANY_CONFIG_DIR="/home/andre/.config/geany/"
GEANY_FILE="/home/andre/.config/geany/colorschemes/current.conf"

if [ ! -f "$WAL_COLORS" ]; then
    echo "Erro: $WAL_COLORS não encontrado"
    exit 1
fi

# Extrair cores - AJUSTE O CAMPO (print $2 ou $3) conforme seu arquivo
color0=$(grep 'color0' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color1=$(grep 'color1' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color2=$(grep 'color2' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color3=$(grep 'color3' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color4=$(grep 'color4' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color5=$(grep 'color5' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color6=$(grep 'color6' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color7=$(grep 'color7' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color8=$(grep 'color8' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color9=$(grep 'color9' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color10=$(grep 'color10' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color11=$(grep 'color11' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color12=$(grep 'color12' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color13=$(grep 'color13' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color14=$(grep 'color14' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color15=$(grep 'color15' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')

# DEBUG - Mostrar o que foi extraído
echo "DEBUG: color0 = [$color0]"
echo "DEBUG: color1 = [$color1]"
echo "DEBUG: color2 = [$color2]"
echo "DEBUG: color3 = [$color3]"
echo "DEBUG: color4 = [$color4]"
echo "DEBUG: color5 = [$color5]"
echo "DEBUG: color6 = [$color6]"
echo "DEBUG: color7 = [$color7]"
echo "DEBUG: color8 = [$color8]"
echo "DEBUG: color9 = [$color9]"
echo "DEBUG: color10 = [$color10]"
echo "DEBUG: color11 = [$color11]"
echo "DEBUG: color12 = [$color12]"
echo "DEBUG: color13 = [$color13]"
echo "DEBUG: color14 = [$color14]"
echo "DEBUG: color15 = [$color15]"

# Se estiver vazio, tenta com $3
if [ -z "$color0" ]; then
    color0=$(grep 'color0' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color1=$(grep 'color1' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color2=$(grep 'color2' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color3=$(grep 'color3' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color4=$(grep 'color4' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color5=$(grep 'color5' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color6=$(grep 'color6' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color7=$(grep 'color7' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color8=$(grep 'color8' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color9=$(grep 'color9' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color10=$(grep 'color10' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color11=$(grep 'color11' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color12=$(grep 'color12' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color13=$(grep 'color13' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color14=$(grep 'color14' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color15=$(grep 'color15' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    echo "DEBUG: Tentou com \$3 - color0 = [$color0]"
fi

# Se ainda estiver vazio, ERRO
if [ -z "$color0" ] || [ -z "$color7" ] || [ -z "$color4" ]; then
    echo "ERRO: Não consegui extrair as cores"
    echo "Conteúdo do arquivo:"
    cat "$WAL_COLORS"
    exit 1
fi

# Criar pasta de configuração se não existir
mkdir -p "$(dirname "$GEANY_CONFIG_DIR")"
mkdir -p "$(dirname "$GEANY_FILE")"

# Remover arquivo antigo se existir
rm -f "$GEANY_FILE"

# Criar a configuração do Geany com as variáveis de cor
cat > "$GEANY_FILE" << EOF
# Colorscheme generated for the silvia theme.

[theme_info]
name=gh0stzk
description=silvia theme for the BSPWM environment by gh0stzk
version=1.0
author=gh0stzk
url=https://github.com/gh0stzk/dotfiles

[named_colors]
bg_color=$color0
fg_color=$color15
cl_color=$color4
red_color=$color9
green_color=$color14
purple_color=$color12
cyan_color=$color8
pink_color=$color13
blue_color=$color2
orange_color=$color11
yellow_color=$color15
white_color=$color7
comment_color=$color1

[named_styles]
default=fg_color;bg_color
error=red_color


# Editor styles
#------------------------------------

selection=bg_color;purple_color;true;true
current_line=;cl_color;true
brace_good=bg_color;blue_color;true;true
brace_bad=bg_color;blue_color;true;true
margin_line_number=white_color;cl_color
margin_folding=white_color;cl_color
fold_symbol_highlight=purple_color
indent_guide=white_color
caret=white_color;white_color;false;
marker_line=fg_color;purple_color
marker_search=marker_line
marker_mark=white_color;red_color
call_tips=0x839496;0x002b36
white_space=indent_guide


# Programming languages
#------------------------------------

comment=comment_color
comment_doc=comment
comment_line=comment
comment_line_doc=comment_doc
comment_doc_keyword=comment_doc,bold
comment_doc_keyword_error=comment_doc,italic

number=purple_color
number_1=number
number_2=number_1

type=pink_color;;true;false
class=type
function=green_color
parameter=function

keyword=blue_color;;true;false
keyword_1=keyword
keyword_2=keyword
keyword_3=keyword_1
keyword_4=keyword_1

identifier=default
identifier_1=identifier
identifier_2=identifier
identifier_3=identifier_1
identifier_4=identifier_1

string=yellow_color
string_1=string
string_2=string_1
string_3=default
string_4=default
string_eol=0xdc322f
character=string_1
backtick=string_2
here_doc=string_2

scalar=orange_color
label=default,bold
preprocessor=0xcb4b16
regex=purple_color
operator=pink_color
decorator=string_1,bold
other=default


# Markup-type languages
#------------------------------------

tag=type
tag_unknown=tag,bold
tag_end=tag,bold
attribute=keyword_1
attribute_unknown=attribute,bold
value=string_1
entity=default


# Diff
#------------------------------------

line_added=0x859900
line_removed=0xdc322f
line_changed=0x268bd2


EOF


echo "Geany atualizado!"