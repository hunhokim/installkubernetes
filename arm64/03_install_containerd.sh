#!/bin/bash

set -o pipefail

if ! [[ -e containerd-1.6.4-linux-arm64.tar.gz ]]; then
  wget https://github.com/containerd/containerd/releases/download/v1.6.4/containerd-1.6.4-linux-arm64.tar.gz
fi
if ! [[ -e /usr/local/bin/containerd ]]; then
  sudo tar Cxzvf /usr/local containerd-1.6.4-linux-arm64.tar.gz
fi

if ! [[ -e containerd.service ]]; then 
  wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
fi
if ! [[ -e /usr/local/lib/systemd/system/containerd.service ]]; then
  sudo mkdir -p /usr/local/lib/systemd/system/
  sudo cp containerd.service /usr/local/lib/systemd/system/containerd.service

  sudo systemctl daemon-reload
  sudo systemctl enable --now containerd
fi

if ! [[ -e runc.arm64 ]]; then
  wget https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.arm64
fi
if ! [[ -e /usr/local/sbin/runc ]]; then
  sudo install -m 755 runc.arm64 /usr/local/sbin/runc
fi

if ! [[ -e cni-plugins-linux-arm64-v1.1.1.tgz ]]; then
  wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-arm64-v1.1.1.tgz
fi
if ! [[ -e /opt/cni/bin ]]; then
  sudo mkdir -p /opt/cni/bin
  sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-arm64-v1.1.1.tgz
fi

containerd config default > config.toml
sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" config.toml
sudo mkdir -p /etc/containerd/
sudo cp config.toml /etc/containerd/config.toml
