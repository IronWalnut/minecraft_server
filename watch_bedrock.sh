#!/bin/bash
set -euo pipefail

API_URL="https://net-secondary.web.minecraft-services.net/api/v1.0/download/links"
VERSION_FILE="/opt/minecraft_server/VERSION"
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
LATEST_FILE=$(basename "$DOWNLOAD_URL")

if [[ ! "$LATEST_FILE" =~ bedrock-server-[0-9]+(\.[0-9]+){2,3}\.zip ]]; then
    echo "$(date -Iseconds) - ERROR: Unexpected filename format: $LATEST_FILE" >&2
    exit 1
fi

LATEST_VERSION="${LATEST_FILE#bedrock-server-}"
LATEST_VERSION="${LATEST_VERSION%.zip}"

########################################
# Compare Versions and Trigger Upgrade
########################################
CURRENT_VERSION=$(cat "$VERSION_FILE")

if [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
    echo "$(date -Iseconds) - New Bedrock version found!"
    echo "Current: $CURRENT_VERSION"
    echo "New: $LATEST_VERSION"

    if [ -x "$UPDATE_SCRIPT" ]; then
        echo "Triggering update..."
        "$UPDATE_SCRIPT" "$DOWNLOAD_URL" &
    else
        echo "WARNING: $UPDATE_SCRIPT is not executable"
    fi
else
    echo "$(date -Iseconds) - No change ($LATEST_VERSION)"
fi
