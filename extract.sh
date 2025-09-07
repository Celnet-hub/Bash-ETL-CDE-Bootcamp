#!/bin/bash

# exit script if any command fails
set -e

# check if url and file destination is passed as an arguement to the script
if [ $# -lt 1 ]; then
	echo "Usage: $0 <url> <destination_folder> [filename]"
	exit 1
fi

# declear variable for the data url
DATA_URL="$1"


# Destination folder: default to 'raw' if not provided
if [ -n "$2" ]; then
  DESTINATION_FOLDER="$2"
else
  DESTINATION_FOLDER="raw"
fi
mkdir -p "$DESTINATION_FOLDER"

# check if destination filename is passed as an argument, else set a default
if [ -n "$3" ]; then
	DESTINATION_FILE="$3"
else
	DESTINATION_FILE=$(basename "$DATA_URL")
fi

DESTINATION_PATH="$DESTINATION_FOLDER/$DESTINATION_FILE"


# download file
if command -v wget >/dev/null 2>&1; then
	echo "Downloading data with wget...."
	wget -O "$DESTINATION_PATH" "$DATA_URL"
elif command -v curl >/dev/null 2>&1; then
	echo "Wget not installed. Downloading with curl...."
	curl -L -o "$DESTINATION_PATH" "$DATA_URL"
else
	echo "wget or curl is not installed" >&2
	exit 1
fi

echo "Download completed: $DESTINATION_PATH"

