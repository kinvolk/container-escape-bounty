#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly root=$(dirname "${BASH_SOURCE[0]}")

# shellcheck source=/dev/null
source "${root}/common.bash"

install_docker() {
  # https://docs.docker.com/install/linux/docker-ce/fedora/
  sudo dnf config-manager \
  --add-repo \
  https://download.docker.com/linux/fedora/docker-ce.repo
  sudo dnf install -y docker-ce docker-ce-cli containerd.io

  # By default, Docker doesn't listen on 127.0.0.1:2375
  sudo mkdir -p /etc/systemd/system/docker.service.d
  cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/10-http.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://127.0.0.1:2375 --selinux-enabled --containerd=/run/containerd/containerd.sock
EOF
  sudo systemctl daemon-reload
  sudo systemctl --now enable docker
}

install_docker_userns() {
  cat <<EOF | sudo tee /usr/lib/systemd/system/docker-userns.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
BindsTo=containerd.service
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker-userns.socket

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://127.0.0.1:2376 --selinux-enabled --containerd=/run/containerd/containerd.sock --userns-remap=default --pidfile /var/run/docker-userns.pid
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

  cat <<EOF | sudo tee /usr/lib/systemd/system/docker-userns.socket
[Unit]
Description=Docker Socket for the API
PartOf=docker-userns.service

[Socket]
ListenStream=/var/run/docker-userns.socket
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF
  sudo systemctl daemon-reload
  sudo systemctl --now enable docker-userns
}

install_docker
install_docker_userns

common::caddy_write_config "${domain:?}"
common::caddy_run
common::contained.af_run fedora
