#!/bin/bash

# Variables
GAME_DIR="$HOME/.local/share/Steam/steamapps/common/Warhammer 40,000 DARKTIDE"
APP_ID=1361210
PROTON_VERSION=$(cat "$HOME/.local/share/Steam/steamapps/compatdata/$APP_ID/version")

if [ ! -d "$GAME_DIR" ]; then
    printf "Game Directory:\n %s \n\t does not exist? Is the game installed?\n" "$GAME_DIR"
    exit 1
else
    cd "$GAME_DIR" || exit 1
fi

curl -O https://cdn.discordapp.com/attachments/1048312484227973120/1079276466610634822/Darktide-Mod-Loader.zip -v || exit 1
unzip -Bo "$GAME_DIR/Darktide-Mod-Loader.zip"

# This is kind of hacky, restore backed up mod_load_order file.
mv ./tools/mod_load_order.txt.bak ./tools/mod_load_order.txt

rm -rf "$GAME_DIR/modloader.zip"

## Run Windows Exe in Proton Path

# Patch Darktide Database to Install Mods
# TODO: Not sure if this needs to run twice, but.. It doesn't take any time to run.
STEAM_COMPAT_DATA_PATH="$HOME/.local/share/Steam/steamapps/compatdata/$APP_ID" \
    STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam" \
    python "$HOME/.local/share/Steam/compatibilitytools.d/$PROTON_VERSION/proton" run ./tools/dtkit-patch.exe --unpatch ./bundle/ > /dev/null 2>&1
STEAM_COMPAT_DATA_PATH="$HOME/.local/share/Steam/steamapps/compatdata/$APP_ID" \
    STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam" \
    python "$HOME/.local/share/Steam/compatibilitytools.d/$PROTON_VERSION/proton" run ./tools/dtkit-patch.exe --patch ./bundle/ > /dev/null 2>&1
