#!/bin/bash
set -e

# === Terminal Colors ===
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'
BLUE_LINE="\e[38;5;220m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"

BUN_INSTALL="$HOME/.bun"
PATH="$BUN_INSTALL/bin:$PATH"

# === Header Display ===
function show_header() {
    clear
    echo -e "\e[38;5;220m"
    echo " ██████╗  ██████╗ ██╗     ██████╗ ██╗   ██╗██████╗ ███████╗"
    echo "██╔════╝ ██╔═══██╗██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝"
    echo "██║  ███╗██║   ██║██║     ██║  ██║██║   ██║██████╔╝███████╗"
    echo "██║   ██║██║   ██║██║     ██║  ██║╚██╗ ██╔╝██╔═══╝ ╚════██║"
    echo "╚██████╔╝╚██████╔╝███████╗██████╔╝ ╚████╔╝ ██║     ███████║"
    echo " ╚═════╝  ╚═════╝ ╚══════╝╚═════╝   ╚═══╝  ╚═╝     ╚══════╝"
    echo -e "\e[0m"
    echo -e "🚀 \e[1;33mOctra Testnet Installer\e[0m - Powered by \e[1;33mGoldVPS Team\e[0m 🚀"
    echo -e "🌐 \e[4;33mhttps://goldvps.net\e[0m - Best VPS with Low Price"
    echo ""
}

# === Check Root ===
function check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[✘] Please run this script as root.${RESET}"
        exit 1
    fi
}

# === Install Base Dependencies ===
function install_dependencies() {
    echo -e "${YELLOW}[+] Installing required dependencies (git, curl, unzip, ufw)...${RESET}"
    apt update && apt install -y git curl unzip ufw
}

# === Check and Install Bun ===
function install_bun_if_needed() {
    if ! command -v bun &> /dev/null; then
        echo -e "${RED}[!] Bun is not installed.${RESET}"
        echo -e "${YELLOW}[+] Installing Bun...${RESET}"

        # Ensure unzip is installed
        if ! command -v unzip &> /dev/null; then
            echo -e "${YELLOW}[+] 'unzip' is missing, installing...${RESET}"
            apt install -y unzip
        fi

        curl -fsSL https://bun.sh/install | bash

        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"

        echo -e "${GREEN}[✓] Bun has been installed successfully.${RESET}"
    else
        echo -e "${GREEN}[✓] Bun is already installed.${RESET}"
    fi
}

# === Clone wallet-gen Repository ===
function clone_wallet_repo() {
    if [ -d "wallet-gen" ]; then
        echo -e "${YELLOW}[!] 'wallet-gen' directory already exists. Skipping clone.${RESET}"
    else
        echo -e "${YELLOW}[+] Cloning wallet-gen repository...${RESET}"
        git clone https://github.com/octra-labs/wallet-gen.git
    fi
}

# === Configure Firewall ===
function configure_firewall() {
    echo -e "${YELLOW}[+] Configuring firewall rules...${RESET}"
    ufw allow 22/tcp
    ufw allow 8888/tcp
    ufw --force enable
}

# === Run Wallet Generator ===
function run_wallet_generator() {
    cd wallet-gen || exit
    chmod +x wallet-generator.sh
    echo -e "${YELLOW}[+] Launching wallet-generator.sh...${RESET}"
    ./wallet-generator.sh
    cd ..
}

# === Main Menu ===
function main_menu() {
    while true; do
        show_header
        echo -e "${BLUE_LINE}"
        echo -e "${GREEN}1) Create Wallet${RESET}"
        echo -e "${GREEN}2) Exit${RESET}"
        echo -e "${BLUE_LINE}"
        echo -ne "\nChoose an option [1-2]: "
        read -r choice
        case $choice in
            1)
                install_dependencies
                install_bun_if_needed
                configure_firewall
                clone_wallet_repo
                run_wallet_generator
                read -n 1 -s -r -p "Press any key to return to menu..."
                ;;
            2)
                echo -e "${GREEN}Exiting...${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${RESET}"
                sleep 1
                ;;
        esac
    done
}

# === Script Execution ===
check_root
main_menu
