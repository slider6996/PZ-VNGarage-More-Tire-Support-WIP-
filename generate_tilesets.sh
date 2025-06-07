#!/bin/bash
#
# Generate a spritemap of all tiles

# Define "here" as the directory this script is in
HERE="$(realpath "$(dirname "$0")")"

if [ ! -d "$HERE/designs/tiles" ]; then
	echo "ERROR - Unable to locate designs/tiles directory"
	exit 1
fi

# Ensure necessary directorys exist
[ -d "$HERE/supplemental/Tiles/2x" ] || mkdir -p "$HERE/supplemental/Tiles/2x"
[ -d "$HERE/designs/tilesets" ] || mkdir -p "$HERE/designs/tilesets"

cd "$HERE"
ls -1 designs/tiles | while read DIR; do
	if [ -d "designs/tiles/$DIR" ]; then
		# @todo Support tiles other than 128x256

		# Zomboid requires all tilemaps to be lowercase with no spacing
		OUT="$(echo $DIR | sed 's: :_:g' | tr '[:upper:]' '[:lower:]')"

		# Generate a 1024x2048 tilemap based off the sprites in this directory.
		montage designs/tiles/$DIR/*.png -tile 8x8 -geometry 128x256 -background transparent designs/tilesets/$OUT.png
        cp designs/tilesets/$OUT.png supplemental/Tiles/2x/$OUT.png

        echo "Generated spritemap for $OUT"
	fi
done
cd -


