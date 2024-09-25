#!/bin/bash
# .dotfiles/setup.sh

# files tructure
mkdir -p ~/.local/share ~/.local/bin

# bash
mv ~/.bashrc ~/.bashrc_orig

cat <<EOF > ~/.bashrc
# ~/.bashrc
source ~/.bashrc_orig
source ~/.dotfiles/.bashrc_common

#BRC_FEAT_KEYCHAINS="id_rsa"
#BRC_FEAT_GIT_PROXY=1
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
cat <<EOF >> ~/.bashrc
# vim
#VRC_FEAT_COPILOT=1
#VRC_FEAT_COC=1

EOF

# This is to catch various things that add to .bashrc
cat <<EOF >> ~/.bashrc

## Testing

# .bashrc

EOF

# setup.sh

