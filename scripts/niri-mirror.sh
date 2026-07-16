#!/bin/bash
# Lista as telas ativas do niri, passa para o fuzzel e espelha a escolhida
SELECAO=$(niri msg --json outputs | jq -r 'keys[]' | fuzzel -d)

if [ -n "$SELECAO" ]; then
    wl-mirror "$SELECAO"
fi
