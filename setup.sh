#!/bin/bash
# .dotfiles/setup.sh
# Note: all configuration for everything is in the .bashrc;
# which is why its the only file built here, instead of symlinked.
# Everything else is auto-detected, or uses env var flags.

# files tructure
mkdir -p ~/.local/share ~/.local/bin

# bash
mv ~/.bashrc ~/.bashrc_orig

cat <<EOF > ~/.bashrc
# ~/.bashrc
source ~/.bashrc_orig
source ~/.dotfiles/.bashrc_common

#export BRC_FEAT_KEYCHAINS="id_rsa"
#export BRC_FEAT_GIT_PROXY=1
source ~/.dotfiles/.bashrc_features

EOF

# tmux
ln -rs ~/.dotfiles/.tmux.conf ~/.tmux.conf

# git
ln -rs ~/.dotfiles/.gitignore_global ~/.gitignore_global
git config --global include.path .dotfiles/.gitconfig
# git-proxy:
#[http]
#	sslVerify=true
#[http "https://gitlab.corp.net"]
#	sslVerify=false
#	proxy="socks5://127.0.0.1:1080"

# vim: toggle features w env vars
ln -rs ~/.dotfiles/.vimrc ~/.vimrc
cat <<EOF >> ~/.bashrc
# vim
#export VRC_FEAT_COPILOT=1
#export VRC_FEAT_COC=1
#export VRC_FEAT_CMAKE=1

EOF

# This is to catch various things that add to .bashrc
cat <<EOF >> ~/.bashrc

## Testing

# .bashrc

EOF

# setup.sh

