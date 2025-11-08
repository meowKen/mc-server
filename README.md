# Minecraft paper server 

Minecraft server with paper plugin in a container

## Installation

### Prerequistes

- docker installed

```sh
# Run the server container
docker compose up -d
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