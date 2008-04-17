
local L = TourGuide.Locale

local zonei, zonec, zonenames = {}, {}, {}
for ci,c in pairs{GetMapContinents()} do
	zonenames[ci] = {GetMapZones(ci)}
	for zi,z in pairs(zonenames[ci]) do
		zonei[z], zonec[z] = zi, ci
	end
end


local cache = {}
local function MapPoint(zone, x, y, desc)
	TourGuide:DebugF(1, "Mapping %q - %s (%.2f, %.2f)", desc, zone, x, y)
	local zi, zc = zone and zonei[zone], zone and zonec[zone]
	if not zi then
		if zone then TourGuide:PrintF("Cannot find zone %q, using current zone.", zone)
		else TourGuide:Print("No zone provided, using current zone.") end

		zi, zc = GetCurrentMapZone(), GetCurrentMapContinent()
		zone = zonenames[zc][zi]
	end

	if TomTom then table.insert(cache, TomTom:AddZWaypoint(zc, zi, x, y, "[TG] "..desc, false))
	elseif Cartographer_Waypoints then
		local pt = NotePoint:new(zone, x/100, y/100, "[TG] "..desc)
		Cartographer_Waypoints:AddWaypoint(pt)
		table.insert(cache, pt.WaypointID)
	end
end


local temp = {}
function TourGuide:ParseAndMapCoords(note, desc, zone)
	if TomTom and TomTom.RemoveWaypoint then
		while cache[1] do TomTom:RemoveWaypoint(table.remove(cache)) end
	elseif Cartographer_Waypoints then
		while cache[1] do Cartographer_Waypoints:CancelWaypoint(table.remove(cache)) end
	end

	if not note then return end

	for x,y in note:gmatch(L.COORD_MATCH) do table.insert(temp, tonumber(y)); table.insert(temp, tonumber(x)) end
	while temp[1] do MapPoint(zone, table.remove(temp), table.remove(temp), desc) end
end

