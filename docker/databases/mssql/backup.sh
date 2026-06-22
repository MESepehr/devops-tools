#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/.env"


DB_NAME=Filmnab_Codefirst_db
TARNAME=${DB_NAME}_$(date +%F_%H-%M-%S)

docker load -i /home/devops/mssql/mssql-tools.tar

docker compose -f "$DIR/docker-compose.yml" run --rm mssql-backup \
  /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "$SA_PASS" \
  -Q "BACKUP DATABASE [$DB_NAME]
      TO DISK='/backup/${TARNAME}.bak'
      WITH INIT, COMPRESSION"


#tar -czf ./mssql_backup/$TARNAME.tar.gz ./mssql_backup/$TARNAME.bak
#rm ./mssql_backup/$TARNAME.bak

