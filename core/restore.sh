#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

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
    if [ -n "${FILE:-}" ]; then
        break
    fi
    echo "Invalid selection."
done

echo "Selected: $FILE"
read -r -p "Restore project configuration? (yes/no): " ANSWER

if [ "$ANSWER" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

if ! tar -tzf "$FILE" > /dev/null; then
    echo "Invalid or corrupted backup archive."
    exit 1
fi

CONTENTS="$(tar -tzf "$FILE")"

if [ "$CONTENTS" != $'config/\nconfig/settings.conf' ] &&
   [ "$CONTENTS" != "config/settings.conf" ]; then
    echo "Unexpected files in backup. Restore rejected."
    exit 1
fi

TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT

tar -xzf "$FILE" -C "$TEMP" --no-same-owner

if [ ! -f "$TEMP/config/settings.conf" ] ||
   [ -L "$TEMP/config/settings.conf" ]; then
    echo "Invalid settings file in backup."
    exit 1
fi

mkdir -p "$ROOT/config"
cp "$TEMP/config/settings.conf" "$ROOT/config/settings.conf"

echo "Configuration restored successfully!"
