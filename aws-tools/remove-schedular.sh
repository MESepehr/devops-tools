#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/.backup-retention.conf"

# --------------------------------------------------
# Setup
# --------------------------------------------------

if [[ "$1" == "--setup" ]]; then
    echo "Installing required packages..."

    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        apt-get install -y findutils

    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y findutils

    elif command -v yum >/dev/null 2>&1; then
        yum install -y findutils

    else
        echo "Unsupported package manager."
        echo "find command must be installed manually."
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

    echo "Configuration removed."
    echo "Run the script again to configure it."
    exit 0
fi


# --------------------------------------------------
# Help
# --------------------------------------------------

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage:"
    echo
    echo "  $0"
    echo "      Run retention cleanup."
    echo
    echo "  $0 --dry-run"
    echo "      Show files that would be deleted."
    echo
    echo "  $0 --setup"
    echo "      Install required packages."
    echo
    echo "  $0 --reset"
    echo "      Remove saved configuration."
    exit 0
fi


# --------------------------------------------------
# First run
# --------------------------------------------------

if [[ ! -f "$CONFIG_FILE" ]]; then

    echo "Backup retention configuration"
    echo

    read -ep "Backup folder: " BACKUP_DIR

    if [[ -z "$BACKUP_DIR" ]]; then
        echo "Backup folder is required."
        exit 1
    fi

    if [[ ! -d "$BACKUP_DIR" ]]; then
        echo "Folder does not exist:"
        echo "$BACKUP_DIR"
        exit 1
    fi


    read -ep "Keep all files newer than how many days [30]: " KEEP_DAYS
    KEEP_DAYS="${KEEP_DAYS:-30}"

    if ! [[ "$KEEP_DAYS" =~ ^[0-9]+$ ]]; then
        echo "Keep days must be a number."
        exit 1
    fi


    read -ep "For older files, keep one every how many days [7]: " RETENTION_INTERVAL
    RETENTION_INTERVAL="${RETENTION_INTERVAL:-7}"

    if ! [[ "$RETENTION_INTERVAL" =~ ^[0-9]+$ ]] || [[ "$RETENTION_INTERVAL" -eq 0 ]]; then
        echo "Retention interval must be a number greater than 0."
        exit 1
    fi


    # --------------------------------------------------
    # Save configuration
    # --------------------------------------------------

    cat > "$CONFIG_FILE" <<EOF
BACKUP_DIR="$BACKUP_DIR"
KEEP_DAYS="$KEEP_DAYS"
RETENTION_INTERVAL="$RETENTION_INTERVAL"
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

if [[ -z "$BACKUP_DIR" ]]; then
    echo "Backup folder is not configured."
    exit 1
fi

if [[ -z "$KEEP_DAYS" ]]; then
    echo "Keep days is not configured."
    exit 1
fi

if [[ -z "$RETENTION_INTERVAL" ]]; then
    echo "Retention interval is not configured."
    exit 1
fi

if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Backup folder does not exist:"
    echo "$BACKUP_DIR"
    exit 1
fi


# --------------------------------------------------
# Dry run
# --------------------------------------------------

DRY_RUN=false

if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
fi


# --------------------------------------------------
# Calculate dates
# --------------------------------------------------

NOW=$(date +%s)

KEEP_SECONDS=$((KEEP_DAYS * 86400))
INTERVAL_SECONDS=$((RETENTION_INTERVAL * 86400))

KEEP_UNTIL=$((NOW - KEEP_SECONDS))


# --------------------------------------------------
# Cleanup
# --------------------------------------------------

echo "Backup retention cleanup"
echo
echo "Backup folder: $BACKUP_DIR"
echo "Keep all files newer than: $KEEP_DAYS days"
echo "Older file interval: every $RETENTION_INTERVAL days"
echo

DELETED_COUNT=0
KEPT_COUNT=0


# --------------------------------------------------
# Process files
# --------------------------------------------------

while IFS= read -r -d '' FILE; do

    FILE_TIME=$(stat -c %Y "$FILE" 2>/dev/null || echo 0)

    if [[ "$FILE_TIME" -eq 0 ]]; then
        echo "Skipping:"
        echo "$FILE"
        continue
    fi


    # --------------------------------------------------
    # Recent files
    # --------------------------------------------------

    if [[ "$FILE_TIME" -ge "$KEEP_UNTIL" ]]; then
        KEPT_COUNT=$((KEPT_COUNT + 1))
        continue
    fi


    # --------------------------------------------------
    # Old files
    # --------------------------------------------------

    AGE_SECONDS=$((NOW - FILE_TIME))

    SLOT=$((AGE_SECONDS / INTERVAL_SECONDS))

    REMAINDER=$((AGE_SECONDS % INTERVAL_SECONDS))


    # --------------------------------------------------
    # Keep one file for each interval
    #
    # The oldest/closest file to the interval boundary
    # is kept. Other files in the same interval are
    # deleted.
    # --------------------------------------------------

    if [[ "$REMAINDER" -lt 3600 ]]; then
        KEPT_COUNT=$((KEPT_COUNT + 1))
        continue
    fi


    # --------------------------------------------------
    # Delete
    # --------------------------------------------------

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] Would delete:"
        echo "$FILE"
    else
        echo "Deleting:"
        echo "$FILE"

        rm -f -- "$FILE"
    fi

    DELETED_COUNT=$((DELETED_COUNT + 1))

done < <(
    find "$BACKUP_DIR" \
        -type f \
        -print0
)


# --------------------------------------------------
# Summary
# --------------------------------------------------

echo
echo "Cleanup completed."
echo "Files kept: $KEPT_COUNT"
echo "Files deleted: $DELETED_COUNT"

if [[ "$DRY_RUN" == true ]]; then
    echo
    echo "Dry-run mode was used."
    echo "No files were deleted."
fi
