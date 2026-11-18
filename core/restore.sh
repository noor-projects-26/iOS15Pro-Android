#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP_DIR="$ROOT/backups"

if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: Python 3 is required for secure restore."
    exit 1
fi

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

if [ -L "$FILE" ] || [ ! -f "$FILE" ]; then
    echo "Invalid backup file."
    exit 1
fi

echo "Selected: $FILE"
read -r -p "Restore project configuration? (yes/no): " ANSWER

if [ "$ANSWER" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

python3 - "$FILE" "$ROOT/config/settings.conf" <<'PY'
import os
import sys
import tarfile
import tempfile

archive_path, target = sys.argv[1:3]
config_dir = os.path.dirname(target)

temp_path = None

try:
    if os.path.islink(config_dir):
        raise ValueError("Configuration directory cannot be a symlink.")

    if os.path.lexists(target) and os.path.islink(target):
        raise ValueError("Existing settings file cannot be a symlink.")

    os.makedirs(config_dir, exist_ok=True)

    with tarfile.open(archive_path, "r:gz") as archive:
        members = archive.getmembers()

        names = [member.name for member in members]

        if len(names) != len(set(names)):
            raise ValueError("Duplicate archive entries rejected.")

        allowed = {"config", "config/settings.conf"}

        if not names or not set(names).issubset(allowed):
            raise ValueError("Unexpected archive paths rejected.")

        if names.count("config/settings.conf") != 1:
            raise ValueError("Settings file missing or duplicated.")

        for member in members:
            if member.name == "config":
                if not member.isdir():
                    raise ValueError("Invalid config directory entry.")
            elif member.name == "config/settings.conf":
                if not member.isfile():
                    raise ValueError("Settings entry must be a regular file.")
                if member.size > 65536:
                    raise ValueError("Settings file exceeds 64 KB.")

        member = next(
            item for item in members
            if item.name == "config/settings.conf"
        )

        source = archive.extractfile(member)
        if source is None:
            raise ValueError("Cannot read settings file.")

        data = source.read(65537)
        if len(data) != member.size or len(data) > 65536:
            raise ValueError("Invalid settings file size.")

    fd, temp_path = tempfile.mkstemp(
        prefix=".settings-restore-",
        dir=config_dir
    )

    with os.fdopen(fd, "wb") as output:
        output.write(data)
        output.flush()
        os.fsync(output.fileno())

    os.chmod(temp_path, 0o600)
    os.replace(temp_path, target)
    temp_path = None

    print("Configuration restored successfully!")

except Exception as error:
    print(f"Restore rejected: {error}", file=sys.stderr)
    sys.exit(1)

finally:
    if temp_path is not None and os.path.exists(temp_path):
        os.unlink(temp_path)
PY
