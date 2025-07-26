#!/bin/bash

# Define colors
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RED="\e[31m"
BOLD_GREEN="\e[1;32m"  # Bold green for header and prompts
UNDERLINE="\e[4m"      # Underline for emphasis
RESET="\e[0m"

# Loop the menu until the user chooses to exit
while true; do
    # Clear the terminal
    clear

    # Display Installer Name (improved header)
    echo -e "${GREEN}╔═══════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║ ${BOLD_GREEN}Puffer Panel Installer${RESET} ${GREEN}║${RESET}"
    echo -e "${GREEN}║                 Version 3.0                   ║${RESET}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════╝${RESET}"
    echo ""  # Add a blank line for spacing

    # Menu options (improved text and typing experience)
    echo -e "${YELLOW}╔═══════════════════════════════════════════════╗${RESET}"
    echo -e "${YELLOW}║               Select an Option:               ║${RESET}"
    echo -e "${YELLOW}╟───────────────────────────────────────────────╢${RESET}"
    echo -e "${YELLOW}║ ${CYAN}1)${RESET} Install PufferPanel on GitHub and All VPS    ${YELLOW}║${RESET}"
    echo -e "${YELLOW}║    ${CYAN}   (For general VPS and GitHub setups)${RESET}      ${YELLOW}║${RESET}"
    echo -e "${YELLOW}║ ${CYAN}2)${RESET} Install PufferPanel on Only CodeSandbox      ${YELLOW}║${RESET}"
    echo -e "${YELLOW}║    ${CYAN}   (Modded version required - see disclaimer)${RESET} ${YELLOW}║${RESET}"
    echo -e "${YELLOW}╟───────────────────────────────────────────────╢${RESET}"
    echo -e "${YELLOW}║ ${UNDERLINE}(Type 'q' or 'exit' to quit)${RESET}                  ${YELLOW}║${RESET}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════╝${RESET}"
    echo -n -e "${BOLD_GREEN}Enter your choice > ${RESET}"
    read -r choice

    # Echo back the choice for better feedback
    echo -e "${CYAN}You selected: $choice${RESET}"
    echo ""  # Blank line for spacing

    # Run the selected installation script
    case $choice in
        1)
            echo -e "${GREEN}Installing PufferPanel on GitHub and All VPS...${RESET}"
            bash <(curl -fsSL https://github.com/spookyMC123/panel-installer/raw/refs/heads/main/script/puffer%20panel/git-install.sh)
            echo -e "${GREEN}Puffer Panel process completed successfully!${RESET}"
            ;;
        2)
            # Show disclaimer "popup"
            echo -e "${RED}================================================${RESET}"
            echo -e "${RED} DISCLAIMER:${RESET}"
            echo -e "${RED} You need to run this cmd in codesandbox modded version only - https://codesandbox.io/p/devbox/nervous-dust-skfsyh ${RESET}"
            echo -e "${RED}================================================${RESET}"

            # Prompt for yes/no
            echo -n -e "${CYAN}Now- do you want to proceed or go back?- yes/no: ${RESET}"
            read -r response
            response=$(echo "$response" | tr '[:upper:]' '[:lower:]' | xargs)  # Convert to lowercase and trim whitespace

            if [ "$response" = "yes" ]; then
                echo -e "${GREEN}Installing PufferPanel on CodeSandbox...${RESET}"
                bash <(curl -fsSL https://raw.githubusercontent.com/JishnuTheGamer/Puffer-panel-installer/refs/heads/main/Installer)
                echo -e "${GREEN}Puffer Panel process completed successfully!${RESET}"
            else
                echo -e "${YELLOW}Going back...${RESET}"
                # Loop will take us back to the menu
            fi
            ;;
        q|exit)
            echo -e "${YELLOW}Exiting the installer. Goodbye!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice '$choice'! Please try again.${RESET}"
            # Loop back to menu
            ;;
    esac

    # Pause briefly before looping back (optional: remove if not needed)
    sleep 2
done
