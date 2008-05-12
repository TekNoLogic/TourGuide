

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
	mapquestgivers:SetScript("OnClick", function(self) checksound(self); TourGuide.db.char.mapquestgivers = not TourGuide.db.char.mapquestgivers end)
	mapquestgivers:SetChecked(TourGuide.db.char.mapquestgivers)

	frame:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(frame)


LibStub("tekKonfig-AboutPanel").new("Tour Guide", "TourGuide")
