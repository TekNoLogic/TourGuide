

local TourGuide = TourGuide
local L = TourGuide.Locale
local ww = WidgetWarlock


local ROWHEIGHT = 26
local ROWOFFSET = 4
local NUMROWS = math.floor(305/(ROWHEIGHT+4))


local offset = 0
local rows = {}
local frame, scrollbar, upbutt, downbutt, title, completed


local function OnShow(self)
	local newval = math.max(0, (TourGuide.current or 0) - NUMROWS/2 - 1)

	scrollbar:SetMinMaxValues(0, math.max(#TourGuide.actions - NUMROWS, 1))
	scrollbar:SetValue(newval)

	TourGuide:UpdateOHPanel()

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

	title = ww.SummonFontString(frame, nil, "SubZoneTextFont", nil, "BOTTOM", frame, "TOP", 0, 10)
	local fontname, fontheight, fontflags = title:GetFont()
	title:SetFont(fontname, 18, fontflags)

	completed = ww.SummonFontString(frame, nil, "NumberFontNormalLarge", nil, "BOTTOMRIGHT", frame, "TOPRIGHT", 0, 10)

	scrollbar, upbutt, downbutt = ww.ConjureScrollBar(frame, true)
	scrollbar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -19)
	scrollbar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 16)
	scrollbar:SetScript("OnValueChanged", function(f, val) self:UpdateOHPanel(val) end)

	upbutt:SetScript("OnClick", function(f)
		scrollbar:SetValue(offset - NUMROWS + 1)
		PlaySound("UChatScrollButton")
	end)

	downbutt:SetScript("OnClick", function(f)
		scrollbar:SetValue(offset + NUMROWS - 1)
		PlaySound("UChatScrollButton")
	end)

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

	title:SetText(self.db.char.currentguide or "No Guide Loaded")
	local r,g,b = self.ColorGradient((self.current-1)/#self.actions)
	completed:SetText(string.format("|cff%02x%02x%02x%d%%", r*255, g*255, b*255, (self.current-1)/#self.actions*100))

	self.guidechanged = nil
	if value then offset = math.floor(value) end
	if (offset + NUMROWS) > #self.actions then offset = #self.actions - NUMROWS end
	if offset < 0 then offset = 0 end

	if offset == 0 then upbutt:Disable() else upbutt:Enable() end
	if offset == (#self.actions - NUMROWS) then downbutt:Disable() else downbutt:Enable() end

	for i in pairs(accepted) do accepted[i] = nil end

	for i in pairs(self.actions) do
		local action, name = self:GetObjectiveInfo(i)
		local _, _, quest, part = name:find(L.PART_FIND)
		if quest and not accepted[quest] and not self:GetObjectiveStatus(i) then accepted[quest] = name end
	end

	for i,row in ipairs(rows) do
		row.i = i + offset
		local action, name = self:GetObjectiveInfo(i + offset)
		if not name then row:Hide()
		else
			local turnedin, logi, complete = self:GetObjectiveStatus(i + offset)
			local optional = self:GetObjectiveTag("O", i + offset)
			row:Show()

			local shortname = name:gsub(L.PART_GSUB, "")
			logi = not turnedin and (not accepted[shortname] or (accepted[shortname] == name)) and logi
			complete = not turnedin and (not accepted[shortname] or (accepted[shortname] == name)) and complete
			local checked = turnedin or action == "ACCEPT" and logi or action == "COMPLETE" and complete

			row.icon:SetTexture(self.icons[action])
			if action ~= "ACCEPT" and action ~= "TURNIN" then row.icon:SetTexCoord(4/48, 44/48, 4/48, 44/48) end
			row.text:SetText(name..(optional and " |cff808080(Optional)" or ""))
			row.detail:SetText(self:GetObjectiveTag("N", i + offset))
			row.check:SetChecked(checked)

			if (TourGuide.current > (i + offset)) and optional and not checked then
				row.text:SetTextColor(0.5, 0.5, 0.5)
--~ 				row.check:SetChecked(true)
				row.check:Disable()
			else
				row.text:SetTextColor(1, 0.82, 0)
				row.check:Enable()
			end
		end
	end
end



