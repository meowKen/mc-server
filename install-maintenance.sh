#!/bin/bash

echo "copying service and timer files"

cp ./minecraft-server-maintenance.service /etc/systemd/system/minecraft-server-maintenance.service
cp ./minecraft-server-maintenance.timer /etc/systemd/system/minecraft-server-maintenance.timer

echo "enabling and copying scripts"

chmod +x ./backup.sh
cp ./backup.sh /usr/local/bin/minecraft-server-backup

echo "starting timer and enabling service"

systemctl daemon-reload
systemctl disable minecraft-server-maintenance.timer
systemctl stop minecraft-server-maintenance.timer
systemctl disable minecraft-server-maintenance.service
systemctl stop minecraft-server-maintenance.service

systemctl enable minecraft-server-maintenance.timer
systemctl start minecraft-server-maintenance.timer
systemctl enable minecraft-server-maintenance.service

echo "Creating the initial backup directory"

mkdir -p /backup

echo "Installation complete."
