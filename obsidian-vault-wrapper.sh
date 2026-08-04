#!/usr/bin/env bash

# 1. Path to your encrypted vault folder
# (e.g. "$HOME/.local/share/plasma-vault/ObsidianVault.enc")
VAULT_PATH="CHANGE ME"

# 2. Path where the decrypted vault is mounted
# (e.g. "$HOME/Vaults/ObsidianVault")
MOUNT_PATH="CHANGE ME"

# 3. Application command to run after mounting
# (e.g., "obsidian", "code", "vlc", "/path/to/appimage")
APP_COMMAND="obsidian"

# 4. Maximum time (in seconds) to wait for vault unlock prompt/mount
TIMEOUT_SECONDS=30

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [[ "$VAULT_PATH" == "CHANGE ME" || "$MOUNT_PATH" == "CHANGE ME" ]]; then
    echo -e "${RED}❌ Error: Please edit the script to set VAULT_PATH and MOUNT_PATH.${NC}"
    exit 1
fi

QDBUS_BIN=$(command -v qdbus-qt6 || command -v qdbus)
if [[ -z "$QDBUS_BIN" ]]; then
    echo -e "${RED}❌ Error: 'qdbus' tool missing. Ensure KDE Plasma tools are installed.${NC}"
    exit 1
fi

if ! command -v "$APP_COMMAND" &> /dev/null; then
    echo -e "${RED}❌ Error: Target application '$APP_COMMAND' not found in PATH.${NC}"
    exit 1
fi

cleanup() {
    echo -e "\n${YELLOW}🔒 Relocking Plasma Vault...${NC}"
    "$QDBUS_BIN" org.kde.kded6 /modules/plasmavault org.kde.plasmavault.closeVault "$VAULT_PATH" >/dev/null 2>&1
}
trap cleanup EXIT

if mountpoint -q "$MOUNT_PATH"; then
    echo -e "${GREEN}ℹ️ Vault is already mounted.${NC}"
else
    echo -e "${YELLOW}🔓 Requesting Vault unlock...${NC}"
    "$QDBUS_BIN" org.kde.kded6 /modules/plasmavault org.kde.plasmavault.openVault "$VAULT_PATH"

    echo "⏳ Waiting for Vault mount..."
    elapsed=0
    while ! mountpoint -q "$MOUNT_PATH"; do
        sleep 0.5
        elapsed=$((elapsed + 1))
        
        if [ $((elapsed / 2)) -ge "$TIMEOUT_SECONDS" ]; then
            echo -e "${RED}❌ Timeout: Vault failed to mount within ${TIMEOUT_SECONDS}s (Cancelled prompt?).${NC}"
            exit 1
        fi
    done
    echo -e "${GREEN}✅ Vault unlocked!${NC}"
fi

echo -e "${GREEN}🚀 Launching ${APP_COMMAND}...${NC}"
"$APP_COMMAND" "$@"
APP_EXIT_CODE=$?

exit $APP_EXIT_CODE
