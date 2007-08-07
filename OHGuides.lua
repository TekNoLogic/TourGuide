

local TourGuide = TourGuide
local OptionHouse = DongleStub("OptionHouse-1.0")
local ww = WidgetWarlock
WidgetWarlock = nil


local ROWHEIGHT = 26
local ROWOFFSET = 4
local NUMROWS = math.floor(305/(ROWHEIGHT+4))


local offset = 0



local function OnShow()
--~ 	offset = TourGuide.current - NUMROWS/2 - 1
--~ 	if offset < 0 then offset = 0
--~ 	elseif (offset + NUMROWS) > #TourGuide.actions then offset = #TourGuide.actions - NUMROWS end
	TourGuide:UpdateGuidesPanel()
end


function TourGuide:CreateGuidesPanel()
	local frame = ww.SummonOptionHouseBaseFrame()
	local w = frame:GetWidth()

	frame.rows = {}
	for i=1,NUMROWS do
		local row = CreateFrame("Button", nil, frame)
		row:SetPoint("TOPLEFT", i == 1 and frame or frame.rows[i-1], i == 1 and "TOPLEFT" or "BOTTOMLEFT", 0, -ROWOFFSET)
		row:SetWidth(w/2)
		row:SetHeight(ROWHEIGHT)

		local check = ww.SummonCheckBox(ROWHEIGHT, row, "TOPLEFT", ROWOFFSET, 0)
		local text = ww.SummonFontString(row, nil, nil, "GameFontNormal", nil, "LEFT", check, "RIGHT", ROWOFFSET, 0)

--~ 		check:SetScript("OnClick", function(f) self:SetTurnedIn(row.i, f:GetChecked()) end)

		row.text = text
--~ 		row.detail = detail
		row.check = check
--~ 		row.icon = icon
		frame.rows[i] = row
	end

--~ 	frame:EnableMouseWheel()
--~ 	frame:SetScript("OnMouseWheel", function(f, val)
--~ 		offset = offset - val
--~ 		if offset < 0 then offset = 0
--~ 		elseif (offset + NUMROWS) > #self.actions then offset = #self.actions - NUMROWS end
--~ 		self:UpdateOHPanel()
--~ 	end)

	self.OHGuidesFrame = frame
	frame:SetScript("OnShow", OnShow)
	OnShow()
--~ 	self:UpdateGuidesPanel()
	return frame
end


function TourGuide:UpdateGuidesPanel()
	if not self.OHGuidesFrame or not self.OHGuidesFrame:IsVisible() then return end
	for i,row in ipairs(self.OHGuidesFrame.rows) do
--~ 		row.i = i + offset

		local name = self.guidelist[i]

		row.text:SetText(name)
		row.check:SetChecked(self.db.char.currentguide == name)
	end
end

