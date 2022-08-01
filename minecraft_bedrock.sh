#!/bin/bash

##################################################################
# Notes: This script is run as sudo by crontab on server reboot. #
# It will push a backup the world, then start the server.        #
# All directory references are relative to this script.          #
##################################################################
BEDROCK_SERVER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LD_LIBRARY_PATH="$BEDROCK_SERVER_DIR"
cd $BEDROCK_SERVER_DIR

######## Wait for networking stuff to come online after reboot ########
echo "Waiting 60 seconds for network..."
sleep 60
echo "DONE!"

######## Run Server GitHub Backup ########
# Create commit on all files with timestamp as message
CURRENT_TIME=$(date "+%Y.%m.%d-%H.%M.%S")
echo "Committing Changes..."
git add -A && git status && git commit -a -m "Auto-commit $CURRENT_TIME"
echo "DONE!"

# Push to GitHub using SSH
echo "Pushing to Github..."
git push origin main -v
echo "DONE!"

######## Start Minecraft Bedrock Server ########
echo "Starting Server..."
cd $BEDROCK_SERVER_DIR && ./bedrock_server