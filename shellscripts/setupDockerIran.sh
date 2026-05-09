#!/bin/bash
apt update
apt install -y docker.io
echo '{
  "insecure-registries" : ["https://docker.arvancloud.ir"],
  "registry-mirrors": ["https://docker.arvancloud.ir"]
}' > /etc/docker/daemon.json

mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL https://codekit.s3.ir-thr-at1.arvanstorage.ir/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
docker compose version