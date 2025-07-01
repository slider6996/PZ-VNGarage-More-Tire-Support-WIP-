#!/bin/bash

# Define "here" as the directory this script is in
HERE="$(realpath "$(dirname "$0")")"
# Load settings
source "$HERE/settings.sh"
TEMP="$(mktemp -d)"

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
[ -d "$HERE/Tiles/2x" ] || mkdir -p "$HERE/Tiles/2x"
[ -d "$HERE/Packs" ] || mkdir -p "$HERE/Packs"
[ -d "$HERE/supplemental/BlenderResources" ] || mkdir -p "$HERE/supplemental/BlenderResources"

touch "$HERE/Tiles/.gitignore"
touch "$HERE/Packs/.gitignore"

# Sync assets from the game installation
echo '' > "$HERE/Tiles/.gitignore"
find "$PZ_DIR_PATH" -name '*.tiles' | while read TILE; do
	# Copy tiles to the local mod directory
	# This is useful for TileZed to be able to load the tilesets.
	cp "$TILE" "$HERE/Tiles/"
	echo "$(basename $TILE)" >> "$HERE/Tiles/.gitignore"
done

echo '' > "$HERE/Packs/.gitignore"
find "$PZ_DIR_PATH/media/texturepacks" -name '*.pack' | while read PACK; do
	# Copy packs to the local mod directory
	# This is useful for TileZed to be able to load the packs.
	cp "$PACK" "$HERE/Packs/"
	echo "$(basename $PACK)" >> "$HERE/Packs/.gitignore"
done


# Install Tilezed as per official recommendations
# https://theindiestone.com/forums/index.php?/topic/59675-latest-tilezed-worlded-and-tilesets-september-8-2022/
if [ ! -d "$HERE/supplemental/TileZed" ]; then
	echo "Downloading official TileZed editor for Project Zomboid from Dropbox..."
	wget 'https://www.dropbox.com/s/29suz3a7lfgqwv1/TileZed%2BWorldEd-Sep-08-2022-Linux-64bit.zip?dl=1' -O "$TEMP/pz-editor-2022.zip"
	unzip -o "$TEMP/pz-editor-2022.zip" -d "$HERE/supplemental/"

	# Download Unjammer's version of WorldZed to extract out tile definitions and tile images.
    wget 'https://github.com/Unjammer/WorldEd/releases/download/20250403/B42.Mapping.Tools.zip' -O "$TEMP/map-tools.zip"

    # Extract the spritemaps that are contained,
    # but we only want sprites specifically in the 2x directory.
    # (because this archive includes a few directories)
    mkdir "$TEMP/sprites"
    unzip "$TEMP/map-tools.zip" -d "$TEMP/sprites" 'Tiles/2x/*.png'
    echo '' > "$HERE/Tiles/2x/.gitignore"
    ls -1 "$TEMP/sprites/Tiles/2x/" | while read SPRITE; do
    	cp "$TEMP/sprites/Tiles/2x/$SPRITE" "$HERE/Tiles/2x/"
    	echo "$SPRITE" >> "$HERE/Tiles/2x/.gitignore"
    done

    # Extract updated definitions for TileZed
    unzip -jo "$TEMP/map-tools.zip" -d "$HERE/supplemental/TileZed/share/tilezed/config/" TileD/Tilesets.txt
    unzip -jo "$TEMP/map-tools.zip" -d "$HERE/supplemental/TileZed/share/tilezed/config/" TileD/Rearrange.txt
    if [ -e "$HOME/.TileZed/" ]; then
    	cp "$HERE/supplemental/TileZed/share/tilezed/config/Tilesets.txt" "$HOME/.TileZed/Tilesets.txt"
    	cp "$HERE/supplemental/TileZed/share/tilezed/config/Rearrange.txt" "$HOME/.TileZed/Rearrange.txt"
    fi
fi


# Install updated definitions from TimBaker
wget "https://raw.githubusercontent.com/timbaker/tiled/refs/heads/basements/TileProperties.txt" -O "$HERE/supplemental/TileZed/share/tilezed/config/TileProperties.txt"
if [ -e "$HOME/.TileZed/" ]; then
	cp "$HERE/supplemental/TileZed/share/tilezed/config/TileProperties.txt" "$HOME/.TileZed/TileProperties.txt"
fi


# Install pz-zdoc for documentation generation
if [ ! -d "$HERE/supplemental/pz-zdoc-3.1.0" ]; then
	wget 'https://github.com/cocolabs/pz-zdoc/releases/download/v3.1.0/pz-zdoc-3.1.0.tar' -O $TEMP/pz-zdoc-3.1.0.tar
	tar -xf $TEMP/pz-zdoc-3.1.0.tar -C "$HERE/supplemental/"

	# Patch the script to work with v41
	sed -i 's/JAVA_TARGET_VERSION="1.8"/JAVA_TARGET_VERSION="17.0"/g' "$HERE/supplemental/pz-zdoc-3.1.0/bin/pz-zdoc"
fi

# Download BlenderKit for goodies within Blender
if [ ! -e "$HERE/supplemental/BlenderResources/blenderkit-v3.16.0.250530.zip" ]; then
	wget https://github.com/BlenderKit/BlenderKit/releases/download/v3.16.0.250530/blenderkit-v3.16.0.250530.zip -O "$HERE/supplemental/BlenderResources/blenderkit-v3.16.0.250530.zip"
fi

# Download Blender io_import_x
if [ ! -e "$HERE/supplemental/BlenderResources/io_import_x-master.zip" ]; then
	wget https://github.com/Poikilos/io_import_x/archive/refs/heads/master.zip -O "$HERE/supplemental/BlenderResources/io_import_x-master.zip"
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
echo " * image tilesets should be in Tiles/,"
echo " * designs/tileset-template.svg is a template for new tilesets in Inkscape"
echo " * tiles editor is available in supplementals/TileZed/TileZed.sh"
echo " * PZ-ZDoc is available in supplemental/pz-zdoc-3.1.0/, refer to https://github.com/cocolabs/pz-zdoc for usage"
