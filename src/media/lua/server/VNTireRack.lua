---@global
VNTireRack = {}


--- Check if a given Sprite name is a tire rack
---@param spriteName string The name of the sprite to check
local SpriteNameIsTireRack = function(spriteName)
	return string.find(spriteName, "vn_tire_rack_") ~= nil
end


--- Check if a given Item is a tire
---@param itemName string The name of the item to check
local ScriptItemIsTire = function(itemName)

	-- Simple list of valid tire KeyNames within the game.
	-- To expand support for mods, just add the modded tire names here.
	local ValidTireNames = {
		'ModernTire1',
		'ModernTire2',
		'ModernTire3',
		'ModernTire8',
		'NormalTire1',
		'NormalTire2',
		'NormalTire3',
		'NormalTire8',
		'OldTire1',
		'OldTire2',
		'OldTire3',
		'OldTire8',
	}

	for index, value in ipairs(ValidTireNames) do
		if value == itemName then
			return true
		end
	end

	return false

end


--- Check to see if the placed item is a tire rack, (and attach the expected functionality if so)
---@param isoObject IsoThumpable
VNTireRack.SetupPlacedTile = function(isoObject)
	---@type IsoSprite
	local sprite = isoObject:getSprite()
	---@type ItemContainer
	local container = isoObject:getContainer()

	if not sprite then
		-- Failsafe if the source item doesn't have a sprite
		return
	end

	if not container then
		-- Failsafe if the source item doesn't have a container
		return
	end

	if SpriteNameIsTireRack(sprite:getName()) then
		container:setAcceptItemFunction('VNTireRack.AcceptItemFunction')
		container:setCapacity(180) -- 12 items of 15 weight tires
	end
end


--- Handle accepting only tires on the tire rack
---@param isoObject IsoThumpable
VNTireRack.AcceptItemFunction = function(container, item)
	local sItem = item:getScriptItem()

	if not sItem then
		-- Failsafe if the source item doesn't have a script item
		return false
	end

	return ScriptItemIsTire(sItem:getName())
end


VNTireRack.UpdateSprite = function(isoObject)
	---@type ItemContainer
	local container = isoObject:getContainer()
	---@type IsoSprite
	local sprite = isoObject:getSprite()

	-- Retrieve the facing orientation of the default Sprite,
	-- 0 = North, 1 = East, 2 = South, 3 = West
	-- This is dependent on the spritemap, and is used to adjust the QTY offset to the correct orientation sprite.
	local orientation = tonumber(string.sub(sprite:getName(), -1))

	local base = string.match(sprite:getName(), '.*_')

	-- Use the number of items currently in the inventory to adjust the sprite position.
	-- Positions 0 - 3 are 0 qty,
	-- Positions 4 - 7 are 1 qty,
	-- etc.  (P + 4*len) will provide the accurate positional sprite.
	local len = container:getItems():size()

	if len > 12 then
		-- Failsafe as there are only 12 sets of sprites in the spritemap (plus one overflow)
		isoObject:setOverlaySprite(base .. tostring(orientation + (4 * 13)))
	elseif len > 0 then
		isoObject:setOverlaySprite(base .. tostring(orientation + (4 * len)))
	else
		isoObject:setOverlaySprite(nil)
	end
end


--- Check to see if any newly placed Tile is a tire rack and perform the adjustments if necessary.
--- This only applies to NEWLY placed tiles, not existing ones.
Events.OnObjectAdded.Add(VNTireRack.SetupPlacedTile)


--- Handle EXISTING objects already on the map at the time of game load.
MapObjects.OnLoadWithSprite('vn_tire_rack_unpainted_0', VNTireRack.SetupPlacedTile, 5)
MapObjects.OnLoadWithSprite('vn_tire_rack_unpainted_1', VNTireRack.SetupPlacedTile, 5)
MapObjects.OnLoadWithSprite('vn_tire_rack_unpainted_2', VNTireRack.SetupPlacedTile, 5)
MapObjects.OnLoadWithSprite('vn_tire_rack_unpainted_3', VNTireRack.SetupPlacedTile, 5)


--- Overwrite the TransferItem method to provide an artificial hook for updating the inventory.
local oldTransferItem = ISInventoryTransferAction.transferItem --This is to make it possible to store it I think?
function ISInventoryTransferAction:transferItem(...)
	-- Run the original method first; we have no need to modify that behaviour
	local ret = {oldTransferItem(self, ...)}

	if self.srcContainer and self.srcContainer:getParent() then
		---@type IsoObject
		local parent = self.srcContainer:getParent()

		---@type IsoSprite
		local sprite = parent:getSprite()

		if sprite and SpriteNameIsTireRack(sprite:getName()) then
			-- Instruct the tire rack to update its sprite
			VNTireRack.UpdateSprite(parent)
		end
	end

	if self.destContainer and self.destContainer:getParent() then
		---@type IsoObject
		local parent = self.destContainer:getParent()

		---@type IsoSprite
		local sprite = parent:getSprite()

		if sprite and SpriteNameIsTireRack(sprite:getName()) then
			-- Instruct the tire rack to update its sprite
			VNTireRack.UpdateSprite(parent)
		end
	end

	return unpack(ret)
end
