#!/bin/bash
cp /etc/apt/sources.list /etc/apt/sources.list.back-$(date +%Y%m%d-%H%M%S)
sed -i 's/archive.ubuntu.com/mirror.arvancloud.ir/g' /etc/apt/sources.list
apt update
apt upgrade -y