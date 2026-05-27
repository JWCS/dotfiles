#!/usr/bin/env bash
# Enter the reversible OS sandbox: live host root as read-only lower,
# writable upper on /data, driven via systemd-nspawn. Run with sudo.
#
#   sudo ./enter.sh
#
# Host OS writes land in /data/sandbox/upper (reviewable, reversible).
# Project writes go to the real /opt via bind (persistent, backed up).
# Docker uses the HOST daemon via the bound /run/docker.sock.
set -euo pipefail

# Override per-machine via env: SANDBOX_ROOT (writable disk), SANDBOX_USER.
# For a 2nd ISOLATED sandbox: SANDBOX_ROOT=/data/sandbox2 sudo -E ./enter.sh
S="${SANDBOX_ROOT:-/data/sandbox}"
SBX_USER="${SANDBOX_USER:-azureuser}"
USER_HOME="${SANDBOX_USER_HOME:-/home/$SBX_USER}"
# Machine name must be unique per running container (nspawn keys on it; the
# --directory basename "merged" collides across roots). Derive from SANDBOX_ROOT.
MACHINE="${SANDBOX_NAME:-$(basename "$S")}"

[ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }
mkdir -p "$S/upper" "$S/work" "$S/merged"

[ -S /run/docker.sock ] || echo "warn: /run/docker.sock missing - is dockerd running on the host?"

# Overlay root (idempotent). lower=/ only captures sda1; /data,/opt,/mnt
# are separate mounts and appear as empty dirs (no recursion into upper).
if ! mountpoint -q "$S/merged"; then
  mount -t overlay claude-sbx \
    -o lowerdir=/,upperdir="$S/upper",workdir="$S/work" \
    "$S/merged"
fi

# Network shares the host netns (apt etc. work), BUT the host /etc/resolv.conf is
# a symlink into /run/systemd/resolve, which is empty in the container's fresh
# /run -> DNS dies (curl by IP works, by name fails: "Could not resolve host").
# That broke Claude's API/autoupdate/usage (Bun error code "FailedToOpenSocket").
# replace-stub points resolv.conf at the resolved stub (127.0.0.53), reachable
# via the shared host netns. (copy-uplink is unreliable here: it writes nothing
# when resolved exposes no per-link uplink servers, so DNS silently stays dead.)
#   --background=""    : disable nspawn's per-machine terminal tint (the blue bg)
#   --link-journal=no  : host+container share machine-id (overlay) -> skip the
#                        "refusing to link journals" noise
# /opt + /home are bound real -> Claude config, binary, projects at real paths.
# CPK_AUTOMATION=1 (forwarded via `sudo -E` from cpk-host-launch) signals
# that the sandbox is being launched without a human at the tty. Forward
# BRC_FEAT_KEYCHAINS_SKIP=1 into the sandbox so the bashrc skips the
# ssh-key passphrase prompt that would otherwise hang.
auto_setenv=()
if [ "${CPK_AUTOMATION:-}" = "1" ]; then
    auto_setenv+=(--setenv=BRC_FEAT_KEYCHAINS_SKIP=1 --setenv=CPK_AUTOMATION=1)
fi

exec systemd-nspawn -q \
  --machine="$MACHINE" \
  --directory="$S/merged" \
  --private-users=no \
  --resolv-conf=replace-stub \
  --link-journal=no \
  --background="" \
  --user="$SBX_USER" \
  --bind=/opt \
  --bind=/home \
  --bind=/tmp/tmux-1000:/tmp/host-tmux-sock \
  --bind=/run/docker.sock \
  --bind=/mnt:/scratch \
  --setenv=HOME="$USER_HOME" \
  --setenv=TERM="${TERM:-xterm-256color}" \
  --setenv=CLAUDE_CONFIG_DIR=/opt/ws/global/claude \
  --setenv=PATH="$USER_HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
  "${auto_setenv[@]}" \
  /bin/bash -l
