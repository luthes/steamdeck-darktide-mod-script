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

# Check if the mod_load_order file exists, does backup before unziping the fresh files
if [ -f "./mods/mod_load_order.txt" ]; then
    mv ./mods/mod_load_order.txt ./mods/mod_load_order.txt.bk
fi

# Download the latest version of Darktide Mod Loader directly from the github
# Instead of removing the zip after extracting, wget will only download the zip again if it's different from current one
# This way we have a local copy just in case and don't have to download a new one each time
# (if the name of the zip changes in the future, something could be done to make it more dynamic, but won't bother with that for now)
wget -v -N https://github.com/Darktide-Mod-Framework/Darktide-Mod-Loader/releases/latest/download/Darktide-Mod-Loader.zip

# This will update files and create non-existente ones, but not overwrite files that match existing ones
unzip -uo "$GAME_DIR/Darktide-Mod-Loader.zip"

# This is kind of hacky, restore backed up mod_load_order file.
mv ./mods/mod_load_order.txt.bk ./mods/mod_load_order.txt

## Run Windows Exe in Proton Path

# Patch Darktide Database to Install Mods
# TODO: Not sure if this needs to run twice, but.. It doesn't take any time to run.
STEAM_COMPAT_DATA_PATH="$HOME/.local/share/Steam/steamapps/compatdata/$APP_ID" \
    STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam" \
    python "$HOME/.local/share/Steam/compatibilitytools.d/$PROTON_VERSION/proton" run ./tools/dtkit-patch.exe --unpatch ./bundle/ > /dev/null 2>&1
STEAM_COMPAT_DATA_PATH="$HOME/.local/share/Steam/steamapps/compatdata/$APP_ID" \
    STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam" \
    python "$HOME/.local/share/Steam/compatibilitytools.d/$PROTON_VERSION/proton" run ./tools/dtkit-patch.exe --patch ./bundle/ > /dev/null 2>&1

