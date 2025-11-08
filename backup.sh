#!/bin/bash

current_date=$(date +%Y-%m-%d)

if [ -z "$current_date" ]; then
  echo "Failed to get current date"
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
  docker exec minecraft-server-mc-1 rcon-cli say "$msg" > /dev/null
  docker exec minecraft-server-mc-1 rcon-cli say "$msg2" > /dev/null
  sleep 60
done

msg2="Get your shit and fuck off, please."   

echo "$msg"
docker exec minecraft-server-mc-1 rcon-cli say "$msg2" > /dev/null

for i in {1..12}; do
  time_before_restart=$((60 - (5 * i)))
  msg="Emergency! Server is shutting down for backup in ${time_before_restart} seconds..."
  echo "$msg"
  docker exec minecraft-server-mc-1 rcon-cli say "$msg" > /dev/null
  sleep 5
done

# Command to stop the Minecraft server gracefully
docker exec minecraft-server-mc-1 rcon-cli save-all
docker exec minecraft-server-mc-1 rcon-cli stop

docker compose down

# Rotate backups: keep only the last 7 days
find ./backup -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;

echo "Old backups rotated, creating new backup..."

# Create a new backup
tar -czf ./backup/data-$current_date.tar.gz ./data

if [ $? -ne 0 ]; then
  echo "Backup creation failed"
  exit 1
fi

echo "Backup created successfully: data-$current_date.tar.gz"
echo "Starting minecraft server..."

docker compose up -d

exit 0
