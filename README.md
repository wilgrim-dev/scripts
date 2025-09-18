## Odoo Database Management Scripts

This repository contains Bash scripts for managing Odoo databases, including a script to restore a database from a zip file and a script to create a backup.

### Odoo Restore

The odoo-restore script automates the process of restoring an Odoo database from a zip file. It handles both modern .zip dumps and older binary formats.

#### Usage

To run the restore script, use the following command:

````
$./odoo-restore <database_name> <dump_zip>
````

<database_name>: The name you want to give to the new database.

<dump_zip>: The path to the Odoo database dump file (.zip, .sql, or binary).

#### Features

* Interactive Drop: If the specified database already exists, the script will prompt you to confirm if you want to drop it before proceeding. This prevents accidental data loss.

* Intelligent Restore: The script automatically detects the dump file format (.zip, .sql, or binary) and uses the correct PostgreSQL command (psql or pg_restore) to perform the restoration.

* Filestore Handling: For .zip dumps, the script extracts and moves the filestore directory to the correct location.

#### Prerequisites

* PostgreSQL Client Tools: Ensure psql, createdb, and dropdb are installed and in your system's PATH.

* unzip: The unzip utility is required to handle .zip dump files.

### Odoo Backup

The odoo-dump script simplifies the creation of a complete Odoo database backup, including the database itself and its filestore.

#### Usage

To create a backup, use the following command:

````
$./odoo-dump
````

#### Features

* Single-file Backup: The script creates a single .zip file containing a dump.sql, manifest.json file and the filestore folder, which is the standard Odoo backup format.

* Timestamped Filename: The backup file is automatically named with the database name and a timestamp (e.g., odoo_db_2023-10-27_10-30-00.zip), making it easy to manage multiple backups.

#### Prerequisites

* PostgreSQL Client Tools: Ensure pg_dump is installed and in your system's PATH.

* zip: The zip utility is required to compress the backup files.

* jq: jq utility is required to manipulate jsons. Ensure jq is installed in your system's PATH.