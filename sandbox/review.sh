#!/usr/bin/env bash
# Show every OS change the sandbox made. The overlay upper IS the diff:
# it contains exactly the files Claude created/modified, nothing else.
set -euo pipefail

U="${SANDBOX_ROOT:-/data/sandbox}/upper"
[ -d "$U" ] || { echo "no upper yet - nothing changed"; exit 0; }

echo "== modified / new files =="
find "$U" -type f -printf '%P\n' | sort

echo
echo "== deletions (overlay whiteouts) =="
find "$U" -type c -printf '%P\n' 2>/dev/null | sort

echo
echo "== new / touched directories =="
find "$U" -mindepth 1 -type d -printf '%P/\n' | sort

echo
echo "(inspect a change:  diff <(cat /FILE) $U/FILE )"
echo "(note: apt installs show up as many files under var/ + usr/ - prefer"
echo " re-running 'apt install <pkg>' on the host over merging those by hand)"
