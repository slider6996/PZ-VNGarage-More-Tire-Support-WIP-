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
VNGarage.Workbench = VNGarage.Workbench or {}

-- Set of what items can be stored and which set/position they are stored within.
VNGarage.Workbench.ItemSets = {
	['set00'] = {
		['DuctTape'] = 0,
		['Saw'] = 2,
		['Nails'] = 4,
		['Ratchet'] = 6,
		['Screwdriver'] = 8,
		['Screws'] = 10,
		['TireIron'] = 12,
		['Wrench'] = 14,
	},
	['set01'] = {
		['DuctTape'] = 16,
		['GardenSaw'] = 18,
		['Saw'] = 20,
		['Hammer'] = 22,
		['HandAxe'] = 24,
		['Nails'] = 26,
		['Screwdriver'] = 28,
		['Screws'] = 30,
	}
}

-- List of item types that should be remapped to something else
-- This is useful for nails and box of nails that should share the same sprite
-- or a screwdriver and an improvised screwdriver.
VNGarage.Workbench.ItemAliases = {
	['NailsBox'] = 'Nails',
	['ScrewsBox'] = 'Screws',
}


--- Check if the given isoObject is a battery shelf
---@param isoObject IsoObject
---@return boolean
function VNGarage.Workbench.ObjectIsWorkbench(isoObject)
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
	return string.find(spriteName, "vn_workbench_") ~= nil
end


--- Update the shelf sprite based on how many batteries are stored.
--- Will automatically send the "updateSprite" notification to clients when in server mode
---@param object IsoObject
function VNGarage.Workbench.UpdateSprite(object)
	print('Workbench UpdateSprite')
	---@type ItemContainer
	local container = object:getContainer()
	---@type IsoGridSquare
	local square = object:getSquare()
	---@type IsoSprite
	local sprite = object:getSprite()

	-- Retrieve the facing orientation of the default Sprite,
	-- 0 = North, 1 = East, 2 = South, 3 = West
	-- This is dependent on the spritemap, and is used to adjust the QTY offset to the correct orientation sprite.
	-- The sprite name is "vn_tire_rack_unpainted_[0-3]",
	-- string.sub(...) trims off to just the last character.
	local orientation = tonumber(string.sub(sprite:getName(), -1))
	local offset = 0
	local prefix = 'vn_workbench_items_'

	if orientation == 0 or orientation == 3 or orientation == 4 or orientation == 7 then
		-- If the orientation is North or West, we can safely skip the sprite update.
		-- This is because the tools are not visible in those orientations.
		return
	elseif orientation == 1 then
		prefix = 'vn_workbench_items_01_'
	elseif orientation == 2 then
		-- South-facing orientation sprites are offset by 1 in the spritemap
		offset = 1
		-- and use the first item set
		prefix = 'vn_workbench_items_01_'
	elseif orientation == 5 then
		prefix = 'vn_workbench_items_02_'
	elseif orientation == 6 then
		-- South-facing orientation sprites are offset by 1 in the spritemap
		offset = 1
		-- and use the second item set
		prefix = 'vn_workbench_items_02_'
	end

	-- Assign a blank sprite overlay so item removals still trigger UpdateSprite.
	object:setOverlaySprite('vn_workbench_63')

	local function in_array(table, value)
		for _, v in ipairs(table) do
			if v == value then
				return true
			end
		end
		return false
	end

	local function count_trues(table)
		local count = 0
		for _, v in pairs(table) do
			if v[1] == true then
				count = count + 1
			end
		end
		return count
	end

	---@param square IsoGridSquare
	local function clear_tiles(square)
		local current_objects = square:getObjects()
		local current_size = current_objects:size()
		local current_idx = 0
		while current_idx < current_size do
			local obj = current_objects:get(current_idx)
			current_idx = current_idx + 1
			if obj then
				local obj_sprite = obj:getSprite()
				if obj_sprite then
					local obj_sprite_name = obj_sprite:getName()
					if obj_sprite_name and string.find(obj:getSprite():getName(), "vn_workbench_items_") ~= nil then
						square:RemoveTileObject(obj)
						-- Removing a tile will shift the array, so backtrack the index.
						current_idx = current_idx - 1
						current_size = current_objects:size()
					end
				end
			end
		end
	end

	-- Clear any current tile overrides
	clear_tiles(square)


	-- Definition of which item sets contain which items.
	-- This is required because not all items can fit on a single spritemap at once,
	-- so group commonly bundled items together.
	local sets = {}
	for set, dat in pairs(VNGarage.Workbench.ItemSets) do
		sets[set] = {}
		for item, idx in pairs(dat) do
			-- Create a new entry for each item in the set.
			sets[set][item] = { false, idx }
		end
	end

	---@type ArrayList
	local items = container:getItems()
	---@type int
	local len = items:size()

	-- Determine which items are currently stored.
	-- Used to know which sprite to render and which item set to use.
	for i = 0, len - 1 do
		---@type InventoryItem
		local item = items:get(i)
		if item then
			local item_type = item:getType()
			-- Remap a few values to common items
			if VNGarage.Workbench.ItemAliases[item_type] ~= nil then
				-- If the item is an alias, remap it to the common item type.
				item_type = VNGarage.Workbench.ItemAliases[item_type]
			end

			print('Checking item ' .. item_type)

			if sets['set00'][item_type] ~= nil then
				--print(item_type .. ' in set 00')
				sets['set00'][item_type][1] = true
			end
			if sets['set01'][item_type] ~= nil then
				--print(item_type .. ' in set 01')
				sets['set01'][item_type][1] = true
			end
		end
	end

	local best_match = nil
	local best_match_count = 0
	local c = 0

	c = count_trues(sets['set00'])
	if c > best_match_count then
		best_match = 'set00'
		best_match_count = c
	end

	c = count_trues(sets['set01'])
	if c > best_match_count then
		best_match = 'set01'
		best_match_count = c
	end

	if best_match_count > 0 then
		-- At least one set has some items stored.
		local sprite_indexes = sets[best_match]
		for key, _ in pairs(sprite_indexes) do
			local idx = sets[best_match][key][2]
			--print('Checking if ' .. key .. ' with IDX ' .. tostring(idx) .. ' should be rendered')
			if sets[best_match][key][1] then
				-- If the item is in the set, set the overlay sprite.
				local spriteOverlay = prefix .. tostring(offset + idx)
				print('rendering ' .. spriteOverlay)
				local clone = IsoObject.new(getCell(), square, spriteOverlay)
				square:AddTileObject(clone)
			end
		end
	end
end
