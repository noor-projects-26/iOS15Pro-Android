#!/data/data/com.termux/files/usr/bin/bash

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP_DIR="$ROOT/backups"

shopt -s nullglob
FILES=("$BACKUP_DIR"/backup-*.tar.gz)

if [ "${#FILES[@]}" -eq 0 ]; then
    echo "No backups found."
    exit 1
fi

echo "Available backups:"
select FILE in "${FILES[@]}"; do
    [ -n "$FILE" ] && break
    echo "Invalid selection."
done

echo "Selected: $FILE"
read -r -p "Restore project configuration? (yes/no): " ANSWER

if [ "$ANSWER" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT

tar -xzf "$FILE" -C "$TEMP"

if [ ! -f "$TEMP/config/settings.conf" ]; then
    echo "Invalid backup."
    exit 1
fi

mkdir -p "$ROOT/config"
cp "$TEMP/config/settings.conf" "$ROOT/config/settings.conf"

echo "Configuration restored successfully!"
