
local bg = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	insets = {left = 5, right = 5, top = 5, bottom = 5},
	tile = true, tileSize = 16,
}

local ICONSIZE, CHECKSIZE, GAP = 16, 16, 8
local FIXEDWIDTH = ICONSIZE + CHECKSIZE + GAP*4 - 4

local TourGuide = TourGuide
local OptionHouse = LibStub("OptionHouse-1.1")
local ww = WidgetWarlock


local function GetQuadrant(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "BOTTOMLEFT", "BOTTOM", "LEFT" end
	local hhalf = (x > UIParent:GetWidth()/2) and "RIGHT" or "LEFT"
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, vhalf, hhalf
end


local f = CreateFrame("Button", nil, UIParent)
f:SetPoint("BOTTOMRIGHT", QuestWatchFrame, "TOPRIGHT", -60, -15)
f:SetHeight(24)
f:SetFrameStrata("LOW")
f:EnableMouse(true)
f:RegisterForClicks("anyUp")
f:SetBackdrop(bg)
f:SetBackdropColor(0.09, 0.09, 0.19, 0.5)
f:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5)

local check = ww.SummonCheckBox(CHECKSIZE, f, "LEFT", GAP, 0)
local icon = ww.SummonTexture(f, "ARTWORK", ICONSIZE, ICONSIZE, nil, "LEFT", check, "RIGHT", GAP-4, 0)
local text = ww.SummonFontString(f, "OVERLAY", "GameFontNormalSmall", nil, "RIGHT", -GAP-4, 0)
text:SetPoint("LEFT", icon, "RIGHT", GAP-4, 0)

local item = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
item:SetFrameStrata("LOW")
item:SetHeight(36)
item:SetWidth(36)
item:SetPoint("BOTTOMRIGHT", QuestWatchFrame, "TOPRIGHT", -62, 10)
item:RegisterForClicks("anyUp")
local itemicon = ww.SummonTexture(item, "ARTWORK", 24, 24, "Interface\\Icons\\INV_Misc_Bag_08")
itemicon:SetAllPoints(item)
item:Hide()

local f2 = CreateFrame("Frame", nil, UIParent)
local f2anchor = "RIGHT"
f2:SetHeight(32)
f2:SetWidth(100)
local text2 = ww.SummonFontString(f2, "OVERLAY", "GameFontNormalSmall", nil, "RIGHT", -GAP-4, 0)
local icon2 = ww.SummonTexture(f2, "ARTWORK", ICONSIZE, ICONSIZE, nil, "RIGHT", text2, "LEFT", -GAP+4, 0)
local check2 = ww.SummonCheckBox(CHECKSIZE, f2, "RIGHT", icon2, "LEFT", -GAP+4, 0)
check2:SetChecked(true)
f2:Hide()


local elapsed, oldsize, newsize
f2:SetScript("OnUpdate", function(self, el)
	elapsed = elapsed + el
	if elapsed > 1 then
		self:Hide()
		icon:SetAlpha(1)
		text:SetAlpha(1)
		f:SetWidth(newsize)
	else
		self:SetPoint(f2anchor, f, f2anchor, 0, elapsed*40)
		self:SetAlpha(1 - elapsed)
		text:SetAlpha(elapsed)
		icon:SetAlpha(elapsed)
		f:SetWidth(oldsize + (newsize-oldsize)*elapsed)
	end
end)


function TourGuide:PositionStatusFrame()
	if self.db.profile.statusframepoint then
		f:ClearAllPoints()
		f:SetPoint(self.db.profile.statusframepoint, self.db.profile.statusframex, self.db.profile.statusframey)
	end

	if self.db.profile.itemframepoint then
		item:ClearAllPoints()
		item:SetPoint(self.db.profile.itemframepoint, self.db.profile.itemframex, self.db.profile.itemframey)
	end
end


function TourGuide:SetText(i)
	self.current = i
	local action, quest = self:GetObjectiveInfo(i)
	local note = self:GetObjectiveTag("N")
	local newtext = (quest or"???")..(note and " [?]" or "")

	if text:GetText() ~= newtext or icon:GetTexture() ~= self.icons[action] then
		oldsize = f:GetWidth()
		icon:SetAlpha(0)
		text:SetAlpha(0)
		elapsed = 0
		f2:SetWidth(f:GetWidth())
		f2anchor = select(3, GetQuadrant(f))
		f2:ClearAllPoints()
		f2:SetPoint(f2anchor, f, f2anchor, 0, 0)
		f2:SetAlpha(1)
		icon2:SetTexture(icon:GetTexture())
		icon2:SetTexCoord(4/48, 44/48, 4/48, 44/48)
		text2:SetText(text:GetText())
		f2:Show()
	end

	icon:SetTexture(self.icons[action])
	if action ~= "ACCEPT" and action ~= "TURNIN" then icon:SetTexCoord(4/48, 44/48, 4/48, 44/48) end
	text:SetText(newtext)
	check:SetChecked(false)
	if i == 1 then f:SetWidth(FIXEDWIDTH + text:GetWidth()) end
	newsize = FIXEDWIDTH + text:GetWidth()

	if self.UpdateFubarPlugin then self.UpdateFubarPlugin(quest, self.icons[action], note) end
