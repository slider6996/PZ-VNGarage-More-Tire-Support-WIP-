---
--- Server functions and utilities for Veracious Network's Garage
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

require 'Items/SuburbsDistributions'
require 'Items/ProceduralDistributions'

-- The server does not expose a mechanism for updating inventory (at least that I could find),
-- so attach a call to run every "10 minutes" in game to refresh the sprites of all tire racks.
if isServer() then
	Events.EveryTenMinutes.Add(VNGarage.BatteryShelf.ScheduledCheck)
	Events.EveryTenMinutes.Add(VNGarage.TireRack.ScheduledUpdateCheck)
end

--- Add various items to the global loot table.
local function LootTable()
	local function addToDistroTable(container, items, chance)
		-- Syntax of the distribution loot table is item/items, chance.
		for _, item in pairs(items) do
			table.insert(container, item)
			table.insert(container, chance)
		end
	end

	local magazines = {
		"VNGarage.VNMagazine1",
		"VNGarage.VNMagazine2",
	}

	addToDistroTable(SuburbsDistributions["all"]["postbox"].items, magazines, 0.1)
	--addToDistroTable(SuburbsDistributions["all"]["Outfit_Mechanic"].items, magazines, 1)
	addToDistroTable(ProceduralDistributions.list["BookstoreAutomotive"].items, magazines, 5)
	addToDistroTable(ProceduralDistributions.list["BookstoreBooks"].items, magazines, 5)
	addToDistroTable(ProceduralDistributions.list["BookstoreBlueCollar"].items, magazines, 5)
	addToDistroTable(ProceduralDistributions.list["BookstoreMisc"].items, magazines, 5)
	addToDistroTable(ProceduralDistributions.list["CarSupplyLiterature"].items, magazines, 10)
	addToDistroTable(ProceduralDistributions.list["CarSupplyMagazines"].items, magazines, 20)
	addToDistroTable(ProceduralDistributions.list["CarDealerDesk"].items, magazines, 15)
	addToDistroTable(ProceduralDistributions.list["CrateBooks"].items, magazines, 5)
	addToDistroTable(ProceduralDistributions.list["CrateMagazines"].items, magazines, 1)
	addToDistroTable(ProceduralDistributions.list["CrateMechanics"].items, magazines, 4)
	addToDistroTable(ProceduralDistributions.list["GarageMechanics"].items, magazines, 8)
	addToDistroTable(ProceduralDistributions.list["LibraryMagazines"].items, magazines, 2)
	addToDistroTable(ProceduralDistributions.list["MechanicOutfit"].items, magazines, 5)
	addToDistroTable(ProceduralDistributions.list["MechanicTools"].items, magazines, 5)
	addToDistroTable(ProceduralDistributions.list["MechanicShelfBooks"].items, magazines, 2)
	addToDistroTable(ProceduralDistributions.list["MechanicSpecial"].items, magazines, 1)
	addToDistroTable(ProceduralDistributions.list["PostOfficeMagazines"].items, magazines, 1)
	addToDistroTable(ProceduralDistributions.list["StoreShelfMechanics"].items, magazines, 1)
	addToDistroTable(ProceduralDistributions.list["ToolStoreBooks"].items, magazines, 2)

	ItemPickerJava.Parse()
end

Events.OnInitGlobalModData.Add(LootTable)
