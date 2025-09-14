#!/bin/bash

# Exit on any error
set -e

# Define variables for paths and service name
PLAYIT_BINARY="/usr/local/bin/playit"
PLAYIT_SERVICE="/etc/systemd/system/playit.service"
WORKING_DIR="/root"
BINARY_SRC="playit-linux-amd64"

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root. Use sudo." >&2
    exit 1
fi

# Check if source binary exists
if [[ ! -f "$BINARY_SRC" ]]; then
    echo "Error: $BINARY_SRC not found in the current directory." >&2
    exit 1
fi

# Move binary to /usr/local/bin
echo "Installing $BINARY_SRC to $PLAYIT_BINARY..."
if ! mv "$BINARY_SRC" "$PLAYIT_BINARY"; then
    echo "Error: Failed to move $BINARY_SRC to $PLAYIT_BINARY." >&2
    exit 1
fi

# Ensure the binary is executable
chmod +x "$PLAYIT_BINARY"

# Change to systemd directory
echo "Navigating to /etc/systemd/system..."
cd /etc/systemd/system || { echo "Error: Failed to change to /etc/systemd/system." >&2; exit 1; }

# Create playit.service file
echo "Creating systemd service file at $PLAYIT_SERVICE..."
cat <<EOF > "$PLAYIT_SERVICE"
[Unit]
Description=Playit Tunnel Agent
After=network.target

[Service]
ExecStart=$PLAYIT_BINARY
Restart=on-failure
User=root
WorkingDirectory=$WORKING_DIR
Environment="PLAYIT_CONFIG_PATH=/root/.playit/config.toml"

[Install]
WantedBy=multi-user.target
EOF

# Check if service file was created successfully
if [[ ! -f "$PLAYIT_SERVICE" ]]; then
    echo "Error: Failed to create $PLAYIT_SERVICE." >&2
    exit 1
fi

# Reload systemd daemon
echo "Reloading systemd daemon..."
if ! systemctl daemon-reload; then
    echo "Error: Failed to reload systemd daemon." >&2
    exit 1
fi

# Enable and start the service
echo "Enabling and starting playit service..."
if ! systemctl enable playit; then
    echo "Error: Failed to enable playit service." >&2
    exit 1
fi

if ! systemctl start playit; then
    echo "Error: Failed to start playit service." >&2
    exit 1
fi

# Verify service status
echo "Checking playit service status..."
systemctl status playit --no-pager

echo "Playit service installed and started successfully!"
