#!/bin/bash
# .dotfiles/setup.sh
# Note: all configuration for everything is in the .bashrc;
# which is why its the only file built here, instead of symlinked.
# Everything else is auto-detected, or uses env var flags.

# files structure
function _mk_file_structure(){
mkdir -p ~/.local/share ~/.local/bin
}

# inputrc
function _ln_inputrc(){
ln -rs ~/.dotfiles/.inputrc ~/.inputrc
}

# bash
function _bashrc_init(){
mv ~/.bashrc ~/.bashrc_orig
cat <<EOF > ~/.bashrc
# ~/.bashrc
source ~/.bashrc_orig
source ~/.dotfiles/.bashrc_common

#export BRC_FEAT_KEYCHAINS="id_rsa"
#export BRC_FEAT_GIT_PROXY=1
source ~/.dotfiles/.bashrc_features

EOF
}

# tmux
function _ln_tmux(){
ln -rs ~/.dotfiles/.tmux.conf ~/.tmux.conf
# Note: this references tpm, which has to be installed as well...
}

# git
function _gitconf_init(){
ln -rs ~/.dotfiles/.gitignore_global ~/.gitignore_global
cat <<EOF ~/.gitconfig
# ~/.gitconfig
[user]
#	name = My Name
#	email = my@email
[include]
	path = .dotfiles/.gitconfig
	#path = .dotfiles/.gitconfig.delta
# git-proxy:
#[http]
#	sslVerify=true
#[http "https://gitlab.corp.net"]
#	sslVerify=false
#	proxy="socks5://127.0.0.1:1080"

EOF
}

function _sshconf_init(){
cat <<EOF >> ~/.ssh/config
# .ssh/config
HashKnownHosts yes
HostKeyAlgorithms +ssh-rsa
PubkeyAcceptedKeyTypes +ssh-rsa

EOF
#Host gitlab.corp.net
#HostName gitlab.corp.net
#User git
#ProxyCommand nc -v -x 127.0.0.1:1080 %h %p
}

# vim: toggle features w env vars
function _vimrc_init(){
ln -rs ~/.dotfiles/.vimrc ~/.vimrc
cat <<EOF >> ~/.bashrc
# vim
#export VRC_FEAT_COPILOT=1
#export VRC_FEAT_COC=1
#export VRC_FEAT_CMAKE=1

EOF
}

# This is to catch various things that add to .bashrc
function _bashrc_footer(){
cat <<EOF >> ~/.bashrc

## Testing

# TODO: dedup PATH?
# .bashrc

EOF
}

function main(){
_mk_file_structure
_ln_inputrc
_bashrc_init
_ln_tmux
_gitconf_init
_sshconf_init
_vimrc_init
_bashrc_footer
echo "Remember to setup .gitconfig, .ssh/config, and ca-certificate if corp pc"
}

# TODO: if not sourced then run main
main

# setup.sh

