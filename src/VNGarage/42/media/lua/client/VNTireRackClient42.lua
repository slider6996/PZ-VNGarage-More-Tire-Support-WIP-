---
--- Common functions and utilities for Veracious Network's Garage (Version B42)
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

-- Item containers are hard coded in B42 to have a 100 kg weight limit.
-- This is unfortunate, but we can use JB's workaround to fix this.
-- https://pzwiki.net/wiki/JB_Max_Capacity_Override
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3452113500
-- JB_MaxCapacityOverride.addContainer = function(containerType, capacity, preventNesting, _equippedWeight)
local JB_MaxCapacityOverride = require("JB_MaxCapacityOverride")
JB_MaxCapacityOverride.addContainer("TireRackUnpainted", 180, true)
JB_MaxCapacityOverride.addContainer("TireRackBlue", 180, true)
JB_MaxCapacityOverride.addContainer("TireRackGreen", 180, true)
JB_MaxCapacityOverride.addContainer("TireRackOrange", 180, true)
JB_MaxCapacityOverride.addContainer("TireRackPink", 180, true)
JB_MaxCapacityOverride.addContainer("TireRackPurple", 180, true)
JB_MaxCapacityOverride.addContainer("TireRackRed", 180, true)
JB_MaxCapacityOverride.addContainer("TireRackYellow", 180, true)
