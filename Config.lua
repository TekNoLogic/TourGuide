

local TourGuide = TourGuide
local L = TourGuide.Locale
local NUMROWS, ROWHEIGHT, GAP, EDGEGAP, CENTEROFFSET = 26, 17, 8, 16, 28
local HELPROWHEIGHT, ROWOFFSET = 24, 3
local offset, rows = 0, {}
local tekcheck = LibStub("tekKonfig-Checkbox")
local tekbutton = LibStub("tekKonfig-Button")
local ww = WidgetWarlock


local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
TourGuide.configpanel = frame
frame.name = "Tour Guide"
frame:Hide()
frame:SetScript("OnShow", function()
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Tour Guide", L["These settings are saved on a per-char basis. Upon completion of a guide the next guide will load automatically.  Completed guides can be reset by shift-clicking."])

	local qtrack = tekcheck.new(frame, nil, L["Automatically track quests"], "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	qtrack.tiptext = L["Automatically toggle the default quest tracker for current 'complete quest' objectives."]
	local checksound = qtrack:GetScript("OnClick")
	qtrack:SetScript("OnClick", function(self) checksound(self); TourGuide.db.char.trackquests = not TourGuide.db.char.trackquests end)
	qtrack:SetChecked(TourGuide.db.char.trackquests)


	local showstatusframe = tekcheck.new(frame, nil, L["Show status frame"], "TOPLEFT", qtrack, "BOTTOMLEFT", 0, -GAP)
	showstatusframe.tiptext = L["Display the status frame with current quest objective."]
	showstatusframe:SetScript("OnClick", function(self) checksound(self); TourGuide.db.char.showstatusframe = not TourGuide.db.char.showstatusframe; TourGuide:PositionStatusFrame() end)
	showstatusframe:SetChecked(TourGuide.db.char.showstatusframe)

	local resetpos = tekbutton.new_small(frame, "TOP", showstatusframe, "CENTER", 0, 11)
	resetpos:SetPoint("RIGHT", frame, "CENTER", -EDGEGAP/2 - CENTEROFFSET, 0)
	resetpos:SetText(L["Reset"])
	resetpos.tiptext = L["Reset the status frame to the default position"]
	resetpos:SetScript("OnClick", function(self)
		TourGuide.db.profile.statusframepoint, TourGuide.db.profile.statusframex, TourGuide.db.profile.statusframey = nil
		TourGuide:PositionStatusFrame()
	end)


	local showuseitem = tekcheck.new(frame, nil, L["Show item button"], "TOPLEFT", showstatusframe, "BOTTOMLEFT", 0, -GAP)
	showuseitem.tiptext = L["Display a button when you must use an item to start or complete a quest."]
	showuseitem:SetChecked(TourGuide.db.char.showuseitem)

	local resetpos2 = tekbutton.new_small(frame, "TOP", showuseitem, "CENTER", 0, 11)
	resetpos2:SetPoint("RIGHT", frame, "CENTER", -EDGEGAP/2 - CENTEROFFSET, 0)
	resetpos2:SetText(L["Reset"])
	resetpos2.tiptext = L["Reset the item button to the default position"]
	resetpos2:SetScript("OnClick", function(self)
		TourGuide.db.profile.itemframepoint, TourGuide.db.profile.itemframex, TourGuide.db.profile.itemframey = nil
		TourGuide:PositionItemFrame()
	end)

	local showuseitemcomplete, showuseitemcompletelabel = tekcheck.new(frame, nil, L["Show buttom for 'complete' objectives"], "TOPLEFT", showuseitem, "BOTTOMLEFT", GAP*2, -GAP)
	showuseitemcomplete.tiptext = L["The advanced quest tracker in the default UI will show these items.  Enable this if you would rather have TourGuide's button."]
	showuseitemcomplete:SetScript("OnClick", function(self) checksound(self); TourGuide.db.char.showuseitemcomplete = not TourGuide.db.char.showuseitemcomplete; TourGuide:UpdateStatusFrame() end)
	showuseitemcomplete:SetChecked(TourGuide.db.char.showuseitemcomplete)
	if TourGuide.db.char.showuseitem then
		showuseitemcomplete:Enable()
		showuseitemcompletelabel:SetFontObject(GameFontHighlight)
	else
		showuseitemcomplete:Disable()
		showuseitemcompletelabel:SetFontObject(GameFontDisable)
	end

	showuseitem:SetScript("OnClick", function(self)
		checksound(self)
		TourGuide.db.char.showuseitem = not TourGuide.db.char.showuseitem
		TourGuide:UpdateStatusFrame()
		if TourGuide.db.char.showuseitem then
			showuseitemcomplete:Enable()
			showuseitemcompletelabel:SetFontObject(GameFontHighlight)
		else
			showuseitemcomplete:Disable()
			showuseitemcompletelabel:SetFontObject(GameFontDisable)
		end
	end)


	local mapnotecoords = tekcheck.new(frame, nil, L["Map note coords"], "TOPLEFT", showuseitemcomplete, "BOTTOMLEFT", -GAP*2, -GAP)
	mapnotecoords.tiptext = L["Map coordinates found in tooltip notes (requires TomTom)."]
	mapnotecoords:SetScript("OnClick", function(self) checksound(self); TourGuide.db.char.mapnotecoords = not TourGuide.db.char.mapnotecoords end)
	mapnotecoords:SetChecked(TourGuide.db.char.mapnotecoords)

	local mapquestgivers = tekcheck.new(frame, nil, L["Automatically map questgivers"], "TOPLEFT", mapnotecoords, "BOTTOMLEFT", 0, -GAP)
	mapquestgivers.tiptext = L["Automatically map questgivers for accept and turnin objectives (requires LightHeaded and TomTom)."]
	mapquestgivers:SetChecked(TourGuide.db.char.mapquestgivers)

	local mapquestgivernotes, mapquestgivernoteslabel = tekcheck.new(frame, nil, L["Always map coords from notes"], "TOPLEFT", mapquestgivers, "BOTTOMLEFT", GAP*2, -GAP)
	mapquestgivernotes.tiptext = L["Map note coords even when LightHeaded provides coords."]
	mapquestgivernotes:SetScript("OnClick", function(self) checksound(self); TourGuide.db.char.alwaysmapnotecoords = not TourGuide.db.char.alwaysmapnotecoords end)
	mapquestgivernotes:SetChecked(TourGuide.db.char.alwaysmapnotecoords)
	if TourGuide.db.char.mapquestgivers then
		mapquestgivernotes:Enable()
		mapquestgivernoteslabel:SetFontObject(GameFontHighlight)
	else
		mapquestgivernotes:Disable()
		mapquestgivernoteslabel:SetFontObject(GameFontDisable)
	end

	mapquestgivers:SetScript("OnClick", function(self)
		checksound(self)
		TourGuide.db.char.mapquestgivers = not TourGuide.db.char.mapquestgivers
		if TourGuide.db.char.mapquestgivers then
			mapquestgivernotes:Enable()
			mapquestgivernoteslabel:SetFontObject(GameFontHighlight)
		else
			mapquestgivernotes:Disable()
			mapquestgivernoteslabel:SetFontObject(GameFontDisable)
		end
	end)

	local rafmode = tekcheck.new(frame, nil, L["Recruit-a-friend mode"], "TOPLEFT", mapquestgivernotes, "BOTTOMLEFT", -GAP*2, -GAP)
	rafmode.tiptext = L["Use recruit-a-friend modifications to guides, if present."]
	rafmode:SetScript("OnClick", function(self)
		checksound(self)
		TourGuide.db.char.rafmode = not TourGuide.db.char.rafmode
		TourGuide:LoadGuide(TourGuide.db.char.currentguide)
		TourGuide:UpdateStatusFrame()
		TourGuide:UpdateGuidesPanel()
	end)
	rafmode:SetChecked(TourGuide.db.char.rafmode)


	-- Help box
	local descriptions = {
		ACCEPT = L["Accept quest"],
		COMPLETE = L["Complete quest"],
		TURNIN = L["Turn in quest"],
		KILL = L["Kill mob"],
		RUN = L["Run to"],
		FLY = L["Fly to"],
		SETHEARTH = L["Set hearth"],
		HEARTH = L["Use hearth"],
		NOTE = L["Note"],
		USE = L["Use item"],
		BUY = L["Buy item"],
		BOAT = L["Boat to"],
		GETFLIGHTPOINT = L["Get flight point"],
	}
	local order = {
		"ACCEPT",   "SETHEARTH",
		"COMPLETE", "HEARTH",
		"TURNIN",   "GETFLIGHTPOINT",
		"KILL",     "FLY",
		"BUY",      "RUN",
		"USE",      "BOAT",
		"NOTE",
	}


	-- Help box
	local anchor
	local helpbox = LibStub("tekKonfig-Group").new(frame, "Help", "TOP", rafmode, "BOTTOM", 0, -EDGEGAP)
	helpbox:SetPoint("LEFT", frame, EDGEGAP, 0)
	helpbox:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -EDGEGAP/2 - CENTEROFFSET, EDGEGAP)
	for i,icontype in ipairs(order) do
		local f = CreateFrame("Frame", nil, frame)
		if not anchor then
			f:SetPoint("TOPLEFT", helpbox, 16, -12)
			anchor = f
		elseif i % 2 == 0 then
			f:SetPoint("TOP", anchor, "TOP")
			f:SetPoint("LEFT", helpbox, "CENTER", 8, 0)
		else
			f:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT")
			anchor = f
		end
		f:SetPoint("RIGHT", -16, 0)
		f:SetHeight(HELPROWHEIGHT)

		local icon = ww.SummonTexture(f, nil, HELPROWHEIGHT-ROWOFFSET, HELPROWHEIGHT-ROWOFFSET, TourGuide.icons[icontype], "LEFT")
		if icontype ~= "ACCEPT" and icontype ~= "TURNIN" then icon:SetTexCoord(4/48, 44/48, 4/48, 44/48) end

		local text = ww.SummonFontString(f, nil, "GameFontHighlight", descriptions[icontype], "LEFT", icon, "RIGHT", ROWOFFSET, 0)
	end

	-- Guide list
	local group = LibStub("tekKonfig-Group").new(frame, "Guide", "TOP", subtitle, "BOTTOM", 0, -EDGEGAP-GAP)
	group:SetPoint("LEFT", frame, "CENTER", EDGEGAP/2 - CENTEROFFSET, 0)
	group:SetPoint("BOTTOMRIGHT", -EDGEGAP, EDGEGAP)

	local scrollbar = LibStub("tekKonfig-Scroll").new(group, 6, NUMROWS/3)

	local function OnClick(self)
		if IsShiftKeyDown() then
			TourGuide.db.char.completion[self.guide] = nil
			TourGuide.db.char.turnins[self.guide] = {}
			TourGuide:UpdateGuidesPanel()
			GameTooltip:Hide()
		else
			local text = self.guide
			if not text then self:SetChecked(false)
			else
				TourGuide:LoadGuide(text)
				TourGuide:UpdateStatusFrame()
				TourGuide:UpdateGuidesPanel()
			end
		end
	end
	for i=1,NUMROWS do
		local row = CreateFrame("CheckButton", nil, group)
		if i == 1 then row:SetPoint("TOP", 0, -4)
		else row:SetPoint("TOP", rows[i-1], "BOTTOM") end
		row:SetPoint("LEFT", 4, 0)
		row:SetPoint("RIGHT", scrollbar, "LEFT", -4, 0)
		row:SetHeight(ROWHEIGHT)

		local highlight = row:CreateTexture()
		highlight:SetTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
		highlight:SetTexCoord(0, 1, 0, 0.578125)
		highlight:SetAllPoints()
		row:SetHighlightTexture(highlight)
		row:SetCheckedTexture(highlight)

		local text = row:CreateFontString(nil, nil, "GameFontWhite")
		text:SetPoint("LEFT", GAP, 0)
		local complete = row:CreateFontString(nil, nil, "GameFontWhite")
		complete:SetPoint("RIGHT", -GAP, 0)

		row:SetScript("OnClick", OnClick)

		row.text = text
		row.complete = complete
		rows[i] = row
	end


	local f = scrollbar:GetScript("OnValueChanged")
	scrollbar:SetMinMaxValues(0, math.max(0, #TourGuide.guidelist - NUMROWS - 1))
	scrollbar:SetScript("OnValueChanged", function(self, value, ...)
		offset = math.floor(value)
		TourGuide:UpdateGuidesPanel()
		return f(self, value, ...)
	end)

	frame:EnableMouseWheel()
	frame:SetScript("OnMouseWheel", function(self, val) scrollbar:SetValue(scrollbar:GetValue() - val*NUMROWS/3) end)

	local function newoffset() for i,name in ipairs(TourGuide.guidelist) do if name == TourGuide.db.char.currentguide then return i - (NUMROWS/2) - 1 end end end
	local function OnShow(self) scrollbar:SetValue(newoffset() or 0) end
	frame:SetScript("OnShow", OnShow)
	OnShow(frame)
end)

InterfaceOptions_AddCategory(frame)


LibStub("tekKonfig-AboutPanel").new("Tour Guide", "TourGuide")


function TourGuide:UpdateGuidesPanel()
	if not frame:IsVisible() then return end
	for i,row in ipairs(rows) do
		row.i = i + offset + 1

		local name = self.guidelist[i + offset + 1]
		row.text:SetText(name)
		row.guide = name
		row:SetChecked(self.db.char.currentguide == name)

		local complete = self.db.char.currentguide == name and (self.current-1)/#self.actions or self.db.char.completion[name]
		local r,g,b = self.ColorGradient(complete or 0)
		local completetext = complete and complete ~= 0 and string.format(L["|cff%02x%02x%02x%d%% complete"], r*255, g*255, b*255, complete*100)
		row.complete:SetText(completetext)
	end
end


----------------------------
--      LDB Launcher      --
----------------------------

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:GetDataObjectByName("TourGuideLauncher") or ldb:NewDataObject("TourGuideLauncher", {type = "launcher", icon = "Interface\\Icons\\Ability_Hunter_Pathfinding", tocname = "TourGuide"})
dataobj.OnClick = function() InterfaceOptionsFrame_OpenToCategory(frame) end
