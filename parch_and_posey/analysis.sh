#!/bin/bash

# ==============================================================================
# Description: This script loads Parch and Posey CSV data into a PostgreSQL
#              database. It performs the following steps:
#              1. Checks for and creates the specified database.
#              2. Creates the table schema using 'create_tables.sql'.
#              3. Iterates over CSV files and copies them to the database.
# ==============================================================================

set -euo pipefail # Exit immediately if a command exits with a non-zero status.

# --- PostgreSQL Configuration ---
# IMPORTANT: Edit these variables to match your local PostgreSQL setup.
PG_USER="dubem_user"
PG_HOST="localhost"
PG_PORT="5432"
DB_NAME="posey"

# For security, password is set via an environment variable.
# Before running the script, run in terminal:
# export PGPASSWORD="your_password"
if [ -z "$PGPASSWORD" ]; then
    echo "Warning: PGPASSWORD environment variable is not set."
    echo "You may be prompted for a password."
fi

# --- File Path Configuration ---
DATA_DIR="./pnp_data"
SQL_DIR="./sql_script"
SCHEMA_FILE="$SQL_DIR/create_tables.sql"

echo "Starting data ingestion process for Parch and Posey data..."

# Check if the database exists and create it if it doesn't.
echo "Checking if database '$DB_NAME' exists..."
if psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
    echo "Database '$DB_NAME' already exists. Skipping creation."
else
    echo "Database '$DB_NAME' not found. Creating it now..."
    createdb -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" "$DB_NAME"
    echo "Database '$DB_NAME' created successfully."
fi

# Create the table schema before loading data.
echo "Creating table schema from $SCHEMA_FILE..."
psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$DB_NAME" -f "$SCHEMA_FILE"
echo "Schema created successfully."


############ LOADING the DATA ################################
echo "Beginning data copy from CSV files in $DATA_DIR..."

# Define a helper function for copying to the Database
copy_csv() {
    local table_name="$1"
    local csv_file="$DATA_DIR/$table_name.csv"
    echo " - Loading data from $csv_file into table: $table_name"
    psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$DB_NAME" \
         -c "\copy $table_name FROM '$csv_file' WITH (FORMAT csv, HEADER true);"
    echo " - Successfully loaded data into $table_name."
}

# Call the function for each table in the correct sequence
copy_csv "region"
copy_csv "sales_reps"
copy_csv "accounts"
copy_csv "orders"
copy_csv "web_events"

echo "Data ingestion process complete. All files have been loaded into the '$DB_NAME' database."
