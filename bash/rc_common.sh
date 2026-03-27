# ~/.dotfiles/.bashrc_common
# This sets up environment shell stuff, common to shell instance behavior
# It also sources "common utils", but other functions / extensions are in .bashrc_features

# Custom adds
[[ $- == *i* ]] && stty -ixon # Stops the Ctrl-S thing in vim # The weird first half is "inapprop ioctl for device stty", only interactive mode
PATH=~/.local/bin:$PATH

source ~/.dotfiles/bash/util.sh

export HISTTIMEFORMAT="%F %T "
# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# https://stackoverflow.com/questions/9457233/unlimited-bash-history
unset HISTSIZE
unset HISTFILESIZE
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
shopt -s histappend

# TODO: modernize ps1's; the rest of the dotfiles are cleaner
# PS1 Mod
parse_git_repo() { local -; set +x
  basename -s .git `git config --get remote.origin.url` 2> /dev/null
}
parse_git_branch() { local -; set +x
  # dotfiles home git branch I want to ignore
  if [ "$(parse_git_repo)" != dotfiles ]; then
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
  fi
}
PS1='$(parse_git_branch)\[\033[00m\]'$PS1
show_virtual_env() { local -; set +x
  if [[ -n "${VIRTUAL_ENV:-}" && -n "${DIRENV_DIR:-}" ]]; then
    echo "($(basename $VIRTUAL_ENV))"
  fi
}
PS1='$(show_virtual_env)'$PS1
PS1=$PS1'\n> '

# general
