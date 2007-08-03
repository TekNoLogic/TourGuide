

local TourGuide = TourGuide
local OptionHouse = DongleStub("OptionHouse-1.0")
local ww = WidgetWarlock
WidgetWarlock = nil


local ROWHEIGHT = 26
local ROWOFFSET = 4
local NUMROWS = math.floor(305/(ROWHEIGHT+4))


local offset = 0

local L = {
	Accepted = "Accepted",
	Complete = "|cffF07902Complete",
	Finished = "|cff00ff00Finished",
}


local function OnShow()
	offset = TourGuide.current - NUMROWS/2 - 1
	if offset < 0 then offset = 0
	elseif (offset + NUMROWS) > #TourGuide.actions then offset = #TourGuide.actions - NUMROWS end
	TourGuide:UpdateOHPanel()
end


function TourGuide:CreateOHPanel()
	local self = TourGuide

	local frame = ww.SummonOptionHouseBaseFrame()

	frame.rows = {}
	for i=1,NUMROWS do
		local row = CreateFrame("Button", nil, frame)
		row:SetPoint("TOPLEFT", i == 1 and frame or frame.rows[i-1], i == 1 and "TOPLEFT" or "BOTTOMLEFT", 0, -ROWOFFSET)
		row:SetWidth(630)
		row:SetHeight(ROWHEIGHT)

		local check = ww.SummonCheckBox(ROWHEIGHT, row, "TOPLEFT", ROWOFFSET, 0)
		local icon = ww.SummonTexture(row, ROWHEIGHT, ROWHEIGHT, nil, "TOPLEFT", check, "TOPRIGHT", ROWOFFSET, 0)
		local text = ww.SummonFontString(row, nil, nil, "GameFontNormal", nil, "LEFT", icon, "RIGHT", ROWOFFSET, 0)

		check:SetScript("OnClick", function(f)
			self.turnedin[text:GetText()] = f:GetChecked()
			self:UpdateOHPanel()
			self:UpdateStatusFrame()
		end)

		row.text = text
		row.status = status
		row.check = check
		row.icon = icon
		frame.rows[i] = row
	end

	frame:EnableMouseWheel()
	frame:SetScript("OnMouseWheel", function(f, val)
		offset = offset - val
		if offset < 0 then offset = 0
		elseif (offset + NUMROWS) > #self.actions then offset = #self.actions - NUMROWS end
		self:UpdateOHPanel()
	end)

	self.OHFrame = frame
	frame:SetScript("OnShow", OnShow)
	OnShow()
	return frame
end


function TourGuide:UpdateOHPanel()
	if not self.OHFrame or not self.OHFrame:IsVisible() then return end
	for i,row in ipairs(self.OHFrame.rows) do
		local action, name, note, logi, complete, itemstarted = self:GetObjectiveInfo(i+offset)
		local checked = self.turnedin[name] or (action == "ACCEPT" and logi) or (action == "COMPLETE" and complete)

		row.icon:SetTexture(self.icons[action])
		row.text:SetText(name)
		row.check:SetChecked(checked)
	end
end


local _, title = GetAddOnInfo("TourGuide")
local author, version = GetAddOnMetadata("TourGuide", "Author"), GetAddOnMetadata("TourGuide", "Version")
local oh = OptionHouse:RegisterAddOn("Tour Guide", title, author, version)
oh:RegisterCategory("Eversong Woods", TourGuide.CreateOHPanel)

