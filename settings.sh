##
# Settings for this mod, used in deployment generally.
##

##
# Name of this mod, used to create the directory in the game
#
export MOD_NAME="VNGarage"

##
# Title for Steam Workshop
#
export MOD_TITLE="Veracious Network's Garage"

##
# Once you have a workshop ID for your mod, put it here.
# leave as 0 for a new mod
#
export WORKSHOP_ID=3133520800

##
# Tags to set for Steam workshop, refer to the currently supported tags
# and separate each tag with a semicolon (;)
export MOD_TAGS="Build 41;Build 42;Building;Multiplayer;Realistic"

##
# Set the visibility for Steam, recommended to be 'public' for published mods.
# Supported values are:
# public
# friends
# private
# unlisted
export MOD_VISIBILITY="public"

##
# Set to the mod version to show inside Project Zomboid.
#
# Should be a string that only contains letters, numbers, periods, underscores, tilde, or dashes.
# Used to set `modversion=` within `mod.info` files.
export MOD_VERSION="2025.06.09"

##
# Description for Steam Workshop, supports BBCode
# @see https://www.bbcode.org/how-to-use-bbcode-a-complete-guide.php
#
# Quick ref:
# [b]bold text[/b]
# [i]italic text[/i]
# [u]underlined text[/u]
# [s]strikethrough text[/s]
# [url=link]text[/url]
# [img]link[/img]
#
# MOVED TO `DESCRIPTION.bbcode`

##
# Newline-separated list of tiles to install
#
# ex:
# TILES="mytiles1.tiles
# mytiles2.tiles"
#
# To specify a different destination filename:
# TILES="mytile_someversion.tiles:MyMod/SpecificVersion:mytile.tiles"
#
# If no tiles are used, leave this empty.
#
export TILES="vn_garage_b41.tiles:VNGarage:vn_garage.tiles
vn_garage.tiles:VNGarage/common"

##
# Newline-separated list of packs to install
#
# ex:
# TILES="mypacks1.pack
# mypacks2.pack"
#
# If no packs are used, leave this empty.
#
export PACKS="vn_garage.pack:VNGarage
vn_garage.pack:VNGarage/common"