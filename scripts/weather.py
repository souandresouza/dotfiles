#!/usr/bin/env python3

import json

from pyquery import PyQuery  # install using `pip install pyquery`

################################### CONFIGURATION ###################################
location_id = "e1327fde1147429ff28484d1dc279fac8b72226ce87c571d2cdb8bd3e4156069"

# celcius or fahrenheit
unit = "metric"  # metric or imperial

# forcase type
forecast_type = "Hourly"  # Hourly or Daily

########################################## MAIN ##################################

# get html page
_l = "pt-BR" if unit == "metric" else "pt-BR"
url = f"https://weather.com/{_l}/clima/hoje/l/{location_id}"

# get html data
html_data = PyQuery(url=url)

# current temperature
temp = html_data("span[data-testid='TemperatureValue']").eq(0).text()

# min-max temperature
temp_min = (
    html_data("div[data-testid='wxData'] > span[data-testid='TemperatureValue']")
    .eq(1)
    .text()
)
temp_max = (
    html_data("div[data-testid='wxData'] > span[data-testid='TemperatureValue']")
    .eq(0)
    .text()
)

out_data = {
    "text": f"  {temp}C",
    "tooltip": f"Min: {temp_min}C\nMax: {temp_max}C",
}
print(json.dumps(out_data))

