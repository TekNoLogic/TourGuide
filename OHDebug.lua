
local function OnMouseWheel(frame, delta)
	if delta > 0 then
		if IsShiftKeyDown() then frame:ScrollToTop()
		else frame:ScrollUp() end
	elseif delta < 0 then
		if IsShiftKeyDown() then frame:ScrollToBottom()
		else frame:ScrollDown() end
	end
end


local f = CreateFrame("ScrollingMessageFrame", nil, UIParent)
f:SetMaxLines(250)
f:SetFontObject(ChatFontNormal)
f:SetJustifyH("LEFT")
f:SetFading(false)
f:EnableMouseWheel(true)
f:SetScript("OnMouseWheel", OnMouseWheel)
f:SetScript("OnHide", f.ScrollToBottom)
f:Hide()


local orig = f.AddMessage
f.AddMessage = function(self, txt, ...)
	local newtext = txt:gsub("TourGuide|r:", date("%X").."|r", 1)
	return orig(self, newtext, ...)
end


TourGuideOHDebugFrame = f


function TourGuideOHDebugFunc()
	f:SetParent(OptionHouseOptionsFrame)
	f:SetFrameStrata(OptionHouseOptionsFrame:GetFrameStrata())
	f:SetFrameLevel(OptionHouseOptionsFrame:GetFrameLevel())
	f:ClearAllPoints()
	f:SetWidth(630)
	f:SetHeight(305)
	f:SetPoint("TOPLEFT", 190, -103)
	f:Show()

	return f
end

