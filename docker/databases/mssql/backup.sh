#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/.env"

read -rp "Enter SQL Server database name: " DB_NAME
if [[ -z "$DB_NAME" ]]; then
  echo "Error: database name cannot be empty." >&2
  exit 1
fi

read -rp "Enter backup folder path: " BACKUP_DIR
if [[ -z "$BACKUP_DIR" ]]; then
  echo "Error: backup folder path cannot be empty." >&2
  exit 1
fi

mkdir -p "$BACKUP_DIR"

TARNAME="${DB_NAME}_$(date +%F_%H-%M-%S)"
BACKUP_FILE="${BACKUP_DIR%/}/${TARNAME}.bak"

docker load -i /home/devops/mssql/mssql-tools.tar

docker compose -f "$DIR/docker-compose.yml" run --rm mssql-backup \
  /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "$SA_PASS" \
  -Q "BACKUP DATABASE [$DB_NAME] \
      TO DISK='/backup/${TARNAME}.bak' \
      WITH INIT, COMPRESSION"

mv "$DIR/mssql_backup/$TARNAME.bak" "$BACKUP_FILE"

echo "Backup completed: $BACKUP_FILE"