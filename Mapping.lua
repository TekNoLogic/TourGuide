
local L = TourGuide.Locale

local zonei, zonec = {}, {}
for ci,c in pairs{GetMapContinents()} do
	for zi,z in pairs{GetMapZones(ci)} do
		zonei[z], zonec[z] = zi, ci
	end
end


local function MapPoint(zone, x, y, desc)
	local zi, zc = zone and zonei[zone], zone and zonec[zone]
	if not zi then
		if zone then TourGuide:PrintF("Cannot find zone %q, using current zone.", zone)
		else TourGuide:Print("No zone provided, using current zone.") end

		zi, zc = GetCurrentMapZone(), GetCurrentMapContinent()
	end

	if TomTom then TomTom:AddZWaypoint(zc, zi, x, y, desc) --AddZWaypoint(c,z,x,y,desc)  select(z, GetMapZones(c))
	elseif Cartographer_Waypoints then Cartographer_Waypoints:AddLHWaypoint(zc, zi, x, y, desc) end -- continent, zone, x, y desc
end


function TourGuide:ParseAndMapCoords(note, desc, zone)
	for x,y in note:gmatch(L.COORD_MATCH) do MapPoint(zone, tonumber(x), tonumber(y), desc) end
end


function TourGuide:PurgeWaypoints(desc)
	if not desc or not TomTom then return end

	local Astrolabe = DongleStub("Astrolabe-0.4")
	local TomTom = TomTom

	if not TomTom.w_points or #TomTom.w_points == 0 then return end

	if TomTom.m_points then
		for c,ctbl in pairs(TomTom.m_points) do
			for z,ztbl in pairs(ctbl) do
				for idx,entry in pairs(ztbl) do
					if type(entry) == "table" then
						if entry.label == desc then
							self:DebugF(1, "Removing %q from Astrolabe", entry.label)
							Astrolabe:RemoveIconFromMinimap(entry.icon)
							entry:Hide()
							table.insert(TomTom.minimapIcons, entry.icon)
							ztbl[idx] = nil
						end
					end
				end
			end
		end
	end

	if TomTom.w_points then
		local newpoints = {}
		for k,wp in ipairs(TomTom.w_points) do
			if wp.icon.label == desc then
				self:DebugF(1, "Removing %q from TomTom", wp.icon.label)
				local icon = wp.icon
				icon:Hide()
				TomTom.w_points[k] = nil
				table.insert(TomTom.worldmapIcons, icon)
			end
		end
	end
end
