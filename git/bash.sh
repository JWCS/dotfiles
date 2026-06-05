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

# --- read-only commit walker (GitHub/GitLab MR-style step-through) ---------
# Like git-next / git-prev but NO checkout: working tree never moves.
# Walks the first-parent chain; at each stop shows the commit's own patch
# (commit vs its parent). Cursor commit is exported as $GR so any diff alias
# can be reused read-only:  git d "$GR^!"  ·  git ds "$GR^!"  ·  git show $GR
#   git-review [<rev>|<base>..<tip>]  start (default: HEAD)
#   git-review-next [n]   step n commits toward tip   (default 1)
#   git-review-prev [n]   step n commits toward root  (default 1)
#   git-review-show       full patch at cursor
#   git-review-stat       diffstat at cursor
#   git-review-log [n]    lg context around tip
#   git-review-pos        re-announce cursor / re-export $GR
#   git-review-end        clear state
_GIT_REVIEW_CUR=''   # commit under the cursor
_GIT_REVIEW_TIP=''   # tip that 'next' walks toward

function _git_review_init_maybe(){
  if [ -z "${_GIT_REVIEW_CUR:-}" ]; then
    _GIT_REVIEW_TIP="$(git rev-parse HEAD)" || return $?
    _GIT_REVIEW_CUR="$_GIT_REVIEW_TIP"
  fi
}
function _git_review_announce(){
  local cur tip ahead
  cur="${_GIT_REVIEW_CUR:?}"
  tip="${_GIT_REVIEW_TIP:-$cur}"
  export GR="$cur"
  ahead="$(git rev-list --count --first-parent "${cur}..${tip}" 2>/dev/null)"
  >&2 echo "review @ $(git rev-parse --short "$cur")  (+${ahead:-0} to tip)  \$GR set → git d \"\$GR^!\" · git ds \"\$GR^!\""
}
function git-review(){
  local arg base tip
  arg="${1:-HEAD}"
  if [[ "$arg" == *..* ]]; then
    base="${arg%%..*}" ; tip="${arg##*..}"
    _GIT_REVIEW_TIP="$(git rev-parse "${tip:?}^{commit}")" || return $?
    _GIT_REVIEW_CUR="$(git rev-list --first-parent --reverse "${base:?}..${_GIT_REVIEW_TIP}" | head -1)"
    if [ -z "$_GIT_REVIEW_CUR" ]; then >&2 echo "review: empty range ${base}..${tip}"; return 1; fi
  else
    _GIT_REVIEW_TIP="$(git rev-parse "${arg}^{commit}")" || return $?
    _GIT_REVIEW_CUR="$_GIT_REVIEW_TIP"
  fi
  _git_review_announce
  git show --stat "${_GIT_REVIEW_CUR}"
}
function git-review-next(){
  _git_review_init_maybe || return $?
  local n step
  n="${1:-1}"
  step="$(git rev-list --first-parent --reverse "${_GIT_REVIEW_CUR}..${_GIT_REVIEW_TIP:?}" | sed -n "${n}p")"
  if [ -z "$step" ]; then >&2 echo "review: already at tip ($(git rev-parse --short "${_GIT_REVIEW_TIP}"))"; return 1; fi
  _GIT_REVIEW_CUR="$step"
  _git_review_announce
  git show --stat "${_GIT_REVIEW_CUR}"
}
function git-review-prev(){
  _git_review_init_maybe || return $?
  local n target
  n="${1:-1}"
  target="$(git rev-parse -q --verify "${_GIT_REVIEW_CUR}~${n}")" \
    || { >&2 echo "review: no commit ${n} before cursor (hit root?)"; return 1; }
  _GIT_REVIEW_CUR="$target"
  _git_review_announce
  git show --stat "${_GIT_REVIEW_CUR}"
}
function git-review-show(){ _git_review_init_maybe || return $?; export GR="${_GIT_REVIEW_CUR}"; git show "${_GIT_REVIEW_CUR}"; }
function git-review-stat(){ _git_review_init_maybe || return $?; export GR="${_GIT_REVIEW_CUR}"; git show --stat "${_GIT_REVIEW_CUR}"; }
function git-review-log(){  _git_review_init_maybe || return $?; git lg -n "${1:-15}" "${_GIT_REVIEW_TIP:-HEAD}"; }
function git-review-pos(){
  if [ -z "${_GIT_REVIEW_CUR:-}" ]; then >&2 echo "review: not started — run 'git-review [rev|base..tip]'"; return 1; fi
  _git_review_announce
}
function git-review-end(){ unset _GIT_REVIEW_CUR _GIT_REVIEW_TIP GR; >&2 echo "review: cleared"; }

