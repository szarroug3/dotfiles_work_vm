#!/bin/bash
HIGHLIGHT="#595b59"
clock() {
    TIME=$(date "+%I.%M")
    DATE=$(date "+%a %m.%d.%y")
    CAL=$(khal list now --format "{start-style} {title}" -a "Calendar" | grep Today -A 1 | sed -n 2p)
    if [[ ! -z $CAL ]]; then
        echo -n "%{F$HIGHLIGHT}$(printf '%b' "\uf073")%{F-} $DATE  %{F$HIGHLIGHT}$(printf '%b' "\uf017")%{F-} $TIME  %{F$HIGHLIGHT}$(printf '%b' "\uf274")%{F-} $CAL"
    else
        echo -n "%{F$HIGHLIGHT}$(printf '%b' "\uf073")%{F-} $DATE  %{F$HIGHLIGHT}$(printf '%b' "\uf017")%{F-} $TIME"
    fi
}
volume() {
    MUTE=$(pactl list sinks | grep 'Mute:' | head -n 2 | tail -n 1 | awk -F ': ' '{print $2}')
    VOL=$(pactl list sinks | grep '^[[:space:]]Volume:' | head -n 2 | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')
    if [ "$MUTE" == 'yes' ] || [ "$VOL" == 0 ]; then
        echo -n "%{F$HIGHLIGHT}$(printf '%-b' "\uf026")%{F-}%{O14}Mute"
    elif (($VOL > 49)); then
        echo -n "%{F$HIGHLIGHT}$(printf '%-b' "\uf028")%{F-}$(printf ' %03.2d%s' "$VOL" "%")"
    else
        echo -n "%{F$HIGHLIGHT}$(printf '%-b' "\uf027")%{F-}%{O4}$(printf ' %03.2d%s' "$VOL" "%")"
    fi
}
wifi() {
    if ip link show | grep -q tun0; then
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
workspace() {
    WORKSPACE="%{F$HIGHLIGHT} \uf24d %{F-}"
    for ROW in $(i3-msg -t get_workspaces | jq '. |=sort_by(.num)' | jq -c --arg M "$1" '.[] | select(.output==$M)'); do
        NUM="$(echo $ROW | jq .num)"
        FOCUSED="$(echo $ROW | jq .focused)"
        if [[ $FOCUSED = true ]]; then
            WORKSPACE+="%{+u} $NUM %{-u}"
        else
            WORKSPACE+="%{A:i3-msg workspace $NUM:} $NUM %{A}"
        fi
    done
    WORKSPACE+="%{F$HIGHLIGHT} \uf120 %{F-}"
    echo -e "$WORKSPACE"
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

# List of all the monitors/screens you have in your setup
while true; do
    TMP=0
    BAROUT=""
    # BAR="$(windowtitle)%{c}$(music)%{r}$(mail)  $(wifi)  $(volume)  $(clock)  $(bat)"
    BAR="$(windowtitle)%{c}$(music)%{r}$(mail)  $(wifi)  $(volume)  $(clock)  $(bat)"
    for MONITOR in $(i3-msg -t get_outputs | jq -r '. |=sort_by(.rect.x)' | jq -r '.[] | select(.name!="xroot-0") | .name'); do
        BAROUT+="%{S${TMP}}%{U#BC5A74}%{l}$(workspace $MONITOR)$BAR"
        let TMP=$TMP+1
    done
    echo $BAROUT
done |

lemonbar -p -d -B#C0000000 -F#FFFFFF\
                        -g x23++\
                        -f "FiraMono:bold:size=8"\
                        -f "FontAwesome:bold:size=9"\
                        -u 3\
                        | zsh
