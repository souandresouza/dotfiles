#!/bin/bash
# ~/.local/bin/hypr-backup.sh
BACKUP_DIR="$HOME/.config/hypr-backups/$(date +%Y-%m-%d_%H-%M-%S)"
mkdir -p $BACKUP_DIR
cp -r ~/.config/hypr/* $BACKUP_DIR/
echo "Backup criado em: $BACKUP_DIR"