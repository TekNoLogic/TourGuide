

local ww = {}


function ww.SummonCheckBox(size, parent, ...)
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


function ww.SummonOptionHouseBaseFrame(frametype)
	local frame = CreateFrame(frametype or "Frame", nil, OptionHouseOptionsFrame)
	frame:SetWidth(630)
	frame:SetHeight(305)
	frame:SetPoint("TOPLEFT", 190, -103)
	return frame
end



function ww.SummonTexture(parent, w, h, texture, ...)
	local tex = parent:CreateTexture()
	tex:SetWidth(w)
	tex:SetHeight(h)
	tex:SetTexture(texture)
	if select(1, ...) then tex:SetPoint(...) end
	return tex
end


function ww.SummonFontString(parent, a1, a2, inherit, text, ...)
	local fs = parent:CreateFontString(a1, a2, inherit)
	fs:SetText(text)
	if select(1, ...) then fs:SetPoint(...) end
	return fs
end


--------------


local TourGuide = TourGuide
local OptionHouse = DongleStub("OptionHouse-1.0")


local ROWHEIGHT = 26
local ROWOFFSET = 4
local NUMROWS = math.floor(305/(ROWHEIGHT+4))


local offset = 0

local L = {
	Accepted = "Accepted",
	Complete = "|cffF07902Complete",
	Finished = "|cff00ff00Finished",
}

function TourGuide:CreateOHPanel()
	local self = TourGuide

	local frame = ww.SummonOptionHouseBaseFrame()
	frame:SetScript("OnShow", function() self:UpdateOHPanel() end)

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

--~ 	local scroll = CreateFrame("ScrollFrame", nil, frame)
--~ 	scroll:SetAllPoints()
	frame:EnableMouseWheel()
	frame:SetScript("OnMouseWheel", function(f, val)
		offset = offset - val
--~ 		else offset = offset + val end
		if offset < 0 then offset = 0 end
		if (offset + NUMROWS) > #self.actions then offset = #self.actions - NUMROWS end
		self:UpdateOHPanel()
	end)

	self.OHFrame = frame
	self:UpdateOHPanel()
	return frame
end


function TourGuide:UpdateOHPanel()
	if not self.OHFrame then return end
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

