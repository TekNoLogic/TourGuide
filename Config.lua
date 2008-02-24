

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

	frame:SetScript("OnShow", LibStub("tekKonfig-FadeIn").FadeIn)
	LibStub("tekKonfig-FadeIn").FadeIn(frame)
end)

InterfaceOptions_AddCategory(frame)
