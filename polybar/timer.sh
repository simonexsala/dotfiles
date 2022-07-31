#!/bin/bash

start=$(date +%H:%m)
dunstify "Productivity Timer" "30 minute timer started at $start" -a Timer -t 5000 -u 2
sleep 1800 # 30 minutes
dunstify "Productivity Timer" "Time is up!" -a Timer -t 5000 -u 2
sleep 300 # 5 minutes
dunstify "Productivity Timer" "Five minutes have passed!" -a Timer -t 5000 -u 2
