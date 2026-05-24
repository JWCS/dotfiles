#!/usr/bin/env bash
# Attach a 2nd shell to an ALREADY-RUNNING sandbox container, sharing its overlay
# (same upper diff, same netns). Use for a second Claude/agent in the SAME sandbox
# without restarting. Run with sudo.
#
#   sudo ./attach.sh                       # attach to machine "sandbox" (default)
#   sudo SANDBOX_NAME=sandbox2 ./attach.sh # attach to a named instance
#
# Going forward, the cleaner pattern is to run tmux INSIDE one enter.sh and spawn
# agents in its windows; attach.sh is for grabbing a shell in a live container you
# started plain. nsenter is used because the container runs `bash -l`, not systemd,
# so `machinectl shell` has no PID1 to talk to.
set -euo pipefail

MACHINE="${1:-${SANDBOX_NAME:-}}"
SBX_USER="${SANDBOX_USER:-azureuser}"
USER_HOME="${SANDBOX_USER_HOME:-/home/$SBX_USER}"

[ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }

# Resolve machine: explicit arg/env wins; otherwise auto-pick the sole running
# container (so you don't have to remember its name, e.g. "merged" vs "sandbox").
running=$(machinectl list --no-legend 2>/dev/null | awk '$2=="container"{print $1}')
if [ -z "$MACHINE" ]; then
  n=$(printf '%s\n' "$running" | grep -c .)
  if [ "$n" -eq 1 ]; then
    MACHINE="$running"
  elif [ "$n" -eq 0 ]; then
    echo "no running sandbox container - start one with enter.sh first"; exit 1
  else
    echo "multiple containers running - pass one as arg:"; printf '  %s\n' $running; exit 1
  fi
fi

L=$(machinectl show "$MACHINE" -p Leader --value 2>/dev/null || true)
[ -n "$L" ] || { echo "container '$MACHINE' not running. running: ${running:-(none)}"; exit 1; }

# Enter all of the leader's namespaces, drop to the sandbox user, mirror enter.sh env.
exec nsenter -t "$L" -a -- runuser -u "$SBX_USER" -- env \
  HOME="$USER_HOME" \
  TERM="${TERM:-xterm-256color}" \
  CLAUDE_CONFIG_DIR=/opt/ws/global/claude \
  PATH="$USER_HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
  /bin/bash -l
