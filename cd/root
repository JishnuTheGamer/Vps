#!/bin/bash

CONFIG_FILE="/etc/ssh/sshd_config"

# Step 1: Backup original config
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

# Step 2: Enable PermitRootLogin yes
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' "$CONFIG_FILE"
grep -q "^PermitRootLogin" "$CONFIG_FILE" || echo "PermitRootLogin yes" >> "$CONFIG_FILE"

# Step 3: Handle PasswordAuthentication variations
sed -i '/^#PasswordAuthentication/d' "$CONFIG_FILE"
sed -i '/^PasswordAuthentication/d' "$CONFIG_FILE"
echo "PasswordAuthentication yes" >> "$CONFIG_FILE"

# Step 4: Restart SSH service (using ssh.service)
echo "[*] Restarting SSH service..."
systemctl restart ssh

# Step 5: Prompt user to manually set root password
echo
echo "=============================="
echo "Ab aap manually root password set karen:"
echo "Run this command: sudo passwd root"
echo "=============================="
echo
