#!/bin/bash
set -e

# === Basic Configuration ===
LOG_DIR="/root/nexus_logs"

# === Terminal Colors ===
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# === Header Display ===
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
    echo -e "🚀 \e[1;33mNexus Node Installer\e[0m - Powered by \e[1;33mGoldVPS Team\e[0m 🚀"
    echo -e "🌐 \e[4;33mhttps://goldvps.net\e[0m - Best VPS with Low Price"
    echo ""
}

# === Cek Root ===
function check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Harus dijalankan sebagai root!${RESET}"
        exit 1
    fi
}

# === Install dependensi dasar ===
function install_deps() {
    echo -e "${YELLOW}[+] Memasang dependensi dasar...${RESET}"
    apt update && apt install -y git curl unzip ufw
}

# === Cek dan Install Bun ===
function check_and_install_bun() {
    if ! command -v bun &> /dev/null; then
        echo -e "${RED}[!] Bun tidak ditemukan.${RESET}"
        echo -e "${YELLOW}[+] Mulai install Bun...${RESET}"

        # Pastikan unzip terinstall
        if ! command -v unzip &> /dev/null; then
            echo -e "${YELLOW}[+] unzip belum ada, memasang unzip...${RESET}"
            apt install -y unzip
        fi

        curl -fsSL https://bun.sh/install | bash
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        echo -e "${GREEN}[✓] Bun berhasil diinstal.${RESET}"
    else
        echo -e "${GREEN}[✓] Bun sudah terinstal.${RESET}"
    fi
}

# === Clone wallet-gen ===
function clone_repo() {
    if [ -d "wallet-gen" ]; then
        echo -e "${YELLOW}[!] Direktori wallet-gen sudah ada.${RESET}"
    else
        echo -e "${YELLOW}[+] Meng-clone repo wallet-gen...${RESET}"
        git clone https://github.com/octra-labs/wallet-gen.git
    fi
}

# === Setup Firewall ===
function setup_firewall() {
    echo -e "${YELLOW}[+] Mengatur firewall...${RESET}"
    ufw allow 22/tcp
    ufw allow 8888/tcp
    ufw --force enable
}

# === Jalankan wallet-generator.sh ===
function create_wallet() {
    cd wallet-gen || exit
    chmod +x wallet-generator.sh
    ./wallet-generator.sh
    cd ..
}

# === Menu Utama ===
function main_menu() {
    while true; do
        show_header
        echo -e "${YELLOW}1) Create Wallet${RESET}"
        echo -e "${YELLOW}2) Exit${RESET}"
        echo -ne "\nPilih opsi [1-2]: "
        read -r choice
        case $choice in
            1)
                create_wallet
                read -n 1 -s -r -p "Tekan tombol apapun untuk kembali ke menu..."
                ;;
            2)
                echo -e "${GREEN}Keluar...${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}Pilihan tidak valid!${RESET}"
                sleep 1
                ;;
        esac
    done
}

# === Eksekusi Awal ===
check_root
install_deps
check_and_install_bun
clone_repo
setup_firewall
main_menu
