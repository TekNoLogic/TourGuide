

WidgetWarlock = {}


WidgetWarlock.TooltipBorderBG = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}


function WidgetWarlock.SummonCheckBox(size, parent, ...)
	local check = CreateFrame("CheckButton", nil, parent)
	check:SetWidth(size)
	check:SetHeight(size)
	if select(1, ...) then check:SetPoint(...) end

	check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

	return check
end


function WidgetWarlock.SummonOptionHouseBaseFrame(frametype)
	local frame = CreateFrame(frametype or "Frame", nil, OptionHouseOptionsFrame)
	frame:SetWidth(630)
	frame:SetHeight(305)
	frame:SetPoint("TOPLEFT", 190, -103)
	return frame
end



function WidgetWarlock.SummonTexture(parent, w, h, texture, ...)
	local tex = parent:CreateTexture()
	tex:SetWidth(w)
	tex:SetHeight(h)
	tex:SetTexture(texture)
	if select(1, ...) then tex:SetPoint(...) end
	return tex
end


function WidgetWarlock.SummonFontString(parent, a1, a2, inherit, text, ...)
	local fs = parent:CreateFontString(a1, a2, inherit)
	fs:SetText(text)
	if select(1, ...) then fs:SetPoint(...) end
	return fs
end
