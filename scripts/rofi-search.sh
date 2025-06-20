#!/bin/bash
# Rofi web search script
query=$(rofi -dmenu -p "Web Search: ")
if [ -n "$query" ]; then
    firefox --new-tab "https://www.google.com/search?q=$query"
fi
