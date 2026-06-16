#!/bin/bash
set -euo pipefail

TIMESTAMP=$(date +%Y%m%d-%H%M%S)

if [ -f /etc/apt/sources.list ]; then
  cp /etc/apt/sources.list "/etc/apt/sources.list.back-${TIMESTAMP}"
  sed -i 's/archive.ubuntu.com/mirror.arvancloud.ir/g' /etc/apt/sources.list
  sed -i 's/security.ubuntu.com/mirror.arvancloud.ir/g' /etc/apt/sources.list
fi

if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
  cp /etc/apt/sources.list.d/ubuntu.sources "/etc/apt/sources.list.d/ubuntu.sources.back-${TIMESTAMP}"
  sed -i 's/nova.clouds.archive.ubuntu.com/mirror.arvancloud.ir/g' /etc/apt/sources.list.d/ubuntu.sources
  sed -i 's/archive.ubuntu.com/mirror.arvancloud.ir/g' /etc/apt/sources.list.d/ubuntu.sources
  sed -i 's/security.ubuntu.com/mirror.arvancloud.ir/g' /etc/apt/sources.list.d/ubuntu.sources
fi

apt update
apt upgrade -y
