#!/bin/bash
# new_machine_setup.sh
# This file might not be on the new machine at very beginning, but
# it's at least good docs for what should be done... probably
# as a pre-req for .dotfiles to get properly installed/setup itself.
# OR, you can run it before anything else with curl:

# bash <(curl -s http//raw.github.com/JWCS/dotfiles/new_machine_setup.sh)

sudo apt update

man-db -y && sudo unminimize

# setup apt
sudo su
apt install -y software-properties-common dialog ca-certificates bash-completion
add-apt-repository -y ppa:apt-fast/stable
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y apt-fast
exit
# TODO: update mirrors by speed
# https://askubuntu.com/a/719551/1060493
# curl -s http://mirrors.ubuntu.com/mirrors.txt | xargs -n1 -I {} sh -c 'echo `curl -r 0-102400 -s -w %{speed_download} -o /dev/null {}/ls-lR.gz` {}' |sort -g -r |head -1| awk '{ print $2  }'
# Note: apt-fast.conf has different mirrors than apt sources; both locations need update
# Note: some cloud vm's might return only one mirror... their version of ubuntu might already be optimized...

# lowlevel/expected
sudo apt-fast install -y netcat make curl wget less openssh-client inotify-tools

# common
sudo add-apt-repository -y ppa:git-core/ppa ; sudo apt-fast update
sudo apt-fast install -y git git-lfs fd-find ripgrep tmux proxychains jq socat keychain
[ ! -f ~/.local/bin/fd ] && mkdir -p ~/.local/bin && ln -s $(which fdfind) ~/.local/bin/fd

# TODO: actually, hv this source install.sh, then run these; bc likely still want to run these once dotfiles

# Last but not least, setup self
# git clone --filter=blob:none # ssh/https, dep if ssh key installed...

