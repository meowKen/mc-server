# Minecraft paper server 

Minecraft server with paper plugin in a container

## Installation

### Prerequistes

- docker installed

```sh
# Run the server container
docker compose up -d
```

## Server settings

Most settings are in ./data/server.properties

### Server logs

Just show the container logs

```sh
docker logs <container_name>
```

### OP

Settings to add OP player can be done by creating a file ./data/ops.json filled as follow : 

```json
[
  {
    "uuid": "player_GUID_as_seen_in_server_console",
    "name": "player_NAME_as_seen_in_server_console",
    "level": 4,
    "bypassesPlayerLimit": true
  }
]
```

### Server commands

either attach the contianer

```sh
docker attach <container_name>
# ! Attention, attaching will exit the server when exiting the console
```

or throw commands at the container

```sh
msg="This command is run in the server via the rcon interface !"
docker exec minecraft-server-mc-1 rcon-cli say "$msg"
```

## Maintenance

Provide a automated backup system, wuth systemd service

```sh
# Install the service
./install-maintenance.sh
```

The service will run everyday at noon and do the following :

- Notify server users 5 minutes prior to the backup
- after the 5 minutes delay, shutdown server and container
- do a backup that will be stored in './backup'

Have fun !
