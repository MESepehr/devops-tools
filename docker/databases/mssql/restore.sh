#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/.env"

##Copy the backup file to ./mssql_backup
export FILE_NAME=filmnab.bak

## Use bellow command to file the LogicalName of DB under LogicalName column
#docker compose run --rm mssql-backup \
#  /opt/mssql-tools/bin/sqlcmd \
#  -S localhost -U sa -P "$SA_PASS" \
#  -Q "RESTORE FILELISTONLY FROM DISK='/backup/$FILE_NAME'"

export LOGICAL_NAME=Filmnab_NewDb
export DB_NAME=Filmnab_db

if [ -z "LOGICAL_NAME" ]; then
exit 1
fi

#docker compose run --rm mssql-backup \
#  /opt/mssql-tools/bin/sqlcmd \
#  -S localhost -U sa -P "$SA_PASS" \
#  -Q "RESTORE DATABASE [$DB_NAME] 
#      FROM DISK='/backup/$FILE_NAME'
#      WITH MOVE '$LOGICAL_NAME' TO '/var/opt/mssql/data/$DB_NAME.mdf',
#      MOVE '$LOGICAL_NAME_log' TO '/var/opt/mssql/data/$DB_NAME_log.ldf',
#      REPLACE, RECOVERY"
echo $LOGICAL_NAME

docker compose run --rm mssql-backup \
  /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "$SA_PASS" \
  -Q "RESTORE DATABASE [$DB_NAME] 
      FROM DISK='/backup/$FILE_NAME'
      WITH MOVE '${LOGICAL_NAME}' TO '/var/opt/mssql/data/${DB_NAME}.mdf',
      MOVE '${LOGICAL_NAME}_log' TO '/var/opt/mssql/data/${DB_NAME}_log.ldf',
      REPLACE, RECOVERY"
