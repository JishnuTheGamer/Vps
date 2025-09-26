#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
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

# Function to display confirmation prompt
confirm_action() {
    local message="$1"
    echo -e "${YELLOW}$message${NC}"
    read -p "$(echo -e "${YELLOW}Are you sure you want to continue? (y/N): ${NC}")" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Operation cancelled.${NC}"
        return 1
    fi
    return 0
}

# -------- Functions --------

cleanup_nginx() {
    print_status "Removing Nginx configuration for Pterodactyl"
    
    if [[ -f "/etc/nginx/sites-enabled/pterodactyl.conf" ]]; then
        sudo rm -f /etc/nginx/sites-enabled/pterodactyl.conf
        print_success "Removed enabled site configuration"
    fi
    
    if [[ -f "/etc/nginx/sites-available/pterodactyl.conf" ]]; then
        sudo rm -f /etc/nginx/sites-available/pterodactyl.conf
        print_success "Removed available site configuration"
    fi
    
    if [[ -f "/etc/nginx/conf.d/pterodactyl.conf" ]]; then
        sudo rm -f /etc/nginx/conf.d/pterodactyl.conf
        print_success "Removed conf.d configuration"
    fi

    if command -v nginx >/dev/null 2>&1; then
        sudo systemctl restart nginx
        print_success "Nginx reloaded"
    fi
}

uninstall_panel() {
    print_header "UNINSTALLING PTERODACTYL PANEL"
    
    if ! confirm_action "This will remove the Pterodactyl Panel and all its data."; then
        return
    fi

    print_status "Stopping Panel service"
    sudo systemctl stop pteroq.service 2>/dev/null || true
    sudo systemctl disable pteroq.service 2>/dev/null || true
    sudo rm -f /etc/systemd/system/pteroq.service
    sudo systemctl daemon-reload
    print_success "Panel service stopped and disabled"

    print_status "Removing Panel cronjob"
    sudo crontab -l | grep -v 'php /var/www/pterodactyl/artisan schedule:run' | sudo crontab - 2>/dev/null || true
    print_success "Cronjob removed"

    print_status "Removing Panel files"
    sudo rm -rf /var/www/pterodactyl
    print_success "Panel files removed"

    print_status "Removing Panel MySQL database and user"
    sudo mysql -u root -e "DROP DATABASE IF EXISTS panel;" 2>/dev/null || true
    sudo mysql -u root -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';" 2>/dev/null || true
    sudo mysql -u root -e "FLUSH PRIVILEGES;" 2>/dev/null || true
    print_success "Database and user removed"

    cleanup_nginx

    print_success "Panel uninstalled successfully!"
}

uninstall_wings() {
    print_header "UNINSTALLING PTERODACTYL WINGS"
    
    if ! confirm_action "This will remove Wings and all its data."; then
        return
    fi

    print_status "Stopping Wings service"
    sudo systemctl stop wings.service 2>/dev/null || true
    sudo systemctl disable wings.service 2>/dev/null || true
    sudo rm -f /etc/systemd/system/wings.service
    sudo systemctl daemon-reload
    print_success "Wings service stopped and disabled"

    print_status "Removing Wings files"
    sudo rm -rf /etc/pterodactyl
    sudo rm -rf /var/lib/pterodactyl
    sudo rm -rf /var/log/pterodactyl
    sudo rm -f /usr/local/bin/wings
    sudo rm -f /usr/local/bin/wing
    print_success "Wings files removed"

    print_success "Wings uninstalled successfully!"
}

uninstall_both() {
    print_header "UNINSTALLING BOTH PANEL AND WINGS"
    
    if ! confirm_action "This will remove both Pterodactyl Panel and Wings completely."; then
        return
    fi

    uninstall_panel
    uninstall_wings
    
    print_success "Panel and Wings uninstalled together successfully!"
}

# -------- Menu --------

show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}            🗑️ PTERODACTYL UNINSTALLER            ${NC}"
    echo -e "${CYAN}                 by Nobita-hosting               ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "${YELLOW}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                📋 MENU OPTIONS                ║${NC}"
    echo -e "${YELLOW}╠═══════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║   ${GREEN}1)${NC} ${CYAN}Uninstall Panel Only${NC}                  ${YELLOW}║${NC}"
    echo -e "${YELLOW}║   ${GREEN}2)${NC} ${CYAN}Uninstall Wings Only${NC}                  ${YELLOW}║${NC}"
    echo -e "${YELLOW}║   ${GREEN}3)${NC} ${CYAN}Uninstall Panel + Wings${NC}               ${YELLOW}║${NC}"
    echo -e "${YELLOW}║   ${GREEN}0)${NC} ${RED}Exit Uninstaller${NC}                     ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════╝${NC}"
    echo -e ""
    echo -e "${MAGENTA}⚠️  Warning: These actions cannot be undone!${NC}"
    echo -e ""
}

while true; do
    show_menu
    
    read -p "$(echo -e "${YELLOW}Choose an option [0-3]: ${NC}")" choice

    case $choice in
        1) 
            uninstall_panel
            ;;
        2) 
            uninstall_wings
            ;;
        3) 
            uninstall_both
            ;;
        0) 
            echo -e "${GREEN}Exiting uninstaller...${NC}"
            exit 0
            ;;
        *) 
            echo -e "${RED}❌ Invalid option! Please choose 0-3.${NC}"
            sleep 2
            ;;
    esac

    echo -e ""
    read -p "$(echo -e "${YELLOW}Press Enter to return to menu...${NC}")" -n 1
done
