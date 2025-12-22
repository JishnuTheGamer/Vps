#!/bin/bash

# Blueprint Installer Script
# Made by Jishnu

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    echo -e "${GREEN}[Blueprint Installer]${NC} $1"
}

print_error() {
    echo -e "${RED}[Blueprint Installer] ERROR:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[Blueprint Installer] WARNING:${NC} $1"
}

print_header() {
    echo -e "${CYAN}==========================================${NC}"
    echo -e "${PURPLE}    $1${NC}"
    echo -e "${CYAN}==========================================${NC}"
}

print_status() {
    echo -e "${BLUE}[STATUS]${NC} $1"
}

# Function to check if command was successful
check_status() {
    if [ $? -eq 0 ]; then
        print_message "✓ $1"
    else
        print_error "$2"
        exit 1
    fi
}

# Function to animate progress
animate_progress() {
    local pid=$1
    local message="$2"
    local delay=0.1
    local spinstr='|/-\'
    
    echo -n "$message "
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

check_success() {
    if [ $? -eq 0 ]; then
        print_message "✓ $1"
    else
        print_error "$2"
    fi
}

# Function: Fresh Blueprint Installation
blueprint_fresh_install() {
    print_header "BLUEPRINT FRESH INSTALLATION"
    
    # Set Pterodactyl directory
    read -p "Enter Pterodactyl installation directory [/var/www/pterodactyl]: " PTERODACTYL_DIRECTORY
    PTERODACTYL_DIRECTORY=${PTERODACTYL_DIRECTORY:-/var/www/pterodactyl}
    
    # Verify directory exists
    if [ ! -d "$PTERODACTYL_DIRECTORY" ]; then
        print_error "Directory $PTERODACTYL_DIRECTORY does not exist!"
        read -p "Create directory? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo mkdir -p "$PTERODACTYL_DIRECTORY"
            check_status "Created directory $PTERODACTYL_DIRECTORY" "Failed to create directory"
        else
            echo "Exiting..."
            return 1
        fi
    fi
    
    export PTERODACTYL_DIRECTORY
    print_message "Using directory: $PTERODACTYL_DIRECTORY"
    
    # Step 1: Install basic dependencies
    print_status "Installing basic dependencies..."
    sudo apt update
    sudo apt install -y curl wget unzip ca-certificates git gnupg zip > /dev/null 2>&1 &
    animate_progress $! "Installing basic dependencies"
    check_success "Basic dependencies installed" "Failed to install basic dependencies"
    
    # Step 2: Navigate to Pterodactyl directory
    print_status "Changing to Pterodactyl directory..."
    cd "$PTERODACTYL_DIRECTORY" || { print_error "Failed to change directory"; return 1; }
    check_status "Changed to $PTERODACTYL_DIRECTORY"
    
    # Step 3: Download Blueprint release
    print_status "Downloading latest Blueprint release..."
    DOWNLOAD_URL=$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)
    
    if [ -z "$DOWNLOAD_URL" ]; then
        print_error "Failed to get download URL from GitHub API"
        return 1
    fi
    
    print_message "Downloading from: $DOWNLOAD_URL"
    wget "$DOWNLOAD_URL" -O "$PTERODACTYL_DIRECTORY/release.zip" > /dev/null 2>&1 &
    animate_progress $! "Downloading Blueprint"
    check_success "Blueprint release downloaded" "Failed to download Blueprint release"
    
    # Step 4: Extract the release
    print_status "Extracting Blueprint release..."
    unzip -o release.zip > /dev/null 2>&1 &
    animate_progress $! "Extracting files"
    check_success "Blueprint release extracted" "Failed to extract Blueprint release"
    
    # Clean up zip file
    rm -f release.zip
    print_message "Cleaned up release.zip"
    
    # Step 5: Install Node.js
    print_status "Installing Node.js..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg > /dev/null 2>&1 &
    animate_progress $! "Adding Node.js repository"
    check_success "Node.js GPG key added" "Failed to add Node.js GPG key"
    
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
    sudo apt update > /dev/null 2>&1 &
    animate_progress $! "Updating package list"
    
    sudo apt install -y nodejs > /dev/null 2>&1 &
    animate_progress $! "Installing Node.js"
    check_success "Node.js installed" "Failed to install Node.js"
    
    # Step 6: Install Yarn and dependencies
    print_status "Installing Yarn and dependencies..."
    cd "$PTERODACTYL_DIRECTORY" || { print_error "Failed to change directory"; return 1; }
    
    npm i -g yarn > /dev/null 2>&1 &
    animate_progress $! "Installing Yarn"
    check_success "Yarn installed globally" "Failed to install Yarn"
    
    yarn install > /dev/null 2>&1 &
    animate_progress $! "Installing Node.js dependencies"
    check_success "Node.js dependencies installed" "Failed to install Node.js dependencies"
    
    # Step 7: Create .blueprintrc file
    print_status "Creating .blueprintrc configuration file..."
    BLUEPRINT_RC_FILE="$PTERODACTYL_DIRECTORY/.blueprintrc"
    
    if [ -f "$BLUEPRINT_RC_FILE" ]; then
        print_warning ".blueprintrc file already exists!"
        read -p "Overwrite? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_message "Keeping existing .blueprintrc file"
        else
            create_blueprintrc=1
        fi
    else
        create_blueprintrc=1
    fi
    
    if [ "$create_blueprintrc" = "1" ]; then
        cat > "$BLUEPRINT_RC_FILE" << EOF
WEBUSER="www-data"
OWNERSHIP="www-data:www-data"
USERSHELL="/bin/bash"
EOF
        check_status ".blueprintrc file created" "Failed to create .blueprintrc file"
        
        # Show contents
        print_message "Contents of .blueprintrc:"
        cat "$BLUEPRINT_RC_FILE"
    fi
    
    # Step 8: Set execute permissions and run blueprint.sh
    print_status "Setting up Blueprint..."
    
    BLUEPRINT_SCRIPT="$PTERODACTYL_DIRECTORY/blueprint.sh"
    
    if [ -f "$BLUEPRINT_SCRIPT" ]; then
        chmod +x "$BLUEPRINT_SCRIPT"
        check_status "Execute permissions granted to blueprint.sh" "Failed to set permissions"
        
        print_status "Running Blueprint installation script..."
        echo "=========================================="
        bash "$BLUEPRINT_SCRIPT"
        
        if [ $? -eq 0 ]; then
            echo ""
            print_message "Blueprint installation completed successfully!"
            print_message "Installation directory: $PTERODACTYL_DIRECTORY"
        else
            print_error "Blueprint script encountered an error"
        fi
    else
        print_error "blueprint.sh not found in $PTERODACTYL_DIRECTORY"
        print_message "Please check if the download and extraction were successful"
    fi
    
    print_header "FRESH INSTALLATION COMPLETED"
}

