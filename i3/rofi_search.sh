URL='https://www.google.com/search?q='
QUERY=$(echo '' | rofi -dmenu -p "WebSearch:")
if [ -n "$QUERY" ]; then
    xdg-open "${URL}${QUERY}" 2> /dev/null
    exec i3-msg '[class="Vivaldi-stable"] focus'
fi
