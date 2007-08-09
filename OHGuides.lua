

local TourGuide = TourGuide
local OptionHouse = DongleStub("OptionHouse-1.0")
local ww = WidgetWarlock
WidgetWarlock = nil


local ROWHEIGHT = 22
local NUMROWS = math.floor(305/(ROWHEIGHT))


local offset, elapsed = 0, 0
local rows = {}
local frame, fader


local function OnShow()
	TourGuide:UpdateGuidesPanel()

	frame:SetAlpha(0)
	elapsed = 0
	fader:Show()
end


local function OnClick(self)
	local text = self.text:GetText()
	if not text then self:SetChecked(false)
	else
		TourGuide:LoadGuide(text)
		TourGuide:UpdateGuidesPanel()
		TourGuide:UpdateStatusFrame()
	end
end


function TourGuide:CreateGuidesPanel()
	fader = CreateFrame("Frame")
	fader:Hide()
	fader:SetScript("OnUpdate", function(self, elap)
		elapsed = elapsed + elap
		if elapsed > 1 then
			self:Hide()
			frame:SetAlpha(1)
		else frame:SetAlpha(elapsed) end
	end)

	frame = ww.SummonOptionHouseBaseFrame()
	local w = frame:GetWidth()

	rows = {}
	for i=1,NUMROWS*2 do
		local anchor, point
		if i == 1 then anchor, point = frame, "TOPLEFT"
		elseif i <= NUMROWS then anchor, point = rows[i-1], "BOTTOMLEFT"
		else anchor, point = rows[i-NUMROWS], "TOPRIGHT" end

		local row = CreateFrame("CheckButton", nil, frame)
		row:SetPoint("TOPLEFT", anchor, point)
		row:SetWidth(w/2)
		row:SetHeight(ROWHEIGHT)

		local highlight = ww.SummonTexture(row, w/2, ROWHEIGHT, "Interface\\HelpFrame\\HelpFrameButton-Highlight")
		highlight:SetTexCoord(0, 1, 0, 0.578125)
		highlight:SetAllPoints()
		row:SetHighlightTexture(highlight)
		row:SetCheckedTexture(highlight)

		local text = ww.SummonFontString(row, nil, nil, "GameFontNormal", nil, "LEFT", 6, 0)

		row:SetScript("OnClick", OnClick)

		row.text = text
		rows[i] = row
	end

--~ 	frame:EnableMouseWheel()
--~ 	frame:SetScript("OnMouseWheel", function(f, val)
--~ 		offset = offset - val*NUMROWS
--~ 		if (offset + NUMROWS*2) > #self.guidelist then offset = #self.guidelist - NUMROWS*2 end
--~ 		if offset < 0 then offset = 0 end
--~ 		self:UpdateGuidesPanel()
--~ 	end)

	frame:SetScript("OnShow", OnShow)
	OnShow()
	return frame
end


function TourGuide:UpdateGuidesPanel()
	if not frame or not frame:IsVisible() then return end
	for i,row in ipairs(rows) do
		row.i = i + offset

		local name = self.guidelist[i]

		row.text:SetText(name)
		row:SetChecked(self.db.char.currentguide == name)
	end
end

