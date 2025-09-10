#!/bin/bash


# Defaulting to the current directory where the script is run as the source directory.
SOURCE_DIR="."

# Set the destination directory name.
DEST_DIR="json_and_CSV"


# check if destination directort exits. The -p flag ensures that no error is reported if the directory exists.
echo "Checking if destination directory $DEST_DIR exists"
mkdir -p "$DEST_DIR"
echo "Directory check complete."
echo ""

# Find and move all .csv and .json files from the source to the destination.
# Using a loop to handle files one by one, which is safer for filenames with spaces.
# The -v (verbose) flag in the mv command shows which files are being moved.

echo "Starting file migration..."

# Move all CSV files from source to destination
for file in "$SOURCE_DIR"/*.csv; do
  # The "if" statement prevents errors if no files of a certain type are found.
  if [ -f "$file" ]; then
    mv -v "$file" "$DEST_DIR/"
  fi
done

# Move all JSON files
for file in "$SOURCE_DIR"/*.json; do
  if [ -f "$file" ]; then
    mv -v "$file" "$DEST_DIR/"
  fi
done

echo ""
echo "File migration complete. All CSV and JSON files have been moved to '$DEST_DIR'."
