#!/bin/bash
##################################################################
# Notes: This script is run as a systemd service on reboot.     #
# It will push a backup the world, then start the server.       #
# All directory references are relative to this script.         #
##################################################################

# Set working dir & LD_LIBRARY_PATH to directory the script is in
BEDROCK_SERVER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LD_LIBRARY_PATH="$BEDROCK_SERVER_DIR"
cd $BEDROCK_SERVER_DIR

# Run Server GitHub Backup
CURRENT_TIME=$(date "+%Y.%m.%d-%H.%M.%S")
echo "Committing Changes..."
git add -A && git commit -a -m "Auto-commit $CURRENT_TIME"
echo "DONE!"
echo

# Push to GitHub using SSH and capturing stderr, track upload times
SECONDS=0
git push origin main -v 2>&1
echo "DONE! - Took $(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds"
echo

# Start Minecraft Bedrock Server
echo "Starting Server..."
cd $BEDROCK_SERVER_DIR && ./bedrock_server
