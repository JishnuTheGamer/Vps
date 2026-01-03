#!/bin/bash

# ==========================================
#     CLOUDFLARED INSTALLER & UNINSTALLER
#     Auto Detect | Auto Fix | User Proof
# ==========================================

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
NC="\033[0m"

pause() {
    read -rp "Press Enter to continue..."
}

install_cloudflared() {
    clear
    echo -e "${BLUE}┌────────────────────────────────────┐"
    echo -e "│      Installing Cloudflared       │"
    echo -e "└────────────────────────────────────┘${NC}"

    # Install repo + package
    sudo mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
        | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' \
        | sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null

    sudo apt update
    sudo apt install -y cloudflared

    if ! command -v cloudflared >/dev/null 2>&1; then
        echo -e "${RED}✘ Cloudflared installation failed${NC}"
        pause
        return
    fi

    echo -e "${GREEN}✔ Cloudflared installed successfully${NC}"
    echo ""

    # Detect existing service
    if systemctl list-units --type=service | grep -q cloudflared; then
        echo -e "${YELLOW}⚠ Existing Cloudflared service detected${NC}"
        echo -e "${CYAN}→ Removing old service...${NC}"
        sudo cloudflared service uninstall
        echo -e "${GREEN}✔ Old service removed${NC}"
        echo ""
    fi

    # Ask for token or command
    echo -e "${BLUE}🔑 Paste Cloudflare Tunnel token"
    echo -e "${DIM}(sirf token ya poora command — dono chalega)${NC}"
    read -rp "> " USER_INPUT

    # Clean input (remove command if pasted)
    CF_TOKEN=$(echo "$USER_INPUT" \
        | sed 's/sudo cloudflared service install //g' \
        | sed 's/cloudflared service install //g' \
        | xargs)

    if [[ -z "$CF_TOKEN" ]]; then
        echo -e "${RED}✘ Invalid or empty token${NC}"
        pause
        return
    fi

    echo -e "${CYAN}🚀 Installing Cloudflared service...${NC}"
    sudo cloudflared service install "$CF_TOKEN"

    sleep 1

    if systemctl is-active --quiet cloudflared; then
        echo -e "${GREEN}✔ Cloudflared service installed & running${NC}"
    else
        echo -e "${YELLOW}⚠ Service installed but not running${NC}"
        echo -e "${YELLOW}→ Check with: systemctl status cloudflared${NC}"
    fi

    pause
}

uninstall_cloudflared() {
    clear
    echo -e "${BLUE}┌────────────────────────────────────┐"
    echo -e "│      Uninstalling Cloudflared     │"
    echo -e "└────────────────────────────────────┘${NC}"

    sudo cloudflared service uninstall 2>/dev/null
    sudo apt remove -y cloudflared
    sudo rm -f /etc/apt/sources.list.d/cloudflared.list
    sudo rm -f /usr/share/keyrings/cloudflare-main.gpg

    echo -e "${GREEN}✔ Cloudflared completely removed${NC}"
    pause
}

# ================= MENU =================

while true; do
    clear
    echo -e "${YELLOW}"
    echo "╔═════════════════════════════════════════════╗"
    echo "║        CLOUDFLARED MANAGEMENT MENU          ║"
    echo "╠═════════════════════════════════════════════╣"
    echo "║                                             ║"
    echo -e "║ ${GREEN}1) Install / Setup Tunnel${NC}              ║"
    echo "║                                             ║"
    echo -e "║ ${RED}2) Uninstall Completely${NC}                ║"
    echo "║                                             ║"
    echo "║ 3) Exit                                     ║"
    echo "╚═════════════════════════════════════════════╝"
    echo -ne "${BLUE}Select an option: ${NC}"
    read choice

    case $choice in
        1) install_cloudflared ;;
        2) uninstall_cloudflared ;;
        3) clear; exit ;;
        *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
    esac
done
