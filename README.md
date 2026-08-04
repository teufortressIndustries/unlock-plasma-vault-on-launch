# unlock-plasma-vault-on-launch
A simple KDE Plasma Vault wrapper that prompts you to unlock the vault before launching an application, and locks it once the application closes.

# How do I use this?

## Part 1: Setting Up and Using the Script

### 1. Edit the Script Variables

Open the script (obsidian-vault-wrapper.sh) in a text editor and replace the placeholder values at the top:

* **`VAULT_PATH`**: The path to your encrypted folder (usually in `~/.local/share/plasma-vault/`).
* **`MOUNT_PATH`**: The path where the folder appears when unlocked (e.g., `~/Vaults/Obsidian`).
* **`APP_COMMAND`**: The command or AppImage path used to launch your app (e.g., `obsidian`).

### 2. Save and Make It Executable

1. Save the file to a folder like `~/.local/bin/` or your home directory as `launch-vault-app.sh`.
2. Make it executable via your terminal:
```bash
chmod +x /path/to/launch-vault-app.sh

```



---

## Part 2: How to Make a `.desktop` Launcher

A `.desktop` file lets you launch this script from your application menu or place an icon on your desktop.

1. **Create the launcher file (or edit an existing one at `~/.local/share/applications/`):**
Create a new file in `~/.local/share/applications/` named `obsidian-vault.desktop`. You can do this with your text editor or via terminal:

```bash
nano ~/.local/share/applications/obsidian-vault.desktop

```


2. **Add the configuration text:**
Paste the following content into the file. Be sure to update **`Exec`** and **`Path`** to match the real location where you saved your script in Part 1.

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=Obsidian (Secure Vault)
Comment=Mounts Plasma Vault, runs Obsidian, and relocks on exit
Exec=/home/YOUR_USERNAME/.local/bin/launch-vault-app.sh
Path=/home/YOUR_USERNAME/.local/bin/
Icon=obsidian
Terminal=false
Categories=Utility;Office;

```

> **Note:** Replace `/home/YOUR_USERNAME/` with your actual full home directory path. Avoid using `~` inside `.desktop` files as some desktop environments won't resolve it properly.


3. **Make the launcher executable:**
Make the desktop entry executable so KDE Plasma allows running it:

```bash
chmod +x ~/.local/share/applications/obsidian-vault.desktop

```


---

## How it works once ready

1. Launch **Obsidian (Secure Vault)** from your application menu or desktop shortcut.
2. KDE Plasma will ask for your **Vault password**.
3. Once unlocked, the script launches Obsidian.
4. When you close Obsidian, the script's `cleanup` routine automatically runs and **locks the Plasma Vault**.
