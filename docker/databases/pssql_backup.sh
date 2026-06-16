#!/bin/bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/.env"

DB_USER=${DB_USER:-${PG_USER:-postgres}}
DB_NAME=${DB_NAME:-${PG_DB:-postgres}}
CONTAINER_NAME=${CONTAINER_NAME:-pg_server}
BACKUP_DIR=${BACKUP_DIR:-"$DIR/backups"}

mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="${BACKUP_DIR}/${DB_NAME}_backup_${TIMESTAMP}.sql.gz"

echo "Starting backup for database: $DB_NAME for $DB_USER"

docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$FILENAME"

echo "Backup successful! File saved to: $FILENAME"
