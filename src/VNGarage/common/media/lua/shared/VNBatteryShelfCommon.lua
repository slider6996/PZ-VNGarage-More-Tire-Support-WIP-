---
--- Common functions and utilities for Veracious Network's Garage
---
--- @see https://github.com/VeraciousNetwork/PZ-VNGarage
--- Copyright (C) 2024-2025  Charlie Powell <cdp1337@veraciousnetwork.com>
---
--- This program is free software: you can redistribute it and/or modify
--- it under the terms of the GNU Affero General Public License as
--- published by the Free Software Foundation, either version 3 of the
--- License, or (at your option) any later version.
---
--- This program is distributed in the hope that it will be useful,
--- but WITHOUT ANY WARRANTY; without even the implied warranty of
--- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--- GNU Affero General Public License for more details.
---
--- You should have received a copy of the GNU Affero General Public License
--- along with this program.  If not, see <https://www.gnu.org/licenses/>.

---@global
VNGarage = VNGarage or {}
VNGarage.BatteryShelfCommon = {}


--- Check if the given isoObject is a battery shelf
---@param isoObject IsoObject
---@return boolean
function VNGarage.BatteryShelfCommon.ObjectIsShelf(isoObject)
	---@type IsoSprite
	local sprite = isoObject:getSprite()
	if not sprite then
		-- Ensure the object has a sprite, (items cannot be placed)
		return false
	end

	---@type ItemContainer
	if not isoObject:getContainer() then
		-- This is a container type object, probably a redundant check, but doesn't harm anything.
		return false
	end

	local spriteName = sprite:getName()

	if spriteName == nil or spriteName == '' then
		-- Failsafe for if an empty sprite is passed in.
		-- This happens with transfers from vehicles, corpses, etc.
		return false
	end

	-- Submitted sprite name contains "vn_battery_shelf_";
	-- while this is not a 100% guarantee, it's a good enough check for now.
	return string.find(spriteName, "vn_battery_shelf_") ~= nil
end


--- Update the shelf sprite based on how many batteries are stored.
--- Will automatically send the "updateSprite" notification to clients when in server mode
---@param isoObject IsoObject
function VNGarage.BatteryShelfCommon.UpdateSprite(isoObject)
	---@type ItemContainer
	local container = isoObject:getContainer()
	---@type IsoSprite
	local sprite = isoObject:getSprite()

	-- Retrieve the facing orientation of the default Sprite,
	-- 0 = North, 1 = East, 2 = South, 3 = West
	-- This is dependent on the spritemap, and is used to adjust the QTY offset to the correct orientation sprite.
	-- The sprite name is "vn_tire_rack_unpainted_[0-3]",
	-- string.sub(...) trims off to just the last character.
	local orientation = tonumber(string.sub(sprite:getName(), -1))

	-- Retrieve the base sprite name, this will be the "type" of tire rack.
	-- @todo Add support for other types of battery shelves; should there be more
	local base = 'vn_battery_shelf'

	-- Use the number of items currently in the inventory to adjust the sprite position.
	-- Positions 0 - 3 are 0 qty,
	-- Positions 4 - 7 are 1 qty,
	-- etc.  (P + 4*len) will provide the accurate positional sprite.
	local len = container:getItems():size()

	if isServer() then
		if isoObject:getModData().VNBatteryCount == len then
			-- Do not perform unnecessary spriteUpdates, (they'd just clutter up the network traffic)
			return
		end

		-- Cache the number of tires last sent, so the next tick can check & will know whether or not to send the sprite
		isoObject:getModData().VNBatteryCount = len
	end

	if len > 6 then
		-- Failsafe as there are only 6 sets of sprites in the spritemap
		isoObject:setOverlaySprite(base .. tostring(orientation + (4 * 6)))
	elseif len > 0 then
		-- At least 1 battery, but less than 7.  Standard sprites.
		isoObject:setOverlaySprite(base .. tostring(orientation + (4 * len)))
	else
		-- No batteries, just remove the sprite overlay.
		isoObject:setOverlaySprite(nil)
	end

	if isServer() then
		-- Sprite only needs sent when in server/client mode (from the server)
		isoObject:transmitUpdatedSprite()
	end
end


--- Called as soon as the player completes a craft of a tire rack from a recipe
---@param thumpable Thumpable
function VNGarage.BatteryShelfCommon.OnCreateRecipe(thumpable)
	VNGarage.BatteryShelfCommon.SetupPlacedTile(thumpable)
end


--- Check to see if the placed item is a shelf, and attach the expected functionality if so
---@param isoObject IsoThumpable
function VNGarage.BatteryShelfCommon.SetupPlacedTile(isoObject)
	if VNGarage.BatteryShelfCommon.ObjectIsShelf(isoObject) then
		---@type ItemContainer
		local container = isoObject:getContainer()

		container:setAcceptItemFunction('VNGarage.BatteryShelfCommon.AcceptItemFunction')

		if isServer() then
			isoObject:getModData().VNBatteryCount = nil
			VNGarage.BatteryShelfServer.Shelves[#VNGarage.BatteryShelfServer.Shelves+1] = isoObject
		end
	end
end


--- Handle accepting only car batteries on the battery shelf
---@param container IsoThumpable
---@param item InventoryItem
---@return boolean
function VNGarage.BatteryShelfCommon.AcceptItemFunction(container, item)
	return item:hasTag('CarBattery')
end


--- Update the global index of container icons to include the tire rack.
---@global
ContainerButtonIcons = ContainerButtonIcons or {}
ContainerButtonIcons.VNBatteryShelf = getTexture("media/textures/Item_VNBatteryShelf.png")



--- Check to see if any newly placed Tile is a battery shelf and perform the adjustments if necessary.
--- This only applies to NEWLY placed tiles, not existing ones.
Events.OnObjectAdded.Add(VNGarage.BatteryShelfCommon.SetupPlacedTile)


--- Handle EXISTING objects already on the map at the time of game load.
local tile_tags = {
	'vn_battery_shelf',
}
for _, value in ipairs(tile_tags) do
	MapObjects.OnLoadWithSprite(value .. '_0', VNGarage.BatteryShelfCommon.SetupPlacedTile, 5)
	MapObjects.OnLoadWithSprite(value .. '_1', VNGarage.BatteryShelfCommon.SetupPlacedTile, 5)
	MapObjects.OnLoadWithSprite(value .. '_2', VNGarage.BatteryShelfCommon.SetupPlacedTile, 5)
	MapObjects.OnLoadWithSprite(value .. '_3', VNGarage.BatteryShelfCommon.SetupPlacedTile, 5)
end

