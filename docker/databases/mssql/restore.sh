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

# Try to discover logical file names from the backup
echo "Inspecting backup to discover logical file names..."
FILELIST_RAW=$(docker compose run --rm mssql-backup \
  /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASS" \
  -Q "RESTORE FILELISTONLY FROM DISK='/backup/$FILE_NAME'" -s "|" -W -h -1 || true)

DATA_LOGICAL=""
LOG_LOGICAL=""
while IFS= read -r line; do
  # skip empty lines
  [[ -z "$line" ]] && continue
  # each column separated by |, LogicalName is first, Type is third
  col1=$(echo "$line" | awk -F'|' '{print $1}')
  col3=$(echo "$line" | awk -F'|' '{print $3}')
  case "$col3" in
    D) DATA_LOGICAL="$col1" ;; 
    L) LOG_LOGICAL="$col1" ;; 
  esac
done <<< "$FILELIST_RAW"

if [[ -z "$DATA_LOGICAL" || -z "$LOG_LOGICAL" ]]; then
  echo "Warning: could not parse logical names from backup, falling back to filename-based names." >&2
  DATA_LOGICAL="$(basename "$FILE_NAME" .bak)"
  LOG_LOGICAL="${DATA_LOGICAL}_log"
fi

echo "Backup file: $DEST_PATH"
echo "Target database: $DB_NAME"
echo "Data logical name: $DATA_LOGICAL"
echo "Log logical name: $LOG_LOGICAL"

docker compose run --rm mssql-backup \
  /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "$SA_PASS" \
  -Q "RESTORE DATABASE [$DB_NAME] \
      FROM DISK='/backup/$FILE_NAME' \
      WITH MOVE '$DATA_LOGICAL' TO '/var/opt/mssql/data/${DB_NAME}.mdf', \
      MOVE '$LOG_LOGICAL' TO '/var/opt/mssql/data/${DB_NAME}_log.ldf', \
      REPLACE, RECOVERY"