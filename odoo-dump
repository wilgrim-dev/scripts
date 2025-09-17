#!/bin/bash

# --- Configuration ---
# Set these variables before running the script
BACKUP_DIR="/tmp/odoo_backups"

# --- Dependencies Check ---
# This script requires 'psql' for database queries and 'jq' for JSON manipulation.
# Make sure they are installed on your system.
command -v psql >/dev/null 2>&1 || { echo >&2 "Error: psql is not installed. Aborting."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "Error: jq is not installed. Aborting."; exit 1; }

# --- Script Logic ---

# Create a temporary directory for the backup contents
TEMP_DIR=$(mktemp -d)

# Use a trap to ensure the temporary directory is cleaned up on script exit
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Created temporary directory: $TEMP_DIR"

# Step 1: Get the database name interactively
read -p "Enter the Odoo database name (e.g., odoo15prod): " DB_NAME
echo "Using database: '$DB_NAME'"

# Step 2: Dump the database into a .sql file
echo "Dumping database '$DB_NAME' to a SQL file..."
pg_dump --no-owner --format=plain --file="$TEMP_DIR/dump.sql" "$DB_NAME"
if [ $? -ne 0 ]; then
    echo "Error: pg_dump failed. Exiting."
    exit 1
fi

# Step 3: Get the filestore path interactively
read -p "Does odoo.conf have custom data directory? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    read -p "Enter the full Odoo filestore directory path (e.g., /home/odoo/.local/share/Odoo/filestore/odoo15prod): " ODOO_FILESTORE
else
    read -p "Enter Odoo's user home directory path (e.g., /home/odoo/): " ODOO_FILESTORE
    ODOO_FILESTORE="$ODOO_FILESTORE/.local/share/Odoo/filestore/$DB_NAME"
fi

# Copy the filestore
echo "Using filestore path: '$ODOO_FILESTORE'"
echo "Copying filestore from '$ODOO_FILESTORE'..."
if [ -d "$ODOO_FILESTORE" ]; then
    cp -r "$ODOO_FILESTORE" "$TEMP_DIR/filestore"
else
    echo "Warning: Filestore directory not found at '$ODOO_FILESTORE'."
fi

# Step 4: Create the manifest.json file
# This is the bash equivalent of the dump_db_manifest() Python function.
echo "Creating manifest.json from database data..."

# Get Odoo's major version from the database
# This query is more reliable as it uses the base module
MAJOR_VERSION=$(psql -d "$DB_NAME" -t -A -c "SELECT latest_version FROM ir_module_module WHERE name = 'base';")
if [ -z "$MAJOR_VERSION" ]; then
    echo "Warning: Could not determine Odoo major version from the database. Defaulting to '14.0'."
    MAJOR_VERSION="14.0"
fi
MAJOR_VERSION=$(echo "$MAJOR_VERSION" | cut -d'.' -f1,2)

# Get PostgreSQL version
PG_VERSION=$(psql -d "$DB_NAME" -t -A -c "SELECT substring(version() FROM 'PostgreSQL ([0-9]+\.[0-9]+)');")
if [ -z "$PG_VERSION" ]; then
    echo "Warning: Could not determine PostgreSQL version."
    PG_VERSION="unknown"
fi

# Get a list of all installed modules
# We query the database for all modules with a state of 'installed'
MODULES_JSON=$(psql -d "$DB_NAME" -t -A -c "SELECT COALESCE(jsonb_object_agg(name, latest_version), '{}') FROM ir_module_module WHERE state = 'installed';")

# Use jq to build the final JSON object with all the collected data
jq -n \
  --arg odoo_dump "1" \
  --arg db_name "$DB_NAME" \
  --arg version "$MAJOR_VERSION" \
  --argjson version_info '[]' \
  --arg major_version "$MAJOR_VERSION" \
  --arg pg_version "$PG_VERSION" \
  --argjson modules "$MODULES_JSON" \
  '{
    odoo_dump: $odoo_dump,
    db_name: $db_name,
    version: $version,
    version_info: ($major_version | split(".") | map(tonumber) + [0, "final", 0, ""]),
    major_version: $major_version,
    pg_version: $pg_version,
    modules: $modules
  }' > "$TEMP_DIR/manifest.json"

# Step 5: Zip the contents of the temporary directory
BACKUP_FILENAME="${DB_NAME}_$(date +%Y-%m-%d_%H-%M-%S).zip"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILENAME"

# Ensure the final backup directory exists
mkdir -p "$BACKUP_DIR"

# Change to the temp directory to perform the zip operation easily
cd "$TEMP_DIR" || exit

echo "Creating final ZIP file: $BACKUP_PATH"
zip -r "$BACKUP_PATH" ./*

echo "Backup completed successfully!"
echo "Backup file is located at: $BACKUP_PATH"

