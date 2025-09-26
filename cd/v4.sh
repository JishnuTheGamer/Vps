#!/bin/bash

# Benar ASCII Art Banner
cat << "EOF"
888b      88               88           88                       
8888b     88               88           ""    ,d               
88 `8b    88               88                 88               
88  `8b   88   ,adPPYba,   88,dPPYba,   88  MM88MMM  ,adPPYYba,  
88   `8b  88  a8"     "8a  88P'    "8a  88    88     ""     `Y8  
88    `8b 88  8b       d8  88       d8  88    88     ,adPPPPP88  
88     `8888  "8a,   ,a8"  88b,   ,a8"  88    88,    88,    ,88  
88      `888   `"YbbdP"'   8Y"Ybbd8"'   88    "Y888  `"8bbdP"Y8  
EOF

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Start Tailscale service

# Attempt auto-connect using placeholder key
sudo tailscale up 

echo "Tailscale setup attempted. Login."
