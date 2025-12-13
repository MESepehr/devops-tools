#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/.env"

DB_NAME=example_db
docker compose -f "$DIR/docker-compose.yml" run --rm mssql-backup \
  /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "$SA_PASS" \
  -Q "BACKUP DATABASE [$DB_NAME]
      TO DISK='/backup/${DB_NAME}_$(date +%F_%H-%M-%S).bak'
      WITH INIT, COMPRESSION"


#TARNAME=${DB_NAME}_$(date +%F_%H-%M-%S)
#tar -czf ./mssql_backup/$TARNAME.tar.gz ./mssql_backup/$DB_NAME.bak