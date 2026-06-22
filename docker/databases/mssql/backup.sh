#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/.env"

usage() {
  echo "Usage: $0 [-d database_name] [-p backup_folder_path]"
  echo "  -d    SQL Server database name"
  echo "  -p    host backup folder path"
  exit 1
}

DB_NAME=""
BACKUP_DIR=""

while getopts ":d:p:" opt; do
  case "$opt" in
    d) DB_NAME="$OPTARG" ;; 
    p) BACKUP_DIR="$OPTARG" ;; 
    *) usage ;; 
  esac
done

if [[ -z "$DB_NAME" ]]; then
  read -rp "Enter SQL Server database name: " DB_NAME
fi
if [[ -z "$DB_NAME" ]]; then
  echo "Error: database name cannot be empty." >&2
  exit 1
fi

if [[ -z "$BACKUP_DIR" ]]; then
  read -rp "Enter backup folder path: " BACKUP_DIR
fi
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

cp "$DIR/mssql_backup/$TARNAME.bak" "$BACKUP_DIR/$DB_NAME.bak"
mv "$DIR/mssql_backup/$TARNAME.bak" "$BACKUP_FILE"

echo "Backup completed: $BACKUP_FILE"