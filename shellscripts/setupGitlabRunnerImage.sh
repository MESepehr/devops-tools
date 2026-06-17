#!/bin/bash
set -euo pipefail

curl -SL https://git.ngtartanak.co.ir/codekit/devops-tools/-/raw/main/pipeline/gitlab/RunnerDocker/docker-compose.yml -o docker-compose.yml
curl -SL https://git.ngtartanak.co.ir/codekit/devops-tools/-/raw/main/pipeline/gitlab/RunnerDocker/Dockerfile -o Dockerfile
mkdir -p config
if [ ! -f "config/config.toml" ]; then
  curl -SL https://git.ngtartanak.co.ir/codekit/devops-tools/-/raw/main/pipeline/gitlab/RunnerDocker/config/config.toml -o config/config.toml
fi
docker compose build
echo "Edit config/config.toml then run docker compose up -d"
#nano config/config.toml
#docker compose up