#!/bin/bash
# Obtém o dia do ano (1-365/366). O formato %j deve ser universal.
current_day=$(date +%j)
# Remove zero à esquerda, se houver (torna "023" em "23")
current_day=$((10#$current_day))

# Calcula total de dias no ano
year=$(date +%Y)
if (( (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) )); then
    total_days=366
else
    total_days=365
fi

# Cálculo da porcentagem usando aritmética de inteiros do Bash
# Multiplica por 1000 para obter uma casa decimal de precisão
percentage_int=$(( (current_day * 1000) / total_days ))
# Separa a parte inteira da decimal
percentage_integer=$((percentage_int / 10))
percentage_decimal=$((percentage_int % 10))

# Formata a saída para a Waybar
echo "{\"text\": \"${percentage_integer}.${percentage_decimal}%\", \"tooltip\": \"Dia ${current_day} de ${total_days}\"}"