end


local lastmapped, lastmappedaction
function TourGuide:UpdateStatusFrame()
	self:Debug(1, "UpdateStatusFrame", self.current)

	if self.updatedelay then
		local _, logi = self:GetObjectiveStatus(self.updatedelay)
		self:Debug(1, "Delayed update", self.updatedelay, logi)
		if logi then return end
	end

	local nextstep
	self.updatedelay = nil

	for i in ipairs(self.actions) do
		local name = self.quests[i]
		if not self.turnedin[name] and not nextstep then
			local action, name, quest = self:GetObjectiveInfo(i)
			local turnedin, logi, complete = self:GetObjectiveStatus(i)
			local note, useitem, optional, lootitem, lootqty = self:GetObjectiveTag("N", i), self:GetObjectiveTag("U", i), self:GetObjectiveTag("O", i), self:GetObjectiveTag("L", i)
			local level = tonumber((self:GetObjectiveTag("LV", i)))
			local needlevel = level and level > UnitLevel("player")
			self:Debug(11, "UpdateStatusFrame", i, action, name, note, logi, complete, turnedin, quest, useitem, optional, lootitem, lootqty, lootitem and GetItemCount(lootitem) or 0, level, needlevel)
			local hasuseitem = useitem and self:FindBagSlot(useitem)

			-- Test for completed objectives and mark them done
			if (action == "RUN" or action == "FLY" or action == "HEARTH" or action == "BOAT") and (GetSubZoneText() == name or GetZoneText() == name) then return self:SetTurnedIn(i, true) end

			if action == "KILL" or action == "NOTE" then
				if not optional and lootitem and GetItemCount(lootitem) >= lootqty then return self:SetTurnedIn(i, true) end

				local quest, questtext = self:GetObjectiveTag("Q", i), self:GetObjectiveTag("QO", i)
				if quest and questtext then
					local qi = self:GetQuestLogIndexByName(quest)
					for lbi=1,GetNumQuestLeaderBoards(qi) do
						self:Debug(1, quest, questtext, qi, GetQuestLogLeaderBoard(lbi, qi))
						if GetQuestLogLeaderBoard(lbi, qi) == questtext then return self:SetTurnedIn(i, true) end
					end
				end
			end

			local incomplete
			if action == "ACCEPT" then incomplete = (not optional or hasuseitem) and not logi
			elseif action == "TURNIN" then incomplete = not optional or logi and complete
			elseif action == "COMPLETE" then incomplete = not complete and (not optional or logi)
			elseif action == "NOTE" or action == "KILL" then incomplete = not optional or lootitem and GetItemCount(lootitem) >= lootqty or needlevel
			elseif action == "GRIND" then incomplete = needlevel
			else incomplete = not logi end

			if incomplete then nextstep = i end

			if action == "COMPLETE" and logi and self.db.char.trackquests then
				local j = i
				repeat
					action = self:GetObjectiveInfo(j)
					turnedin, logi, complete = self:GetObjectiveStatus(j)
					if action == "COMPLETE" and logi and not complete then AddQuestWatch(logi) -- Watch if we're in a 'COMPLETE' block
					elseif action == "COMPLETE" and logi then RemoveQuestWatch(logi) end -- or unwatch if done
					j = j + 1
				until action ~= "COMPLETE"
			end
		end
	end
	QuestLog_Update()
	QuestWatch_Update()

	if not nextstep and self:LoadNextGuide() then return self:UpdateStatusFrame() end

	if not nextstep then return end

	self:SetText(nextstep)
	self.current = nextstep
	local action, quest, fullquest = self:GetObjectiveInfo(nextstep)
	local turnedin, logi, complete = self:GetObjectiveStatus(nextstep)
	local note, useitem, optional = self:GetObjectiveTag("N", nextstep), self:GetObjectiveTag("U", nextstep), self:GetObjectiveTag("O", nextstep)
	local zonename = self:GetObjectiveTag("Z", nextstep) or self.zonename
	self:DebugF(1, "Progressing to objective \"%s %s\"", action, quest)

	-- Mapping
	if (TomTom or Cartographer_Waypoints) and (lastmapped ~= quest or lastmappedaction ~= action) then
		lastmappedaction, lastmapped = action, quest
		self:ParseAndMapCoords(note, quest, zonename) --, zone)
	end


	local newtext = (quest or "???")..(note and " [?]" or "")

	if text:GetText() ~= newtext or icon:GetTexture() ~= self.icons[action] then
		oldsize = f:GetWidth()
		icon:SetAlpha(0)
		text:SetAlpha(0)
		elapsed = 0
		f2:SetWidth(f:GetWidth())
		f2anchor = select(3, GetQuadrant(f))
		f2:ClearAllPoints()
		f2:SetPoint(f2anchor, f, f2anchor, 0, 0)
		f2:SetAlpha(1)
		icon2:SetTexture(icon:GetTexture())
		text2:SetText(text:GetText())
		f2:Show()
	end

	icon:SetTexture(self.icons[action])
	text:SetText(newtext)
	check:SetChecked(false)
	if not f2:IsVisible() then f:SetWidth(FIXEDWIDTH + text:GetWidth()) end
	newsize = FIXEDWIDTH + text:GetWidth()

	local tex = useitem and select(10, GetItemInfo(tonumber(useitem)))
	if tex then
		itemicon:SetTexture(tex)
		item:SetAttribute("type1", "item")
		item:SetAttribute("item1", "item:"..useitem)
		item:Show()
	else item:Hide() end

	self:UpdateOHPanel()
