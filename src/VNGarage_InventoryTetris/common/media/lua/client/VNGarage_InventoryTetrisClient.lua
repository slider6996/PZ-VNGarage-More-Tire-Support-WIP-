---
--- Inventory Tetris support for Veracious Network's Garage (Version B42)
---
--- @see https://github.com/VeraciousNetwork/PZ-VNGarage
--- Copyright (C) 2025  Charlie Powell <cdp1337@veraciousnetwork.com>
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

require "InventoryTetris/TetrisContainerData";


local function LoadContainerData()
	local tireRackDefinition = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 20,
					["height"] = 6
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0
				}
			},
			[2] = {
				["size"] = {
					["width"] = 20,
					["height"] = 6
				},
				["position"] = {
					["x"] = 0,
					["y"] = 6
				}
			},
			[3] = {
				["size"] = {
					["width"] = 20,
					["height"] = 6
				},
				["position"] = {
					["x"] = 0,
					["y"] = 12
				}
			},
			[4] = {
				["size"] = {
					["width"] = 20,
					["height"] = 6
				},
				["position"] = {
					["x"] = 0,
					["y"] = 18
				}
			}
		}
	}

	local batteryShelfDefinition = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 12,
					["height"] = 3
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0
				}
			},
			[2] = {
				["size"] = {
					["width"] = 12,
					["height"] = 3
				},
				["position"] = {
					["x"] = 0,
					["y"] = 3
				}
			}
		}
	}

	local containerData = {
		["TireRackUnpainted_180"] = tireRackDefinition,
		["TireRackBlue_180"] = tireRackDefinition,
		["TireRackGreen_180"] = tireRackDefinition,
		["TireRackOrange_180"] = tireRackDefinition,
		["TireRackPink_180"] = tireRackDefinition,
		["TireRackPurple_180"] = tireRackDefinition,
		["TireRackRed_180"] = tireRackDefinition,
		["TireRackYellow_180"] = tireRackDefinition,
		["VNBatteryShelf_30"] = batteryShelfDefinition
	}

	TetrisContainerData.registerContainerDefinitions(containerData)
end

Events.OnGameBoot.Add(LoadContainerData)
