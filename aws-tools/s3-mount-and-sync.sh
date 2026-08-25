#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/.backup.conf"
PASSWD_FILE="$SCRIPT_DIR/.s3fs-passwd"

# --------------------------------------------------
# Setup
# --------------------------------------------------

if [[ "$1" == "--setup" ]]; then
    echo "Installing required packages..."

    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        apt-get install -y s3fs awscli rsync

    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y s3fs awscli rsync

    elif command -v yum >/dev/null 2>&1; then
        yum install -y s3fs awscli rsync

    else
        echo "Unsupported package manager."
        echo "Install s3fs, awscli and rsync manually."
        exit 1
    fi

    echo "Setup completed."
    exit 0
fi


# --------------------------------------------------
# Reset
# --------------------------------------------------

if [[ "$1" == "--reset" ]]; then
    rm -f "$CONFIG_FILE"
    rm -f "$PASSWD_FILE"

    echo "Configuration removed."
    echo "Run the script again to configure it."
    exit 0
fi


# --------------------------------------------------
# Check dependencies
# --------------------------------------------------

for command in s3fs rsync; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "$command is not installed."
        echo "Run: $0 --setup"
        exit 1
    fi
done


# --------------------------------------------------
# First run
# --------------------------------------------------

if [[ ! -f "$CONFIG_FILE" ]]; then

    echo "First run configuration"
    echo

    read -rp "S3 bucket name: " S3_BUCKET

    read -rp "S3 endpoint [https://s3.ir-thr-at1.arvanstorage.ir]: " S3_ENDPOINT
    S3_ENDPOINT="${S3_ENDPOINT:-https://s3.ir-thr-at1.arvanstorage.ir}"

    read -rp "S3 access key: " S3_ACCESS_KEY

    read -rsp "S3 secret key: " S3_SECRET_KEY
    echo

    read -rp "Local folder to backup: " SOURCE_DIR

    read -rp "Mount point [/mnt/backup]: " MOUNT_POINT
    MOUNT_POINT="${MOUNT_POINT:-/mnt/backup}"

    # Validate source folder
    if [[ ! -d "$SOURCE_DIR" ]]; then
        echo "Source folder does not exist:"
        echo "$SOURCE_DIR"
        exit 1
    fi

    # Create mount point
    mkdir -p "$MOUNT_POINT"

    # Save S3 credentials
    cat > "$PASSWD_FILE" <<EOF
$S3_ACCESS_KEY:$S3_SECRET_KEY
EOF

    chmod 600 "$PASSWD_FILE"

    # Save configuration
    cat > "$CONFIG_FILE" <<EOF
S3_BUCKET="$S3_BUCKET"
S3_ENDPOINT="$S3_ENDPOINT"
SOURCE_DIR="$SOURCE_DIR"
MOUNT_POINT="$MOUNT_POINT"
PASSWD_FILE="$PASSWD_FILE"
EOF

    chmod 600 "$CONFIG_FILE"

    echo
    echo "Configuration saved."
fi


# --------------------------------------------------
# Load configuration
# --------------------------------------------------

source "$CONFIG_FILE"


# --------------------------------------------------
# Validate configuration
# --------------------------------------------------

if [[ ! -f "$PASSWD_FILE" ]]; then
    echo "S3 credentials file not found."
    echo "Run: $0 --reset"
    exit 1
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Source folder does not exist:"
    echo "$SOURCE_DIR"
    exit 1
fi

mkdir -p "$MOUNT_POINT"


# --------------------------------------------------
# Mount bucket
# --------------------------------------------------

if mountpoint -q "$MOUNT_POINT"; then
    echo "Bucket is already mounted."
else
    echo "Mounting bucket..."

    s3fs "$S3_BUCKET" "$MOUNT_POINT" \
        -o passwd_file="$PASSWD_FILE" \
        -o allow_other \
        -o url="$S3_ENDPOINT" \
        -o use_path_request_style \
        -o nonempty

    echo "Bucket mounted."
fi


# --------------------------------------------------
# Sync
# --------------------------------------------------

echo "Syncing files..."

rsync -av \
    --ignore-existing \
    "$SOURCE_DIR"/ \
    "$MOUNT_POINT"/

echo "Sync completed."