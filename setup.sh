#!/bin/bash
# .dotfiles/setup.sh

# files tructure
mkdir -p ~/.local/share ~/.local/bin

# bash
mv ~/.bashrc ~/.bashrc_orig

cat <<EOF > ~/.bashrc
#!/bin/bash
# ~/.bashrc
source ~/.bashrc_orig
source ~/.dotfiles/.bashrc_common

#BRC_FEAT_KEYCHAINS="id_rsa"
#BRC_FEAT_GIT_PROXY
source ~/.dotfiles/.bashrc_features

## Testing

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

# vim
cat <<EOF > ~/.vimrc
" ~/.vimrc
source ~/.dotfiles/.vimrc


EOF
# TODO: vim-plug, and plugins
# Atm, not using any "lightweight" and non-internet plugins...

# setup.sh

