---
--- Client functions and utilities for Veracious Network's Garage
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

---@global
VNGarage = VNGarage or {}
VNGarage.BatteryShelf = VNGarage.BatteryShelf or {}
-- Persistent storage of all shelves in the game
-- Used to walk through in the cron job.
VNGarage.BatteryShelf.Shelves = VNGarage.BatteryShelf.Shelves or {}

Events.EveryTenMinutes.Add(VNGarage.BatteryShelf.ScheduledCheck)