#!/bin/bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#.....................
# Look
#.....................

# xinitrc
ln -sf ${BASEDIR}/xinitrc $HOME/.xinitrc

# Xresources
ln -sf ${BASEDIR}/Xresources $HOME/.Xresources

# Xresources.d
rm -rf $HOME/.Xresources.d
ln -sf ${BASEDIR}/Xresources.d $HOME/.Xresources.d

# i3
rm -rf $HOME/.config/i3
ln -sf ${BASEDIR}/i3 $HOME/.config/i3

# dunst
mkdir $HOME/.config/dunst
ln -sf ${BASEDIR}/dunst/dunstrc $HOME/.config/dunst/dunstrc

# compton
ln -sf ${BASEDIR}/compton.conf $HOME/.config/compton.conf

# cursor pack
mkdir -p $HOME/.icons
mkdir -p $HOME/.icons/default
rm $HOME/.icons/default/cursors
ln -sf ${BASEDIR}/icons/index.theme $HOME/.icons/default/index.theme
ln -sf /usr/share/icons/Capitaine/cursors $HOME/.icons/default/cursors

#.....................
# Terminal
#.....................

# zsh
rm -rf $HOME/.oh-my-zsh
ln -sf ${BASEDIR}/zsh/oh-my-zsh $HOME/.oh-my-zsh
ln -sf ${BASEDIR}/zsh/zprofile $HOME/.zprofile
ln -sf ${BASEDIR}/zsh/zshrc $HOME/.zshrc
cp -r ${BASEDIR}/zsh/zsh-output-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-output-highlighting

#.....................
# Git
#.....................

ln -sf ${BASEDIR}/gitignore $HOME/.gitignore
git config --global core.excludesfile ~/.gitignore

#.....................
# Apps
#.....................

# vim
mkdir $HOME/.vim/colors
mkdir $HOME/.vim/after
mkdir $HOME/.vim/after/syntax
ln -sf ${BASEDIR}/vim/vimrc $HOME/.vimrc
cp ${BASEDIR}/vim/cake.vim $HOME/.vim/colors/cake.vim
cp ${BASEDIR}/vim/python.vim $HOME/.vim/after/syntax/python.vim

#.....................
# emacs
# ...................
rm -rf $HOME/.emacs.d
mkdir $HOME/.emacs.d
ln -sf ${BASEDIR}/emacs/emacs $HOME/.emacs
ln -sf ${BASEDIR}/emacs/themes/molokai. $HOME/.emacs.d/themes
ln -sf ${BASEDIR}/emacs/emacs.service $HOME/.config/systemd/user/emacs.service

# bin
rm -rf $HOME/bin
ln -sf ${BASEDIR}/bin $HOME/bin

#.....................
# Linters
# ...................

# python
ln -sf ${BASEDIR}/linters/python/flake8 $HOME/.config/flake8
ln -sf ${BASEDIR}/linters/python/pylintrc $HOME/.config/.pylintrc

#.....................
# Mail
# ...................
 ln -sf ${BASEDIR}/mail/muttrc $HOME/.muttrc
 ln -sf ${BASEDIR}/mail/neomuttrc $HOME/.neomuttrc
