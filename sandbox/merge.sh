#!/usr/bin/env bash
# Merge reviewed OS changes from the sandbox upper into the REAL host root.
# Run with sudo.
#
#   sudo ./merge.sh /etc/foo.conf /usr/local/bin/bar   # merge specific paths
#   sudo ./merge.sh --all                              # merge everything (dry-run first)
#
# Best for /etc and /usr/local config tweaks. For apt installs, prefer
# 're-running apt install <pkg>' on the host instead of file-copying dpkg state.
set -euo pipefail

U="${SANDBOX_ROOT:-/data/sandbox}/upper"
[ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }
[ -d "$U" ] || { echo "no upper - nothing to merge"; exit 1; }

if [ "${1:-}" = "--all" ]; then
  echo "DRY RUN (rsync upper/ -> /):"
  rsync -aAXn --info=NAME "$U"/ /
  read -rp "Apply for real? [y/N] " a
  [ "$a" = y ] || { echo "aborted"; exit 0; }
  rsync -aAX "$U"/ /
  echo "merged all. (deletions/whiteouts are NOT applied - remove those by hand)"
else
  [ $# -ge 1 ] || { echo "usage: merge.sh <path>... | --all"; exit 1; }
  for p in "$@"; do
    src="$U/${p#/}"
    [ -e "$src" ] || { echo "skip (not in upper): $p"; continue; }
    install -D "$src" "/${p#/}"
    echo "merged: $p"
  done
fi
