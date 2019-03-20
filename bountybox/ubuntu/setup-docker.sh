#!/bin/bash

# replace the default repo in the URL with the closest mirror
sudo sed -i 's,http://archive.ubuntu.com/ubuntu,mirror://mirrors.ubuntu.com/mirrors.txt,g' /etc/apt/sources.list

# install required packages
sudo apt-get -y update
DEBIAN_FRONTEND=noninteractive sudo apt-get -y install apt-transport-https ca-certificates curl git gnupg-agent golang iptables software-properties-common systemd

# install docker-ce
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker ubuntu
sudo systemctl start docker.service
sudo systemctl enable docker.service
