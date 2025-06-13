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

