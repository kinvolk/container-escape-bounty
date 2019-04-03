#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly root=$(dirname "${BASH_SOURCE[0]}")

# shellcheck source=/dev/null
source "${root}/common.bash"

docker_listen_http() {
  # By default, Docker doesn't listen on 127.0.0.1:2375
  # https://docs.flatcar-linux.org/os/customizing-docker/#drop-in-configuration
  sudo mkdir -p /etc/systemd/system/docker.service.d
  cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/10-http.conf
[Service]
Environment="DOCKER_OPTS=-H tcp://127.0.0.1:2375"
EOF
  sudo systemctl daemon-reload
  sudo systemctl restart docker
}

docker_listen_http

common::caddy_write_config "${domain:?}"
common::caddy_run
common::contained.af_run
