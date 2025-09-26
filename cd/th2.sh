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

# Function to animate progress
animate_progress() {
    local pid=$1
    local message=$2
    local delay=0.1
    local spinstr='|/-\'
    
    print_status "$message"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
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

# Welcome message
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
echo -e "${CYAN}           Nebula Blueprint Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
sleep 2

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root or with sudo"
    exit 1
fi

print_header "STARTING NEBULA BLUEPRINT INSTALLATION"

# ------------------------------
# Target directory
# ------------------------------
TARGET_DIR="/var/www/pterodactyl"

print_status "Creating target directory"
mkdir -p "$TARGET_DIR" > /dev/null 2>&1
check_success "Target directory created" "Failed to create directory"

# ------------------------------
# Temp repository folder
# ------------------------------
TEMP_REPO="/tmp/ak-nobita-bot"

print_status "Cleaning up old temporary files"
rm -rf "$TEMP_REPO" > /dev/null 2>&1
check_success "Old files cleaned up" "Failed to clean up"

# ------------------------------
# Clone repository temporarily
# ------------------------------
print_header "DOWNLOADING NEBULA BLUEPRINT"
print_status "Cloning repository"
git clone https://github.com/nobita586/ak-nobita-bot.git "$TEMP_REPO" > /dev/null 2>&1 &
animate_progress $! "Cloning repository"
check_success "Repository cloned" "Failed to clone repository"

# ------------------------------
# Check if nebula.blueprint exists
# ------------------------------
SOURCE_FILE="$TEMP_REPO/src/nebula.blueprint"

print_status "Checking for nebula.blueprint"
if [ -f "$SOURCE_FILE" ]; then
    print_success "nebula.blueprint found"
    
    # Move to target directory
    print_status "Moving blueprint to target directory"
    mv "$SOURCE_FILE" "$TARGET_DIR/" > /dev/null 2>&1
    check_success "Blueprint moved to $TARGET_DIR" "Failed to move blueprint"
else
    print_error "nebula.blueprint not found in repository!"
    rm -rf "$TEMP_REPO" > /dev/null 2>&1
    exit 1
fi

# ------------------------------
# Remove temporary repo
# ------------------------------
print_status "Cleaning up temporary files"
rm -rf "$TEMP_REPO" > /dev/null 2>&1
check_success "Temporary files cleaned up" "Failed to clean up"

# ------------------------------
# Auto-run blueprint
# ------------------------------
print_header "EXECUTING BLUEPRINT"
cd "$TARGET_DIR" || exit 1

print_status "Checking for blueprint tool"
if command -v blueprint >/dev/null 2>&1; then
    print_success "Blueprint tool found"
    
    print_status "Running blueprint installation"
    blueprint -i nebula.blueprint > /dev/null 2>&1 &
    animate_progress $! "Running blueprint installation"
    
    if [ $? -eq 0 ]; then
        print_success "Blueprint executed successfully"
    else
        print_error "Blueprint execution failed"
        exit 1
    fi
else
    print_error "Blueprint tool not installed"
    echo -e ""
    echo -e "${YELLOW}To install blueprint, run:${NC}"
    echo -e "${CYAN}curl -sSL https://blueprintjs.dev/install.sh | bash${NC}"
    echo -e ""
    exit 1
fi

# Installation Complete
print_header "INSTALLATION COMPLETE"
echo -e "${GREEN}🎉 Nebula Blueprint has been successfully installed!${NC}"
echo -e ""
echo -e "${YELLOW}📋 INSTALLATION SUMMARY:${NC}"
echo -e "  ${CYAN}•${NC} ${GREEN}Repository cloned successfully${NC}"
echo -e "  ${CYAN}•${NC} ${GREEN}nebula.blueprint downloaded${NC}"
echo -e "  ${CYAN}•${NC} ${GREEN}Blueprint executed successfully${NC}"
echo -e ""
echo -e "${YELLOW}📍 LOCATION:${NC}"
echo -e "  ${CYAN}•${NC} ${GREEN}Blueprint file: ${TARGET_DIR}/nebula.blueprint${NC}"
echo -e ""
echo -e "${YELLOW}🚀 NEXT STEPS:${NC}"
echo -e "  ${CYAN}•${NC} Check your panel for new features"
echo -e "  ${CYAN}•${NC} Review the blueprint configuration"
echo -e "  ${CYAN}•${NC} Restart your panel if required"
echo -e ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}           Thank you for using Nobita-hosting!   ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Wait for user to see completion message
echo -e ""
read -p "$(echo -e "${YELLOW}Press Enter to exit...${NC}")" -n 1
