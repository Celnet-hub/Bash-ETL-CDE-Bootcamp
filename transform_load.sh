#!/bin/bash

# exit script if any command fails
set -e

if [ $# -lt 3 ]; then
  echo "Usage: $0 <input.csv> <old_col_name_name> <new_col_name>"
  exit 1
fi

INPUT="$1"
old_col_name="$2"
new_col_name="$3"
cols_to_keep="Year,Value,Units,variable_code"

output_dir="Transformed"
output_file="2023_year_finance.csv"

# create the directory
mkdir -p "$output_dir"


# If the selection list still mentions old_col_name, rewrite to NEW_COL so the cut works post-rename.
KEEP_UPDATED="${cols_to_keep//${old_col_name}/${new_col_name}}"

if command -v mlr >/dev/null 2>&1; then
  echo "Using Miller (mlr) for CSV-safe transforms..."
  mlr --icsv --ocsv \
    rename "$old_col_name","$new_col_name" then cut -o -f "$KEEP_UPDATED" \
    "$INPUT" > "$output_dir/$output_file"

fi

###### confirm file exists and columns match ---
cd "$output_dir"
if [ ! -f "$output_file" ] || [ ! -s "$output_file" ]; then
  echo "Output file missing or empty: $output_file" >&2
  exit 1
fi


header="$(head -n1 "$output_file")"

# Exact match check (string compare)
if [ "$header" = "$KEEP_UPDATED" ]; then
  echo "Created $output_file"
  echo "Verified columns: $header"
else
  echo "Created $output_file but header differs."
  echo "   Expected: $KEEP_UPDATED"
  echo "   Actual:   $header"
  exit 1
fi
