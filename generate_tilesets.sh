#!/bin/bash
#
# Generate a spritemap of all tiles

# Define "here" as the directory this script is in
HERE="$(realpath "$(dirname "$0")")"

if [ ! -d "$HERE/designs/Tiles/singles" ]; then
	echo "ERROR - Unable to locate designs/Tiles/singles directory"
	exit 1
fi

# Ensure necessary directorys exist
[ -d "$HERE/designs/Tiles/2x" ] || mkdir -p "$HERE/designs/Tiles/2x"

cd "$HERE/designs/Tiles"
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


