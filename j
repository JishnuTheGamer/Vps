#!/bin/bash

# Update and upgrade the system
echo "Updating package list..."
apt update -y
echo "Upgrading packages..."
apt upgrade -y

# Install Docker Compose
echo "Installing Docker Compose..."
apt install docker-compose -y

# Install Neofetch
echo "Installing Neofetch..."
apt install neofetch -y

# Run Neofetch to display system information
echo "Running Neofetch..."
neofetch

echo "All tasks completed successfully!"
