#!/bin/bash
# .dotfiles/setup.sh
# Note: all configuration for everything is in the .bashrc;
# which is why its the only file built here, instead of symlinked.
# Everything else is auto-detected, or uses env var flags.
# Note: some files can harmlessly be ran again; this one, is bad

# files structure
function _mk_file_structure(){
mkdir -p ~/.local/share ~/.local/bin
}

# inputrc
function _ln_inputrc(){
[ -f ~/.inputrc ] || ln -rs ~/.dotfiles/.inputrc ~/.inputrc
}

# bash
function _bashrc_init(){
[ -f ~/.bashrc_orig ] && { echo "ERROR: bashrc_orig already exists!"; return 1; }
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
[ -f ~/.tmux.conf ] || ln -rs ~/.dotfiles/.tmux.conf ~/.tmux.conf
# Note: this references tpm, which has to be installed as well...
}

# git
function _gitconf_init(){
[ -f ~/.gitignore_global ] || ln -rs ~/.dotfiles/.gitignore_global ~/.gitignore_global
cat <<EOF > ~/.gitconfig
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
mkdir -p ~/.ssh
cat <<EOF >> ~/.ssh/config
# .ssh/config
HashKnownHosts yes
HostKeyAlgorithms +ssh-rsa
PubkeyAcceptedKeyTypes +ssh-rsa

#Host gitlab.corp.net
#HostName gitlab.corp.net
#User git
#ProxyCommand nc -v -x 127.0.0.1:1080 %h %p

EOF
}

# vim: toggle features w env vars
function _vimrc_init(){
ln -rs ~/.dotfiles/.vimrc ~/.vimrc
cat <<EOF >> ~/.bashrc
# vim
#export VRC_FEAT_COPILOT=1
#export VRC_FEAT_COC=1
#export VRC_FEAT_CMAKE=1
#export VRC_FEAT_TP_STD=1

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
_mk_file_structure && \
_ln_inputrc && \
_bashrc_init && \
_ln_tmux && \
_gitconf_init && \
_sshconf_init && \
_vimrc_init && \
_bashrc_footer && \
echo "Remember to setup .gitconfig, .ssh/config, and ca-certificate if corp pc"
}

# Utilities
# https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
(return 0 2>/dev/null) && sourced=1 || sourced=0

# If not sourced
if [ "$sourced" -eq "0" ]; then
  main
fi

# setup.sh

