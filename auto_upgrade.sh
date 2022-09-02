#!/bin/bash

# Set BEDROCK_SERVER_DIR to the directory the script is in
BEDROCK_SERVER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Set temp dirs to download & extract new server files
AUTO_UPGRADE_TEMP_DIR="/home/kwalton/Downloads/bedrock_auto_upgrade"
EXTRACTED_DIR="$AUTO_UPGRADE_TEMP_DIR/extracted_server_files"

# Ask user for URL
echo "Enter URL for Bedrock Server download:"
echo "(From https://www.minecraft.net/en-us/download/server/bedrock)"
read BEDROCK_ZIP_URL
echo

# Parse file name from user input
ZIP_FILE_NAME=$(echo "$BEDROCK_ZIP_URL" | sed 's:.*/::')

# Confirm Upgrade y/n?
echo "Got URL: $BEDROCK_ZIP_URL"
echo "And file name: $ZIP_FILE_NAME"
echo
echo "WARNING: THIS IS A POTENTIALLY DESTRUCTIVE OPERATION!"
while true; do
    read -p "Continue? (y/n)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer [Yy] or [Nn].";;
    esac
done
echo

# Kill Server Processes
echo "Killing server processes..."
pkill -ef bedrock
echo "DONE!"
echo

# Move to BEDROCK_SERVER_DIR
cd $BEDROCK_SERVER_DIR

# Run GitHub Backup
CURRENT_TIME=$(date "+%Y.%m.%d-%H.%M.%S")
echo "Committing changes..."
# Create commit on all files with timestamp as message
git add -A && git commit -a -m "Pre-upgrade commit $CURRENT_TIME"
echo "DONE!"
echo

# Push to GitHub using SSH and capturing stderr, track upload times
SECONDS=0
git push origin main -v 2>&1
echo "DONE! - Took $(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds"
echo

# Create & move to temp dir to download & extract new server files
mkdir $AUTO_UPGRADE_TEMP_DIR
cd $AUTO_UPGRADE_TEMP_DIR

# Download & Extract Zip
echo "Downloading server zip..."
wget $BEDROCK_ZIP_URL
unzip "$AUTO_UPGRADE_TEMP_DIR/$ZIP_FILE_NAME" -d "$EXTRACTED_DIR"
echo

# Delete generic config files we don't want to overwrite ours with
echo "Deleting generic config files..."
rm "$EXTRACTED_DIR/allowlist.json" 
rm "$EXTRACTED_DIR/permissions.json" 
rm "$EXTRACTED_DIR/server.properties"
echo "DONE!"
echo

# Move back to BEDROCK_SERVER_DIR & delete ALL untracked files to remove old version
cd $BEDROCK_SERVER_DIR
git clean -dfx

# Copy newly extracted files into repo
cp -a "$EXTRACTED_DIR/." "$BEDROCK_SERVER_DIR"

# Remove temp dir
rm -R "$AUTO_UPGRADE_TEMP_DIR"
