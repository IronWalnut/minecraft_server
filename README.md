# Server Info
**IP:** waltoncloud.ddns.net

**Port:** 19132 (default)

# Server Maintenance & Backups
The server will reboot for maintenance and to back up the world files on Mondays, Wednesdays, and Fridays at 4am EST. Being logged in during this time will result in being kicked from the server, and is probably a bad idea.


# Installation Notes
The `minecraft_bedrock.sh` script includes logic to save changes and push to this repo when started and is designed to be run on server reboot. The `minecraft_bedrock` executable file is not included with this repo and can be downloaded from [minecraft.net](https://www.minecraft.net/en-us/download/server/bedrock).

### Command Line Example:
```
# Running with backup script
sudo /opt/minecraft/minecraft_bedrock.sh

# Just starting the server executable
sudo LD_LIBRARY_PATH=/opt/minecraft /opt/minecraft/bedrock_server
```

### Cronjob Example (running as sudo):
```
@reboot /opt/minecraft/minecraft_bedrock.sh > /opt/minecraft/server_console.log
```