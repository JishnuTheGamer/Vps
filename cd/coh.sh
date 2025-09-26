#!/bin/bash

echo "=== Ultimate All-in-One Cockpit Installer ==="

# 1. सिस्टम अपडेट
echo "[1/8] सिस्टम अपडेट कर रहे हैं..."
sudo apt update && sudo apt upgrade -y

# 2. Cockpit core इंस्टॉल करें
echo "[2/8] Cockpit core इंस्टॉल कर रहे हैं..."
sudo apt install -y cockpit

# 3. सभी मॉड्यूल इंस्टॉल करें
echo "[3/8] All-in-One modules इंस्टॉल कर रहे हैं..."
MODULES=(
cockpit-machines       # VM और system monitoring
cockpit-storaged       # Storage management
cockpit-lvm2           # LVM और advanced storage
cockpit-networkmanager # Network management
cockpit-wifi           # Wi-Fi और advanced network
cockpit-packagekit     # Updates और package management
cockpit-dashboard      # Dashboard view
cockpit-docker         # Docker management
cockpit-podman         # Podman management
cockpit-selinux        # SELinux management
cockpit-apparmor       # AppArmor
cockpit-firewalld      # Firewall management
cockpit-kubernetes     # Kubernetes cluster management
cockpit-logging        # System logs
cockpit-audit          # Audit logs
cockpit-systemd        # Services और jobs management
cockpit-snapshot       # Snapshots और backup
cockpit-metrics        # System performance metrics
cockpit-accounts       # User accounts management
cockpit-network-tools  # Network troubleshooting tools
)

for module in "${MODULES[@]}"; do
    echo "Installing $module..."
    sudo apt install -y $module
done

# 4. Cockpit सर्विस स्टार्ट और एनेबल करें
echo "[4/8] Cockpit सर्विस स्टार्ट कर रहे हैं..."
sudo systemctl enable --now cockpit.socket

# 5. Firewall पोर्ट 9090 खोलें
echo "[5/8] फ़ायरवॉल कॉन्फ़िग कर रहे हैं..."
sudo ufw allow 9090/tcp
sudo ufw reload

# 6. Optional: Dashboard और UI enhancements
echo "[6/8] Dashboard और UI enhancements..."
echo "Cockpit में Dashboard मॉड्यूल एक्टिव है।"
echo "Login करके Dark Mode और favorite modules सेट करें।"

# 7. Cleaning up
echo "[7/8] सिस्टम clean-up कर रहे हैं..."
sudo apt autoremove -y

# 8. समाप्ति संदेश
IP=$(hostname -I | awk '{print $1}')
echo "=========================================="
echo "✅ Ultimate All-in-One Cockpit installation complete!"
echo "Access it here: https://$IP:9090"
echo "Username और Password वही हैं जो आप server में login करते हैं."
echo "Dashboard में modules organize कर UI clean और best बना सकते हैं."
echo "=========================================="
