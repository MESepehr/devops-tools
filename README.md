# DevOps Tools

این ریپو مجموعه‌ای از قالب‌ها و ابزارهای آماده برای راه‌اندازی، build، deploy و نگهداری سرویس‌هاست. ساختار پوشه‌ها عمداً ساده نگه داشته شده تا بتوانید هر بخش را در پروژه مقصد کپی کنید یا مستقیم از همین ریپو به عنوان مرجع استفاده کنید.

## فهرست سریع

```text
docker/
  Dockerfile-laravel          قالب Docker برای Laravel
  Dockerfile-nextjs           قالب Docker برای Next.js با PM2
  Dockerfile-python           قالب Docker برای Python/Gunicorn
  docker-compose.yml          قالب عمومی اجرای image ساخته شده
  npmbuild/Dockerfile         قالب build برای پروژه‌های npm
  dotnet/                     قالب Docker و compose برای .NET
  databases/                  PostgreSQL, PostgreSQL + pgvector, MySQL, MSSQL
  gitlab/                     اجرای GitLab CE با Docker Compose
  metabase/                   اجرای Metabase با PostgreSQL
nginx/
  laravel.config              reverse proxy و فایل سرور برای Laravel/API
  react.config                نمونه serve کردن SPA و proxy مسیر /api
  proxyport.config            reverse proxy به یک پورت داخلی
  proxyothersite.config       reverse proxy به یک سایت دیگر
pipeline/gitlab/
  *.yml                       قالب‌های GitLab CI برای Docker و static build
  RunnerDocker/               GitLab Runner داخل Docker
shellscripts/
  setupUbuntuIran.sh          تغییر mirrorهای Ubuntu به mirror داخلی
  setupDockerIran.sh          نصب Docker و Docker Compose با mirror داخلی
```

## شروع سریع سرور

برای تغییر mirrorهای Ubuntu و آپدیت سیستم:

```bash
curl -sf https://git.ngtartanak.co.ir/codekit/devops-tools/-/raw/main/shellscripts/setupUbuntuIran.sh | bash
```

برای نصب Docker و پلاگین Docker Compose:

```bash
curl -sf https://git.ngtartanak.co.ir/codekit/devops-tools/-/raw/main/shellscripts/setupDockerIran.sh | bash
```

نکته: این دو اسکریپت فایل‌های apt را تغییر می‌دهند و باید با دسترسی root اجرا شوند. قبل از تغییر، از فایل‌های موجود backup می‌گیرند.

## Docker

قالب عمومی اجرا در [docker/docker-compose.yml](/Users/mesepehr/Desktop/Projects/devops-tools/docker/docker-compose.yml) قرار دارد. در pipelineها معمولاً مقدارهای `GITHUB_IMAGE_NAME` و `EXPOSE_PORT` با `sed` جایگزین می‌شوند.

اجرای دستی یک image:

```bash
cd docker
cp .env.example .env 2>/dev/null || touch .env
docker compose up -d
```

قالب‌های اپلیکیشن:

- [docker/Dockerfile-laravel](/Users/mesepehr/Desktop/Projects/devops-tools/docker/Dockerfile-laravel): نصب Composer dependencyها، اجرای migration/cache و سرو با `php artisan serve`.
- [docker/Dockerfile-nextjs](/Users/mesepehr/Desktop/Projects/devops-tools/docker/Dockerfile-nextjs): build چندمرحله‌ای Next.js، اجرای production با `pm2-runtime` روی پورت `3000`.
- [docker/Dockerfile-python](/Users/mesepehr/Desktop/Projects/devops-tools/docker/Dockerfile-python): نصب `requirements.txt` و اجرای `gunicorn app.main:app`.
- [docker/npmbuild/Dockerfile](/Users/mesepehr/Desktop/Projects/devops-tools/docker/npmbuild/Dockerfile): فقط برای build پروژه‌های npm و خروجی گرفتن از artifact.
- [docker/dotnet/Dockerfile](/Users/mesepehr/Desktop/Projects/devops-tools/docker/dotnet/Dockerfile): publish پروژه `Eshop` با .NET 9 و اجرای خروجی با runtime image.

## دیتابیس‌ها

فایل‌های دیتابیس در [docker/databases](/Users/mesepehr/Desktop/Projects/devops-tools/docker/databases) هستند و از `.env` همان پوشه می‌خوانند.

