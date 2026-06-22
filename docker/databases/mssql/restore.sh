#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/.env"

usage() {
  echo "Usage: $0 <backup-file.bak> <target-db-name>"
  echo "Example: $0 filmnab.bak Filmnab_db"
  exit 1
}

if [[ $# -ne 2 ]]; then
  usage
fi

FILE_NAME="$1"
DB_NAME="$2"

if [[ "${FILE_NAME##*.}" != "bak" ]]; then
  echo "Error: backup file must end with .bak" >&2
  usage
fi

LOGICAL_NAME="$(basename "$FILE_NAME" .bak)"

if [[ -z "$LOGICAL_NAME" ]]; then
  echo "Error: could not derive LOGICAL_NAME from '$FILE_NAME'" >&2
  exit 1
fi

if [[ -z "$DB_NAME" ]]; then
  echo "Error: target database name is required" >&2
  usage
fi

echo "Backup file: $FILE_NAME"
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
