#!/bin/bash
#
# Generate a spritemap of the selected sprites

if [ $# -lt 1 -o "$1" == '-h' -o "$1" == '-help' ]; then
	echo "Usage: $0 [variation]"
	echo ""
	echo "Where [variation] is the color variation (unpainted, red, blue, etc)"
	exit 1
fi

# Define "here" as the directory this script is in
HERE="$(realpath "$(dirname "$0")")"

if [ ! -e "$HERE/designs/tiles/vn_tire_rack_$1" ]; then
	echo "ERROR - Unable to locate $1 sprites within design/tiles"
	exit 1
fi

cd "$HERE"
montage designs/tiles/vn_tire_rack_${1}/tirerack_*.png -tile 8x8 -geometry 128x256 -background transparent designs/tilesets/vn_tire_rack_${1}.png
cp designs/tilesets/vn_tire_rack_${1}.png supplemental/Tiles/2x/vn_tire_rack_${1}.png
cd -

echo "Generated spritemap for $1 tire rack"
