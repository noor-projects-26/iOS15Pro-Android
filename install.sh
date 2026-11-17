#!/data/data/com.termux/files/usr/bin/bash

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "================================"
echo "     iOS15Pro-Android"
echo "================================"

echo "Checking Termux environment..."

if ! command -v getprop >/dev/null 2>&1; then
    echo "Error: Android environment not detected."
    exit 1
fi

echo "Android environment detected."
echo
bash "$PROJECT_DIR/core/device-check.sh"

echo
echo "Initial diagnostic completed."
echo "No system settings were changed."
