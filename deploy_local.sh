#!/bin/bash
#
# Deploy code to local game (useful for testing)

# Define "here" as the directory this script is in
HERE="$(realpath "$(dirname "$0")")"
# Load settings
source "$HERE/settings.sh"

# Set target directory for local testing
DEST="$HOME/Zomboid/mods/$MOD_NAME"

if [ ! -d "$DEST" ]; then
	mkdir -p "$DEST"
fi

# Sync local tilesets to working directory for TileZed
rsync "$HERE/designs/tilesets/" "$HERE/supplemental/Tiles/2x" -r

# Sync local mod code to local game for testing
rsync "$HERE/src/" "$DEST" -r --delete

# Install any tiles (if present)
if [ -n "$TILES" ]; then
	for TILE in $TILES; do
		cp "$HERE/supplemental/Tiles/$TILE" "$DEST/media/$TILE"
	done
fi

# Install any packs (if present)
if [ -n "$PACKS" ]; then
	for PACK in $PACKS; do
		cp "$HERE/supplemental/Packs/$PACK" "$DEST/media/texturepacks/$PACK"
	done
fi
