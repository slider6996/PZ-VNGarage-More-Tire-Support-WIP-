#!/bin/bash
#
# Bundle code to a distributable package and upload to Steam

# Define "here" as the directory this script is in
HERE="$(realpath "$(dirname "$0")")"
# Load settings
source "$HERE/settings.sh"

if [ -z "$(which steamcmd)" ]; then
	echo "ERROR: steamcmd not found, please install it"
	exit 1
fi

if [ $(ps aux | grep steam | wc -l) -gt 1 ]; then
	echo "ERROR: Please close Steam before running this script"
	exit 1
fi

if [ ! -e "$HERE/.secret" ]; then
	echo "ERROR: Please create a file at $HERE/.secret containing your Steam Workshop login (and optionally Steam password)"
	echo "ex: your_steam_username your_steam_password"
	exit 1
fi
SECRET="$(cat "$HERE/.secret")"
if [ -z "$SECRET" ]; then
	echo "ERROR: Please enter your Steam Workshop login (and optionally Steam password) in $HERE/.secret"
	exit 1
fi

source "$HERE/build_dist.sh"


echo "Uploading to Steam workshop...."

steamcmd +login $SECRET +workshop_build_item "$DIST/metadata.vdf" +quit

# Clear the CHANGELOG, (as this is now recorded in the distribution)
echo "[list]
  [*]
[/list]" > "$HERE/CHANGELOG"


if [ "$WORKSHOP_ID" -eq 0 ]; then
	# Extract the workshop ID from the output of steamcmd
	echo "New mod uploaded to Steam workshop, please set the WORKSHOP_ID in settings.sh."
fi