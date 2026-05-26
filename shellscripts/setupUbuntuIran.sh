#!/bin/bash
cp /etc/apt/sources.list /etc/apt/sources.list.back-$(date +%Y%m%d-%H%M%S)
cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.back-$(date +%Y%m%d-%H%M%S)
sed -i 's/archive.ubuntu.com/mirror.arvancloud.ir/g' /etc/apt/sources.list
sed -i 's/security.ubuntu.com/mirror.arvancloud.ir/g' /etc/apt/sources.list
sed -i 's/nova.clouds.archive.ubuntu.com/mirror.arvancloud.ir/g' /etc/apt/sources.list.d/ubuntu.sources
sed -i 's/security.ubuntu.com/mirror.arvancloud.ir/g' /etc/apt/sources.list.d/ubuntu.sources
apt update
apt upgrade -y