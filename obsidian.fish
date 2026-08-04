function obsidian --description "Open KDE Plasma Vault, run Obsidian, and lock Vault on exit"
    # place this file in ~/.config/fish/functions/
    # replace "obsidian" above to change the alias
    # configuration
    set -l vault_path "CHANGE ME" # (e.g. "$HOME/.local/share/plasma-vault/ObsidianVault.enc")
    set -l mount_path "CHANGE ME" # (e.g. "$HOME/Vaults/ObsidianVault")
    set -l app_command "obsidian" # change to any app you'd like
    set -l timeout_seconds 30

    set -l red (set_color red)
    set -l green (set_color green)
    set -l yellow (set_color yellow)
    set -l reset (set_color normal)

    if test "$vault_path" = "CHANGE ME"; or test "$mount_path" = "CHANGE ME"
        echo "$red❌ Error: Please edit the function to set vault_path and mount_path.$reset"
        return 1
    end

    set -l qdbus_bin (command -v qdbus-qt6; or command -v qdbus)
    if test -z "$qdbus_bin"
        echo "$red❌ Error: 'qdbus' tool missing. Ensure KDE Plasma tools are installed.$reset"
        return 1
    end

    if not command -v "$app_command" >/dev/null 2>&1
        echo "$red❌ Error: Target application '$app_command' not found in PATH.$reset"
        return 1
    end

    if mountpoint -q "$mount_path"
        echo "$greenℹ️ Vault is already mounted.$reset"
    else
        echo "$yellow🔓 Requesting Vault unlock...$reset"
        $qdbus_bin org.kde.kded6 /modules/plasmavault org.kde.plasmavault.openVault "$vault_path"

        echo "⏳ Waiting for Vault mount..."
        set -l elapsed 0
        while not mountpoint -q "$mount_path"
            sleep 0.5
            set elapsed (math $elapsed + 1)

            if test (math -s0 $elapsed / 2) -ge $timeout_seconds
                echo "$red❌ Timeout: Vault failed to mount within {$timeout_seconds}s (Cancelled prompt?).$reset"
                return 1
            end
        end
        echo "$green✅ Vault unlocked!$reset"
    end

    echo "$green🚀 Launching $app_command...$reset"
    command $app_command $argv
    set -l app_exit_code $status

    echo -e "\n$yellow🔒 Relocking Plasma Vault...$reset"
    $qdbus_bin org.kde.kded6 /modules/plasmavault org.kde.plasmavault.closeVault "$vault_path" >/dev/null 2>&1

    return $app_exit_code
end
