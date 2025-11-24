#!/bin/bash

# Set BEDROCK_SERVER_DIR to the directory the script is in
BEDROCK_SERVER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Set temp dirs to download & extract new server files
AUTO_UPGRADE_TEMP_DIR="/home/kwalton/Downloads/bedrock_auto_upgrade"
EXTRACTED_DIR="$AUTO_UPGRADE_TEMP_DIR/extracted_server_files"

########################################
# Accept parameter OR prompt for URL
########################################

if [ -n "${1-}" ]; then
    # Parameter provided
    BEDROCK_ZIP_URL="$1"
    echo "Using provided URL: $BEDROCK_ZIP_URL"
    echo
else
    # No parameter → ask interactively
    echo "Enter URL for Bedrock Server download:"
    echo "(From https://www.minecraft.net/en-us/download/server/bedrock)"
    while true; do
        read -r BEDROCK_ZIP_URL
        if [ -n "$BEDROCK_ZIP_URL" ]; then
            break
        fi
        echo "URL cannot be empty. Please enter a valid download URL:"
    done
    echo
fi

########################################
# Parse File Name and Version
########################################

# Parse file name from URL
ZIP_FILE_NAME=$(echo "$BEDROCK_ZIP_URL" | sed 's:.*/::')

# Parse version from URL
# Removes everything before "bedrock-server-" and strips ".zip"
VERSION=$(echo "$BEDROCK_ZIP_URL" | sed 's:.*bedrock-server-::')
VERSION=${VERSION%.zip}

########################################
# Print Values for Debugging
########################################
echo "URL: $BEDROCK_ZIP_URL"
echo "File name: $ZIP_FILE_NAME"
echo "Version: $VERSION"

########################################
# Kill Server Processes
########################################
echo "Killing server processes..."
pkill -x bedrock_server || true
echo "DONE!"
echo

########################################
# Create / Update VERSION File
########################################
cd "$BEDROCK_SERVER_DIR"
echo "Updating VERSION file..."
echo "$VERSION" > ./VERSION
echo "DONE!"
echo

########################################
# Commit + Push Git Changes
########################################
CURRENT_TIME=$(date "+%Y.%m.%d-%H.%M.%S")
echo "Committing changes..."
git add -A && git commit -a -m "Auto-upgrade $ZIP_FILE_NAME - $CURRENT_TIME"
echo "DONE!"
echo

echo "Pushing to GitHub..."
SECONDS=0
git push origin main -v 2>&1
echo "DONE! - Took $(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds"
echo

########################################
# Download & Extract New Bedrock Server
########################################
mkdir "$AUTO_UPGRADE_TEMP_DIR"
cd "$AUTO_UPGRADE_TEMP_DIR"

echo "Downloading server zip..."
curl --http1.1 -L -O \
    -H "User-Agent: Mozilla/5.0" \
    "$BEDROCK_ZIP_URL"

echo "Extracting..."
unzip "$AUTO_UPGRADE_TEMP_DIR/$ZIP_FILE_NAME" -d "$EXTRACTED_DIR"
echo

########################################
# Remove Default Config Files
########################################
echo "Deleting generic config files..."
rm -f "$EXTRACTED_DIR/allowlist.json"
rm -f "$EXTRACTED_DIR/permissions.json"
rm -f "$EXTRACTED_DIR/server.properties"
echo "DONE!"
echo

########################################
# Clean Repo (remove old files)
########################################
echo "Deleting untracked files from repo..."
cd "$BEDROCK_SERVER_DIR"
git clean -dfx
echo "DONE!"
echo

########################################
# Copy New Bedrock Server Files
########################################
echo "Copying extracted files to repo..."
cp -a "$EXTRACTED_DIR/." "$BEDROCK_SERVER_DIR"
echo "DONE!"
echo

########################################
# Remove Temp Download Directory
########################################
echo "Removing temp dir..."
rm -rf "$AUTO_UPGRADE_TEMP_DIR"
echo "DONE!"
echo

########################################
# Tag in Git
########################################
cd "$BEDROCK_SERVER_DIR"
git tag "release/$VERSION"
git push origin --tags

echo
echo "Upgrade complete!"

########################################
# Restart Server
########################################
/opt/minecraft_server/minecraft_bedrock.sh > /opt/minecraft_server/server_console.log &
