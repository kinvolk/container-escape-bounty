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

install_docker_userns() {
  # Following the docs from docker to enable user-namespace for docker
  # https://docs.docker.com/engine/security/userns-remap/
  sudo touch /etc/subuid
  sudo touch /etc/subgid

  cat <<EOF | sudo tee /etc/systemd/system/docker-userns.service
[Unit]
Requires=torcx.target
After=torcx.target
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=containerd.service docker-userns.socket network-online.target
Wants=network-online.target
Requires=containerd.service docker-userns.socket

[Service]
EnvironmentFile=/run/metadata/torcx
Environment=TORCX_IMAGEDIR=/docker
Type=notify
EnvironmentFile=-/run/flannel/flannel_docker_opts.env
Environment=DOCKER_SELINUX=--selinux-enabled=true

# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/env PATH=\${TORCX_BINDIR}:${PATH} \${TORCX_BINDIR}/dockerd --host=fd:// --host=tcp://127.0.0.1:2376 --containerd=/var/run/docker/libcontainerd/docker-containerd.sock --userns-remap=default --pidfile /var/run/docker-userns.pid \$DOCKER_SELINUX \$DOCKER_OPTS \$DOCKER_CGROUPS \$DOCKER_OPT_BIP \$DOCKER_OPT_MTU \$DOCKER_OPT_IPMASQ
ExecReload=/bin/kill -s HUP \$MAINPID
LimitNOFILE=1048576
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
EOF

  cat <<EOF | sudo tee /etc/systemd/system/docker-userns.socket
[Unit]
Requires=torcx.target
After=torcx.target
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
  sudo systemctl restart docker-userns
}


docker_listen_http
install_docker_userns

common::caddy_write_config "${domain:?}"
common::caddy_run
common::contained.af_run flatcar
