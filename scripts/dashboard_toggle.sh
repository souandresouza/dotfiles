#!/bin/bash
pkill -f dashboard.sh || kitty --app-id=dashboard -e bash /home/andre/.config/scripts/dashboard.sh
