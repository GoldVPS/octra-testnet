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
    echo -e "${YELLOW}[+] Installing base dependency: curl and git...${RESET}"
    apt update && apt install -y curl git
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
    ./wallet-generator.sh &
    sleep 3  # kasih delay agar proses background sempat jalan

    ip=$(curl -s ipv4.icanhazip.com)
    echo -e "${GREEN}[✓] Wallet Generator is running!${RESET}"
    echo -e "${CYAN}🔗 Open your browser: http://$ip:8888${RESET}"
    echo ""
    cd ..
}

# === get_next_screen_name ===
function get_next_screen_name() {
    base="octra-multi"
    counter=1
    while screen -list | grep -q "${base}${counter}"; do
        counter=$((counter + 1))
    done
    echo "${base}${counter}"
}

# === Run MultiSend (Add Wallet) ===
function run_multisend() {
    echo -ne "${CYAN}Enter wallet name (e.g. mywallet1): ${RESET}"
    read -r name
    screen_name="octra-${name}"

    if [ ! -d "octra_pre_client" ]; then
        echo -e "${YELLOW}[+] Cloning octra_pre_client...${RESET}"
        git clone https://github.com/octra-labs/octra_pre_client.git
    fi

    cd octra_pre_client || exit

    if [ ! -d "venv" ]; then
        echo -e "${YELLOW}[+] Installing Python & dependencies...${RESET}"
        apt install -y python3 python3-venv python3-pip screen

        echo -e "${YELLOW}[+] Setting up Python virtual environment...${RESET}"
        python3 -m venv venv
        source venv/bin/activate

        echo -e "${YELLOW}[+] Installing Python requirements...${RESET}"
        pip install -r requirements.txt
        deactivate
    fi

    echo ""
    echo -ne "${CYAN}Enter your private key: ${RESET}"
    read -r priv_key
    echo -ne "${CYAN}Enter your Octra address: ${RESET}"
    read -r octra_addr

    cat > wallet.json <<EOF
{
  "priv": "$priv_key",
  "addr": "$octra_addr",
  "rpc": "https://octra.network"
}
EOF

    echo -e "${GREEN}[✓] wallet.json created successfully.${RESET}"
    chmod +x run.sh

    echo -e "${YELLOW}[+] Starting run.sh in screen session '${screen_name}'...${RESET}"
    screen -dmS "$screen_name" bash -c "source venv/bin/activate && ./run.sh"

    cd ..
    echo -e "${GREEN}[✓] Multi Send is running in screen: ${CYAN}$screen_name${RESET}"
    echo -e "${CYAN}To view it: ${YELLOW}screen -r $screen_name${RESET}"
    echo ""
    read -n 1 -s -r -p "Press any key to return to menu..."
}

# === View Logs (Attach to screen) ===
function view_multisend_logs() {
    echo -e "${YELLOW}[+] Searching for active Multi Send screens...${RESET}"

    # Ambil list screen yang cocok dengan prefix octra-
    mapfile -t screen_list < <(screen -ls | grep -o "octra-[^[:space:]]*" || true)

    if [ ${#screen_list[@]} -eq 0 ]; then
        echo -e "${RED}No active Multi Send screens found.${RESET}"
        read -n 1 -s -r -p "Press any key to return to menu..."
        return
    fi

    echo -e "${BLUE_LINE}"
    for i in "${!screen_list[@]}"; do
        index=$((i + 1))
        echo -e "${GREEN}${index}) ${screen_list[$i]}${RESET}"
    done
    echo -e "${GREEN}$(( ${#screen_list[@]} + 1 ))) Cancel${RESET}"
    echo -e "${BLUE_LINE}"

    echo -ne "\nChoose a screen to attach [1-${#screen_list[@]}]: "
    read -r choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#screen_list[@]}" ]; then
        screen -r "${screen_list[$((choice - 1))]}"
    else
        echo -e "${YELLOW}Cancelled or invalid option.${RESET}"
        sleep 1
    fi
}

# === Main Menu ===
function main_menu() {
    while true; do
        show_header
        echo -e "${BLUE_LINE}"
        echo -e "${GREEN}1) Create Wallet${RESET}"
        echo -e "${GREEN}2) Multi Send (can add more wallets)${RESET}"
        echo -e "${GREEN}3) View Logs${RESET}"
        echo -e "${GREEN}4) Exit${RESET}"
        echo -e "${BLUE_LINE}"
        echo -ne "\nChoose an option [1-4]: "
        read -r choice
        case $choice in
            1)
                install_wallet_requirements
                install_bun_if_needed
                configure_firewall
                clone_wallet_repo
                run_wallet_generator
                read -n 1 -s -r -p "Press any key to return to menu..."
                ;;
            2)
                run_multisend
                ;;
            3)
                view_multisend_logs
                ;;
            4)
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

# === Execute ===
check_root
main_menu
