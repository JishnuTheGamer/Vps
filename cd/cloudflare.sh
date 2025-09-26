#!/bin/bash

# === Colors for Output ===
GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m" # No Color

echo -e "${GREEN}[*] Starting Cloudflared Installation...${NC}"

# Step 1: Create keyrings directory
echo -e "${GREEN}[+] Creating keyrings directory...${NC}"
sudo mkdir -p --mode=0755 /usr/share/keyrings

# Step 2: Add Cloudflare GPG key
echo -e "${GREEN}[+] Adding Cloudflare GPG key...${NC}"
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Step 3: Add repository to apt sources
echo -e "${GREEN}[+] Adding Cloudflare repository...${NC}"
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

# Step 4: Update package list and install cloudflared
echo -e "${GREEN}[+] Updating package list and installing cloudflared...${NC}"
sudo apt-get update && sudo apt-get install -y cloudflared

# Step 5: Verify installation
if command -v cloudflared >/dev/null 2>&1; then
    echo -e "${GREEN}[✓] Cloudflared installed successfully!${NC}"
else
    echo -e "${RED}[✗] Installation failed.${NC}"
fi
