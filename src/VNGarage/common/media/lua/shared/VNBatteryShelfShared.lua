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
---
--- Load order of scripts: `shared`, then `client`, then `server`.

---@global
VNGarage = VNGarage or {}
VNGarage.BatteryShelf = VNGarage.BatteryShelf or {}
-- Persistent storage of all shelves in the game
-- Used to walk through in the cron job.
VNGarage.BatteryShelf.Shelves = VNGarage.BatteryShelf.Shelves or {}


--- Check if the given isoObject is a battery shelf
---@param isoObject IsoObject
---@return boolean
function VNGarage.BatteryShelf.ObjectIsShelf(isoObject)
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
function VNGarage.BatteryShelf.UpdateSprite(isoObject)
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

	if orientation == 0 or orientation == 3 then
		-- If the orientation is North or West, we can safely skip the sprite update.
		-- This is because the batteries are not visible in those orientations.
		isoObject:setOverlaySprite(nil)
		return
	end

	-- Retrieve the base sprite name, this will be the "type" of tire rack.
	-- @todo Add support for other types of battery shelves; should there be more
	local base = 'vn_battery_shelf_'

	-- Use the number of items currently in the inventory to adjust the sprite position.
	-- Positions 0 - 3 are 0 qty,
	-- Positions 4 - 7 are 1 qty,
	-- etc.  (P + 4*len) will provide the accurate positional sprite.
	local len = container:getItems():size()
	local spriteOverlay = nil

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
		spriteOverlay = base .. tostring(orientation + (4 * 6))
	elseif len > 0 then
		-- At least 1 battery, but less than 7.  Standard sprites.
		spriteOverlay = base .. tostring(orientation + (4 * len))
	end

	-- @todo Check if (spriteOverlay, true) works instead of a cron watch in B42.
	-- The new code from zombie/iso/IsoObject.class supports network calls within this method.
	isoObject:setOverlaySprite(spriteOverlay)

	if isServer() then
		-- Sprite only needs sent when in server/client mode (from the server)
		isoObject:transmitUpdatedSprite()
	end
end


--- Called as soon as the player completes a craft of a tire rack from a recipe
---@param table table
---@param table.thumpable IsoThumpable
---@param table.character IsoPlayer
---@param table.craftRecipeData CraftRecipeData
---@param table.facing string
function VNGarage.BatteryShelf.OnCreateRecipe(table)
	VNGarage.BatteryShelf.SetupPlacedTile(table.thumpable)
end


--- Check to see if the placed item is a shelf, and attach the expected functionality if so
---@param isoObject IsoThumpable
function VNGarage.BatteryShelf.SetupPlacedTile(isoObject)
	if VNGarage.BatteryShelf.ObjectIsShelf(isoObject) then
		---@type ItemContainer
		local container = isoObject:getContainer()

		container:setAcceptItemFunction('VNGarage.BatteryShelf.AcceptItemFunction')

		isoObject:getModData().VNBatteryCount = nil
		VNGarage.BatteryShelf.Shelves[#VNGarage.BatteryShelf.Shelves+1] = isoObject
	end
end


--- Handle accepting only car batteries on the battery shelf
---@param container IsoThumpable
---@param item InventoryItem
---@return boolean
function VNGarage.BatteryShelf.AcceptItemFunction(container, item)
	return item:hasTag('CarBattery')
end


--- Scheduled check to see if this charger has power charge any batteries in it.
--- Also updates the sprite when operating in server mode.
function VNGarage.BatteryShelf.ScheduledCheck()
	local is_server = isServer()
	local is_client = isClient()

	for _, isoObject in pairs(VNGarage.BatteryShelf.Shelves) do
		if isoObject then
			if is_server then
				--- Since the server handles updateSprites in Java and does not expose a mechanism for triggering this,
				--- manually watch the containers and check if they need to be refreshed every so often.
				VNGarage.BatteryShelf.UpdateSprite(isoObject)
			end

			---@type ItemContainer
			local container = isoObject:getContainer()
			local items = container:getItems()
			---@type int
			local len = items:size()
			---@type IsoGridSquare
			local square = isoObject:getSquare()
			---@type boolean
			local has_power = square:haveElectricity() or square:hasGridPower()
			if len > 0 and has_power then
				-- If the shelf has at least 1 battery, and has electricity, then we can charge the batteries.
				for i = 0, len - 1 do
					---@type DrainableComboItem
					local item = items:get(i)
					if item and item:hasTag('CarBattery') then
						-- If the item is a car battery, we can charge it.
						-- This will only charge batteries that are not fully charged.
						local current_uses = item:getCurrentUsesFloat()
						if current_uses < 1.0 then
							item:setCurrentUsesFloat(current_uses + 0.002)
						end
					end
				end
			end
		end
	end
end


--- Update the global index of container icons to include the tire rack.
---@global
ContainerButtonIcons = ContainerButtonIcons or {}
ContainerButtonIcons.VNBatteryShelf = getTexture("media/textures/Item_VNBatteryShelf.png")



--- Check to see if any newly placed Tile is a battery shelf and perform the adjustments if necessary.
--- This only applies to NEWLY placed tiles, not existing ones.
Events.OnObjectAdded.Add(VNGarage.BatteryShelf.SetupPlacedTile)


--- Handle EXISTING objects already on the map at the time of game load.
local tile_tags = {
	'vn_battery_shelf',
}
for _, value in ipairs(tile_tags) do
	MapObjects.OnLoadWithSprite(value .. '_0', VNGarage.BatteryShelf.SetupPlacedTile, 5)
	MapObjects.OnLoadWithSprite(value .. '_1', VNGarage.BatteryShelf.SetupPlacedTile, 5)
	MapObjects.OnLoadWithSprite(value .. '_2', VNGarage.BatteryShelf.SetupPlacedTile, 5)
	MapObjects.OnLoadWithSprite(value .. '_3', VNGarage.BatteryShelf.SetupPlacedTile, 5)
end

