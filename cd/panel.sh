#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

# Clear screen and show welcome message
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}           PTERODACTYL PANEL INSTALLER           ${NC}"
echo -e "${CYAN}                 by Nobita-hosting               ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Get domain name
read -p "$(echo -e "${YELLOW}🌐 Enter your domain (e.g., panel.example.com): ${NC}")" DOMAIN

# Validate domain input
if [ -z "$DOMAIN" ]; then
    print_error "Domain cannot be empty!"
    exit 1
fi

print_header "STARTING INSTALLATION PROCESS"

# --- Dependencies ---
print_header "INSTALLING DEPENDENCIES"
print_status "Updating package list"
apt update > /dev/null 2>&1 &
animate_progress $! "Updating packages"
print_success "Package list updated"

print_status "Installing required packages"
apt install -y curl apt-transport-https ca-certificates gnupg unzip git tar sudo lsb-release > /dev/null 2>&1 &
animate_progress $! "Installing dependencies"
print_success "Dependencies installed"

# Detect OS
OS=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

if [[ "$OS" == "ubuntu" ]]; then
    print_status "Detected Ubuntu - Adding PHP PPA"
    apt install -y software-properties-common > /dev/null 2>&1
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1 &
    animate_progress $! "Adding PHP repository"
    print_success "PHP PPA added"
elif [[ "$OS" == "debian" ]]; then
    print_status "Detected Debian - Adding PHP repository"
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury-php.gpg > /dev/null 2>&1
    echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/sury-php.list > /dev/null
    print_success "PHP repository added"
fi

# Add Redis repository
print_status "Adding Redis repository"
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg > /dev/null 2>&1
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list > /dev/null
print_success "Redis repository added"

print_status "Updating package list with new repositories"
apt update > /dev/null 2>&1 &
animate_progress $! "Updating package lists"
print_success "Package lists updated"

# --- Install PHP + extensions ---
print_header "INSTALLING PHP AND EXTENSIONS"
print_status "Installing PHP 8.3 and extensions"
apt install -y php8.3 php8.3-{cli,fpm,common,mysql,mbstring,bcmath,xml,zip,curl,gd,tokenizer,ctype,simplexml,dom} > /dev/null 2>&1 &
animate_progress $! "Installing PHP and extensions"
print_success "PHP and extensions installed"

# --- Install other services ---
print_status "Installing MariaDB, Nginx, and Redis"
apt install -y mariadb-server nginx redis-server > /dev/null 2>&1 &
animate_progress $! "Installing core services"
print_success "Core services installed"

# --- Install Composer ---
print_header "INSTALLING COMPOSER"
print_status "Downloading and installing Composer"
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer > /dev/null 2>&1 &
animate_progress $! "Installing Composer"
print_success "Composer installed"

# --- Download Pterodactyl Panel ---
print_header "DOWNLOADING PTERODACTYL PANEL"
print_status "Creating web directory"
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl

print_status "Downloading Pterodactyl panel"
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz > /dev/null 2>&1 &
animate_progress $! "Downloading panel files"
print_success "Panel downloaded"

print_status "Extracting panel files"
tar -xzvf panel.tar.gz > /dev/null 2>&1 &
animate_progress $! "Extracting files"
print_success "Files extracted"

