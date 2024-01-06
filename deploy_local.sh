#!/bin/bash

DEST="/home/$(whoami)/Zomboid/mods/VNGarage"
HERE="$(dirname "$0")"

if [ ! -d "$DEST" ]; then
	mkdir -p "$DEST"
fi

# Sync local tilesets to working directory for TileZed
rsync "$HERE/designs/tilesets/" "$HERE/supplemental/Tiles/2x" -r

# Sync local mod code to local game for testing
rsync "$HERE/src/" "$DEST" -r --delete
cp "$HERE/supplemental/Tiles/vn_garage.tiles" "$DEST/media/vn_garage.tiles"
cp "$HERE/supplemental/Packs/vn_garage.pack" "$DEST/media/texturepacks/vn_garage.pack"
