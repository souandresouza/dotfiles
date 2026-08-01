#!/bin/bash

# URL para sua cidade
URL="https://wttr.in/Sao_Joao_do_Rio_Vermelho"

# Opções para formato simples e sem arte ASCII
# %c: condição (ex: ☀️), %t: temperatura, %w: vento, %h: umidade
# Parâmetros: ?format=%c+%t+%w+%h&m (m = métrico)
WEATHER=$(curl -s "${URL}?format=%c+%t+%w+%h&m")

# Exemplo de saída: "☀️ +17°C ↙14km/h 72%"
echo "$WEATHER"