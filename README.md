# Dotfiles for Arch, i3-gaps, and lemonbar-xft
A lot of this was taken from [okubax's dotfiles](https://github.com/okubax/dotfiles)

# Requirements
General
* urxvt (rxvt-unicode)
* [i3-gaps](https://github.com/Airblader/i3)
* [lemonbar-xft](https://aur.archlinux.org/packages/lemonbar-xft-git/)
* zsh (set as your default shell)
* update your PATH to include $HOME/bin
* compton
* [j4-dmenu-desktop](https://aur.archlinux.org/packages/j4-dmenu-desktop/)

Zsh
* urxvt-perls
* tmux
* fortune-mod

Fonts
* [FontAwesome](https://aur.archlinux.org/packages/ttf-font-awesome/)
* FiraMono (ttf-fira-mono)

Random-color-picker
* [hsetroot](https://aur.archlinux.org/packages/hsetroot/)
* update Xresources.d/.colors to use your home directory rather than /home/samreen

Vim
* [vim-plug](https://github.com/junegunn/vim-plug)
* run vim after getting vim-plug and run :PlugInstall
* (Optional) pylint (python2-pylint for python2 or python-pylint for python3)
* (Optional) flake8