# Function: Reinstall Blueprint (Rerun Only)
reinstall_blueprint() {
    print_header "REINSTALLING BLUEPRINT"
    
    # Check if we're in a Pterodactyl directory
    if [ ! -f "blueprint.sh" ] && [ ! -f ".blueprintrc" ]; then
        print_error "This doesn't appear to be a Blueprint/Pterodactyl directory!"
        read -p "Enter Pterodactyl installation directory [/var/www/pterodactyl]: " PTERODACTYL_DIRECTORY
        PTERODACTYL_DIRECTORY=${PTERODACTYL_DIRECTORY:-/var/www/pterodactyl}
        
        if [ ! -d "$PTERODACTYL_DIRECTORY" ]; then
            print_error "Directory $PTERODACTYL_DIRECTORY does not exist!"
            return 1
        fi
        
        cd "$PTERODACTYL_DIRECTORY" || { print_error "Failed to change directory"; return 1; }
    fi
    
    if [ ! -f "blueprint.sh" ]; then
        print_error "blueprint.sh not found in current directory!"
        print_error "Please navigate to your Pterodactyl installation directory first."
        return 1
    fi
    
    print_status "Starting reinstallation..."
    
    # Check if blueprint command exists
    if command -v blueprint &> /dev/null; then
        print_status "Running blueprint reinstallation command..."
        blueprint -rerun-install > /dev/null 2>&1 &
        animate_progress $! "Reinstalling Blueprint"
        check_success "Reinstallation completed" "Reinstallation failed"
    else
        print_warning "Blueprint command not found, running blueprint.sh directly..."
        
        # Make sure blueprint.sh is executable
        if [ ! -x "blueprint.sh" ]; then
            chmod +x blueprint.sh
        fi
        
        # Run blueprint.sh with reinstall flag or just run it
        if grep -q "rerun\|reinstall" blueprint.sh; then
            bash blueprint.sh --rerun > /dev/null 2>&1 &
        else
            bash blueprint.sh > /dev/null 2>&1 &
        fi
        
        animate_progress $! "Reinstalling Blueprint"
        check_success "Reinstallation completed" "Reinstallation failed"
    fi
    
    print_header "REINSTALLATION COMPLETED"
}

