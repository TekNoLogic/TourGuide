

local TourGuide = TourGuide
local ww = WidgetWarlock


local ROWHEIGHT = 26
local ROWOFFSET = 4
local NUMROWS = math.floor(305/(ROWHEIGHT+4))


local offset = 0
local rows = {}
local frame


local function OnShow(self)
	offset = TourGuide.current - NUMROWS/2 - 1
	if offset < 0 then offset = 0
	elseif (offset + NUMROWS) > #TourGuide.actions then offset = #TourGuide.actions - NUMROWS end
	TourGuide:UpdateOHPanel()

	self:SetAlpha(0)
	self:SetScript("OnUpdate", ww.FadeIn)
end


function TourGuide:CreateObjectivePanel()
	frame = CreateFrame("Frame", nil, UIParent)

	for i=1,NUMROWS do
		local row = CreateFrame("Button", nil, frame)
		row:SetPoint("TOPLEFT", i == 1 and frame or rows[i-1], i == 1 and "TOPLEFT" or "BOTTOMLEFT", 0, -ROWOFFSET)
		row:SetWidth(630)
		row:SetHeight(ROWHEIGHT)

		local check = ww.SummonCheckBox(ROWHEIGHT, row, "TOPLEFT", ROWOFFSET, 0)
		local icon = ww.SummonTexture(row, ROWHEIGHT, ROWHEIGHT, nil, "TOPLEFT", check, "TOPRIGHT", ROWOFFSET, 0)
		local text = ww.SummonFontString(row, nil, nil, "GameFontNormal", nil, "LEFT", icon, "RIGHT", ROWOFFSET, 0)
		local detail = ww.SummonFontString(row, nil, nil, "GameFontNormal", nil, "RIGHT", -ROWOFFSET, 0)
		detail:SetPoint("LEFT", text, "RIGHT", ROWOFFSET*3, 0)
		detail:SetJustifyH("RIGHT")
		detail:SetTextColor(240/255, 121/255, 2/255)

		check:SetScript("OnClick", function(f) self:SetTurnedIn(row.i, f:GetChecked()) end)

		row.text = text
		row.detail = detail
		row.check = check
		row.icon = icon
		rows[i] = row
	end

	frame:EnableMouseWheel()
	frame:SetScript("OnMouseWheel", function(f, val)
		offset = offset - val
		if (offset + NUMROWS) > #self.actions then offset = #self.actions - NUMROWS end
		if offset < 0 then offset = 0 end
		self:UpdateOHPanel()
	end)

	frame:SetScript("OnShow", OnShow)
	ww.SetFadeTime(frame, 0.5)
	OnShow(frame)
	return frame
end


local accepted = {}
function TourGuide:UpdateOHPanel()
	if not frame or not frame:IsVisible() then return end

	for i in pairs(accepted) do accepted[i] = nil end

	for i=1,offset-1 do
		local action, name, note, logi, complete, hasitem, turnedin, fullquestname = self:GetObjectiveInfo(i + offset)
		if name then
			local shortname = name:gsub("%s%(Part %d+%)", "")
			if action == "ACCEPT" and not turnedin and (accepted[name] or not accepted[shortname]) then
				accepted[name] = true
				accepted[shortname] = true
			end
		end
	end

	for i,row in ipairs(rows) do
		row.i = i + offset
		local action, name, note, logi, complete, hasitem, turnedin, fullquestname = self:GetObjectiveInfo(i + offset)
		if not name then row:Hide()
		else
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
			row.detail:SetText(note)
			row.check:SetChecked(checked)
		end
	end
end



