#!/bin/bash
HIGHLIGHT="#D8DEE9"
clock() {
	TIME=$(date "+%I:%M")
    DATE=$(date "+%a %m/%d/%y")
	echo -n "%{F$HIGHLIGHT}$(printf '%b' "\uf073")%{F-} $DATE  %{F$HIGHLIGHT}$(printf '%b' "\uf017")%{F-} $TIME"
}
#Copied from /u/Dylan112
workspace() {
	workspacenext="A4:i3-msg workspace next_on_output:"
        workspaceprevious="A5:i3-msg workspace prev_on_output:"
	currentworkspaceline="$(wmctrl -d | grep '\*')"
	
	wslist=$(\
                wmctrl -d \
                | awk '/ / {print $2 $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20}' ORS=''\
                | sed -e 's/\s*  //g' \
                -e 's/\*[ 0-9A-Za-z]*[^ -~]*/  &  /g' \
		-e 's/\-[ 0-9A-Za-z]*[^ -~]*/%{F#A0A0A0}%{A:i3-msg workspace &:}  &  %{A}%{F#A0A0A0}/g' \
		-e 's/\*\([ 0-9A-Za-z]*[^ -~]\)/%{F#FFFFFF}\1%{F-}/g' \
                -e 's/ -/ /g' \
                )
        echo -n "%{$workspacenext}%{$workspaceprevious}$wslist%{A}%{A}"
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
    echo "%{B#c0303048}$(workspace)%{B-}$(windowtitle)%{r}%{B#c0303048}$(bat)  $(clock)%{B-}"
    sleep .1;
done |

lemonbar -p -d -B#c0262626 -F#A0A0A0\
	-f "FiraMono:size=7"\
	-f "FontAwesome:size=8"\
	eDP-1\
	| zsh
