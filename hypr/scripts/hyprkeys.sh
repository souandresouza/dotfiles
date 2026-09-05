#!/bin/sh

# Extrai binds com suas descrições
grep -E '^hl\.bind\(' $HOME/.config/hypr/config/binds.lua | \
  while IFS= read -r line; do
    # Extrai o atalho (primeiro argumento entre aspas)
    shortcut=$(echo "$line" | grep -oP '(?<=hl\.bind\(")[^"]+' | head -1)

    # Tenta extrair a descrição do campo description
    description=$(echo "$line" | grep -oP 'description\s*=\s*"([^"]+)"' | sed 's/description\s*=\s*"\(.*\)"/\1/')

    # Se não encontrou description, tenta extrair o comando executado
    if [ -z "$description" ]; then
      # Para binds com hl.dsp.exec_cmd
      cmd=$(echo "$line" | grep -oP 'hl\.dsp\.exec_cmd\("[^"]+"' | sed 's/hl\.dsp\.exec_cmd("\([^"]*\)"/\1/')

      # Se encontrou um comando, usa ele como descrição resumida
      if [ -n "$cmd" ]; then
        # Simplifica o comando para exibição
        cmd_simple=$(echo "$cmd" | sed -E 's/^.*\/([^\/]+)\.sh$/\1/' | sed -E 's/^.*\/([^\/]+)$/\1/')
        description="→ $cmd_simple"
      else
        # Para binds de ação (focus, swap, etc)
        action=$(echo "$line" | grep -oP 'hl\.dsp\.\w+' | sed 's/hl\.dsp\.//' | head -1)
        if [ -n "$action" ]; then
          description="[$action]"
        fi
      fi
    fi

    # Mostra o resultado
    if [ -n "$description" ]; then
      echo "$shortcut  ─  $description"
    else
      echo "$shortcut"
    fi
  done | \
  fuzzel --dmenu --prompt " Atalhos:> " --match-mode=exact --no-sort --no-icons -l 25 -w 120
