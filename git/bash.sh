#!/bin/bash
# git cmds with extra shell

source ~/.dotfiles/bash/util.sh

function rm-orig(){
  find ${1:-.} -name '*.orig' -exec rm {} \;
}

function git-branch-prune(){
  git fetch -p && git branch -vv | cut -b3- | awk '/: gone]/{system("git branch -d "$1)}'
}

function git-diff-sort(){
git diff --numstat $@ \
| awk '{print ($1+$2)"\t"$3}' | sort -k1 -nr | cut -f2 \
| git diff -O/dev/stdin $@
}

# TODO: add to git-alias?
# TODO: add -n support... somehow minimal parsing?
# https://stackoverflow.com/a/14200660/
_GIT_NEXT_ORIGIN=''
function git-next-origin(){
  if [ -z "$_GIT_NEXT_ORIGIN" ]; then >&2 echo "No origin set"; return 1; fi
  git checkout "$_GIT_NEXT_ORIGIN" || return $?
  _GIT_NEXT_ORIGIN=''
}
function git-next(){
  local orig next num_
  orig="${1:-${_GIT_NEXT_ORIGIN:?}}"
  next="$(git rev-list --first-parent --topo-order HEAD.."${orig:?}" | tail -1)" || return $?
  num_="$(git rev-list --first-parent --topo-order HEAD.."${orig:?}" | wc -l)" || return $?
  if (( num_ <= 1 )); then git checkout ${orig:?} ; _GIT_NEXT_ORIGIN="" ; return $? ; fi
  git checkout ${next:?}
  >&2 echo "HEAD is $((${num_:?}-1)) commits from '${orig:?}'"
  git lg -n$((${num_:?}+2)) ${orig:?}
}
function git-prev(){
  if [ -z "${_GIT_NEXT_ORIGIN?}" ]; then _GIT_NEXT_ORIGIN="$(git branch --show-current)" ; fi
  local orig target dist
  orig="$(git rev-parse HEAD)"
  target="$(git rev-parse -q --verify "${1:-}^{commit}" \
         || git rev-parse -q --verify "HEAD~${1:-1}")" || return $?
  git -c advice.detachedHead=false checkout "$target"
  dist="$(git rev-list --count $target..$orig)"
  git lg -n $((3+$dist)) ${orig:?}
}

