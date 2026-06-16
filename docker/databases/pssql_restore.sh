#!/bin/bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/.env"

DB_USER=${DB_USER:-${PG_USER:-postgres}}
DB_NAME=${DB_NAME:-${PG_DB:-postgres}}
CONTAINER_NAME=${CONTAINER_NAME:-pg_server}
BACKUP_FILE=${BACKUP_FILE:?Set BACKUP_FILE to the .sql.gz file you want to restore}

# 1. Drop and create the schema
docker exec -i "$CONTAINER_NAME" psql -U postgres -d "$DB_NAME" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# 2. Grant target user to schema
docker exec -i "$CONTAINER_NAME" psql -U postgres -d "$DB_NAME" -c "GRANT ALL ON SCHEMA public TO $DB_USER;"

gunzip -c "$BACKUP_FILE" | docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME"
