#!/bin/bash
# ~/capture-lock.sh

# 1. Inicia o hyprlock em segundo plano
hyprlock &
LOCK_PID=$!

# 2. Espera 2-3 segundos para a interface carregar completamente
sleep 3

# 3. Captura a tela INTEIRA. O hyprlock geralmente cobre tudo.
#    A opção -l pode ser usada para especificar a camada (layer).
#    Experimente com e sem ela se a captura ficar preta.
grim -o $(hyprctl monitors -j | jq -r '.[0].name') ~/Imagens/hyprlock_screenshot_$(date +%s).png

# 4. (Opcional) Mata o processo do hyprlock após a captura.
#    Comente a linha abaixo se quiser que o locker continue ativo para você desbloquear.
# kill $LOCK_PID

echo "Captura salva em ~/Imagens/"