print_status "Setting permissions"
chmod -R 755 storage/* bootstrap/cache/ > /dev/null 2>&1
print_success "Permissions set"

# --- MariaDB Setup ---
print_header "CONFIGURING DATABASE"
print_status "Setting up MariaDB database and user"
DB_NAME=panel
DB_USER=pterodactyl
DB_PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16 ; echo '')
mariadb -e "CREATE USER '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';" > /dev/null 2>&1
mariadb -e "CREATE DATABASE ${DB_NAME};" > /dev/null 2>&1
mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1' WITH GRANT OPTION;" > /dev/null 2>&1
mariadb -e "FLUSH PRIVILEGES;" > /dev/null 2>&1
print_success "Database configured"

# --- .env Setup ---
print_header "CONFIGURING ENVIRONMENT"
print_status "Setting up environment file"
if [ ! -f ".env.example" ]; then
    curl -Lo .env.example https://raw.githubusercontent.com/pterodactyl/panel/develop/.env.example > /dev/null 2>&1
fi
cp .env.example .env
sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|g" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_NAME}|g" .env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USER}|g" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|g" .env
if ! grep -q "^APP_ENVIRONMENT_ONLY=" .env; then
    echo "APP_ENVIRONMENT_ONLY=false" >> .env
fi
print_success "Environment configured"

# --- Install PHP dependencies ---
print_status "Installing PHP dependencies with Composer"
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader > /dev/null 2>&1 &
animate_progress $! "Installing dependencies"
print_success "PHP dependencies installed"

# --- Generate Application Key ---
print_status "Generating application key"
php artisan key:generate --force > /dev/null 2>&1
print_success "Application key generated"

# --- Run Migrations ---
print_status "Running database migrations"
php artisan migrate --seed --force > /dev/null 2>&1 &
animate_progress $! "Running migrations"
print_success "Database migrations completed"

# --- Permissions ---
print_status "Setting final permissions"
chown -R www-data:www-data /var/www/pterodactyl/* > /dev/null 2>&1
apt install -y cron > /dev/null 2>&1
systemctl enable --now cron > /dev/null 2>&1
(crontab -l 2>/dev/null; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1") | crontab - > /dev/null 2>&1
print_success "Permissions and cron configured"

# --- SSL Certificate ---
print_header "CONFIGURING SSL CERTIFICATE"
print_status "Generating self-signed SSL certificate"
mkdir -p /etc/certs/panel
cd /etc/certs/panel
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
-subj "/C=NA/ST=NA/L=NA/O=NA/CN=Generic SSL Certificate" \
-keyout privkey.pem -out fullchain.pem > /dev/null 2>&1 &
animate_progress $! "Generating SSL certificate"
print_success "SSL certificate generated"

# --- Nginx Setup ---
print_header "CONFIGURING NGINX"
print_status "Creating Nginx configuration"
PHP_VERSION="8.3"

tee /etc/nginx/sites-available/pterodactyl.conf > /dev/null << EOF
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    root /var/www/pterodactyl/public;
    index index.php;

    ssl_certificate /etc/certs/panel/fullchain.pem;
    ssl_certificate_key /etc/certs/panel/privkey.pem;

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_index index.php;
        include /etc/nginx/fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize=100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

print_status "Enabling site configuration"
ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf 2>/dev/null || true

print_status "Testing Nginx configuration"
nginx -t > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_success "Nginx configuration test passed"
    print_status "Restarting Nginx"
    systemctl restart nginx > /dev/null 2>&1
    print_success "Nginx configured and restarted"
else
    print_error "Nginx configuration test failed"
    exit 1
fi

# --- Queue Worker ---
print_header "CONFIGURING QUEUE WORKER"
print_status "Setting up Pterodactyl queue worker"

tee /etc/systemd/system/pteroq.service > /dev/null << 'EOF'
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

print_status "Enabling and starting services"
systemctl daemon-reload > /dev/null 2>&1
systemctl enable --now redis-server > /dev/null 2>&1
systemctl enable --now pteroq.service > /dev/null 2>&1
print_success "Queue worker configured"

# --- Final Configuration ---
print_header "FINAL CONFIGURATION"
print_status "Updating environment settings"
cd /var/www/pterodactyl

# Remove existing settings if they exist
sed -i '/^APP_ENVIRONMENT_ONLY=/d' .env
sed -i '/^APP_THEME=/d' .env
sed -i '/^APP_TIMEZONE=/d' .env
sed -i '/^MAIL_/d' .env

# Add new env variables
echo "APP_ENVIRONMENT_ONLY=false" >> .env
echo "APP_THEME=Nobita-hosting" >> .env

# Auto detect timezone
TIMEZONE=$(timedatectl show --property=Timezone --value)
echo "APP_TIMEZONE=${TIMEZONE}" >> .env

# Mail configuration
echo "MAIL_MAILER=smtp" >> .env
echo "MAIL_HOST=smtp.zoho.in" >> .env
echo "MAIL_PORT=587" >> .env
echo "MAIL_USERNAME=no.reply@editorxprress.site" >> .env
echo "MAIL_PASSWORD=58@S5wZuWtpdDDX" >> .env
echo "MAIL_ENCRYPTION=tls" >> .env
echo "MAIL_FROM_ADDRESS=no.reply@editorxprress.site" >> .env
echo 'MAIL_FROM_NAME="Nobita-hosting"' >> .env

print_success "Environment settings updated"

# --- Installation Complete ---
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}          INSTALLATION COMPLETE!                 ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "${GREEN}🎉 Pterodactyl Panel has been successfully installed!${NC}"
echo -e ""
echo -e "${YELLOW}📋 NEXT STEPS:${NC}"
echo -e "  ${CYAN}1.${NC} Create an admin account:"
echo -e "     ${GREEN}cd /var/www/pterodactyl && php artisan p:user:make${NC}"
echo -e ""
echo -e "  ${CYAN}2.${NC} Access your panel at:"
echo -e "     ${GREEN}https://${DOMAIN}${NC}"
echo -e ""
echo -e "${YELLOW}🔧 TECHNICAL DETAILS:${NC}"
echo -e "  ${CYAN}•${NC} Database Name: ${GREEN}${DB_NAME}${NC}"
echo -e "  ${CYAN}•${NC} Database User: ${GREEN}${DB_USER}${NC}"
echo -e "  ${CYAN}•${NC} Database Password: ${GREEN}${DB_PASS}${NC}"
echo -e "  ${CYAN}•${NC} Installation Directory: ${GREEN}/var/www/pterodactyl${NC}"
echo -e "  ${CYAN}•${NC} Theme: ${GREEN}Nobita-hosting${NC}"
echo -e ""
echo -e "${YELLOW}⚠️  IMPORTANT:${NC}"
echo -e "  ${CYAN}•${NC} Remember to replace the self-signed SSL certificate"
echo -e "    with a valid one for production use"
echo -e ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}           Thank you for using Nobita-hosting!   ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Prompt to create admin user
echo -e ""
read -p "$(echo -e "${YELLOW}Would you like to create an admin user now? (y/N): ${NC}")" -n 1 -r
echo -e ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_header "CREATING ADMIN USER"
    cd /var/www/pterodactyl
    php artisan p:user:make
fi

echo -e ""
echo -e "${GREEN}✨ Installation completed successfully!${NC}"
echo -e ""
