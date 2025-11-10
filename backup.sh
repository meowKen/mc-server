#!/bin/bash

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

info() {
  log "INFO: $1"
}

error() {
  log "ERROR: $1"
}

log_directory="/var/logs"

if [ ! -d "$log_directory" ]; then
  mkdir -p "$log_directory"
fi

log_file="${log_directory}/minecraft-server-backup.log"

if [ ! -f "$log_file" ]; then
  touch "$log_file"
fi

minecraft_server_directory="/home/arnaud/minecraft-server"

if [ ! -d "$minecraft_server_directory" ]; then
  echo "Minecraft server directory does not exist: $minecraft_server_directory"
  exit 1
fi

docker_compose_file="${minecraft_server_directory}/docker-compose.yml"

if [ ! -f "$docker_compose_file" ]; then
  echo "Docker compose file does not exist: $docker_compose_file"
  exit 1
fi

server_data_directory="${minecraft_server_directory}/data"

if [ ! -d "$server_data_directory" ]; then
  echo "World directory does not exist: $server_data_directory"
  exit 1
fi

backup_directory="${minecraft_server_directory}/backup"

if [ ! -d "$backup_directory" ]; then
  mkdir -p "$backup_directory"
fi

info "Backup script started"

current_date=$(date +%Y-%m-%d)

if [ -z "$current_date" ]; then
  error "Failed to get current date"
  exit 1
fi

for i in {0..3}; do
  time_before_restart=$((5 - i))

  if [ $time_before_restart -eq 5 ]; then
        msg="Server is shutting down for backup in ${time_before_restart} minutes..."
        msg2="Get your stuff saved and log off safely!"
  fi

  if [ $time_before_restart -eq 4 ] ; then
      msg="Server is shutting down for backup in ${time_before_restart} minutes..."
      msg2="Get your stuff saved and log off please."
  fi

  if [ $time_before_restart -eq 3 ] ; then
      msg="Server is shutting down for backup in ${time_before_restart} minutes..."
      msg2="Hey, get your stuff saved and log off."
  fi

  if [ $time_before_restart -eq 2 ] ; then
      msg="Server is shutting down for backup in ${time_before_restart} minutes..."
      msg2="You are getting on my nerves, gaver your stuff and log off."
  fi

  echo "$msg"
  info "$msg"
  docker exec minecraft-server-mc-1 rcon-cli say "$msg" > /dev/null
  docker exec minecraft-server-mc-1 rcon-cli say "$msg2" > /dev/null
  sleep 60
done

msg2="Get your shit and fuck off, please."   
docker exec minecraft-server-mc-1 rcon-cli say "$msg2" > /dev/null

info "Server is shutting down for backup in 1 minute"

for i in {1..12}; do
  time_before_restart=$((60 - (5 * i)))
  msg="Emergency! Server is shutting down for backup in ${time_before_restart} seconds..."
  echo "$msg"
  docker exec minecraft-server-mc-1 rcon-cli say "$msg" > /dev/null
  sleep 5
done

# Command to stop the Minecraft server gracefully
info "Stopping Minecraft server gracefully"
docker exec minecraft-server-mc-1 rcon-cli save-all || { error "Failed to save all, error: $?" ; exit 1; }
docker exec minecraft-server-mc-1 rcon-cli stop || { error "Failed to stop server, error: $?" ; exit 1; }

docker compose -f "$docker_compose_file" down || {
  error "Failed to bring down docker compose, error: $?";
  exit 1;
}

# Rotate backups: keep only the last 7 days
find ./backup -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;

info "Old backups rotated, creating new backup..."

# Create a new backup
tar -czf "$backup_directory"/data-"$current_date".tar.gz "${server_data_directory}" || {
  error "Failed to create backup archive, error: $?";
  exit 1;
}


info "Backup created successfully: data-${current_date}.tar.gz"
info "Starting minecraft server..."

docker compose -f "$docker_compose_file" up -d || {
  error "Failed to start docker compose, error: $?";
  exit 1;
}

exit 0
