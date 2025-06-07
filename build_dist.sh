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

# Install any tiles (if present)
if [ -n "$TILES" ]; then
	for TILE in $TILES; do
		# Split tile line by a colon for mod:tile file
		PARTS=(${TILE//:/ })

		[ -d "$DEST/${PARTS[1]}/media" ] || mkdir -p "$DEST/${PARTS[1]}/media"
		if [ ${#PARTS[@]} -eq 3 ]; then
			# Allow the user to define SOURCE:DEST:NEW_FILENAME
			# Allows the dev to specify a different filename for the source vs destination,
			# useful when having multiple tiles for different versions of the game which should
			# all get generated to the same base filename inside the respective versions.
			cp "$HERE/supplemental/Tiles/${PARTS[0]}" "$DEST/${PARTS[1]}/media/${PARTS[2]}"
		else
			# Normal behaviour; SOURCE:DEST
			cp "$HERE/supplemental/Tiles/${PARTS[0]}" "$DEST/${PARTS[1]}/media/${PARTS[0]}"
		fi

	done
fi

# Install any packs (if present)
if [ -n "$PACKS" ]; then
	for PACK in $PACKS; do
		# Split tile line by a colon for mod:tile file
		PARTS=(${PACK//:/ })

		[ -d "$DEST/${PARTS[1]}/media/texturepacks" ] || mkdir -p "$DEST/${PARTS[1]}/media/texturepacks"
		if [ ${#PARTS[@]} -eq 3 ]; then
			# Allow the user to define SOURCE:DEST:NEW_FILENAME
			# Allows the dev to specify a different filename for the source vs destination,
			# useful when having multiple tiles for different versions of the game which should
			# all get generated to the same base filename inside the respective versions.
			cp "$HERE/supplemental/Packs/${PARTS[0]}" "$DEST/${PARTS[1]}/media/texturepacks/${PARTS[2]}"
		else
			# Normal behaviour; SOURCE:DEST
			cp "$HERE/supplemental/Packs/${PARTS[0]}" "$DEST/${PARTS[1]}/media/texturepacks/${PARTS[0]}"
		fi
	done
fi

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
