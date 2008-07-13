

local TourGuide = TourGuide
local GAP = 8
local tekcheck = LibStub("tekKonfig-Checkbox")


local frame = CreateFrame("Frame", nil, UIParent)
TourGuide.configpanel = frame
frame.name = "Tour Guide"
frame:Hide()
frame:SetScript("OnShow", function()
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Tour Guide", "These settings are saved on a per-char basis.")

	local qtrack = tekcheck.new(frame, nil, "Automatically track quests", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	qtrack.tiptext = "Automatically toggle the default quest tracker for current 'complete quest' objectives."
	local checksound = qtrack:GetScript("OnClick")
	qtrack:SetScript("OnClick", function(self) checksound(self); TourGuide.db.char.trackquests = not TourGuide.db.char.trackquests end)
	qtrack:SetChecked(TourGuide.db.char.trackquests)

	local mapnotecoords = tekcheck.new(frame, nil, "Map note coords", "TOPLEFT", qtrack, "BOTTOMLEFT", 0, -GAP)
	mapnotecoords.tiptext = "Map coordinates found in tooltip notes (requires TomTom)."
	mapnotecoords:SetScript("OnClick", function(self) checksound(self); TourGuide.db.char.mapnotecoords = not TourGuide.db.char.mapnotecoords end)
	mapnotecoords:SetChecked(TourGuide.db.char.mapnotecoords)

	local mapquestgivers = tekcheck.new(frame, nil, "Automatically map questgivers", "TOPLEFT", mapnotecoords, "BOTTOMLEFT", 0, -GAP)
	mapquestgivers.tiptext = "Automatically map questgivers for accept and turnin objectives (requires LightHeaded and TomTom)."
	mapquestgivers:SetChecked(TourGuide.db.char.mapquestgivers)

	local mapquestgivernotes, mapquestgivernoteslabel = tekcheck.new(frame, nil, "Always map coords from notes", "TOPLEFT", mapquestgivers, "BOTTOMLEFT", GAP*2, -GAP)
	mapquestgivernotes.tiptext = "Map note coords even when LightHeaded provides coords."
	mapquestgivernotes:SetScript("OnClick", function(self) checksound(self); TourGuide.db.char.alwaysmapnotecoords = not TourGuide.db.char.alwaysmapnotecoords end)
	mapquestgivernotes:SetChecked(TourGuide.db.char.alwaysmapnotecoords)
	if TourGuide.db.char.mapquestgivers then
		mapquestgivernotes:Enable()
		mapquestgivernoteslabel:SetFontObject(GameFontHighlight)
	else
		mapquestgivernotes:Disable()
		mapquestgivernoteslabel:SetFontObject(GameFontDisable)
	end

	mapquestgivers:SetScript("OnClick", function(self)
		checksound(self)
		TourGuide.db.char.mapquestgivers = not TourGuide.db.char.mapquestgivers
		if TourGuide.db.char.mapquestgivers then
			mapquestgivernotes:Enable()
			mapquestgivernoteslabel:SetFontObject(GameFontHighlight)
		else
			mapquestgivernotes:Disable()
			mapquestgivernoteslabel:SetFontObject(GameFontDisable)
		end
	end)

	frame:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(frame)


LibStub("tekKonfig-AboutPanel").new("Tour Guide", "TourGuide")


----------------------------
--      LDB Launcher      --
----------------------------

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:GetDataObjectByName("TourGuideLauncher") or ldb:NewDataObject("TourGuideLauncher")
dataobj.launcher = true
dataobj.tocname = "TourGuide"
dataobj.icon = "Interface\\Icons\\Ability_Hunter_Pathfinding"
dataobj.OnClick = function() InterfaceOptionsFrame_OpenToFrame(frame) end