end


f:SetScript("OnClick", function(self, btn)
	if btn == "RightButton" then
		OptionHouse:Open("Tour Guide", "Objectives")
	else
		local i = TourGuide:GetQuestLogIndexByName()
		if i then SelectQuestLogEntry(i) end
		ShowUIPanel(QuestLogFrame)
	end
end)


check:SetScript("OnClick", function(self, btn) TourGuide:SetTurnedIn() end)


item:HookScript("OnClick", function()
	if TourGuide:GetObjectiveInfo() == "USE" then TourGuide:SetTurnedIn() end
end)


local function ShowTooltip(self)
	local tip = TourGuide:GetObjectiveTag("N")
	if not tip then return end

 	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	local quad, vhalf, hhalf = GetQuadrant(self)
	local anchpoint = (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
	TourGuide:Debug(11, "Setting tooltip anchor", anchpoint, quad, hhalf, vhalf)
	GameTooltip:SetPoint(quad, self, anchpoint)
	GameTooltip:SetText(tip, nil, nil, nil, nil, true)
end


f:SetScript("OnLeave", function() GameTooltip:Hide() end)
f:SetScript("OnEnter", ShowTooltip)


local function GetUIParentAnchor(frame)
	local w, h, x, y = UIParent:GetWidth(), UIParent:GetHeight(), frame:GetCenter()
	local hhalf, vhalf = (x > w/2) and "RIGHT" or "LEFT", (y > h/2) and "TOP" or "BOTTOM"
	local dx = hhalf == "RIGHT" and math.floor(frame:GetRight() + 0.5) - w or math.floor(frame:GetLeft() + 0.5)
	local dy = vhalf == "TOP" and math.floor(frame:GetTop() + 0.5) - h or math.floor(frame:GetBottom() + 0.5)

	return vhalf..hhalf, dx, dy
end


f:RegisterForDrag("LeftButton")
f:SetMovable(true)
f:SetClampedToScreen(true)
f:SetScript("OnDragStart", function(frame)
	GameTooltip:Hide()
	frame:StartMoving()
end)
f:SetScript("OnDragStop", function(frame)
	frame:StopMovingOrSizing()
	TourGuide:Debug(1, "Status frame moved", GetUIParentAnchor(frame))
	TourGuide.db.profile.statusframepoint, TourGuide.db.profile.statusframex, TourGuide.db.profile.statusframey = GetUIParentAnchor(frame)
	frame:ClearAllPoints()
	frame:SetPoint(TourGuide.db.profile.statusframepoint, TourGuide.db.profile.statusframex, TourGuide.db.profile.statusframey)
	ShowTooltip(frame)
end)


item:RegisterForDrag("LeftButton")
item:SetMovable(true)
item:SetClampedToScreen(true)
item:SetScript("OnDragStart", item.StartMoving)
item:SetScript("OnDragStop", function(frame)
	frame:StopMovingOrSizing()
	TourGuide:Debug(1, "Item frame moved", GetUIParentAnchor(frame))
	TourGuide.db.profile.itemframepoint, TourGuide.db.profile.itemframex, TourGuide.db.profile.itemframey = GetUIParentAnchor(frame)
end)

