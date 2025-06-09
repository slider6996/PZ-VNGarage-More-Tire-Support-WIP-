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

-- Only run this code in SERVER mode
if not isServer() then return end

---@global
VNGarage = VNGarage or {}
VNGarage.TireRack = VNGarage.TireRack or {}

-- Persistent storage of all tire racks in the game
-- Used to walk through in the cron job.
VNGarage.TireRack.Racks = {}

--- Since the server handles updateSprites in Java and does not expose a mechanism for triggering this,
--- manually watch the containers and check if they need to be refreshed every so often.
function VNGarage.TireRack.ScheduledUpdateCheck()
	for index, value in ipairs(VNGarage.TireRack.Racks) do
		if value then
			--- Only update sprites if the object is valid, should address issue #4
			VNGarage.TireRack.UpdateTireRackSprite(value)
		end
	end
end


-- The server does not expose a mechanism for updating inventory (at least that I could find),
-- so attach a call to run every "10 minutes" in game to refresh the sprites of all tire racks.
Events.EveryTenMinutes.Add(VNGarage.TireRack.ScheduledUpdateCheck)
