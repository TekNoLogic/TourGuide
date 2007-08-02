

local TourGuide = TourGuide

local NextItem
TourGuide.current = 1


local f = CreateFrame("Button", nil, UIParent)
f:SetPoint("BOTTOMRIGHT", QuestWatchFrame, "TOPRIGHT", 0, 10)
f:SetHeight(32)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:RegisterForClicks("anyUp")
f:SetMovable(true)
f:SetClampedToScreen(true)
f:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
f:SetBackdropColor(0,0,0,0.3)
f:SetBackdropBorderColor(0,0,0,0.7)

local icon = f:CreateTexture()
icon:SetWidth(24)
icon:SetHeight(24)
icon:SetPoint("LEFT", 4, 0)

local text = f:CreateFontString(nil, nil, "GameFontNormal")
text:SetPoint("LEFT", icon, "RIGHT", 4, 0)

local f2 = CreateFrame("Frame", nil, UIParent)
f2:SetHeight(32)
f2:SetWidth(100)
local text2 = f2:CreateFontString(nil, nil, "GameFontNormal")
local icon2 = f2:CreateTexture()
icon2:SetWidth(24)
icon2:SetHeight(24)
icon2:SetPoint("LEFT", 4, 0)
text2:SetPoint("LEFT", icon2, "RIGHT", 4, 0)
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
		self:SetPoint("LEFT", f, "LEFT", 0, elapsed*40)
		self:SetAlpha(1 - elapsed)
		text:SetAlpha(elapsed)
		icon:SetAlpha(elapsed)
		f:SetWidth(oldsize + (newsize-oldsize)*elapsed)
	end
end)

function TourGuide:SetText(i)
	-- Un-watch the last item if it's completed
	if i > 1 and self.actions[i-1] == "COMPLETE" then
		local qi = GetQuestLogIndexByName("  "..self.quests[i-1])
		if qi and select(7, GetQuestLogTitle(qi)) == 1 then
			RemoveQuestWatch(qi)
			QuestLog_Update()
			QuestWatch_Update()
		end
	end

	-- Watch the next quests to complete, or skip if this quest is complete
	if self.actions[i] == "COMPLETE" then
		local qi = GetQuestLogIndexByName("  "..self.quests[i])
		if qi and select(7, GetQuestLogTitle(qi)) == 1 then return self:NextItem() end

		local j = i
		repeat
			local qi = GetQuestLogIndexByName("  "..self.quests[j])
			if qi and select(7, GetQuestLogTitle(qi)) == 1 then RemoveQuestWatch(qi)
			elseif qi then AddQuestWatch(qi) end
			j = j + 1
		until not self.actions[j] or self.actions[j] ~= "COMPLETE"
		QuestLog_Update()
		QuestWatch_Update()
	end

	-- Skip if we have the quest we're supposted to accept
	if self.actions[i] == "ACCEPT" and GetQuestLogIndexByName("  "..self.quests[i]) then return self:NextItem() end

	if i > 1 then
		oldsize = f:GetWidth()
		newsize = 44 + text:GetWidth()
		icon:SetAlpha(0)
		text:SetAlpha(0)
		elapsed = 0
		f2:SetPoint("LEFT", f, "LEFT", 0, 0)
		f2:SetAlpha(1)
		icon2:SetTexture(icon:GetTexture())
		text2:SetText(text:GetText())
		f2:Show()
	end

	icon:SetTexture(self.icons[self.actions[i]])
	text:SetText(self.quests[i]..(self.notes[i] and " [?]" or ""))
	if i == 1 then f:SetWidth(44 + text:GetWidth()) end
end


function TourGuide:NextItem()
	self.current = self.current + 1
	if self.current > #self.actions then
		self.current = #self.actions
	else
		self:SetText(self.current)
	end
end


f:SetScript("OnClick", function(self, btn)
	if btn == "RightButton" then
		TourGuide.current = TourGuide.current - 1
		TourGuide.current = TourGuide.current == 0 and 1 or TourGuide.current
		TourGuide:SetText(TourGuide.current)
	else TourGuide:NextItem() end
end)


f:SetScript("OnDragStart", function(self) self:StartMoving() end)
f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)


