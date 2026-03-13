#!/bin/bash

#Load .env file
#source ./.env

# Configuration
DB_USER=penpot_admin
DB_NAME=penpot # Replace with your database name
BACKUP_FILE=../backups/penpot_backup_20260313_074749.sql.gz


CONTAINER_NAME="postgres_container"
# 1. Drop and create the schema
docker exec -i $CONTAINER_NAME psql -U postgres -d $DB_NAME -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# 2. Grant target user to schema
docker exec -i $CONTAINER_NAME psql -U postgres -d $DB_NAME -c "GRANT ALL ON SCHEMA public TO $DB_USER;"
#docker exec -i $CONTAINER_NAME psql -U $DB_USER -c "CREATE DATABASE $DB_NAME;"


gunzip -c $BACKUP_FILE | docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME