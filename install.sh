#!/bin/bash

# Define current version and install path
VERSION="2.0"
CICD_SCRIPT="$HOME/bin/cicd-bootstrap.sh"
BACKUP_DIR="$HOME/bin/backup"
CURRENT_VERSION=$(get_installed_version)

# Function to get the current version of the installed script
get_installed_version() {
  if [ -f "$CICD_SCRIPT" ]; then
    # Extract the version from the installed script (assumes version is declared in the first line as VERSION=x.y.z)
    CURRENT_VERSION=$(head -n 1 "$CICD_SCRIPT" | grep -oP '(?<=VERSION=)[^\s]*')
    echo "$CURRENT_VERSION"
  else
    echo "none"  # If the script doesn't exist yet, return "none"
  fi
}

# Function to create a backup of the current script before overwriting
backup_script() {
  if [ -f "$CICD_SCRIPT" ]; then
    echo "[INFO] Backing up the current cicd-bootstrap.sh to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    cp "$CICD_SCRIPT" "$BACKUP_DIR/cicd-bootstrap.sh.bak"
  fi
}

# Display information about version
echo "[INFO] Installing cicd-bootstrap.sh version $VERSION to ~/bin..."

# Check if the current installed version is different from the new one
if [ "$CURRENT_VERSION" != "$VERSION" ]; then
    echo "[INFO] Current installed version: $CURRENT_VERSION"
    echo "[INFO] A new version ($VERSION) is available."
    read -p "Do you want to upgrade? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        backup_script
        cp cicd-bootstrap.sh "$CICD_SCRIPT"
        chmod +x "$CICD_SCRIPT"
        echo "[INFO] Upgraded cicd-bootstrap.sh to version $VERSION."
    else
        echo "[INFO] Skipping upgrade."
        exit 0
    fi
else
    echo "[INFO] The latest version ($VERSION) is already installed."
fi

# Create the ~/bin directory if it doesn't exist
mkdir -p "$HOME/bin"

# Check if the file exists, if not, copy the new one
if [ ! -f "$CICD_SCRIPT" ]; then
    cp cicd-bootstrap.sh "$CICD_SCRIPT"
    chmod +x "$CICD_SCRIPT"
    echo "[INFO] Installed cicd-bootstrap.sh successfully."
else
    echo "[INFO] cicd-bootstrap.sh already exists. Skipping installation."
fi

# Detect which shell the user is using and update the corresponding profile file
SHELL_TYPE=$(basename "$SHELL")
case "$SHELL_TYPE" in
  bash)
    PROFILE_FILE="$HOME/.bashrc"
    ;;
  zsh)
    PROFILE_FILE="$HOME/.zshrc"
    ;;
  fish)
    PROFILE_FILE="$HOME/.config/fish/config.fish"
    ;;
  *)
    PROFILE_FILE="$HOME/.bashrc"  # Default to bash if we can't detect shell
    ;;
esac

# Add the PATH if not already present
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$PROFILE_FILE"; then
  echo 'export PATH="$HOME/bin:$PATH"' >> "$PROFILE_FILE"
  echo "[INFO] Added ~/bin to PATH in $PROFILE_FILE"
fi

# Add the alias if not already present
if ! grep -q 'alias cicd=' "$PROFILE_FILE"; then
  echo 'alias cicd="cicd-bootstrap.sh"' >> "$PROFILE_FILE"
  echo "[INFO] Added alias 'cicd' to $PROFILE_FILE"
fi

# Final instructions for the user
echo "[SUCCESS] Installed cicd-bootstrap.sh version $VERSION."
echo "[INFO] Run 'source $PROFILE_FILE' to apply changes."
echo "[INFO] Use 'cicd' to run the script."

