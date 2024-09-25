#!/bin/bash
#
# Sort a render image into the appropriate directory and filename

if [ $# -lt 1 -o "$1" == '-h' -o "$1" == '-help' ]; then
	echo "Usage: $0 [variation] [tire count]"
	echo ""
	echo "Where [variation] is the color variation (unpainted, red, blue, etc)"
	echo "and [tire count] is the number of tires on the image"
	echo ""
	echo "If tire count is omitted, this script will count from 0 to 13 for bulk exporting a specific color."
	exit 1
fi

# Define "here" as the directory this script is in
HERE="$(realpath "$(dirname "$0")")"

function wait_render {
	echo "Please export tire rack with $2 tires..."
	while [ ! -e "$HERE/designs/render/sprite0012.png" ]; do
		sleep 1
	done
}

if [ $# -eq 1 ]; then
	for i in {0..13}; do
		wait_render "$1" "$i"
		$0 "$1" "$i"
	done

	"$HERE/montage.sh" "$1"
	exit
fi

if [ $2 -lt 10 -a "${2:0:1}" -ne "0" ]; then
	# Allow the dev to use a single digit for tire count
	TIRE_COUNT="0$2"
elif [ "$2" -eq "0" ]; then
	# zero is difficult because it itself starts with .... well '0'.
	TIRE_COUNT="00"
else
	TIRE_COUNT="$2"
fi

if [ ! -e "$HERE/designs/tiles/vn_tire_rack_$1" ]; then
	# Create the destination directory
	mkdir -p "$HERE/designs/tiles/vn_tire_rack_$1"
fi

# Move the image to the appropriate directory
mv "$HERE/designs/render/sprite0000.png" "$HERE/designs/tiles/vn_tire_rack_$1/tirerack_${TIRE_COUNT}_0.png"
mv "$HERE/designs/render/sprite0004.png" "$HERE/designs/tiles/vn_tire_rack_$1/tirerack_${TIRE_COUNT}_1.png"
mv "$HERE/designs/render/sprite0008.png" "$HERE/designs/tiles/vn_tire_rack_$1/tirerack_${TIRE_COUNT}_2.png"
mv "$HERE/designs/render/sprite0012.png" "$HERE/designs/tiles/vn_tire_rack_$1/tirerack_${TIRE_COUNT}_3.png"

echo "Stored $1 tire rack with $2 tires in designs/tiles/vn_tire_rack_$1"