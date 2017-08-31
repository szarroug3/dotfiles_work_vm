#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

xrdb -merge ~/.Xresources &
xrandr --output VGA-1 --auto &
compton --config ~/.config/compton.conf -b &
/home/samreen/.Xresources.d/random-color-picker &
VBoxClient --clipboard &

#exec i3 -V >> ~/i3log-$(date +'%F-%k-%M-%S') 2>&1
exec i3
