#!/bin/bash
#
# Bundle code to a distributable package (ready to be uploaded to Steam workshop)

# Define "here" as the directory this script is in
HERE="$(realpath "$(dirname "$0")")"
# Load settings
source "$HERE/settings.sh"

if [ -z "$(which steamcmd)" ]; then
	echo "ERROR: steamcmd not found, please install it"
	exit 1
fi

CHANGELOG="$(cat "$HERE/CHANGELOG")"
if [ -z "$CHANGELOG" ]; then
	echo "ERROR: Please enter a note of changes in $HERE/CHANGELOG"
	exit 1
fi

if [ ! -e "$HERE/.secret" ]; then
	echo "ERROR: Please create a file at $HERE/.secret containing your Steam Workshop login (and optionally Steam password)"
	exit 1
fi
SECRET="$(cat "$HERE/.secret")"
if [ -z "$SECRET" ]; then
	echo "ERROR: Please enter your Steam Workshop login (and optionally Steam password) in $HERE/.secret"
	exit 1
fi

if [ $(ps aux | grep steam | wc -l) -gt 1 ]; then
	echo "ERROR: Please close Steam before running this script"
	exit 1
fi

# Set target directory for local testing
DIST="$HERE/dist/$(date +%Y%m%d.%H%M)"
DEST="$DIST/content/mods/$MOD_NAME"

if [ ! -d "$DEST" ]; then
	mkdir -p "$DEST"
fi

# Sync local mod code
rsync "$HERE/src/" "$DEST" -r --delete

# Install any tiles (if present)
if [ -n "$TILES" ]; then
	for TILE in $TILES; do
		cp "$HERE/supplemental/Tiles/$TILE" "$DEST/media/$TILE"
	done
fi

# Install any packs (if present)
if [ -n "$PACKS" ]; then
	for PACK in $PACKS; do
		cp "$HERE/supplemental/Packs/$PACK" "$DEST/media/texturepacks/$PACK"
	done
fi

# Deploy Steam-specific content
cp "$HERE/workshop/preview.png" "$DIST/preview.png"

cat > "$DIST/metadata.vdf" << EOD
"workshopitem" {
  "appid" "108600"
  "publishedfileid" "$WORKSHOP_ID"
  "contentfolder" "$DIST/content"
  "previewfile" "$DIST/preview.png"
  "visibility" "0"
  "title" "$MOD_TITLE"
  "description" "$MOD_DESCRIPTION"
  "changenote" "$CHANGELOG"
}
EOD


echo "Bundled mod in $DIST"
echo "Uploading to Steam workshop...."

steamcmd +login $SECRET +workshop_build_item "$DIST/metadata.vdf" +quit

# Clear the CHANGELOG, (as this is now recorded in the distribution)
echo "" > "$HERE/CHANGELOG"
