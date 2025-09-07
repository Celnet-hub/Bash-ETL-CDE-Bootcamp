#!/bin/bash

# cron script is: 0 0 * * * /home/dubem/data-engineering/CDE_CORE/assignments/git_linux/schedule.sh

set -euo pipefail

#### Config ###################
export TZ=Europe/London
BASE_DIR="/home/dubem/data-engineering/CDE_CORE/assignments/git_linux"
LOG_DIR="$BASE_DIR/logs"

### schedule extract
EXTRACT_URL="https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2023-financial-year-provisional/Download-data/annual-enterprise-survey-2023-financial-year-provisional.csv"
EXTRACT_DEST="$BASE_DIR/raw"
EXTRACT_SCRIPT="$BASE_DIR/extract.sh"


#### schedule transload and load
TRANSFORM_LOAD_SCRIPT="$BASE_DIR/transform_load.sh"

#create directory for logs
mkdir -p "$LOG_DIR"


ts="$(date +%F_%H-%M-%S)"

# Run extract; only on success run transform_load
if /bin/bash "$EXTRACT_SCRIPT" "$EXTRACT_URL" "$EXTRACT_DEST" >>"$LOG_DIR/extract_${ts}.log" 2>&1; then
  /bin/bash "$TRANSFORM_LOAD_SCRIPT" >>"$LOG_DIR/transform_${ts}.log" 2>&1
else
  echo "extract.sh failed; skipping transform_load.sh" >>"$LOG_DIR/error_${ts}.log"
  exit 1
fi
