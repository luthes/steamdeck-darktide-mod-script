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

# Check if the zip file exists
if [ -e "./Darktide-Mod-Loader.zip" ]; then
    # Get md5 hash of remote_version and local_version, proceed with download if they don't match
    remote_version=$(curl -sL https://github.com/Darktide-Mod-Framework/Darktide-Mod-Loader/releases/latest/download/Darktide-Mod-Loader.zip | md5sum)
    local_version=$(md5sum "./Darktide-Mod-Loader.zip" )

    echo $remote_version
    echo $local_version
    if [ "$remote_version" != "$local_version" ]; then
        # Remove previous version of the loader
        rm -rf "./Darktide-Mod-Loader.zip"
        # Download the latest version of Darktide Mod Loader directly from the github
        curl -LJOs https://github.com/Darktide-Mod-Framework/Darktide-Mod-Loader/releases/latest/download/Darktide-Mod-Loader.zip
        # This will update files and create non-existente ones, but not overwrite files that match existing ones
        unzip -uo "./Darktide-Mod-Loader.zip"
    fi
else
    # Download the latest version of Darktide Mod Loader directly from the github
    curl -LJOs https://github.com/Darktide-Mod-Framework/Darktide-Mod-Loader/releases/latest/download/Darktide-Mod-Loader.zip
    # This will update files and create non-existente ones, but not overwrite files that match existing ones
    unzip -uo "./Darktide-Mod-Loader.zip"
fi

# Restore mod_load_order backup
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
