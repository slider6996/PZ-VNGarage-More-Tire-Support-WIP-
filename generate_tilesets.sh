#!/bin/bash
#
# Generate a spritemap of all tiles

# Define "here" as the directory this script is in
HERE="$(realpath "$(dirname "$0")")"
# Load settings
source "$HERE/settings.sh"

# Ensure necessary directories exist
[ -d "$HERE/Tiles/2x" ] || mkdir -p "$HERE/Tiles/2x"

if [ ! -d "$HERE/Tiles/singles" ]; then
	echo "No single tiles found in Tiles/singles"
else
	cd "$HERE/Tiles"
    ls -1 singles | while read DIR; do
    	if [ -d "singles/$DIR" ]; then
    		# @todo Support tiles other than 128x256

    		# Zomboid requires all tilemaps to be lowercase with no spacing
    		OUT="$(echo $DIR | sed 's: :_:g' | tr '[:upper:]' '[:lower:]')"

    		# Generate a 1024x2048 tilemap based off the sprites in this directory.
    		montage singles/$DIR/*.png -tile 8x8 -geometry 128x256 -background transparent 2x/$OUT.png

            echo "Generated spritemap for $OUT"
    	fi
    done
    cd -
fi

# Install all pack tilesets
if [ -n "$PACK_SOURCES" ]; then
	for PACK in $PACK_SOURCES; do
		# Split tile line by a colon for mod:tile file
		PARTS=(${PACK//:/ })

		[ -d "$HERE/Packs/${PARTS[1]}" ] || mkdir -p "$HERE/Packs/${PARTS[1]}"
		# Normal behaviour; SOURCE:DEST
		cp "$HERE/Tiles/2x/${PARTS[0]}.png" "$HERE/Packs/${PARTS[1]}/"
	done
fi


