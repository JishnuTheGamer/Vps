#!/bin/bash

# ------------------------------
# Target directory
# ------------------------------
TARGET_DIR="/var/www/pterodactyl"
mkdir -p "$TARGET_DIR"

# ------------------------------
# Temp repository folder
# ------------------------------
TEMP_REPO="/tmp/ak-nobita-bot"

# Remove old temp repo if exists
rm -rf "$TEMP_REPO"

# ------------------------------
# Clone repository temporarily
# ------------------------------
git clone https://github.com/nobita586/ak-nobita-bot.git "$TEMP_REPO"

# ------------------------------
# Check if nebula.blueprint exists
# ------------------------------
SOURCE_FILE="$TEMP_REPO/src/nebula.blueprint"

if [ -f "$SOURCE_FILE" ]; then
    # Move to target directory
    mv "$SOURCE_FILE" "$TARGET_DIR/"
    echo "nebula.blueprint moved to $TARGET_DIR"
else
    echo "nebula.blueprint not found in repo!"
    rm -rf "$TEMP_REPO"
    exit 1
fi

# ------------------------------
# Remove temporary repo
# ------------------------------
rm -rf "$TEMP_REPO"

# ------------------------------
# Auto-run blueprint
# ------------------------------
cd "$TARGET_DIR" || exit 1

if command -v blueprint >/dev/null 2>&1; then
    echo "Running blueprint..."
    blueprint -i nebula.blueprint
else
    echo "Error: 'blueprint' tool not installed."
    exit 1
fi
