# ~/.bashrc
# LAST_CHANGED 2024-09-04
# Note, atm I'm using it as a collection of "gems", because I'm in too many envs
# Update: source .bashrc_common; those are rm'd from here

# This file only contains NEW content; the default installed .bashrc
# should be moved to this file
source ~/.bashrc_orig

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

# opam configuration
test -r /home/jp-neutrino/.opam/opam-init/init.sh && . /home/jp-neutrino/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

# nodejs version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# More Gems:
buildless (){
  unbuffer colcon build $@ 3>&1 1>&2 2>&3 3>&- | less -R
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

# Simplify downstream ssh/git pass
eval `keychain --eval id_rsa 2>/dev/null`

# Tools
source ~/.local/share/git-subrepo/.rc 2>/dev/null

# Tmux functions!
source ~/.dotfiles/tmux/tmux_functions.sh

## Testing

alias git-proxy="HTTPS_PROXY=socks5://127.0.0.1:1080 git"

# ~/.bashrc
