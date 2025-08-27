#!/bin/bash

# install the theme
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt-get update
apt-get install -y nodejs

# install the theme yml
npm i -g yarn
apt update

# go 2 disk
cd /var/www/pterodactyl
yarn

# install the main
apt install -y zip unzip git curl wget
wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip

# install the theme
mv release.zip /var/www/pterodactyl/release.zip
cd /var/www/pterodactyl
unzip release.zip

# install the blueprint
touch /var/www/pterodactyl/.blueprintrc

# echo f the vps
echo \
'WEBUSER="www-data";
OWNERSHIP="www-data:www-data";
USERSHELL="/bin/bash";' >> /var/www/pterodactyl/.blueprintrc

# install updates
chmod +x blueprint.sh
bash blueprint.sh
