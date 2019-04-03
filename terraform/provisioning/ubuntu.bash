#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly root=$(dirname "${BASH_SOURCE[0]}")

# shellcheck source=/dev/null
source "${root}/common.bash"

install_docker() {
  # https://docs.docker.com/install/linux/docker-ce/ubuntu/

  # Try to avoid 'Splitting up ...InRelease into data and signature failed'
  # errors by trying again and again :( (Usually works on second attempt)
  until sudo apt-get update; do : ; done

  sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

  sudo apt-get update
  sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io

  # By default, Docker doesn't listen on 127.0.0.1:2375
  sudo mkdir -p /etc/systemd/system/docker.service.d
  cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/10-http.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://127.0.0.1:2375 --containerd=/run/containerd/containerd.sock
EOF
  sudo systemctl daemon-reload
  sudo systemctl restart docker
}

install_docker

common::caddy_write_config "${domain:?}"
common::caddy_run
common::contained.af_run
