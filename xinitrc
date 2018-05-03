#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

xrdb -merge ~/.Xresources &
python ~/bin/auto_xrandr.py ~/.config/monitors --force &
srandrd python ~/bin/auto_xrandr.py ~/.config/monitors &
compton --config ~/.config/compton.conf -b &
/home/samreen/.Xresources.d/random-color-picker &
unclutter &
udiskie -F &
dropbox &

# if [[ ! -d "~/i3logs" ]]; then
# 	mkdir ~/i3logs
# fi
# exec i3 -V >> ~/i3logs/$(date +'%F-%k-%M-%S') 2>&1
exec i3
