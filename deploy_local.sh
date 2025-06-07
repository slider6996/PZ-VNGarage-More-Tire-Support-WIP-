#!/bin/bash
#
# Deploy code to local game (useful for testing)

# Define "here" as the directory this script is in
HERE="$(realpath "$(dirname "$0")")"

# Load settings
source "$HERE/settings.sh"

LOCAL="$HOME/Zomboid/Workshop/$MOD_NAME"

# Sync local tilesets to working directory for TileZed
rsync "$HERE/designs/tilesets/" "$HERE/supplemental/Tiles/2x" -r

# Build a full distributable copy
# defines DIST as the target of the distributable version
source "$HERE/build_dist.sh"

# Setup directory so it can be deployed within the game in B42
# along with the necessary Steam files
[ -d "$LOCAL/Contents/mods" ] || mkdir -p "$LOCAL/Contents/mods"
cp "$DIST/workshop.txt" "$LOCAL/workshop.txt"
rsync "$HERE/workshop/" "$LOCAL/" -r

# Copy any mods within the full distributable copy to a local DEV version
ls -1 "$DIST/content/mods" | while read IFILE; do
	if [ -d "$DIST/content/mods/$IFILE" ]; then
		# Located path is a directory
		# Sync that directory to the local mods directory.
		rsync "$DIST/content/mods/$IFILE/" "$LOCAL/Contents/mods/$IFILE" -r --delete

		#if [ -e "$LOCAL/DEV_$IFILE/mod.info" ]; then
		#	# Swap target name to differentiate between production version and dev version.
		#	# This causes issues otherwise if the Workshop version is subscribed to;
		#	# that version will take precedence over the local version.
		#	sed -i "s/id=\(.*\)/id=DEV_\1/" "$LOCAL/DEV_$IFILE/mod.info"
		#fi

		#if [ -e "$LOCAL/DEV_$IFILE/42/mod.info" ]; then
		#	# Swap target name to differentiate between production version and dev version.
		#	# This causes issues otherwise if the Workshop version is subscribed to;
		#	# that version will take precedence over the local version.
		#	sed -i "s/id=\(.*\)/id=DEV_\1/" "$LOCAL/DEV_$IFILE/42/mod.info"
		#fi

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
