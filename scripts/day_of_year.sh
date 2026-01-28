#!/bin/bash
CURRENT_DAY=$(date +%j)
YEAR_DAYS=$(date -d 'Dec 31' +%j)
echo "$CURRENT_DAY/$YEAR_DAYS"
