# Server Info
**IP:** waltoncloud.ddns.net

**Port:** 19132 (default)

# Server Maintenance & Backups
The server will reboot for maintenance and to back up the world files on Mondays, Wednesdays, and Fridays at 4am EST. Being logged in during this time will result in being kicked from the server until maintenance is complete. Backups take around \~10 minutes to run.


# Installation Notes
The `minecraft_bedrock.sh` script includes logic to save changes and push to this repo when started and is designed to be run on server reboot. The `minecraft_bedrock` executable files are not included with this repo to save space and can be downloaded from [minecraft.net](https://www.minecraft.net/en-us/download/server/bedrock).

### Command Line Example:
```
# Running with backup script logic
/opt/minecraft_server/minecraft_bedrock.sh

# Or just starting the server executable
LD_LIBRARY_PATH=/opt/minecraft_server /opt/minecraft_server/bedrock_server
```

### Cronjob Example:
```
@reboot /opt/minecraft_server/minecraft_bedrock.sh > /opt/minecraft_server/server_console.log
```