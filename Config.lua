

local TourGuide = TourGuide
local L = TourGuide.Locale
local ww = WidgetWarlock


local frame = CreateFrame("Frame", nil, UIParent)
TourGuide.configpanel = frame
frame.name = "Tour Guide"
frame:Hide()
frame:SetScript("OnShow", function()
	local qtrack = ww.SummonCheckBox(22, frame, "TOPLEFT", 5, -5)
	ww.SummonFontString(qtrack, "OVERLAY", "GameFontNormalSmall", "Automatically track quests", "LEFT", qtrack, "RIGHT", 5, 0)
	qtrack:SetScript("OnClick", function() TourGuide.db.char.trackquests = not TourGuide.db.char.trackquests end)


	local function OnShow(f)
		qtrack:SetChecked(TourGuide.db.char.trackquests)

		f:SetAlpha(0)
		f:SetScript("OnUpdate", ww.FadeIn)
	end

	frame:SetScript("OnShow", OnShow)
	ww.SetFadeTime(frame, 0.5)
	OnShow(frame)
end)

InterfaceOptions_AddCategory(frame)
