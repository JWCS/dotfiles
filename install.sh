#!/bin/bash
# .dotfiles/install.sh

set -o pipefail

function _mkcd(){
  mkdir -p $1 && cd $1
}

function _dist_arch(){
  case "$(uname -m)" in
    aarch64) echo "arm64" ;;
    x86_64) echo "amd64" ;;
    *) return 1 ;;
  esac
}

function _gh_latest_version(){
  # Where $1 is owner/repo
  curl -sL "https://api.github.com/repos/$1/releases/latest" \
  | awk -F\" '/"tag_name":/{print $(NF-1)}' | sed -E 's/v(.*)/\1/g'
}

function _install_gh_deb(){(
  local REPO=${1:?}
  local DL_PATH=${2:?}
  local DL_DEB=${DL_PATH##*/}
  _mkcd ~/Downloads
  curl -OL https://github.com/$REPO/releases/download/$DL_PATH || exit $?
  sudo apt-fast install ./$DL_DEB
)}

function install-keychain(){
  sudo apt-fast install -y keychain
}

function install-subrepo(){
  git clone --filter=blob:none https://github.com/ingydotnet/git-subrepo ~/.local/share/git-subrepo
}

function install-git-delta(){
  local ARCH VERSION REPO
  REPO="dandavison/delta"
  ARCH=$(_dist_arch) || return $?
  VERSION=$(_gh_latest_version $REPO) || return $?
  _install_gh_deb $REPO "${VERSION}/git-delta_${VERSION}_${ARCH}.deb" || return $?
  (
  _mkcd ~/.local/share/delta
  curl -sLO https://github.com/dandavison/delta/raw/refs/heads/main/themes.gitconfig
)}

function install-bat(){
  local ARCH VERSION REPO
  REPO="sharkdp/bat"
  ARCH=$(_dist_arch) || return $?
  VERSION=$(_gh_latest_version $REPO) || return $?
  _install_gh_deb $REPO "v${VERSION}/bat_${VERSION}_${ARCH}.deb"
}

function install-tmux(){
  sudo apt-fast install -y tmux
}

function install-vim(){
  sudo add-apt-repository -y ppa:jonathonf/vim && \
  sudo apt-fast install -y vim-gtk3
}

function install-pipx(){
  # System python is installed exclusively for installing pipx
  sudo apt-fast install -y python3-pip && \
  python3 -m pip install --user pipx && \
  python3 -m pipx ensurepath
}

function install-common-apt(){
  sudo apt-fast install -y silversearcher-ag
}

function install-bash-alias-completion(){
  mkdir ~/.bash_completion.d
  curl https://raw.githubusercontent.com/cykerway/complete-alias/master/complete_alias \
       > ~/.bash_completion.d/complete_alias
}

function install-docker(){
  # Add Docker's official GPG key:
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc || return $?
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || return $?
  sudo apt-fast update

  sudo apt-fast install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin tini || return $?
  # skopeo not found?
  getent group docker &>/dev/null || sudo groupadd docker
  sudo usermod -aG docker $USER
  #newgrp - docker # This launches new shell... no pls
  docker version || echo "NOTE: you must logout and login for non-sudo docker to take effect"

  local ARCH VERSION REPO
  REPO="wagoodman/dive"
  ARCH=$(_dist_arch) || return $?
  VERSION=$(_gh_latest_version $REPO) || return $?
  _install_gh_deb $REPO "v${VERSION}/dive_${VERSION}_linux_${ARCH}.deb"
}

# TODO: add the cli bash script here

# install.sh

