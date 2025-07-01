#!/bin/bash
#
# Bundle code to a distributable package (ready to be uploaded to Steam workshop)
# This will NOT upload to steam, so is useful for testing.

# Define "here" as the directory this script is in
HERE="$(realpath "$(dirname "$0")")"
# Load settings
source "$HERE/settings.sh"


if [ ! -e "$HERE/DESCRIPTION.bbcode" ]; then
	echo "ERROR: Please create a DESCRIPTION.bbcode with the contents of the mod description"
	exit 1
fi


# Set target directory for local testing
if [ -n "$MOD_VERSION" ]; then
	DIST="$HERE/dist/$MOD_NAME-$MOD_VERSION"
else
	DIST="$HERE/dist/$MOD_NAME-$(date +%Y%m%d.%H%M)"
fi
DEST="$DIST/Contents/mods"

# Ensure a clean working directory
if [ -n "$DIST" -a -d "$DIST" ]; then
	rm -rf "$DIST"
fi

# The mod contents is now contained inside DESCRIPTION
# it was getting too unwieldy to be in a simple variable.
# Run through sed to replace quotes with HTML quote characters, (since it is passed to a simple VDF file)
MOD_DESCRIPTION="$(cat "$HERE/DESCRIPTION.bbcode" | sed 's:":\&quot;:g')"


[ -d "$DEST" ] || mkdir -p "$DEST"

# Sync local mod code
rsync "$HERE/src/" "$DEST/" -r --delete

# Scan through the mod declarations for tiles and packs to deploy
find "$DEST" -name mod.info | while read INFO; do
	MOD="${INFO:${#DEST}+1:-9}"

	# Check if this mod is a B42 or above; it will contain the version suffix after a '/'
	PARTS=(${MOD//\// })
	if [ ${#PARTS[@]} -eq 2 ]; then
		MOD="${PARTS[0]}"
		VERSION="${PARTS[1]}"
	else
		# Mod infos not in a versioned directory are assumed to be B41
		VERSION="41"
	fi

	echo "Parsing tiles and packs for $MOD - B$VERSION"
	for PACK in `egrep '^pack=' "$INFO" | sed 's/^pack=//'`; do
		if [ -n "$PACK" ]; then
			if [ -e "$HERE/Packs/${PACK}_b${VERSION}.pack" ]; then
				# There is a version-specific pack; install that in the specific version only
				if [ "$VERSION" == "41" ]; then
					PACK_DEST="$DEST/$MOD/media/texturepacks"
				else
					PACK_DEST="$DEST/$MOD/$VERSION/media/texturepacks"
				fi

				echo "Deploying Packs/${PACK}_b${VERSION}.pack"
				[ -d "$PACK_DEST" ] || mkdir -p "$PACK_DEST"
				cp "$HERE/Packs/${PACK}_b${VERSION}.pack" "$PACK_DEST/${PACK}.pack"
			elif [ -e "$HERE/Packs/${PACK}.pack" ]; then
				# There is a common pack available
				if [ "$VERSION" == "41" ]; then
					PACK_DEST="$DEST/$MOD/media/texturepacks"
				else
					PACK_DEST="$DEST/$MOD/common/media/texturepacks"
				fi

				echo "Deploying Packs/${PACK}.pack"
				[ -d "$PACK_DEST" ] || mkdir -p "$PACK_DEST"
				cp "$HERE/Packs/${PACK}.pack" "$PACK_DEST/${PACK}.pack"
			else
				# No pack available, skip
				echo "WARNING: No pack found for $PACK in $HERE/Packs/"
			fi
		fi
	done

	for TILE in `egrep '^tiledef=' "$INFO" | sed 's/^tiledef=//' | sed 's: [0-9]*::'`; do
		if [ -n "$TILE" ]; then
			if [ -e "$HERE/Tiles/${TILE}_b${VERSION}.tiles" ]; then
				# There is a version-specific pack; install that in the specific version only
				if [ "$VERSION" == "41" ]; then
					TILE_DEST="$DEST/$MOD/media"
				else
					TILE_DEST="$DEST/$MOD/$VERSION/media"
				fi

				echo "Deploying Tiles/${TILE}_b${VERSION}.tiles"
				[ -d "$TILE_DEST" ] || mkdir -p "$TILE_DEST"
				cp "$HERE/Tiles/${TILE}_b${VERSION}.tiles" "$TILE_DEST/${TILE}.tiles"
			elif [ -e "$HERE/Tiles/${TILE}.tiles" ]; then
				# There is a common pack available
				if [ "$VERSION" == "41" ]; then
					TILE_DEST="$DEST/$MOD/media"
				else
					TILE_DEST="$DEST/$MOD/common/media"
				fi

				echo "Deploying Tiles/${TILE}.tiles"
				[ -d "$TILE_DEST" ] || mkdir -p "$TILE_DEST"
				cp "$HERE/Tiles/${TILE}.tiles" "$TILE_DEST/${TILE}.tiles"
			else
				# No pack available, skip
				echo "WARNING: No tile found for $TILE in $HERE/Tiles/"
			fi
		fi
	done
done


# Deploy Steam-specific content
cp "$HERE/src/preview.png" "$DIST/preview.png"

# Build the metadata VDF file, this is what steamcmd uses to know where everything is located
cat > "$DIST/metadata.vdf" << EOD
"workshopitem" {
  "appid" "108600"
  "publishedfileid" "$WORKSHOP_ID"
  "contentfolder" "$DIST/Contents"
  "previewfile" "$DIST/preview.png"
  "visibility" "0"
  "title" "$MOD_TITLE"
  "description" "$MOD_DESCRIPTION"
}
EOD

# Build a workshop.txt file for publishing mod tags
cat > "$DIST/workshop.txt" << EOD
version=1
title=$MOD_TITLE
tags=$MOD_TAGS
visibility=$MOD_VISIBILITY
EOD

if [ -n "$WORKSHOP_ID" -a "$WORKSHOP_ID" -ne 0 ]; then
	# If we have a workshop ID, add it to the workshop.txt file
	echo "id=$WORKSHOP_ID" >> "$DIST/workshop.txt"
fi

cat DESCRIPTION.bbcode | sed 's:^:description=:g' >> "$DIST/workshop.txt"


# Set the mod version inside the PZ mod files
# The user could manually set this within the files, but this allows
# them to set it once in settings.sh and have it applied automatically.
if [ -n "$MOD_VERSION" ]; then
	find "$DEST" -type f -name "mod.info" | while read FILE; do
		# Check if "modversion=" is already present in the file
		if grep -qi "modversion=" "$FILE"; then
			# If it is, replace it with the new version
			sed -i "s/modversion=.*/modversion=$MOD_VERSION/" "$FILE"
		else
			# If not, append it to the end of the file
			echo "" >> "$FILE"
			echo "modversion=$MOD_VERSION" >> "$FILE"
		fi
	done
fi

echo "Bundled mod in $DIST"
