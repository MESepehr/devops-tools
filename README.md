# DevOps Tools

This repository is a small collection of reusable DevOps templates and operational helpers for building, deploying, and running common services. The folder layout is intentionally simple so each piece can be copied into another project or used directly as a reference.

## Quick Map

```text
docker/
  Dockerfile-laravel          Docker template for Laravel
  Dockerfile-nextjs           Docker template for Next.js with PM2
  Dockerfile-python           Docker template for Python/Gunicorn
  docker-compose.yml          Generic compose template for a built image
  npmbuild/Dockerfile         Build-only template for npm projects
  dotnet/                     Docker and compose templates for .NET
  databases/                  PostgreSQL, PostgreSQL + pgvector, MySQL, MSSQL
  gitlab/                     GitLab CE with Docker Compose
  metabase/                   Metabase with PostgreSQL
nginx/
  laravel.config              Reverse proxy and file server sample for Laravel/API
  react.config                SPA static serving with an /api proxy sample
  proxyport.config            Reverse proxy to a local port
  proxyothersite.config       Reverse proxy to another website
pipeline/gitlab/
  *.yml                       GitLab CI templates for Docker and static builds
  RunnerDocker/               GitLab Runner running inside Docker
shellscripts/
  setupUbuntuIran.sh          Switch Ubuntu apt mirrors to an Iran mirror
  setupDockerIran.sh          Install Docker and Docker Compose using Iran mirrors
```

## Server Quick Start

Switch Ubuntu apt mirrors and update the server:

```bash
curl -sf https://git.ngtartanak.co.ir/codekit/devops-tools/-/raw/main/shellscripts/setupUbuntuIran.sh | bash
```

Install Docker and the Docker Compose plugin:

```bash
curl -sf https://git.ngtartanak.co.ir/codekit/devops-tools/-/raw/main/shellscripts/setupDockerIran.sh | bash
```


SetUp gitlab runner on a server:

```bash
curl -sf https://git.ngtartanak.co.ir/codekit/devops-tools/-/raw/main/shellscripts/setupGitlabRunnerImage.sh | bash
```

Note: these scripts modify apt and Docker configuration files and should be run with root privileges. The Ubuntu mirror script creates backups before changing apt source files.

## Docker

The generic runtime compose file is in [docker/docker-compose.yml](docker/docker-compose.yml). In the GitLab CI templates, placeholders such as `GITHUB_IMAGE_NAME` and `EXPOSE_PORT` are usually replaced with `sed`.

Run a generated image manually:

```bash
cd docker
cp .env.example .env 2>/dev/null || touch .env
docker compose up -d
```

Application templates:

- [docker/Dockerfile-laravel](docker/Dockerfile-laravel): installs Composer dependencies, runs Laravel migration/cache commands, and serves with `php artisan serve`.
- [docker/Dockerfile-nextjs](docker/Dockerfile-nextjs): multi-stage Next.js build and production runtime with `pm2-runtime` on port `3000`.
- [docker/Dockerfile-python](docker/Dockerfile-python): installs `requirements.txt` and runs `gunicorn app.main:app`.
- [docker/npmbuild/Dockerfile](docker/npmbuild/Dockerfile): build-only npm image for artifact extraction.
- [docker/dotnet/Dockerfile](docker/dotnet/Dockerfile): publishes the `Eshop` project with .NET 9 and runs it with the ASP.NET runtime image.

## Databases

Database compose files live in [docker/databases](docker/databases) and read variables from the `.env` file in that directory.

Common variables:

```env
PG_USER=postgres
PG_PASS=change_me
PG_DB=app
ROOT_PASS=change_me
DB_USER=app
DB_PASS=change_me
SA_PASS=Change_me_strong_password1!
```

Run the samples:

```bash
cd docker/databases
docker compose -f pssql-docker-compose.yml up -d
docker compose -f pssql18-docker-compose.yml up -d
docker compose -f mysql-docker-compose.yml up -d
docker compose -f mssql-docker-compose.yml up -d
```

PostgreSQL 18 uses [DockerfilePSQL18](docker/databases/DockerfilePSQL18) and builds the `pgvector` extension.

Backup and restore helpers:

```bash
cd docker/databases
./pssql_backup.sh
BACKUP_FILE=./backups/app_backup_YYYYMMDD_HHMMSS.sql.gz ./pssql_restore.sh
DB_NAME=example_db ./mssql_backup.sh
```

## GitLab CI

The main Docker build/deploy template is [pipeline/gitlab/.gitlab-ci.DockerfileBuilder.yml](pipeline/gitlab/.gitlab-ci.DockerfileBuilder.yml). [pipeline/gitlab/.gitlab-ci.yml](pipeline/gitlab/.gitlab-ci.yml) shows a sample pipeline that extends it.

Important build/deploy variables:

```text
CI_REGISTRY
CI_REGISTRY_IMAGE
CI_REGISTRY_USER
CI_REGISTRY_PASSWORD
LOCAL_PORT
ENV_FILE
SSH_PRIVATE_KEY_*
SSH_PORT_*
SERVER_IP_*
SERVER_USER_*
SERVER_PATH_*
```

Other templates:

- [pipeline/gitlab/.gitlab-ci.BuildViaDockerfile.yml](pipeline/gitlab/.gitlab-ci.BuildViaDockerfile.yml): builds inside Docker and copies artifacts out of the container.
- [pipeline/gitlab/react.gitlab-ci.yml](pipeline/gitlab/react.gitlab-ci.yml): builds a React app and deploys the static output with `rsync`.
- [pipeline/gitlab/nextjs.gitlab-ci.yml](pipeline/gitlab/nextjs.gitlab-ci.yml): builds a Next.js app and syncs runtime files to a server.
- [pipeline/gitlab/DirectOnServer.gitlab-ci.yml](pipeline/gitlab/DirectOnServer.gitlab-ci.yml): pulls, builds, and restarts with PM2 directly on the server.
- [pipeline/gitlab/RunnerDocker](pipeline/gitlab/RunnerDocker): runs a GitLab Runner with a Docker daemon.

## Nginx

Nginx samples are in [nginx](nginx). Before using them, update `server_name`, `root` paths, upstream ports, and domain-specific values for the target project.

After copying a config to `/etc/nginx/sites-available`:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## GitLab And Metabase

Run GitLab CE:

```bash
cd docker/gitlab
docker compose up -d
```

Before running it, configure `.env`, domains, SSL certificate paths, and `GITLAB_HOME`.

Run Metabase:

```bash
cd docker/metabase
docker compose up -d
```

Metabase is bound to `127.0.0.1:3000` by default so it can be exposed through Nginx or a tunnel.

## Maintenance Notes

- Do not commit real `.env` files. This repository contains operational examples, but project secrets should usually live in GitLab CI Variables or a secret manager.
- Before using any template, review the image name, exposed port, app path, and branch/tag rules.
- Test production deploy templates on a staging branch or server first, especially templates that use `docker compose down` or `rsync --delete`.
