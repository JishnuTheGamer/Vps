#!/bin/bash

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

# Function to check if command succeeded
check_success() {
    if [ $? -eq 0 ]; then
        print_success "$1"
        return 0
    else
        print_error "$2"
        return 1
    fi
}

# Clear screen and show welcome message
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}           🔐 SSH CONFIGURATION TOOL             ${NC}"
echo -e "${CYAN}                 by Nobita-hosting               ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root or with sudo"
    exit 1
fi

CONFIG_FILE="/etc/ssh/sshd_config"

print_header "SSH CONFIGURATION BACKUP"
print_status "Creating backup of SSH configuration"
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak" 2>/dev/null
check_success "Backup created at ${CONFIG_FILE}.bak" "Failed to create backup"

print_header "ENABLING ROOT LOGIN"
print_status "Configuring PermitRootLogin"
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' "$CONFIG_FILE" 2>/dev/null
sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' "$CONFIG_FILE" 2>/dev/null
grep -q "^PermitRootLogin" "$CONFIG_FILE" 2>/dev/null || echo "PermitRootLogin yes" >> "$CONFIG_FILE"
check_success "Root login enabled" "Failed to enable root login"

print_header "ENABLING PASSWORD AUTHENTICATION"
print_status "Configuring PasswordAuthentication"
# Remove any existing PasswordAuthentication settings
sed -i '/^#PasswordAuthentication/d' "$CONFIG_FILE" 2>/dev/null
sed -i '/^PasswordAuthentication/d' "$CONFIG_FILE" 2>/dev/null
# Add the new setting
echo "PasswordAuthentication yes" >> "$CONFIG_FILE" 2>/dev/null
check_success "Password authentication enabled" "Failed to enable password authentication"

print_header "RESTARTING SSH SERVICE"
print_status "Restarting SSH service"
systemctl restart ssh 2>/dev/null
check_success "SSH service restarted" "Failed to restart SSH service"

# Show configuration summary
print_header "CONFIGURATION SUMMARY"
echo -e "${GREEN}Current SSH Configuration:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
grep -E "^(PermitRootLogin|PasswordAuthentication)" "$CONFIG_FILE" 2>/dev/null | while read line; do
    echo -e "  ${CYAN}•${NC} ${GREEN}$line${NC}"
done
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

print_header "NEXT STEPS REQUIRED"
echo -e "${YELLOW}📋 Manual action required:${NC}"
echo -e ""
echo -e "  ${CYAN}1.${NC} ${GREEN}Set a root password using this command:${NC}"
echo -e "     ${MAGENTA}sudo passwd root${NC}"
echo -e ""
echo -e "  ${CYAN}2.${NC} ${GREEN}Test SSH connection:${NC}"
echo -e "     ${MAGENTA}ssh root@your-server-ip${NC}"
echo -e ""
echo -e "  ${CYAN}3.${NC} ${YELLOW}For security, consider:${NC}"
echo -e "     ${CYAN}•${NC} Using SSH keys instead of passwords"
echo -e "     ${CYAN}•${NC} Changing the default SSH port"
echo -e "     ${CYAN}•${NC} Using fail2ban for brute force protection"
echo -e ""
echo -e "${MAGENTA}⚠️  Security Note:${NC}"
echo -e "  ${RED}Enabling root login with password can be a security risk.${NC}"
echo -e "  ${YELLOW}Make sure to use a strong password and consider additional security measures.${NC}"

print_header "QUICK COMMAND REFERENCE"
echo -e "${GREEN}Set root password:${NC}"
echo -e "  ${CYAN}passwd root${NC}"
echo -e ""
echo -e "${GREEN}Check SSH status:${NC}"
echo -e "  ${CYAN}systemctl status ssh${NC}"
echo -e ""
echo -e "${GREEN}View SSH config:${NC}"
echo -e "  ${CYAN}grep -E '(PermitRootLogin|PasswordAuthentication)' /etc/ssh/sshd_config${NC}"

echo -e ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}           Thank you for using Nobita-hosting!   ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Wait for user to see completion message
echo -e ""
read -p "$(echo -e "${YELLOW}Press Enter to exit...${NC}")" -n 1