متغیرهای رایج:

```env
PG_USER=postgres
PG_PASS=change_me
PG_DB=app
ROOT_PASS=change_me
DB_USER=app
DB_PASS=change_me
SA_PASS=Change_me_strong_password1!
```

اجرای نمونه‌ها:

```bash
cd docker/databases
docker compose -f pssql-docker-compose.yml up -d
docker compose -f pssql18-docker-compose.yml up -d
docker compose -f mysql-docker-compose.yml up -d
docker compose -f mssql-docker-compose.yml up -d
```

PostgreSQL 18 از [DockerfilePSQL18](/Users/mesepehr/Desktop/Projects/devops-tools/docker/databases/DockerfilePSQL18) استفاده می‌کند و extension مربوط به `pgvector` را build می‌کند.

بکاپ و restore:

```bash
cd docker/databases
./pssql_backup.sh
BACKUP_FILE=./backups/app_backup_YYYYMMDD_HHMMSS.sql.gz ./pssql_restore.sh
DB_NAME=example_db ./mssql_backup.sh
```

## GitLab CI

قالب اصلی Docker build/deploy در [pipeline/gitlab/.gitlab-ci.DockerfileBuilder.yml](/Users/mesepehr/Desktop/Projects/devops-tools/pipeline/gitlab/.gitlab-ci.DockerfileBuilder.yml) است. فایل [pipeline/gitlab/.gitlab-ci.yml](/Users/mesepehr/Desktop/Projects/devops-tools/pipeline/gitlab/.gitlab-ci.yml) نمونه استفاده از همین template است.

متغیرهای مهم برای build/deploy:

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

قالب‌های دیگر:

- [pipeline/gitlab/.gitlab-ci.BuildViaDockerfile.yml](/Users/mesepehr/Desktop/Projects/devops-tools/pipeline/gitlab/.gitlab-ci.BuildViaDockerfile.yml): build داخل Docker و کپی artifact از container.
- [pipeline/gitlab/react.gitlab-ci.yml](/Users/mesepehr/Desktop/Projects/devops-tools/pipeline/gitlab/react.gitlab-ci.yml): build پروژه React و deploy خروجی با `rsync`.
- [pipeline/gitlab/nextjs.gitlab-ci.yml](/Users/mesepehr/Desktop/Projects/devops-tools/pipeline/gitlab/nextjs.gitlab-ci.yml): build پروژه Next.js و sync خروجی به سرور.
- [pipeline/gitlab/DirectOnServer.gitlab-ci.yml](/Users/mesepehr/Desktop/Projects/devops-tools/pipeline/gitlab/DirectOnServer.gitlab-ci.yml): pull/build مستقیم روی سرور و restart با PM2.
- [pipeline/gitlab/RunnerDocker](/Users/mesepehr/Desktop/Projects/devops-tools/pipeline/gitlab/RunnerDocker): اجرای GitLab Runner همراه Docker daemon.

## Nginx

نمونه‌ها در [nginx](/Users/mesepehr/Desktop/Projects/devops-tools/nginx) هستند. قبل از استفاده، مقدارهای `server_name`، مسیرهای `root` و پورت‌های داخلی را با پروژه مقصد هماهنگ کنید.

بعد از کپی به `/etc/nginx/sites-available`:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## GitLab و Metabase

برای GitLab CE:

```bash
cd docker/gitlab
docker compose up -d
```

قبل از اجرا مقدارهای `.env`، دامنه‌ها، SSL certificate pathها و `GITLAB_HOME` را تنظیم کنید.

برای Metabase:

```bash
cd docker/metabase
docker compose up -d
```

سرویس Metabase به صورت پیش‌فرض فقط روی `127.0.0.1:3000` bind شده تا پشت Nginx یا tunnel استفاده شود.

## نکته‌های نگهداری

- فایل‌های `.env` واقعی را commit نکنید؛ این ریپو چند نمونه عملیاتی دارد، ولی برای پروژه‌های بعدی بهتر است مقدارهای حساس را در GitLab CI Variables یا secret manager نگه دارید.
- قبل از استفاده از هر template، نام image، پورت expose، مسیر app و branch/tag ruleها را بررسی کنید.
- برای deployهای production ابتدا روی یک branch یا سرور آزمایشی اجرا کنید، مخصوصاً templateهایی که `docker compose down` یا `rsync --delete` دارند.
