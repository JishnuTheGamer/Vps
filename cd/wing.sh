#!/bin/bash
set -e

echo "[*] Starting Pterodactyl Wings setup..."

# ------------------------
# 1. Docker install (stable)
# ------------------------
echo "[*] Installing Docker..."
curl -sSL https://get.docker.com/ | CHANNEL=stable bash
sudo systemctl enable --now docker

# ------------------------
# 2. Update GRUB
# ------------------------
GRUB_FILE="/etc/default/grub"
if [ -f "$GRUB_FILE" ]; then
    echo "[*] Updating GRUB_CMDLINE_LINUX_DEFAULT..."
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="swapaccount=1"/' $GRUB_FILE
    sudo update-grub
fi

# ------------------------
# 3. Wings install
# ------------------------
sudo mkdir -p /etc/pterodactyl
ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then ARCH="amd64"; else ARCH="arm64"; fi
curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$ARCH"
sudo chmod u+x /usr/local/bin/wings

# ------------------------
# 4. Wings service
# ------------------------
WINGS_SERVICE_FILE="/etc/systemd/system/wings.service"
sudo tee $WINGS_SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable wings

# ------------------------
# 5. SSL Certificate
# ------------------------
sudo mkdir -p /etc/certs/wing
cd /etc/certs/wing || exit
sudo openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
-subj "/C=NA/ST=NA/L=NA/O=NA/CN=Generic SSL Certificate" \
-keyout privkey.pem -out fullchain.pem

# ------------------------
# 6. 'wing' helper command
# ------------------------
sudo tee /usr/local/bin/wing > /dev/null <<'EOF'
#!/bin/bash
echo "[!] To start Wings, run manually:"
echo "    sudo systemctl start wings"
echo "[!] Make sure Node port 8080 → 443 is mapped."
EOF
sudo chmod +x /usr/local/bin/wing

echo "[!] Setup complete! Wings is installed."
echo "[!] To run auto-configuration, you will be prompted next."
echo ""

# ------------------------
# 7. Optional Auto-configure Wings
# ------------------------
read -p "Do you want to auto-configure Wings now? (y/n): " AUTO_CONFIG

if [[ "$AUTO_CONFIG" =~ ^[Yy]$ ]]; then
    echo "🔧 Auto-configuring Wings..."
    read -p "Enter UUID: " UUID
    read -p "Enter Token ID: " TOKEN_ID
    read -p "Enter Token: " TOKEN
    read -p "Enter Panel URL (remote): " REMOTE

    mkdir -p /etc/pterodactyl
    tee /etc/pterodactyl/config.yml > /dev/null <<CFG
debug: false
uuid: ${UUID}
token_id: ${TOKEN_ID}
token: ${TOKEN}
api:
  host: 0.0.0.0
  port: 8080
  ssl:
    enabled: true
    cert: /etc/certs/wing/fullchain.pem
    key: /etc/certs/wing/privkey.pem
  upload_limit: 100
system:
  data: /var/lib/pterodactyl/volumes
  sftp:
    bind_port: 2022
allowed_mounts: []
remote: '${REMOTE}'
CFG

    echo "✅ Config saved to /etc/pterodactyl/config.yml"
    echo "🚀 Starting Wings service..."
    systemctl start wings
    echo "✅ Wings started successfully!"
else
    echo "[!] Skipping auto-configuration. To start Wings manually, run:"
    echo "    sudo systemctl start wings"
fi
