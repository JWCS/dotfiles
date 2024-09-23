#!/bin/bash
# .dotfiles/install.sh

function install-keychain(){
  sudo apt-get install keychain
}

function install-subrepo(){
  git clone --filter=blob:none https://github.com/ingydotnet/git-subrepo ~/.local/share/git-subrepo
}

# TODO: add the cli bash script here

# install.sh

