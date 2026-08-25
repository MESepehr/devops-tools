#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/.backup.conf"

# Reset configuration
if [[ "$1" == "--reset" ]]; then
    rm -f "$CONFIG_FILE"
    echo "Configuration removed."
    echo "Run the script again to set a new configuration."
    exit 0
fi


# First run
if [[ ! -f "$CONFIG_FILE" ]]; then

    echo "========================================"
    echo "First run setup"
    echo "Please enter your backup settings."
    echo "========================================"

    read -rp "Database name: " db

    read -rp "MySQL username [backup]: " db_user
    db_user=${db_user:-backup}

    read -rsp "MySQL password: " db_password
    echo

    echo
    echo "Database location:"
    echo "1) Local MySQL"
    echo "2) Docker container"

    read -rp "Select [1/2]: " db_type

    container_name=""

    if [[ "$db_type" == "2" ]]; then
        read -rp "Docker container name: " container_name
    else
        db_type="1"
    fi

    read -ep "Backup directory [/mnt/backup]: " dir
    dir=${dir:-/mnt/backup}

    # Save configuration
    cat > "$CONFIG_FILE" <<EOF
db="$db"
db_user="$db_user"
db_password="$db_password"
db_type="$db_type"
container_name="$container_name"
dir="$dir"
EOF

    chmod 600 "$CONFIG_FILE"

    echo
    echo "Configuration saved."
    echo "Config file: $CONFIG_FILE"
    echo

else

    source "$CONFIG_FILE"

    echo "Using saved configuration."
    echo "To reset the configuration, run:"
    echo
    echo "  $0 --reset"
    echo
fi


# Create backup directory
mkdir -p "$dir"


# Backup file name
timestamp=$(date +%s)
date_part=$(date +%Y-%m-%d)

file="mysql_backup_${db}_${date_part}_${timestamp}.tar.gz"

TEMP_DIR="/tmp/mysql_backup_${db}_${timestamp}"
SQL_FILE="mysql_backup_${db}_${date_part}_${timestamp}.sql"

TEMP_SQL="$TEMP_DIR/$SQL_FILE"
TEMP_TAR="/tmp/$file"

DEST_FILE="$dir/$file"


echo "========================================"
echo "Starting backup"
echo "Database: $db"
echo "Date: $(date)"
echo "Backup directory: $dir"

if [[ "$db_type" == "2" ]]; then
    echo "Database type: Docker"
    echo "Container: $container_name"
else
    echo "Database type: Local"
fi

echo "========================================"


# Create temporary directory
mkdir -p "$TEMP_DIR"


# Cleanup temporary files on exit
cleanup() {
    rm -rf "$TEMP_DIR"
    rm -f "$TEMP_TAR"
}

trap cleanup EXIT


echo "Creating database backup..."


# Backup from Docker
if [[ "$db_type" == "2" ]]; then

    # Check container
    if ! docker ps --format '{{.Names}}' | grep -qx "$container_name"; then
        echo "ERROR: Docker container is not running."
        echo "Container: $container_name"
        exit 1
    fi

    # Create SQL backup
    docker exec \
        "$container_name" \
        mysqldump \
        -u"$db_user" \
        -p"$db_password" \
        "$db" \
        --routines \
        --single-transaction \
        --complete-insert \
        --no-tablespaces \
        > "$TEMP_SQL"

else

    # Create SQL backup from local MySQL
    mysqldump \
        -u"$db_user" \
        -p"$db_password" \
        "$db" \
        --routines \
        --single-transaction \
        --complete-insert \
        --no-tablespaces \
        --result-file="$TEMP_SQL"

fi


# Check SQL backup
if [[ ! -s "$TEMP_SQL" ]]; then
    echo "ERROR: Backup file is empty."
    exit 1
fi


echo "Compressing backup..."


# Create tar.gz
tar -czf "$TEMP_TAR" \
    -C "$TEMP_DIR" \
    "$SQL_FILE"


# Check archive
if [[ ! -s "$TEMP_TAR" ]]; then
    echo "ERROR: Archive was not created."
    exit 1
fi


# Test archive
if ! tar -tzf "$TEMP_TAR" >/dev/null; then
    echo "ERROR: Archive verification failed."
    exit 1
fi


echo "Moving backup to: $DEST_FILE"

mv "$TEMP_TAR" "$DEST_FILE"


# Prevent cleanup from deleting final file
TEMP_TAR=""


echo "Syncing files..."
sync


echo "========================================"
echo "Backup completed successfully."
echo "Backup file:"
echo "$DEST_FILE"
echo "========================================"