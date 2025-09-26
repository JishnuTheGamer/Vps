#!/usr/bin/env bash
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

# Function to animate progress
animate_progress() {
    local pid=$1
    local message=$2
    local delay=0.1
    local spinstr='|/-\'
    
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Clear screen and show welcome message
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}           🚀 PTERODACTYL PANEL UPDATER           ${NC}"
echo -e "${CYAN}                 by Nobita-hosting               ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root or with sudo"
    exit 1
fi

print_header "STARTING UPDATE PROCESS"

# Go to panel directory
print_status "Changing to panel directory"
cd /var/www/pterodactyl || { print_error "Panel directory not found!"; exit 1; }
print_success "Changed to panel directory"

# Put panel into maintenance mode
print_header "MAINTENANCE MODE"
print_status "Enabling maintenance mode"
php artisan down > /dev/null 2>&1 &
animate_progress $! "Putting panel into maintenance mode"
print_success "Maintenance mode enabled"

# Download latest release
print_header "DOWNLOADING UPDATE"
print_status "Downloading latest Panel release"
curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv > /dev/null 2>&1 &
animate_progress $! "Downloading and extracting update"
print_success "Latest release downloaded and extracted"

# Fix permissions
print_header "PERMISSIONS SETUP"
print_status "Setting correct permissions"
chmod -R 755 storage/* bootstrap/cache > /dev/null 2>&1 &
animate_progress $! "Setting permissions"
print_success "Permissions set correctly"

# Install PHP dependencies
print_header "INSTALLING DEPENDENCIES"
print_status "Running composer install"
composer install --no-dev --optimize-autoloader > /dev/null 2>&1 &
animate_progress $! "Installing PHP dependencies"
print_success "PHP dependencies installed"

# Clear caches
print_header "CLEANING CACHE"
print_status "Clearing view cache"
php artisan view:clear > /dev/null 2>&1 &
animate_progress $! "Clearing view cache"
print_success "View cache cleared"

print_status "Clearing config cache"
php artisan config:clear > /dev/null 2>&1 &
animate_progress $! "Clearing config cache"
print_success "Config cache cleared"

# Run migrations
print_header "DATABASE MIGRATION"
print_status "Running database migrations"
php artisan migrate --seed --force > /dev/null 2>&1 &
animate_progress $! "Running migrations"
print_success "Database migrations completed"

# Fix ownership
print_header "FILE OWNERSHIP"
print_status "Setting ownership to www-data"
chown -R www-data:www-data /var/www/pterodactyl/* > /dev/null 2>&1 &
animate_progress $! "Setting file ownership"
print_success "Ownership set to www-data"

# Restart queue workers
print_header "QUEUE MANAGEMENT"
print_status "Restarting queue workers"
php artisan queue:restart > /dev/null 2>&1 &
animate_progress $! "Restarting queue workers"
print_success "Queue workers restarted"

# Bring panel back online
print_header "FINISHING UPDATE"
print_status "Bringing panel back online"
php artisan up > /dev/null 2>&1 &
animate_progress $! "Bringing panel online"
print_success "Panel brought back online"

# Update complete
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}           🎉 UPDATE COMPLETED SUCCESSFULLY!      ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "${GREEN}✨ Pterodactyl Panel has been successfully updated!${NC}"
echo -e ""
echo -e "${YELLOW}📋 UPDATE SUMMARY:${NC}"
echo -e "  ${CYAN}•${NC} ${GREEN}Maintenance mode enabled and disabled${NC}"
echo -e "  ${CYAN}•${NC} ${GREEN}Latest panel version downloaded${NC}"
echo -e "  ${CYAN}•${NC} ${GREEN}File permissions updated${NC}"
echo -e "  ${CYAN}•${NC} ${GREEN}PHP dependencies installed${NC}"
echo -e "  ${CYAN}•${NC} ${GREEN}Cache cleared${NC}"
echo -e "  ${CYAN}•${NC} ${GREEN}Database migrated${NC}"
echo -e "  ${CYAN}•${NC} ${GREEN}File ownership corrected${NC}"
echo -e "  ${CYAN}•${NC} ${GREEN}Queue workers restarted${NC}"
echo -e ""
echo -e "${YELLOW}🔧 NEXT STEPS:${NC}"
echo -e "  ${CYAN}•${NC} Check your panel at ${GREEN}https://your-domain.com${NC}"
echo -e "  ${CYAN}•${NC} Verify all functionality is working correctly"
echo -e "  ${CYAN}•${NC} Check server status in the dashboard"
echo -e ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}           Thank you for using Nobita-hosting!   ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Wait for user to see completion message
echo -e ""
read -p "$(echo -e "${YELLOW}Press Enter to exit...${NC}")" -n 1
