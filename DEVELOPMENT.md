# Project Zomboid Mod Development Guide

End-users can ignore this document. 
This is intended for developers who want to contribute to the mod
or create their own mod based on this template.

## Setting up Project

### Configure settings

Open `settings.sh` and edit to fit your needs.  Enter the mod name, title, description, etc.

### Setup local environment

Running `setup.sh` will setup the local environment for development...

1. Downloads latest official tilesets and sprites
2. Installs TileZed/WorldEd
3. Installs and runs pz-zdoc to generate game documentation from your live game code

This setup generally only needs to be run once.


## Tiles and Spritemap

### Create new tileset

This step is not required for this project as a tileset is already created,
but including instructions for future reference.

1. Run TileZed.sh and click Tools -> Tilesets... to rebuild the local cache of tilesets
2. (if this does not work, delete ~/.TileZed)
3. Click Tools -> Tile Properties (.tiles)
4. Create new tileset named something meaningful located within supplemental/Tiles
5. Add necessary tilesets and save the tiles

### Add or update tileset

For tilesets, save the full tileset as a .png within designs/tilesets (1024x2048 recommended).
The image filename should match what you want the tileset to be named.

1. Run `deploy_local.sh` to copy tileset into TileZed
2. Run TileZed.sh and click Tools -> Tilesets... to rebuild the local cache of tilesets
3. (if this does not work, delete ~/.TileZed)
4. Click Tools -> Tile Properties (.tiles)
5. Open mod tileset from supplemental/Tiles
6. Add necessary tilesets and save the tiles

### Update Pack

1. Run TileZed.sh and click Tools -> Create .pack file
2. Save .pack file in supplemental/Packs/ (overwriting existing file if necessary)
3. Add designs/tilesets as input image directories
4. Add mod-specific tiles file from supplemental/Tiles/ if necessary


## Deploying Local Code

Run `deploy_local.sh` to install the mod in your local game directory.
This is useful for testing prior to deployment.

Make sure you've already setup `settings.sh` prior to running this script.


## Deploying to Steam Workshop

Create a file called `.secret` which contains your Steam username, (and optionally password).

eg: `echo "username" > .secret` or `echo "username mysupersecretpassword" > .secret`

If you omit your password, you may be prompted for it when running `deploy_steam.sh`.
This is recommended as it will prevent your password from being stored in plaintext,
but it's your call to decide if you want to store your password or not.

**Close Steam before running the script**.  For some reason steamcmd fights Steam
and only one can be run at a time.  If you attempt to deploy with Steam running,
the script will tell you and exit.

Make sure you've setup `settings.sh` with the title and description.
`WORKSHOP_ID` can be left as '0' to upload a new mod.
Upon successful upload, copy your new mod ID into settings for future updates.

Run `deploy_dist.sh` to create a package in `dist/` and upload to Steam Workshop.
