# Dotfiles for Arch, i3-gaps, and lemonbar-xft
A lot of this was taken from [okubax's dotfiles](https://github.com/okubax/dotfiles) and [nvnehi's dotfiles](https://github.com/nvnehi/dotfiles)

# Requirements
General
* X11 (xorg-server, xorg-xinit, xorg-xrandr, xorg-xbacklight)
* urxvt (rxvt-unicode)
* [i3-gaps](https://github.com/Airblader/i3)
* [lemonbar-xft](https://aur.archlinux.org/packages/lemonbar-xft-git/)
* zsh (set as your default shell)
* update your PATH to include $HOME/bin
* compton
* emacs
* unclutter

Zsh
* urxvt-perls
* tmux
* fortune-mod
* highlight
* [keyboard-select](https://github.com/muennich/urxvt-perls)

Rofi
* rofi
* xdg-utils

Fonts
* [FontAwesome](https://aur.archlinux.org/packages/ttf-font-awesome/)
* FiraMono (ttf-fira-mono)

Cursors
* [Capitaine Cursors](https://aur.archlinux.org/packages/capitaine-cursors/)

Bar.sh
* alsa (alsa-utils)
* wmctrl
* [optional] iw (fix wifi function in bar.sh and add $(wifi) at the bottom where you want it in the bar)

Random-color-picker
* [hsetroot](https://aur.archlinux.org/packages/hsetroot/)
* update Xresources.d/.colors to use your home directory rather than /home/samreen

Vim
* [vim-plug](https://github.com/junegunn/vim-plug)
* run vim after getting vim-plug and run :PlugInstall
* (Optional) pylint (python2-pylint for python2 or python-pylint for python3)
* (Optional) flake8

Emacs
* Run emacs as a daemon using "systemctl --user enable --now emacs" after running dots.sh

Mail
* neomutt
* offlineimap [need to setup]
* notmuch [need to setup]
