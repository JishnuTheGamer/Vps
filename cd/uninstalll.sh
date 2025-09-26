#!/bin/bash
set -e

# -------- Functions --------

cleanup_nginx() {
    echo ">>> Removing Nginx configuration for Pterodactyl..."
    if [[ -f "/etc/nginx/sites-enabled/pterodactyl.conf" ]]; then
        sudo rm -f /etc/nginx/sites-enabled/pterodactyl.conf
    fi
    if [[ -f "/etc/nginx/sites-available/pterodactyl.conf" ]]; then
        sudo rm -f /etc/nginx/sites-available/pterodactyl.conf
    fi
    if [[ -f "/etc/nginx/conf.d/pterodactyl.conf" ]]; then
        sudo rm -f /etc/nginx/conf.d/pterodactyl.conf
    fi

    if command -v nginx >/dev/null 2>&1; then
        sudo systemctl restart nginx
        echo "✅ Nginx reloaded."
    fi
}

uninstall_panel() {
    echo ">>> Stopping Panel service..."
    sudo systemctl stop pteroq.service || true
    sudo systemctl disable pteroq.service || true
    sudo rm -f /etc/systemd/system/pteroq.service
    sudo systemctl daemon-reload

    echo ">>> Removing Panel cronjob..."
    sudo crontab -l | grep -v 'php /var/www/pterodactyl/artisan schedule:run' | sudo crontab - || true

    echo ">>> Removing Panel files..."
    sudo rm -rf /var/www/pterodactyl

    echo ">>> Removing Panel MySQL database and user..."
    sudo mysql -u root -e "DROP DATABASE IF EXISTS panel;"
    sudo mysql -u root -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';"
    sudo mysql -u root -e "FLUSH PRIVILEGES;"

    cleanup_nginx

    echo "✅ Panel uninstalled successfully!"
}

uninstall_wings() {
    echo ">>> Stopping Wings service..."
    sudo systemctl stop wings.service || true
    sudo systemctl disable wings.service || true
    sudo rm -f /etc/systemd/system/wings.service
    sudo systemctl daemon-reload

    echo ">>> Removing Wings files..."
    sudo rm -rf /etc/pterodactyl
    sudo rm -rf /var/lib/pterodactyl
    sudo rm -rf /var/log/pterodactyl

    echo "✅ Wings uninstalled successfully!"
}

uninstall_both() {
    uninstall_panel
    uninstall_wings
    echo "✅ Panel and Wings uninstalled together successfully!"
}

# -------- Menu --------

while true; do
    clear
    echo "=============================="
    echo "  🗑️ Pterodactyl Uninstall Menu"
    echo "=============================="
    echo "1) Uninstall Panel"
    echo "2) Uninstall Wings"
    echo "3) Uninstall Panel + Wings"
    echo "0) Exit"
    echo "------------------------------"
    read -p "Choose an option: " choice

    case $choice in
        1) uninstall_panel ;;
        2) uninstall_wings ;;
        3) uninstall_both ;;
        0) echo "Exiting..."; exit 0 ;;
        *) echo "❌ Invalid option!"; read -p "Press Enter to continue..." ;;
    esac

    read -p "Press Enter to return to menu..."
done
