#!/bin/bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
WHITE="\e[37m"
RESET="\e[0m"
BOLD="\e[1m"

# Check if curl is installed
check_curl() {
    if ! command -v curl &>/dev/null; then
        echo -e "${RED}${BOLD}Error: curl is not installed.${RESET}"
        echo -e "${YELLOW}Installing curl...${RESET}"
        if command -v apt-get &>/dev/null; then
            sudo apt-get update && sudo apt-get install -y curl
        elif command -v yum &>/dev/null; then
            sudo yum install -y curl
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y curl
        else
            echo -e "${RED}Could not install curl automatically. Please install it manually.${RESET}"
            exit 1
        fi
        echo -e "${GREEN}curl installed successfully!${RESET}"
    fi
}

# Function to run remote scripts
run_remote_script() {
    local url=$1
    local script_name=$(basename "$url" .sh)
    script_name=$(echo "$script_name" | sed 's/.*/\u&/')

    echo -e "${YELLOW}${BOLD}Running: ${CYAN}${script_name}${RESET}"
    check_curl

    local temp_script=$(mktemp)
    echo -e "${YELLOW}Downloading script...${RESET}"

    if curl -fsSL "$url" -o "$temp_script"; then
        echo -e "${GREEN}✓ Download successful${RESET}"
        chmod +x "$temp_script"
        bash "$temp_script"
        local exit_code=$?
        rm -f "$temp_script"
        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}✓ Script executed successfully${RESET}"
        else
            echo -e "${RED}✗ Script execution failed with exit code: $exit_code${RESET}"
        fi
    else
        echo -e "${RED}✗ Failed to download script${RESET}"
    fi
    echo
    read -p "Press Enter to continue..."
}

# Function to show system info
system_info() {
    echo -e "${BOLD}SYSTEM INFORMATION${RESET}"
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "Directory: $(pwd)"
    echo "System: $(uname -srm)"
    echo "Uptime: $(uptime -p)"
    echo "Memory: $(free -h | awk '/Mem:/ {print $3"/"$2}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $3"/"$2 " ("$5")"}')"
    echo
    read -p "Press Enter to continue..."
}

# Function to generate and display menu
show_menu() {
    clear
    menu_content=$(cat <<EOF
${BOLD}========== MAIN MENU ==========${RESET}
${BOLD}1. Panel${RESET}
${BOLD}2. Wing${RESET}
${BOLD}3. Update${RESET}
${BOLD}4. Uninstall${RESET}
${BOLD}5. Blueprint${RESET}
${BOLD}6. Cloudflare${RESET}
${BOLD}7. Change Theme${RESET}
${BOLD}9. System Info${RESET}
${BOLD}10. Exit${RESET}
${BOLD}===============================${RESET}
EOF
)
    echo -e "${CYAN}${menu_content}${RESET}"
    echo -ne "${BOLD}Enter your choice [1-10]: ${RESET}"

    # Save menu (with bold effect) to text file
    echo -e "$menu_content" > menu.txt
}

# Main loop
while true; do
    show_menu
    read -r choice
    case $choice in
        1) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/panel.sh" ;;
        2) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/wing.sh" ;;
        3) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/up.sh" ;;
        4) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/uninstalll.sh" ;;
        5) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/blueprint.sh" ;;
        6) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/cloudflare.sh" ;;
        7) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/th.sh" ;;
        9) system_info ;;
        10) echo "Exiting..."; exit 0 ;;
        *) echo -e "${RED}${BOLD}Invalid option!${RESET}"; read -p "Press Enter to continue..." ;;
    esac
done
