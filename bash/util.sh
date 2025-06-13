#!/bin/bash
# gems and helpers

# utils

function _has_cmd() {
  type $1 &>/dev/null
}

function _is_set() {
  [[ -v $1 ]]
}

function _is_nonempty() {
  [[ -n $1 ]]
}

function _mk_alias(){
  rest="${@:2}"
  alias $1="$rest"
}

# bash alias completion
if [ -f ~/.bash_completion.d/complete_alias ]; then
  # Alias completion
  # https://unix.stackexchange.com/questions/4219/how-do-i-get-bash-completion-for-command-aliases
  source ~/.bash_completion.d/complete_alias
  function alias_nice(){
    _mk_alias "$@"
    complete -F _complete_alias $1
  }
else
  function alias_nice(){
    _mk_alias "$@"
  }
fi

# For safely adding path to path
function addToPATH {
  case ":$PATH:" in
    *":$1:"*) :;; # already there
    *) PATH="$1:$PATH";; # or PATH="$PATH:$1"
  esac
}

# general

cleardir () {
  ls -A | xargs rm -rf
}

function sed-all(){
  local from to path
  from=${1:?}
  to=${2:?}
  path=${3:-./}
  if _has_cmd ag; then
    ag -lQ ${from:?} -- ${path:?} \
    | xargs -I{} sed -i "s/${from:?}/${to:?}/g" {}
  elif _has_cmd rg; then
    rg -lF ${from:?} -- ${path:?} \
    | xargs -I{} sed -i "s/${from:?}/${to:?}/g" {}
  else echo "ag or rg not installed!" >&2; return 1;
  fi
}

