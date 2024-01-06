# Veracious Network's Garage (Project Zomboid Mod)

## Setting up Project

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


pack=vn_tire_rack
tiledef=vn_tire_rack 1300