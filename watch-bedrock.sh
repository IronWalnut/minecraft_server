#!/bin/bash
set -euo pipefail

API_URL="https://net-secondary.web.minecraft-services.net/api/v1.0/download/links"
LAST="/tmp/bedrock_last_ver"
UPDATE_SCRIPT="/opt/minecraft_server/auto_upgrade.sh"

########################################
# Fetch JSON Safely
########################################
JSON=$(curl --http1.1 -L -A "Mozilla/5.0" \
    --connect-timeout 10 \
    --max-time 30 \
    --retry 3 \
    --retry-delay 5 \
    -sS "$API_URL")

########################################
# Extract Linux Download URL
########################################
DOWNLOAD_URL=$(printf "%s" "$JSON" \
    | jq -r '.result.links[] | select(.downloadType=="serverBedrockLinux") | .downloadUrl')

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
    echo "$(date -Iseconds) - ERROR: Could not extract Linux Bedrock download URL" >&2
    exit 1
fi

########################################
# Extract Version from Filename
########################################
LATEST=$(basename "$DOWNLOAD_URL")

if [[ ! "$LATEST" =~ bedrock-server-[0-9]+(\.[0-9]+){2,3}\.zip ]]; then
    echo "$(date -Iseconds) - ERROR: Unexpected filename format: $LATEST" >&2
    exit 1
fi

########################################
# Load Last-Known Version
########################################
if [ ! -f "$LAST" ]; then
    echo "$LATEST" > "$LAST"
    echo "$(date -Iseconds) - First run recorded version: $LATEST"
    exit 0
fi

OLD=$(cat "$LAST")

########################################
# Compare Versions and Trigger Upgrade
########################################
if [ "$LATEST" != "$OLD" ]; then
    echo "$(date -Iseconds) - New Bedrock version found!"
    echo "Old: $OLD"
    echo "New: $LATEST"
    echo "$LATEST" > "$LAST"

    if [ -x "$UPDATE_SCRIPT" ]; then
        "$UPDATE_SCRIPT" "$DOWNLOAD_URL" &
    else
        echo "WARNING: $UPDATE_SCRIPT is not executable"
    fi
else
    echo "$(date -Iseconds) - No change ($LATEST)"
fi
