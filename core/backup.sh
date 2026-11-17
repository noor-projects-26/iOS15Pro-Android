#!/data/data/com.termux/files/usr/bin/bash

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/backups" "$ROOT/config"

STAMP="$(date +%Y%m%d-%H%M%S)"
DEST="$ROOT/backups/backup-$STAMP.tar.gz"

tar -czf "$DEST" -C "$ROOT" config

echo "Backup created successfully!"
echo "Location: $DEST"
