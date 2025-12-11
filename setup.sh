#!/bin/bash
# .dotfiles/setup.sh
# Note: all configuration for everything is in the .bashrc;
# which is why its the only file built here, instead of symlinked.
# Everything else is auto-detected, or uses env var flags.
# Note: some files can harmlessly be ran again; this one, is bad

function _has_cmd() {
  type "$1" &>/dev/null
}

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
#export BRC_FEAT_WSL=1
source ~/.dotfiles/.bashrc_features

EOF
}

# tmux
function _ln_tmux(){
[ -f ~/.tmux.conf ] || ln -rs ~/.dotfiles/.tmux.conf ~/.tmux.conf || return $?
# Note: this references tpm, which has to be installed as well...
if _has_cmd tmux; then # TODO: cleanup
  tmux new-session -d -s setup
  tmux send-keys -t setup '~/.tmux/plugins/tpm/bin/install_plugins && ~/.tmux/plugins/tpm/bin/update_plugins all; exit' Enter
  #tmux send-keys -t setup '~/.tmux/plugins/tpm/bin/install_plugins' Enter
  #tmux send-keys -t setup '~/.tmux/plugins/tpm/bin/update_plugins all' Enter
  #tmux kill-session -t setup
fi
}

# git
function _gitconf_init(){
[ -f ~/.gitignore_global ] || ln -rs ~/.dotfiles/git/.gitignore_global ~/.gitignore_global
[ -f ~/.gitattributes_global ] || ln -rs ~/.dotfiles/git/.gitattributes_global ~/.gitattributes_global
cat <<EOF > ~/.gitconfig
# ~/.gitconfig
[user]
#	name = My Name
#	email = my@email
[include]
	path = ~/.dotfiles/git/.gitconfig
	#path = ~/.dotfiles/git/.gitconfig.delta
  #path = ~/.dotfiles/wsl2/.gitconfig

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
HashKnownHosts no
HostKeyAlgorithms +ssh-rsa
PubkeyAcceptedKeyTypes +ssh-rsa
StrictHostKeyChecking accept-new

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
#export VRC_LANG_MD=1
#export VRC_LANG_SH=1

EOF
if _has_cmd vim; then # TODO: cleanup
  vim '+:PlugUpdate' '+:qa'
fi
}

# This is to catch various things that add to .bashrc
function _bashrc_footer(){
cat <<EOF >> ~/.bashrc

## Testing

# TODO: dedup PATH?
# .bashrc

EOF
}

function setup(){
_mk_file_structure && \
touch ~/.sudo_as_admin_successful && \
~/.dotfiles/install.sh git tmux vim curl && \
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
  setup
fi

# setup.sh

