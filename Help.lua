

local TourGuide = TourGuide
local GAP = 8
local tekcheck = LibStub("tekKonfig-Checkbox")
local ww = WidgetWarlock


local ROWHEIGHT, ROWOFFSET = 24, 3
local descriptions = {
	ACCEPT = "Accept quest",
	COMPLETE = "Complete quest",
	TURNIN = "Turn in quest",
	KILL = "Kill mob",
	RUN = "Run to",
	FLY = "Fly to",
	SETHEARTH = "Set hearth",
	HEARTH = "Use hearth",
	NOTE = "Note",
	USE = "Use item",
	BUY = "Buy item",
	BOAT = "Boat to",
	GETFLIGHTPOINT = "Get flight point",
}
local order = {"ACCEPT", "TURNIN", "COMPLETE", "KILL", "SETHEARTH", "HEARTH", "GETFLIGHTPOINT", "FLY", "BUY", "RUN", "USE", "BOAT", "NOTE"}


local frame = CreateFrame("Frame", nil, UIParent)
TourGuide.configpanel = frame
frame.name = "Help"
frame.parent = "Tour Guide"
frame:Hide()
frame:SetScript("OnShow", function()
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Tour Guide - Help", "Confused?  GOOD!  Okey, fine... here's a few hints.")

	local anchor
	for i,icontype in ipairs(order) do
--~ 		for icontype,desc in pairs(descriptions) do
		local f = CreateFrame("Frame", nil, frame)
		if not anchor then
			f:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
			anchor = f
		elseif i % 2 == 0 then
			f:SetPoint("TOP", anchor, "TOP")
			f:SetPoint("LEFT", frame, "CENTER", 2, 0)
--~ 		elseif i == math.ceil(#order/2) then
--~ 			f:SetPoint("TOP", subtitle, "BOTTOM", 0, -GAP)
--~ 			f:SetPoint("LEFT", frame, "CENTER", 2, 0)
		else
			f:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT")
			anchor = f
		end
		f:SetPoint("RIGHT", -16, 0)
		f:SetHeight(ROWHEIGHT)

		local icon = ww.SummonTexture(f, nil, ROWHEIGHT-ROWOFFSET, ROWHEIGHT-ROWOFFSET, TourGuide.icons[icontype], "LEFT")
		if icontype ~= "ACCEPT" and icontype ~= "TURNIN" then icon:SetTexCoord(4/48, 44/48, 4/48, 44/48) end

		local text = ww.SummonFontString(f, nil, "GameFontHighlight", descriptions[icontype], "LEFT", icon, "RIGHT", ROWOFFSET, 0)
	end

	frame:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(frame)
