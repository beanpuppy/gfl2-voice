#!/bin/bash

# GFL2 Voice Export Script
# Exports voice lines from game files using vgmstream-cli

BASE_SOURCE="/home/justin/Games/girls-frontline-2-exilium/drive_c/Program Files/bilibili Game/GF2_Exilium/Games/GF2_Exilium_Data/LocalCache/Data/AssetBundles_Windows/Assets/ArtsResource/Audio/CriWare"

OUTPUT_DIR="$(pwd)"
VGMSTREAM="./vgmstream-cli"

if [ ! -f "$VGMSTREAM" ]; then
    echo "Error: vgmstream-cli not found in current directory"
    exit 1
fi

extract_audio() {
    local lang_suffix="$1"
    local source_dir="$BASE_SOURCE/$lang_suffix"

    if [ ! -d "$source_dir" ]; then
        echo "Error: $source_dir not found"
        return
    fi

    find "$source_dir" -name "*.awb" | grep -v -E "VO_Chapter|VO_Lobby" | while read -r awb_file; do
        basename_no_ext=$(basename "$awb_file" .awb)

        output_subdir="$OUTPUT_DIR/$lang_suffix/$basename_no_ext"
        mkdir -p "$output_subdir"

        # Extract audio files using vgmstream-cli (suppress output)
        # The -S option extracts subsongs, -o specifies output pattern
        "$VGMSTREAM" -o "$output_subdir/${basename_no_ext}_?n.wav" -S 0 "$awb_file" > /dev/null 2>&1

        # Rename files to remove semicolons and spaces
        find "$output_subdir" -type f -name "*.wav" | while read -r file; do
            newname=$(echo "$file" | sed 's/;/_/g' | sed 's/ /_/g')
            if [ "$file" != "$newname" ]; then
                mv "$file" "$newname"
            fi
        done
    done
}

extract_audio "JP"
extract_audio "CN"
