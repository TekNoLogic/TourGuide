

local TourGuide = TourGuide
local OptionHouse = DongleStub("OptionHouse-1.0")
local ww = WidgetWarlock
WidgetWarlock = nil


local ROWHEIGHT = 22
local NUMROWS = math.floor(305/(ROWHEIGHT))


local offset = 0
local rows = {}
local frame


local function OnShow(self)
	TourGuide:UpdateGuidesPanel()

	self:SetAlpha(0)
	self:SetScript("OnUpdate", ww.FadeIn)
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
	frame = CreateFrame("Frame", nil, UIParent)

	rows = {}
	for i=1,NUMROWS*2 do
		local anchor, point
		if i == 1 then anchor, point, point2 = frame, "TOPLEFT", "CENTER"
		elseif i <= NUMROWS then anchor, point, point2 = rows[i-1], "BOTTOMLEFT", "CENTER"
		else anchor, point, point2 = rows[i-NUMROWS], "TOPRIGHT", "RIGHT" end

		local row = CreateFrame("CheckButton", nil, frame)
		row:SetPoint("TOPLEFT", anchor, point)
		row:SetPoint("RIGHT", frame, point2)
		row:SetHeight(ROWHEIGHT)

		local highlight = ww.SummonTexture(row, nil, nil, "Interface\\HelpFrame\\HelpFrameButton-Highlight")
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
	ww.SetFadeTime(frame, 0.5)
	OnShow(frame)
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

