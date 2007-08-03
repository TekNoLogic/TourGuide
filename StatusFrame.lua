

local TourGuide = TourGuide
local OptionHouse = DongleStub("OptionHouse-1.0")
local ww = WidgetWarlock


local f = CreateFrame("Button", nil, UIParent)
f:SetPoint("BOTTOMRIGHT", QuestWatchFrame, "TOPRIGHT", 0, 10)
f:SetHeight(32)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:RegisterForClicks("anyUp")
f:SetMovable(true)
f:SetClampedToScreen(true)
f:SetBackdrop(ww.TooltipBorderBG)
f:SetBackdropColor(0,0,0,0.3)
f:SetBackdropBorderColor(0,0,0,0.7)

local check = ww.SummonCheckBox(20, f, "LEFT", 8, 0)
local icon = ww.SummonTexture(f, 24, 24, nil, "LEFT", check, "RIGHT", 4, 0)
local text = ww.SummonFontString(f, nil, nil, "GameFontNormal", nil, "RIGHT", -12, 0)
text:SetPoint("LEFT", icon, "RIGHT", 4, 0)

local f2 = CreateFrame("Frame", nil, UIParent)
f2:SetHeight(32)
f2:SetWidth(100)
local text2 = ww.SummonFontString(f2, nil, nil, "GameFontNormal", nil, "RIGHT", -12, 0)
local icon2 = ww.SummonTexture(f2, 24, 24, nil, "RIGHT", text2, "LEFT", -4, 0)
local check2 = ww.SummonCheckBox(20, f2, "RIGHT", icon2, "LEFT", -4, 0)
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
		self:SetPoint("RIGHT", f, "RIGHT", 0, elapsed*40)
		self:SetAlpha(1 - elapsed)
		text:SetAlpha(elapsed)
		icon:SetAlpha(elapsed)
		f:SetWidth(oldsize + (newsize-oldsize)*elapsed)
	end
end)

function TourGuide:SetText(i)
	self.current = i
	local newtext = self.quests[i]..(self.notes[i] and " [?]" or "")

	if text:GetText() ~= newtext or icon:GetTexture() ~= self.icons[self.actions[i]] then
		oldsize = f:GetWidth()
		icon:SetAlpha(0)
		text:SetAlpha(0)
		elapsed = 0
		f2:SetPoint("RIGHT", f, "RIGHT", 0, 0)
		f2:SetAlpha(1)
		icon2:SetTexture(icon:GetTexture())
		text2:SetText(text:GetText())
		f2:Show()
	end

	icon:SetTexture(self.icons[self.actions[i]])
	text:SetText(newtext)
	check:SetChecked(false)
	if i == 1 then f:SetWidth(72 + text:GetWidth()) end
	newsize = 72 + text:GetWidth()
end


function TourGuide:UpdateStatusFrame()
	local nextstep

	for i in ipairs(self.actions) do
		local name = self.quests[i]
		if not self.turnedin[name] and not nextstep then
			local action, name, note, logi, complete, itemstarted = self:GetObjectiveInfo(i)
			if not nextstep and (not logi or (action == "TURNIN" or action == "COMPLETE" and not complete)) then nextstep = i end

			if action == "COMPLETE" and logi and complete then RemoveQuestWatch(logi) -- Un-watch if completed quest
			elseif action == "COMPLETE" and logi then
				local j = i
				repeat
					action, _, _, logi, complete = self:GetObjectiveInfo(j)
					if action == "COMPLETE" and logi and not complete then AddQuestWatch(logi) -- Watch if we're in a 'COMPLETE' block
					elseif action == "COMPLETE" and logi then RemoveQuestWatch(logi) end -- or unwatch if done
					j = j + 1
				until action ~= "COMPLETE"
			end
		end
	end

	QuestLog_Update()
	QuestWatch_Update()

	self:SetText(nextstep or 1)
end


f:SetScript("OnClick", function(self, btn)
	if btn == "RightButton" then
		OptionHouse:Open("Tour Guide", "Eversong Woods")
	else
		local i = TourGuide:GetQuestLogIndexByName()
		if not i then return end
		SelectQuestLogEntry(i)
		ShowUIPanel(QuestLogFrame)
	end
end)


check:SetScript("OnClick", function(self, btn)
	TourGuide.turnedin[TourGuide.quests[TourGuide.current]] = true
	TourGuide:UpdateStatusFrame()
	TourGuide:UpdateOHPanel()
end)


f:SetScript("OnDragStart", function(self) self:StartMoving() end)
f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)


