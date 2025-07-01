#!/bin/bash
# Rofi web search script
query=$(rofi -dmenu -p "Web Search: ")
if [ -n "$query" ]; then
    zen-browser --new-tab "https://www.google.com/search?q=$query"
fi
