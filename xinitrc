#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

python ~/bin/auto_xrandr.py ~/.config/monitors --force &
srandrd python ~/bin/auto_xrandr.py ~/.config/monitors --force &
sleep .1

random-color-picker /home/samreen/.Xresources.d/walls/water_boat.jpg &
compton --config ~/.config/compton.conf -b &
unclutter &
udiskie -F &
dropbox &
davmail -notray > /dev/null 2>&1 &
khalnotifier &

# if [[ ! -d "~/i3logs" ]]; then
# 	mkdir ~/i3logs
# fi
# exec i3 -V >> ~/i3logs/$(date +'%F-%k-%M-%S') 2>&1
exec i3
