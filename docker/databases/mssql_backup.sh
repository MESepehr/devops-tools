#!/bin/bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/.env"


DB_NAME=example_db
TARNAME=${DB_NAME}_$(date +%F_%H-%M-%S)

docker compose -f "$DIR/docker-compose.yml" run --rm mssql-backup \
  /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "$SA_PASS" \
  -Q "BACKUP DATABASE [$DB_NAME]
      TO DISK='/backup/${TARNAME}.bak'
      WITH INIT, COMPRESSION"