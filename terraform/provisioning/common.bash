#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

common::exit_error() {
  local -r message="${1:?}"
  local -r code="${2:-1}"
  echo "${message}" >&2
  exit "${code}"
}

common::caddy_write_config() {
  local -r domain="${1}"
  local -r username="${2}"
  local -r password="${3}"
  sudo mkdir -p /etc/caddy
  sudo mkdir -p /var/www
  cat <<EOF | sudo tee /etc/caddy/Caddyfile
${domain} {
  proxy  / http://localhost:10000 {
    transparent
    websocket
  }
  root   /var/www/
  log    stdout
  errors stdout
  basicauth / "${username}" "${password}"
}
EOF
}

common::caddy_run() {
  # We have hardcoded the container names, and it is highly possible that
  # starting container with same name will fail if we already have a
  # running/stopped container. To avoid this script from erroring out on that
  # and making this script idempotent remove the container before starting it
  # with same name.
  sudo docker rm -f caddy || true

  sudo mkdir -p /var/lib/caddy/dotcaddy
  sudo docker run -d \
    --name caddy \
    --network host \
    --volume=/etc/caddy/Caddyfile:/etc/Caddyfile:ro \
    --volume=/var/lib/caddy/dotcaddy:/root/.caddy:rw,Z \
    quay.io/schu/caddy:0.11.5
}

common::contained.af_run() {
  osname="${1}"
  # We have hardcoded the container names, and it is highly possible that
  # starting container with same name will fail if we already have a
  # running/stopped container. To avoid this script from erroring out on that
  # and making this script idempotent remove the container before starting it
  # with same name.
  sudo docker rm -f contained.af || true

  sudo docker run -d \
    --name contained.af \
    --network host \
    ${contained_af_image} \
    -d -os="${osname}"
}

if [[ $EUID -eq 0 ]]; then
  exit_error "not meant to be run as root"
fi
