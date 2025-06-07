#!/bin/bash
#
# Deploy code to local game (useful for testing)

# Define "here" as the directory this script is in
HERE="$(realpath "$(dirname "$0")")"

# Load settings
source "$HERE/settings.sh"

LOCAL="$HOME/Zomboid/Workshop/$MOD_NAME"

# Build a full distributable copy
# defines DIST as the target of the distributable version
source "$HERE/build_dist.sh"

# Setup directory so it can be deployed within the game in B42
# along with the necessary Steam files
[ -d "$LOCAL/Contents/mods" ] || mkdir -p "$LOCAL/Contents/mods"
cp "$DIST/workshop.txt" "$LOCAL/workshop.txt"
cp "$DIST/preview.png" "$LOCAL/preview.png"

# Copy any mods within the full distributable copy to a local DEV version
ls -1 "$DIST/Contents/mods" | while read IFILE; do
	if [ -d "$DIST/Contents/mods/$IFILE" ]; then
		# Located path is a directory
		# Sync that directory to the local mods directory.
		rsync "$DIST/Contents/mods/$IFILE/" "$LOCAL/Contents/mods/$IFILE" -r --delete

		echo "Deployed local mod $IFILE"

	fi
done


# Check if there is a local server available, (useful for testing server-side code in a local environment)
#SERVER="$HOME/Zomboid/Server"
#if [ -e "$SERVER/servertest.ini" ]; then
#	if ! egrep -q "^Mods=.*DEV_$MOD_NAME" "$SERVER/servertest.ini"; then
#		sed -i "s/Mods=.*/Mods=DEV_$MOD_NAME/" "$SERVER/servertest.ini"
#	fi
#fi
