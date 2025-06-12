#!/bin/bash
# .dotfiles/setup_root.sh
# To make the sudo-su experience ok
# Idk exactly how much I want root to access, or ought to access... but this should be fine & good

function _ln_mirror_root(){
  local ORIG FILE
  ORIG=${1:?}
  FILE=${ORIG##*/}
  [ -L /root/${FILE:?} ] && return
  sudo rm -rf /root/${FILE:?} || :
  sudo ln -s ${ORIG:?} /root/${FILE:?}
}

function setup_root(){
_ln_mirror_root ~/.dotfiles || return $?
_ln_mirror_root ~/.inputrc || return $?
sudo mv /root/.bashrc /root/.bashrc_orig || return $?
_ln_mirror_root ~/.bashrc || return $?
_ln_mirror_root ~/.tmux.conf || return $?
_ln_mirror_root ~/.tmux || return $?
_ln_mirror_root ~/.vimrc || return $?
_ln_mirror_root ~/.vim || return $?
_ln_mirror_root ~/.ssh || return $?
_ln_mirror_root ~/.gitattributes_global || return $?
_ln_mirror_root ~/.gitignore_global || return $?
_ln_mirror_root ~/.gitconfig || return $?
# These aren't created by setup.sh, but still should be shared?
mkdir -p ~/.local && _ln_mirror_root ~/.local || return $?
mkdir -p ~/.gnupg && _ln_mirror_root ~/.gnupg || return $?
}

# Utilities
# https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
(return 0 2>/dev/null) && sourced=1 || sourced=0

# If not sourced
if [ "$sourced" -eq "0" ]; then
  setup_root
fi

