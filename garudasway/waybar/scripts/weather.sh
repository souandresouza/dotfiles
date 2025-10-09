#!/bin/bash

# Get your API key and location from environment variables or config file
API_KEY="${OPENWEATHER_API_KEY:67ff956a782464851d19e0f040d9fd9f}"
LAT="-27.497126"
LON="-48.412581"

url="https://api.openweathermap.org/data/2.5/weather?lat=${LAT}&lon=${LON}&appid=${API_KEY}&units=metric&lang=pt"

# Function to handle errors
handle_error() {
    echo "{\"text\": \"$1\", \"class\": \"error\"}"
    exit 1
}

# Make the API request
response=$(curl -s -w "%{http_code}" "$url")

# Extract HTTP status code (last 3 characters)
http_code="${response: -3}"
# Extract response body (all but last 3 characters)
response_body="${response%???}"

# Check if curl was successful and HTTP status is 200
if [ $? -ne 0 ] || [ "$http_code" != "200" ]; then
    handle_error "Erro na requisição: HTTP $http_code"
fi

# Parse JSON response using jq (ensure jq is installed)
if ! command -v jq &> /dev/null; then
    handle_error "jq não instalado"
fi

# Extract data from JSON
temp=$(echo "$response_body" | jq -r '.main.temp')
description=$(echo "$response_body" | jq -r '.weather[0].description')
icon_code=$(echo "$response_body" | jq -r '.weather[0].icon')

# Check if jq parsing was successful
if [ "$temp" = "null" ] || [ "$description" = "null" ]; then
    handle_error "Erro ao analisar dados da API"
fi

# Format temperature to remove decimal places
temp_int=$(printf "%.0f" "$temp")

# Format output for Waybar
output=$(cat <<EOF
{
    "text": "${temp_int}°C",
    "tooltip": "${description}",
    "class": "weather"
}
EOF
)

echo "$output"
