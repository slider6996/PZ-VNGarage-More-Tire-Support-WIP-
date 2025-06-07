#!/bin/bash

# Define "here" as the directory this script is in
HERE="$(realpath "$(dirname "$0")")"
# Load settings
source "$HERE/settings.sh"

# The zomboid directory must exist within your home directory, (it gets autocreated when you launch the game)
if [ ! -d "$HOME/Zomboid" ]; then
	echo "ERROR: Zomboid directory not found at $HOME/Zomboid"
	echo "Have you ran the game yet?"
	exit 1
fi

if [ ! -e "$HOME/Zomboid/projectzomboid.sh.log" ]; then
	echo "ERROR: Zomboid log file not found at $HOME/Zomboid/projectzomboid.sh.log"
	echo "Have you ran the game yet?"
	exit 1
fi

# Detect the location of the game binary based on the execution log
P="$(egrep '^JVM' "$HOME/Zomboid/projectzomboid.sh.log")"
if [ -z "$P" ]; then
	echo "ERROR: Could not detect game binary location from $HOME/Zomboid/projectzomboid.sh.log"
	echo "Have you ran the game yet?"
	exit 1
fi
export PZ_DIR_PATH="$(echo "$P" | sed 's:JVM=\(.*\)/jre64/lib/server/libjvm.so:\1:')"

# Ensure all the necessary directories in the project exist
[ -d "$HERE/supplemental/Tiles" ] || mkdir -p "$HERE/supplemental/Tiles"
[ -d "$HERE/supplemental/Packs" ] || mkdir -p "$HERE/supplemental/Packs"
[ -d "$HERE/supplemental/BlenderResources" ] || mkdir -p "$HERE/supplemental/BlenderResources"

# Sync assets from the game installation
find "$PZ_DIR_PATH" -name '*.tiles' | while read TILE; do
	# Copy tiles to the local mod directory
	# This is useful for TileZed to be able to load the tilesets.
	cp "$TILE" "$HERE/supplemental/Tiles/"
done

find "$PZ_DIR_PATH/media/texturepacks" -name '*.pack' | while read PACK; do
	# Copy packs to the local mod directory
	# This is useful for TileZed to be able to load the packs.
	cp "$PACK" "$HERE/supplemental/Packs/"
done

# Sync local tilesets to working directory for TileZed
# These contain tilemaps for mod tiles
if [ -d "$HERE/designs/tilesets/" ]; then
	rsync "$HERE/designs/tilesets/" "$HERE/supplemental/Tiles/2x" -r
fi


# Install Tilezed as per official recommendations
# https://theindiestone.com/forums/index.php?/topic/59675-latest-tilezed-worlded-and-tilesets-september-8-2022/
if [ ! -d "$HERE/supplemental/TileZed" ]; then
	echo "Downloading official TileZed editor for Project Zomboid from Dropbox..."
	wget 'https://www.dropbox.com/s/29suz3a7lfgqwv1/TileZed%2BWorldEd-Sep-08-2022-Linux-64bit.zip?dl=1' -O '/tmp/pz-editor-2022.zip'
	unzip '/tmp/pz-editor-2022.zip' -d "$HERE/supplemental/"
fi

# Install pz-zdoc for documentation generation
if [ ! -d "$HERE/supplemental/pz-zdoc-3.1.0" ]; then
	wget 'https://github.com/cocolabs/pz-zdoc/releases/download/v3.1.0/pz-zdoc-3.1.0.tar' -O /tmp/pz-zdoc-3.1.0.tar
	tar -xf /tmp/pz-zdoc-3.1.0.tar -C "$HERE/supplemental/"

	# Patch the script to work with v41
	sed -i 's/JAVA_TARGET_VERSION="1.8"/JAVA_TARGET_VERSION="17.0"/g' "$HERE/supplemental/pz-zdoc-3.1.0/bin/pz-zdoc"
fi

# Download BlenderKit for goodies within Blender
if [ ! -e "$HERE/supplemental/BlenderResources/blenderkit-v3.16.0.250530.zip" ]; then
	wget https://github.com/BlenderKit/BlenderKit/releases/download/v3.16.0.250530/blenderkit-v3.16.0.250530.zip -O "$HERE/supplemental/BlenderResources/blenderkit-v3.16.0.250530.zip"
fi



# Generate game documentation via pz-zdoc
sh "$HERE/supplemental/pz-zdoc-3.1.0/bin/pz-zdoc" annotate -i "$PZ_DIR_PATH/media/lua" -o "$HERE/libs/media/lua"
sh "$HERE/supplemental/pz-zdoc-3.1.0/bin/pz-zdoc" compile -i "$PZ_DIR_PATH" -o "$HERE/libs/media/lua/shared/Library"
cd "$HERE/libs"
zip -r "PZ-Media-LUA.zip" "media"
cd -


echo ""
echo "Mod should be ready to be worked on!"
echo "Notes:"
echo " * image tilesets should be in designs/tilesets/,"
echo " * designs/tileset-template.svg is a template for new tilesets in Inkscape"
echo " * tiles editor is available in supplementals/TileZed/TileZed.sh"
echo " * PZ-ZDoc is available in supplemental/pz-zdoc-3.1.0/, refer to https://github.com/cocolabs/pz-zdoc for usage"
