# ~/.bashrc
# LAST_CHANGED 2023-08-17
# Note, atm I'm using it as a collection of "gems", because I'm in too many envs

# This file only contains NEW content; the default installed .bashrc
# should be moved to this file
source ~/.bashrc_orig

# Custom adds
stty -ixon # Stops the Ctrl-S thing in vim

# ROS
source /opt/ros/melodic/setup.bash

# cuda
export LD_LIBRARY_PATH=/usr/local/cuda-9.0/lib64:$LD_LIBRARY_PATH
export PATH=/usr/local/cuda-9.0/bin:$PATH

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
source $(pyenv root)/completions/pyenv.bash

# direnv
eval "$(direnv hook bash)"
alias tmux='direnv exec / tmux'

# PS1 Mod
parse_git_repo() {
  basename -s .git `git config --get remote.origin.url` 2> /dev/null
}
parse_git_branch() {
  # dotfiles home git branch I want to ignore
  if [ "$(parse_git_repo)" != dotfiles ]; then
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
  fi
}
PS1='$(parse_git_branch)\[\033[00m\]'$PS1
show_virtual_env() {
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $VIRTUAL_ENV))"
  fi
}
PS1='$(show_virtual_env)'$PS1
PS1=$PS1'\n> '

# opam configuration
test -r /home/jp-neutrino/.opam/opam-init/init.sh && . /home/jp-neutrino/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

# nodejs version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# More Gems:
cleardir () {
  ls -A | xargs rm -rf
}

buildless (){
  unbuffer colcon build $@ 3>&1 1>&2 2>&3 3>&- | less -R
}

export PROMPT_COMMAND='history -a'

alias docker-rmi-none="docker images -a | grep '<none>' | awk '{ print $3; }' | xargs docker rmi"
function rm-orig(){
  find ${1:-.} -name '*.orig' -exec rm {} \;
}
function meldtool_wsl(){
  meld --auto-merge \
    "$(wslpath -aw $LOCAL)" "$(wslpath -aw $BASE)" "$(wslpath -aw $REMOTE)" \
    --output "$(wslpath -aw $MERGED)" \
    --label=Local --label=Base --label=Remote \
    --diff "$(wslpath -aw $BASE)" "$(wslpath -aw $LOCAL)" \
    --diff "$(wslpath -aw $BASE)" "$(wslpath -aw $REMOTE)"
}
function meldtool(){
  : ${LOCAL:=${1:?}}
  : ${REMOTE:=${2:?}}
  : ${MERGED:=${3:?}}
  : ${BASE:=${3}}
  meldtool_wsl
}

# ~/.bashrc
