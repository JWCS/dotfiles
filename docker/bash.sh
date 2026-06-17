#!/bin/bash
# docker management commands

source ~/.dotfiles/bash/util.sh

#alias docker-rmi-none="docker images -a | grep '<none>' | awk '{ print $3; }' | xargs docker rmi"
function docker-rmi-none(){
  docker images -a | awk '/<none>/{system("docker rmi "$3)}'
  docker buildx prune -af --filter "until=24h"
}

docker-rm-created(){
  docker ps --filter "status=created" | awk 'FNR>1{system("docker container rm "$1)}'
}

# https://stackoverflow.com/a/73108928/
docker-size(){
  _has_cmd jq || sudo apt-fast install -y jq || return $?
  docker manifest inspect -v "$1" \
  | jq -c 'if type == "array" then .[] else . end' \
  | jq -r '[ ( .Descriptor.platform | [ .os, .architecture, .variant, ."os.version" ] | del(..|nulls) | join("/") ), ( [ ( .OCIManifest // .SchemaV2Manifest ).layers[].size ] | add ) ] | join(" ")' \
  | numfmt --to iec --format '%.2f' --field 2 | sort | column -t ;
}

docker-img-cleanup(){
  local - grep_cmd=cat
  set -uo pipefail
  if (($#)); then grep_cmd="grep -E ""$@"; fi
  docker image prune -f >/dev/null ||: # Note: only <none> imgs; cleaner than awk <none>
  join -v1 -t $'\t' \
    <(docker image ls -a --no-trunc --format '{{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}' \
      | sed 's/^sha256://' | sort -u) \
    <(docker ps -aq \
      | xargs -r docker inspect -f '{{.Image}}' 2>/dev/null \
      | sed 's/^sha256://' | sort -u) \
  | awk -F'\t' '$2 != "<none>:<none>" { print $2 "\t" $1 "\t" $3 }' \
  | $grep_cmd | sort -r -t$'\t' -k3 -h `# sort by size` \
  | while IFS=$'\t' read -r ref id size; do
      finish=${finish:-0}
      if (( finish )); then continue; fi
      printf 'remove %s (%s)? [y/N/q]\n' "$ref" "$size" >/dev/tty
      IFS= read -rsn1 ans </dev/tty || break
      [[ $ans == [Yy]* ]] && printf '%s\n' "$ref" ||:
      if [[ $ans == [Qq]* ]]; then finish=1; echo "wait..." >/dev/tty; fi
    done \
  | xargs -r docker rmi || return $?
  docker buildx prune -af --filter "until=24h"
}
