#!/bin/bash

# exit script if any command fails
set -e

# if [ $# -lt 3 ]; then
#   echo "Usage: $0 <input.csv> <old_col_name_name> <new_col_name>"
#   exit 1
# fi

INPUT="/home/dubem/data-engineering/CDE_CORE/assignments/git_linux/raw/annual-enterprise-survey-2023-financial-year-provisional.csv"
old_col_name="Variable_code"
new_col_name="variable_code"
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
transformed_data_path="$output_dir/$output_file"
if [ ! -f "$transformed_data_path" ] || [ ! -s "$transformed_data_path" ]; then
  echo "Output file missing or empty: $transformed_data_path" >&2
  exit 1
fi


header="$(head -n1 "$transformed_data_path")"

# Exact match check (string compare)
if [ "$header" = "$KEEP_UPDATED" ]; then
  echo "Created $transformed_data_path"
  echo "Verified columns: $header"
else
  echo "Created $transformed_data_path but header differs."
  echo "   Expected: $KEEP_UPDATED"
  echo "   Actual:   $header"
  exit 1
fi


############################################ LOAD ###############################

# make the Gold directory to store transformed data
data_repo="GOLD"
mkdir -p "$data_repo"
cp "$transformed_data_path" "$data_repo/"
ls "$data_repo/"
