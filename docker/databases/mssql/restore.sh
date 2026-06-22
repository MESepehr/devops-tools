#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/.env"

usage() {
  echo "Usage: $0 [-p backup-file.bak] [-d target-db-name]"
  echo "Example: $0 -p export/Filmnab_db.bak -d Filmnab_db"
  exit 1
}

BACKUP_PATH=""
DB_NAME=""

while getopts ":p:d:" opt; do
  case "$opt" in
    p) BACKUP_PATH="$OPTARG" ;; 
    d) DB_NAME="$OPTARG" ;; 
    *) usage ;; 
  esac
done

if [[ -z "$BACKUP_PATH" ]]; then
  read -rp "Enter path to backup file (.bak): " BACKUP_PATH
fi
if [[ -z "$DB_NAME" ]]; then
  read -rp "Enter target database name: " DB_NAME
fi

if [[ -z "$BACKUP_PATH" || -z "$DB_NAME" ]]; then
  usage
fi

if [[ ! -f "$BACKUP_PATH" ]]; then
  echo "Error: backup file '$BACKUP_PATH' does not exist." >&2
  exit 1
fi

if [[ "${BACKUP_PATH##*.}" != "bak" ]]; then
  echo "Error: backup file must end with .bak" >&2
  exit 1
fi

mkdir -p "$DIR/mssql_backup"
FILE_NAME="$(basename "$BACKUP_PATH")"
DEST_PATH="$DIR/mssql_backup/$FILE_NAME"

if [[ "$BACKUP_PATH" != "$DEST_PATH" ]]; then
  cp "$BACKUP_PATH" "$DEST_PATH"
fi
chown 10001:10001 "$DEST_PATH"

LOGICAL_NAME="$(basename "$FILE_NAME" .bak)"
if [[ -z "$LOGICAL_NAME" ]]; then
  echo "Error: could not derive LOGICAL_NAME from '$FILE_NAME'" >&2
  exit 1
fi

echo "Backup file: $DEST_PATH"
echo "Target database: $DB_NAME"
echo "Derived logical name: $LOGICAL_NAME"

docker compose run --rm mssql-backup \
  /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "$SA_PASS" \
  -Q "RESTORE DATABASE [$DB_NAME] \
      FROM DISK='/backup/$FILE_NAME' \
      WITH MOVE '$LOGICAL_NAME' TO '/var/opt/mssql/data/${DB_NAME}.mdf', \
      MOVE '${LOGICAL_NAME}_log' TO '/var/opt/mssql/data/${DB_NAME}_log.ldf', \
      REPLACE, RECOVERY"