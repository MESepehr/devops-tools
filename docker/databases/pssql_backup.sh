#!/bin/bash

#Load .env file
source ./.env

# Configuration
DB_USER=penpot_admin           # Default PostgreSQL user
DB_NAME=penpot # Replace with your database name


BACKUP_DIR="/home/backups"       # Directory to save backups
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="${BACKUP_DIR}/${DB_NAME}_backup_${TIMESTAMP}.sql.gz"


echo "Starting backup for database: $DB_NAME for $DB_USER"

CONTAINER_NAME="postgres_container"
# Run pg_dump inside the docker container
docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$FILENAME"

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Backup successful! File saved to: $FILENAME"
else
    echo "Backup failed!"
    exit 1
fi
