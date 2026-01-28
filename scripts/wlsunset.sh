#!/bin/bash

# Aguardar inicialização
sleep 3

# Usar geoclue se disponível
if command -v geoclue2-agent &> /dev/null; then
    echo "wlsunset: usando geoclue2 (6500K → 3800K)"
    exec wlsunset -t 6500 -T 3800 -g 0.8 -d 2400
else
    echo "wlsunset: usando local fixo Florianópolis"
    exec wlsunset -l -27.49 -L -48.41 -t 6500 -T 3800 -g 0.8 -d 2400
fi
