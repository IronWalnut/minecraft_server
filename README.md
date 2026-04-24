# Server Info
**IP:** waltoncloud.ddns.net

**Port:** 19132 (default)

# Server Maintenance & Backups
The server will reboot for maintenance and to back up the world files on Mondays, Wednesdays, and Fridays at 4am EST. Being logged in during this time will result in being kicked from the server until maintenance is complete. Backups take around \~10 minutes to run.


# Installation Notes
The `minecraft_bedrock.sh` script includes logic to save changes and push to this repo when started and is designed to be run on server reboot. The `minecraft_bedrock` executable files are not included with this repo to save space and can be downloaded from [minecraft.net](https://www.minecraft.net/en-us/download/server/bedrock).

### systemd Services

The server is managed by two systemd services:

- **`minecraft.service`** — starts `minecraft_bedrock.sh` on boot (after network), restarts on failure, logs to `server_console.log`
- **`watch_bedrock.service`** / **`watch_bedrock.timer`** — checks for Bedrock server updates daily at 2am

To install and enable:
```
# Copy service files to systemd
sudo cp /opt/minecraft_server/minecraft.service /etc/systemd/system/
sudo cp /opt/minecraft_server/watch_bedrock.service /etc/systemd/system/
sudo cp /opt/minecraft_server/watch_bedrock.timer /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable --now minecraft.service
sudo systemctl enable --now watch_bedrock.timer
```

Common management commands:
```
sudo systemctl status minecraft        # check server status
sudo systemctl restart minecraft       # restart the server
sudo journalctl -u minecraft -f        # follow service logs
sudo systemctl list-timers             # check timer schedule
```