# Function to display menu
show_menu() {
    clear
    print_header "BLUEPRINT FRAMEWORK INSTALLER"
    echo ""
    echo -e "${GREEN}Made by Jishnu${NC}"
    echo ""
    echo -e "${YELLOW}Select an option:${NC}"
    echo "1) Blueprint fresh install"
    echo "2) Re-install blueprint"
    echo "3) Check system requirements"
    echo "4) Exit"
    echo ""
}

# Function to check system requirements
check_system() {
    print_header "SYSTEM REQUIREMENTS CHECK"
    
    echo -e "${YELLOW}Checking system requirements...${NC}"
    echo ""
    
    # Check OS
    print_status "Operating System:"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "  ✓ $PRETTY_NAME"
    else
        echo "  ✗ Unable to detect OS"
    fi
    
    # Check RAM
    print_status "Memory (RAM):"
    total_mem=$(free -m | awk '/^Mem:/{print $2}')
    if [ $total_mem -gt 1000 ]; then
        echo "  ✓ ${total_mem}MB (Recommended: 1GB+)"
    else
        echo "  ⚠ ${total_mem}MB (Recommended: 1GB+)"
    fi
    
    # Check Disk Space
    print_status "Disk Space:"
    disk_space=$(df -h / | awk 'NR==2 {print $4}')
    echo "  ✓ $disk_space available"
    
    # Check dependencies
    print_status "Checking dependencies:"
    
    declare -A deps=(
        ["curl"]="curl"
        ["wget"]="wget"
        ["unzip"]="unzip"
        ["git"]="git"
        ["node"]="nodejs"
        ["npm"]="npm"
    )
    
    for cmd in "${!deps[@]}"; do
        if command -v $cmd &> /dev/null; then
            echo "  ✓ ${deps[$cmd]}"
        else
            echo "  ✗ ${deps[$cmd]} (Missing)"
        fi
    done
    
    echo ""
    echo -e "${GREEN}System check completed!${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

# Main script execution
main() {
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then 
        print_warning "This script requires sudo privileges for installation"
        print_warning "Some operations may fail without proper permissions"
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Exiting..."
            exit 1
        fi
    fi
    
    while true; do
        show_menu
        read -p "Enter your choice [1-4]: " choice
        
        case $choice in
            1)
                blueprint_fresh_install
                read -p "Press Enter to continue..."
                ;;
            2)
                reinstall_blueprint
                read -p "Press Enter to continue..."
                ;;
            3)
                check_system
                ;;
            4)
                print_header "THANK YOU FOR USING BLUEPRINT INSTALLER"
                echo -e "${GREEN}Made by Jishnu${NC}"
                echo ""
                exit 0
                ;;
            *)
                print_error "Invalid option! Please enter 1, 2, 3, or 4"
                sleep 2
                ;;
        esac
    done
}

# Check if script is being sourced or run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
