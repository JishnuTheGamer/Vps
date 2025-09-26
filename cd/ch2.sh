#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN} $1 ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Function to print status messages
print_status() {
    echo -e "${YELLOW}⏳ $1...${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${MAGENTA}⚠️  $1${NC}"
}

# Function to animate text
animate_text() {
    local text="$1"
    local delay=0.05
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo
}

# Check if curl is installed
check_curl() {
    if ! command -v curl &>/dev/null; then
        print_error "curl is not installed"
        print_status "Installing curl..."
        if command -v apt-get &>/dev/null; then
            sudo apt-get update && sudo apt-get install -y curl
        elif command -v yum &>/dev/null; then
            sudo yum install -y curl
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y curl
        else
            print_error "Could not install curl automatically. Please install it manually"
            exit 1
        fi
        print_success "curl installed successfully"
    fi
}

# Function to run remote scripts
run_remote_script() {
    local url=$1
    local script_name=$(basename "$url" .sh)
    script_name=$(echo "$script_name" | sed 's/.*/\u&/')

    print_header "RUNNING SCRIPT: $script_name"
    check_curl

    local temp_script=$(mktemp)
    print_status "Downloading script"

    if curl -fsSL "$url" -o "$temp_script"; then
        print_success "Download successful"
        chmod +x "$temp_script"
        bash "$temp_script"
        local exit_code=$?
        rm -f "$temp_script"
        if [ $exit_code -eq 0 ]; then
            print_success "Script executed successfully"
        else
            print_error "Script execution failed with exit code: $exit_code"
        fi
    else
        print_error "Failed to download script"
    fi
    
    echo -e ""
    read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")" -n 1
}

# Function to show system info
system_info() {
    print_header "SYSTEM INFORMATION"
    
    echo -e "${WHITE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║               📊 SYSTEM STATUS               ║${NC}"
    echo -e "${WHITE}╠═══════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║   ${CYAN}•${NC} ${GREEN}Hostname:${NC} ${WHITE}$(hostname)${NC}                  ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${CYAN}•${NC} ${GREEN}User:${NC} ${WHITE}$(whoami)${NC}                          ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${CYAN}•${NC} ${GREEN}Directory:${NC} ${WHITE}$(pwd)${NC}           ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${CYAN}•${NC} ${GREEN}System:${NC} ${WHITE}$(uname -srm)${NC}              ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${CYAN}•${NC} ${GREEN}Uptime:${NC} ${WHITE}$(uptime -p | sed 's/up //')${NC}               ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${CYAN}•${NC} ${GREEN}Memory:${NC} ${WHITE}$(free -h | awk '/Mem:/ {print $3"/"$2}')${NC}               ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${CYAN}•${NC} ${GREEN}Disk:${NC} ${WHITE}$(df -h / | awk 'NR==2 {print $3"/"$2 " ("$5")"}')${NC}        ${WHITE}║${NC}"
    echo -e "${WHITE}╚═══════════════════════════════════════════════╝${NC}"
    
    echo -e ""
    read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")" -n 1
}

# Function to display the main menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}           🚀 NOBITA HOSTING MANAGER            ${NC}"
    echo -e "${CYAN}                 Control Panel                  ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "${WHITE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║                📋 MAIN MENU                   ║${NC}"
    echo -e "${WHITE}╠═══════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║   ${GREEN}1)${NC} ${CYAN}Panel Installation${NC}                   ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${GREEN}2)${NC} ${CYAN}Wings Installation${NC}                   ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${GREEN}3)${NC} ${CYAN}Panel Update${NC}                         ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${GREEN}4)${NC} ${CYAN}Uninstall Tools${NC}                      ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${GREEN}5)${NC} ${CYAN}Blueprint Setup${NC}                      ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${GREEN}6)${NC} ${CYAN}Cloudflare Setup${NC}                     ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${GREEN}7)${NC} ${CYAN}Change Theme${NC}                         ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${GREEN}8)${NC} ${CYAN}SSH Configuration${NC}                    ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${GREEN}9)${NC} ${CYAN}System Information${NC}                   ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${GREEN}0)${NC} ${RED}Exit${NC}                               ${WHITE}║${NC}"
    echo -e "${WHITE}╚═══════════════════════════════════════════════╝${NC}"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📝 Select an option [0-9]: ${NC}"
}

# Welcome animation
welcome_animation() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}"
    echo "   ███╗   ██╗ ██████╗ ██████╗ ██╗████████╗ █████╗ "
    echo "   ████╗  ██║██╔═══██╗██╔══██╗██║╚══██╔══╝██╔══██╗"
    echo "   ██╔██╗ ██║██║   ██║██████╔╝██║   ██║   ███████║"
    echo "   ██║╚██╗██║██║   ██║██╔══██╗██║   ██║   ██╔══██║"
    echo "   ██║ ╚████║╚██████╔╝██║  ██║██║   ██║   ██║  ██║"
    echo "   ╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝   ╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${CYAN}                   Hosting Manager${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    sleep 2
}

# Main loop
welcome_animation

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
        8) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/ssh.sh" ;;
        9) system_info ;;
        0) 
            echo -e "${GREEN}Exiting Nobita Hosting Manager...${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${CYAN}           Thank you for using our tools!       ${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            sleep 2
            exit 0 
            ;;
        *) 
            print_error "Invalid option! Please choose between 0-9"
            sleep 2
            ;;
    esac
done
