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

