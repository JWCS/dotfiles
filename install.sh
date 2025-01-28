#!/bin/bash
# .dotfiles/install.sh

set -o pipefail

function _has_cmd() {
  type $1 &>/dev/null
}

function _has_pkg(){
  dpkg -s $1 &>/dev/null
}

function _has_ppa(){
  grep -qr "${1:?}" /etc/apt/sources.list*
}

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

function _check_apt-fast(){
  _has_cmd apt-fast || install-apt-fast
}

function _check-git(){
  install-git
}

function _install_gh_deb(){(
  local REPO=${1:?}
  local DL_PATH=${2:?}
  local DL_DEB=${DL_PATH##*/}
  _mkcd ~/Downloads
  _check_apt-fast || return $?
  [ -f $DL_DEB ] && return 1
  curl -OL https://github.com/$REPO/releases/download/$DL_PATH || return $?
  sudo apt-fast install ./$DL_DEB
)}

function install-apt-fast(){
  echo $FUNCNAME
  _has_cmd apt-fast || {
    sudo add-apt-repository -y ppa:apt-fast/stable || return $?
    sudo apt-get update || return $?
    sudo apt-get -y install apt-fast
  }
}

function install-git(){
  _check_apt-fast || return $?
  PPA="git-core/ppa"
  _has_ppa $PPA && return
  echo $FUNCNAME
  sudo add-apt-repository -y ppa:${PPA:?} || return $?
  sudo apt-fast update || return $?
  sudo apt-fast -y install git git-lfs || return $?
}

function install-keychain(){
  echo $FUNCNAME
  _check_apt-fast || return $?
  _has_cmd keychain || sudo apt-fast install -y keychain
}

function install-subrepo(){
  _check-git
  echo $FUNCNAME
  local REPO='~/.local/share/git-subrepo'
  if [ -d $REPO ]; then
    cd $REPO && git pull
  else
    git clone --filter=blob:none https://github.com/ingydotnet/git-subrepo $REPO
  fi
}

function install-meld(){
  _check_apt-fast || return $?
  sudo apt-fast install -y meld dbus-x11 # for meld over ssh, see notes
}

function install-git-delta(){
  echo $FUNCNAME
  local ARCH VERSION REPO SHARE
  REPO="dandavison/delta"
  ARCH=$(_dist_arch) || return $?
  VERSION=$(_gh_latest_version $REPO) || return $?
  SHARE='~/.local/share/delta/'
  _install_gh_deb $REPO "${VERSION}/git-delta_${VERSION}_${ARCH}.deb" || return $?
  [ -f $SHARE/themes.gitconfig ] && return
  (
  _mkcd $SHARE
  curl -sLO https://github.com/dandavison/delta/raw/refs/heads/main/themes.gitconfig
)}

function install-bat(){
  echo $FUNCNAME
  local ARCH VERSION REPO
  REPO="sharkdp/bat"
  ARCH=$(_dist_arch) || return $?
  VERSION=$(_gh_latest_version $REPO) || return $?
  _install_gh_deb $REPO "v${VERSION}/bat_${VERSION}_${ARCH}.deb"
}

function install-tmux(){
  echo $FUNCNAME
  _check_apt-fast || return $?
  _has_cmd tmux || sudo apt-fast install -y tmux
}

function install-vim(){
  echo $FUNCNAME
  _check_apt-fast || return $?
# Note: jonathon passed away; this is now stale, and 2025-01 there's no replacement yet...
#  PPA='jonathonf/vim'
#  _has_ppa $PPA \
#  || { sudo add-apt-repository -y ppa:${PPA:?} && sudo apt-fast update; } || return $?
  _has_pkg vim-gtk3 || sudo apt-fast install -y vim-gtk3
}

function install-pipx(){
  echo $FUNCNAME
  _check_apt-fast || return $?
  # System python is installed exclusively for installing pipx
  _has_cmd pipx || { \
  sudo apt-fast install -y python3-pip && \
  python3 -m pip install --user pipx && \
  python3 -m pipx ensurepath ; }
}

function install-pyenv(){
  # Note: these were taken from the docs
  _check_apt-fast || return $?
  _check-git || return $?
  sudo apt-fast update
  sudo apt-fast install -y \
    build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl git \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev || return
  curl -fsSL https://pyenv.run | bash
}

function install-common-apt(){
  echo $FUNCNAME
  _check_apt-fast || return $?
  _has_cmd ag || sudo apt-fast install -y silversearcher-ag
}

function install-bash-alias-completion(){
  echo $FUNCNAME
  [ -f ~/.bash_completion.d/complete_alias ] && return
  mkdir -p ~/.bash_completion.d
  curl https://raw.githubusercontent.com/cykerway/complete-alias/master/complete_alias \
       > ~/.bash_completion.d/complete_alias
}

function install-docker(){
  echo $FUNCNAME
  _check_apt-fast || return $?
  _has_cmd docker && docker version &>/dev/null && return
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

# Utilities
# https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
(return 0 2>/dev/null) && sourced=1 || sourced=0

function _install-list(){
declare -F | awk '$3~/^install-/{sub(/^install-/,"",$3); print $3}'
}

# If not sourced
if [ "$sourced" -eq "0" ]; then
  function _arg-alias(){ sed -r "s/(^| )$1($| )/\1$2 /g"; }
  function _arg-alias-list-expr(){
    printf -- 'sed -r '
    _install-list | while read -r short; do
      printf -- '-e "s/(^| )%s($| )/\\1%s /g" ' $short install-$short
    done
  }
  ## Filters: pick one
  # Multiple cmds chained with '--', optional leading '--' on first arg
  # ./this.sh [--] fn1 [arg1 ...] [-- fn2] ...
  function _chain_dashes(){ sed -r -e "s/^ *--//g" -e "s/--/ \&\& /g"; }
  # Multiple cmds, taking no args, whitespace sep
  # ./this.sh fn1 [fn2] ...
  function _chain_space(){ sed -r -e "s/^ *//g" -e "s/ +/ \&\& /g"; }
  ## Cmds:
  if [ -z "$1" ]; then
    _install-list
  elif [ "$1" == "all" ]; then
    _install-list | while read -r short; do
      eval install-$short || { echo "ERROR $?"; break; }
    done
  else
    ARGS=$(echo "$*" | _chain_space | eval $(_arg-alias-list-expr))
    eval $ARGS || echo "ERROR $?"
    echo Done
  fi
fi

# install.sh

