#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
GAME_DIR="./inevit"
LOVEDOS_RELEASE_URL="https://github.com/SuperIlu/lovedos/releases/download/v0.42.23.2/lovedos-0.42.23.2.zip"

echo "=== Inevitabilitas Install Script ==="
echo "This script will install and use next third party software:"
echo "a package manager, one of: apt, pacman, dnf OR zypper"
echo "MS-DOS emulator: DOSBox"
echo "File management: curl AND unzip"
echo "The script will download, unzip, copy and delete lovedos.zip from github setting up neccessary dependencies for the game to work. Create .config files for start.sh to work."

read -p "Do you want to continue to the installation? [Y/n]" confirm
if [[ "$confirm" == "N" || "$confirm" == "n" ]]; then
  echo "Aborted. Read README.md for manual setup instructions."
  exit 0
fi

# Detect package manager
if command -v apt &> /dev/null; then
  INSTALL_CMD="sudo apt install -y"
elif command -v pacman &> /dev/null; then
  INSTALL_CMD="sudo pacman -S --noconfirm"
elif command -v dnf &> /dev/null; then
  INSTALL_CMD="sudo dnf install -y"
elif command -v zypper &> /dev/null; then
  INSTALL_CMD="sudo zypper install -y"
else
  echo "ERROR: No supported package manager found. Read README.md for manual setup instructions."
  exit 1
fi

# Check and install DOSBox
if command -v dosbox &> /dev/null; then
  DOSBOX_BIN="$(which dosbox)"
  echo "DOSBox found at $DOSBOX_BIN"
else
  echo "DOSBox not found. Installing..."
  $INSTALL_CMD dosbox
  DOSBOX_BIN="$(which dosbox)"
  echo "DOSBox installed at $DOSBOX_BIN"
fi

# Check and install curl and unzip
if ! command -v curl &> /dev/null; then
  echo "curl not found. Installing..."
  $INSTALL_CMD curl
fi

if ! command -v unzip &> /dev/null; then
  echo "unzip not found. Installing..."
  $INSTALL_CMD unzip
fi

# Download lovedos release

if [ -f "$GAME_DIR/love.exe" ]; then
  echo "lovedos already found in inevit/, skipping download."
else
  echo "Downloading lovedos release..."
  curl -L "$LOVEDOS_RELEASE_URL" -o "$GAME_DIR/lovedos.zip"
  unzip "$GAME_DIR/lovedos.zip" -d "$GAME_DIR"
  rm "$GAME_DIR/lovedos.zip"
  echo "lovedos downloaded and extracted."
fi

# Write config
echo "Writing .config"
cat > "$GAME_DIR/.config" << EOF
LOVEDOS_DIR=$SCRIPT_DIR/inevit
EOF

echo ""
echo "=== Install complete ==="
echo "Run scripts/start.sh to launch the game."