#!/bin/bash
set -euo pipefail

curl -SL https://git.ngtartanak.co.ir/codekit/devops-tools/-/raw/main/pipeline/gitlab/RunnerDocker/docker-compose.yml -o docker-compose.yml
curl -SL https://git.ngtartanak.co.ir/codekit/devops-tools/-/raw/main/pipeline/gitlab/RunnerDocker/Dockerfile -o Dockerfile
mkdir config
curl -SL https://git.ngtartanak.co.ir/codekit/devops-tools/-/raw/main/pipeline/gitlab/RunnerDocker/config/config.toml -o config/config.toml
docker compose build
nano config/config.toml