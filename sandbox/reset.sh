#!/usr/bin/env bash
# Discard ALL sandbox OS changes -> pristine OS on next enter. Run with sudo.
# Exit any running sandbox shell first (the overlay must be unmounted).
set -euo pipefail

S="${SANDBOX_ROOT:-/data/sandbox}"
[ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }

if mountpoint -q "$S/merged"; then
  echo "unmounting overlay..."
  umount "$S/merged" || { echo "overlay busy - exit the sandbox shell first"; exit 1; }
fi

rm -rf "$S/upper" "$S/work"
mkdir -p "$S/upper" "$S/work"
echo "sandbox reset to pristine."
