
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


--~ TODO: function TourGuide:PurgeWaypoints(desc)
--~ end
