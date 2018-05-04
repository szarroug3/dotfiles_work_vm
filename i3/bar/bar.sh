#!/bin/bash
HIGHLIGHT="#595b59"
clock() {
    TIME=$(date "+%I.%M")
    DATE=$(date "+%a %m.%d.%y")
    echo -n "%{F$HIGHLIGHT}$(printf '%b' "\uf073")%{F-} $DATE  %{F$HIGHLIGHT}$(printf '%b' "\uf017")%{F-} $TIME"
}
volume() {
    MUTE=$(amixer get Speaker | grep % | sed -n 1p | awk -F '[' '{print $3}' | awk -F ']' '{print $1}')
    VOL=$(amixer get Speaker | grep % | sed -n 1p | awk -F '[' '{print $2}' | awk -F '%]' '{print $1}')
    if [ "$MUTE" == 'off' ] || [ "$VOL" == 0 ]; then
        echo -n "%{F$HIGHLIGHT}$(printf '%-b' "\uf026")%{F-}%{O14}Mute"
    elif (($VOL > 49)); then
        echo -n "%{F$HIGHLIGHT}$(printf '%-b' "\uf028")%{F-}$(printf ' %03.2d%s' "$VOL" "%")"
    else
        echo -n "%{F$HIGHLIGHT}$(printf '%-b' "\uf027")%{F-}%{O4}$(printf ' %03.2d%s' "$VOL" "%")"
    fi
}
wifi() {
    vpn=false
    if ping -c 1 home.hpe.com &> /dev/null; then
        VPN='\uf084'
    else
        VPN='\uf1eb'
    fi
    echo -e "%{F$HIGHLIGHT}$VPN %{F-}$(iw wlp2s0 link | grep 'SSID' | cut -c 8-)"
}
mail() {
    notmuch new > /dev/null
    NUM_NEW_MAIL=$(notmuch search --format:json tag:unread | jq ".[] | .matched" | awk '{n += $1}; END{print n}')

    if [[ $NUM_NEW_MAIL ]]; then
        echo -e "%{F$HIGHLIGHT}\uf0e0 %{F-}$NUM_NEW_MAIL"
    fi
}
music() {
    THUNNER=~/.thunner.info
    NOWPLAYING=~/.nowplaying.info
    GPMDP=~/.config/Google\ Play\ Music\ Desktop\ Player/json_store/playback.json

    if [ -s "$THUNNER" ]; then
        STATUS=$(head -n 1 "$THUNNER")
        SONG=$(tail -n 1 "$THUNNER")
        echo -n " %{F$HIGHLIGHT}$(printf '%b' $STATUS)%{F-} $SONG "
    elif [ -s "$NOWPLAYING" ]; then
        SONG=$(cat "$NOWPLAYING")
        echo -e "%{F$HIGHLIGHT}\uf025 %{F-} $SONG "
    elif [ -s "$GPMDP" ] && [[ $(cat "$GPMDP" | jq 'select(.playing)') ]]; then
        SONGINFO=$(cat "$GPMDP" | jq -r 'select(.playing) | "\(.song.title) - \(.song.artist) [\(.song.album)]"')
        echo -e "%{F$HIGHLIGHT}\uf025 %{F-} $SONGINFO "
    else
        echo -n ""
    fi
}
#Copied from /u/Dylan112
workspace() {
    workspacenext="A4:i3-msg workspace next_on_output:"
    workspaceprevious="A5:i3-msg workspace prev_on_output:"
    currentworkspaceline="$(wmctrl -d | grep '\*')"
    
    wslist=$(\
             wmctrl -d \
             | awk '/ / {print $2 $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20}' ORS=''\
             | sed -e 's/\s*//g' \
             -e 's/\*[0-9A-Za-z]*[^ -~]*/& /g' \
             -e 's/\-[0-9A-Za-z]*[^ -~]*/%{A:i3-msg workspace &:} & %{A}/g' \
             -e 's/\*\([0-9A-Za-z]*[^ -~]*\)/%{F#FFFFFF}%{+u} \1%{-u}%{F-}/g' \
             -e 's/ -/ /g' \
          )
        echo -e "%{F$HIGHLIGHT} \uf24d %{F-}%{$workspacenext}%{$workspaceprevious}$wslist%{A}%{A}%{F$HIGHLIGHT} \uf120 %{F-}"
}
windowtitle(){
    # Grabs focused window's title
    # The echo "" at the end displays when no windows are focused.
    TITLE=$(xdotool getactivewindow getwindowname 2>/dev/null | sed -n 1p || echo "")
    TITLECUT=$(xdotool getactivewindow getwindowname 2>/dev/null | sed -n 1p | sed 's/\///g;s/-//g;s/ /\\/g' | cut -c 1-6 || echo "")

    if [ "$TITLECUT" = "glenn@" ]; then
        echo "$(printf '%b' "\ue1d9") $(echo "$TITLE" | cut -c 15-50)"
    else
        echo "$TITLE" | cut -c 1-50
    fi
}
bat() {
    status=$(cat /sys/class/power_supply/BAT0/status)
    capacity=$(cat /sys/class/power_supply/BAT0/capacity)

    if [ "$status" == "Charging" ]; then
        echo -e "%{F$HIGHLIGHT}\uf1e6 %{F-}$capacity%"
    elif (($capacity > 89)); then
        echo -e "%{F$HIGHLIGHT}\uf240 %{F-}$capacity%"
    elif (($capacity > 64)); then
        echo -e "%{F$HIGHLIGHT}\uf241 %{F-}$capacity%"
    elif (($capacity > 39)); then
        echo -e "%{F$HIGHLIGHT}\uf242 %{F-}$capacity%"
    elif (($capacity > 14)); then
        echo -e "%{F$HIGHLIGHT}\uf243 %{F-}$capacity%"
    else
        echo -e "%{F$HIGHLIGHT}\uf244 %{F-}$capacity%"
    fi
}
while true; do
    echo "%{U#BC5A74}$(workspace)$(windowtitle)%{c}$(music)%{r}$(mail)  $(wifi)  $(volume)  $(clock)  $(bat)"
    sleep .1;
done |

lemonbar -p -d -B#C0000000 -F#FFFFFF\
    -g x23++\
    -f "FiraMono:bold:size=8"\
    -f "FontAwesome:bold:size=9"\
    -u 3\
    eDP-1\
    | zsh
