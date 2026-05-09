#!/bin/bash

echo "Running migrations..."
php artisan optimize:clear
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan scribe:generate

echo "Starting Laravel server on $APP_URL"
php artisan serve --host=0.0.0.0 --port=8000
#php artisan octane:start --server=swoole --max-requests=1000 --workers=4 --task-workers=12 --port=8090