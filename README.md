🚀 Octra Testnet Installer - GoldVPS Edition

An automatic installer for running the Octra Testnet wallet generator and multi-send bot,
designed to be beginner-friendly — even for those with no coding knowledge.

------------------------------------------------------------

✨ Key Features

✅ Auto-installs all dependencies (curl, git, bun, Python, etc.)
🔐 Secure & private — no private key is saved anywhere
🧠 Multi Wallet Support — each wallet runs in a separate folder and screen session, no overwriting
🌐 Web-based Wallet Generator via browser
📟 Log Viewer from menu
📦 No manual setup needed — just run curl and go

------------------------------------------------------------

🚀 How to Use

Run the following commands on Ubuntu 20.04 / 22.04 VPS:

curl -O https://raw.githubusercontent.com/GoldVPS/octra-testnet/main/octra-auto.sh
chmod +x octra-auto.sh
./octra-auto.sh

------------------------------------------------------------

🧩 Available Menu

1. Create Wallet
   Launches the web-based wallet generator. Once running, you can open in browser:
   http://YOUR-IP:8888

2. Multi Send (can add more wallets)
   You can add multiple wallets to send TXs.
   Each wallet:
   - Stored in a different folder
   - Runs in its own screen session (screen -r octra-wallet_name)

3. View Logs
   View live TX log output per wallet.

4. Exit

------------------------------------------------------------

🔗 Official Octra Guide

[GENERATE WALLET](https://github.com/octra-labs/wallet-gen)
[MULTISEND](https://github.com/octra-labs/octra_pre_client)

------------------------------------------------------------

🛡️ Security

- Does not save wallet.json to cloud or GitHub
- All processes are local on your VPS
- Open-source, all code is auditable

------------------------------------------------------------

🌐 Credit

Script built and customized by the GoldVPS Team
Website : https://goldvps.net
Telegram: @miftaikyy

------------------------------------------------------------

❤️ License

MIT — GoldVPS Team
