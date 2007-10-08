

local TourGuide = TourGuide
local ww = WidgetWarlock


local ROWHEIGHT = 26
local ROWOFFSET = 4
local NUMROWS = math.floor(305/(ROWHEIGHT+4))


local offset = 0
local rows = {}
local frame, scrollbar


local function OnShow(self)
	scrollbar:SetMinMaxValues(1, math.max(#TourGuide.actions - NUMROWS, 1))
	scrollbar:SetValue(TourGuide.current - NUMROWS/2 - 1)

	self:SetAlpha(0)
	self:SetScript("OnUpdate", ww.FadeIn)
end


local function HideTooltip() GameTooltip:Hide() end

local function ShowTooltip(f)
	if f.text:GetStringWidth() <= f:GetWidth() then return end

	GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
	GameTooltip:SetText(f.text:GetText(), nil, nil, nil, nil, true)
end


function TourGuide:CreateObjectivePanel()
	frame = CreateFrame("Frame", nil, UIParent)
	frame:SetFrameStrata("DIALOG")

	scrollbar = CreateFrame("Slider", "TourGuideOHScroll", frame, "UIPanelScrollBarTemplate")
	scrollbar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -16)
	scrollbar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 16)
	scrollbar:SetScript("OnValueChanged", function(f, val) self:UpdateOHPanel(val) end)
	TourGuideOHScrollScrollUpButton:SetScript("OnClick", function(f)
		scrollbar:SetValue(offset - NUMROWS)
		PlaySound("UChatScrollButton")
	end)

	TourGuideOHScrollScrollDownButton:SetScript("OnClick", function(f)
		scrollbar:SetValue(offset + NUMROWS)
		PlaySound("UChatScrollButton")
	end)

	local uptext = scrollbar:CreateTexture(nil, "BACKGROUND")
	uptext:SetWidth(31)
	uptext:SetHeight(256)
	uptext:SetPoint("TOPLEFT", TourGuideOHScrollScrollUpButton, "TOPLEFT", -7, 5)
	uptext:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
	uptext:SetTexCoord(0, 0.484375, 0, 1.0)

	local downtex = scrollbar:CreateTexture(nil, "BACKGROUND")
	downtex:SetWidth(31)
	downtex:SetHeight(106)
	downtex:SetPoint("BOTTOMLEFT", TourGuideOHScrollScrollDownButton, "BOTTOMLEFT", -7, -3)
	downtex:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
	downtex:SetTexCoord(0.515625, 1.0, 0, 0.4140625)

	local function LevelCorrection(f) f:SetFrameLevel(frame:GetFrameLevel()+1); f:SetScript("OnShow", nil) end
	for i=1,NUMROWS do
		local row = CreateFrame("Button", nil, frame)
		row:SetPoint("TOPLEFT", i == 1 and frame or rows[i-1], i == 1 and "TOPLEFT" or "BOTTOMLEFT", 0, -ROWOFFSET)
		row:SetWidth(630)
		row:SetHeight(ROWHEIGHT)

		local check = ww.SummonCheckBox(ROWHEIGHT, row, "TOPLEFT", ROWOFFSET, 0)
		local icon = ww.SummonTexture(row, nil, ROWHEIGHT, ROWHEIGHT, nil, "TOPLEFT", check, "TOPRIGHT", ROWOFFSET, 0)
		local text = ww.SummonFontString(row, nil, "GameFontNormal", nil, "LEFT", icon, "RIGHT", ROWOFFSET, 0)

		local detailhover = CreateFrame("Button", nil, frame)
		detailhover:SetHeight(ROWHEIGHT)
		detailhover:SetPoint("LEFT", text, "RIGHT", ROWOFFSET*3, 0)
		detailhover:SetPoint("RIGHT", scrollbar, "LEFT", -ROWOFFSET-7, 0)
		detailhover:SetScript("OnEnter", ShowTooltip)
		detailhover:SetScript("OnLeave", HideTooltip)
		detailhover:SetScript("OnShow", LevelCorrection)

		local detail = ww.SummonFontString(detailhover, nil, "GameFontNormal", nil)
		detail:SetAllPoints(detailhover)
		detail:SetJustifyH("RIGHT")
		detail:SetTextColor(240/255, 121/255, 2/255)
		detailhover.text = detail

		check:SetScript("OnClick", function(f) self:SetTurnedIn(row.i, f:GetChecked()) end)

		row.text = text
		row.detail = detail
		row.check = check
		row.icon = icon
		rows[i] = row
	end

	frame:EnableMouseWheel()
	frame:SetScript("OnMouseWheel", function(f, val)
		scrollbar:SetValue(offset - val)
	end)

	frame:SetScript("OnShow", OnShow)
	ww.SetFadeTime(frame, 0.5)
	OnShow(frame)
	return frame
end


local accepted = {}
function TourGuide:UpdateOHPanel(value)
	if not frame or not frame:IsVisible() then return end

	if value then offset = math.floor(value) end
	if (offset + NUMROWS) > #self.actions then offset = #self.actions - NUMROWS end
	if offset < 0 then offset = 0 end

	for i in pairs(accepted) do accepted[i] = nil end

	for i=1,offset-1 do
		local action, name = self:GetObjectiveInfo(i + offset)
		if name then
			local shortname = name:gsub("%s%(Part %d+%)", "")
			if action == "ACCEPT" and not self:GetObjectiveStatus(i + offset) and (accepted[name] or not accepted[shortname]) then
				accepted[name] = true
				accepted[shortname] = true
			end
		end
	end

	for i,row in ipairs(rows) do
		row.i = i + offset
		local action, name = self:GetObjectiveInfo(i + offset)
		if not name then row:Hide()
		else
			local turnedin, logi, complete = self:GetObjectiveStatus(i + offset)
			row:Show()

			local shortname = name:gsub("%s%(Part %d+%)", "")
			logi = not turnedin and (accepted[name] or not accepted[shortname]) and logi
			complete = not turnedin and (accepted[name] or not accepted[shortname]) and complete
			local checked = turnedin or action == "ACCEPT" and logi or action == "COMPLETE" and complete

			if action == "ACCEPT" and logi then
				accepted[name] = true
				accepted[shortname] = true
			end

			row.icon:SetTexture(self.icons[action])
			row.text:SetText(name)
			row.detail:SetText(self:GetObjectiveTag("N", i + offset))
			row.check:SetChecked(checked)
		end
	end
end



