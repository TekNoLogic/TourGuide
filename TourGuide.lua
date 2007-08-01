
local NextItem
local current = 1

local actions = {'ACCEPT', 'COMPLETE', 'TURNIN', 'ACCEPT', 'ACCEPT', 'TURNIN', 'ACCEPT', 'TURNIN', 'ACCEPT', 'ACCEPT', 'ACCEPT', 'ACCEPT', 'COMPLETE', 'COMPLETE', 'COMPLETE', 'COMPLETE', 'TURNIN', 'TURNIN', 'TURNIN', 'TURNIN', 'ACCEPT', 'TURNIN', 'ACCEPT', 'COMPLETE', 'COMPLETE', 'TURNIN', 'ACCEPT', 'COMPLETE', 'TURNIN', 'TURNIN', 'TURNIN', 'RUN'}
local quests = {'Reclaiming Sunstrider Isle', 'Reclaiming Sunstrider Isle', 'Reclaiming Sunstrider Isle', 'Unfortunate Measures', 'YOUR CLASS QUEST', 'YOUR CLASS QUEST', 'Well Watcher Solanian', 'Well Watcher Solanian', 'The Shrine of Dath\'Remar', 'Solanian\'s Belongings', 'A Fistful of Slivers', 'Thirst Unending', 'Thirst Unending', 'A Fistful of Slivers', 'Unfortunate Measures', 'Solanian\'s Belongings', 'Thirst Unending', 'A Fistful of Slivers', 'Unfortunate Measures', 'Solanian\'s Belongings', 'Report to Lanthan Perilon', 'Report to Lanthan Perilon', 'Aggression', 'Aggression', 'The Shrine of Dath\'Remar', 'Aggression', 'Felendren the Banished', 'Felendren the Banished', 'Felendren the Banished', 'Tainted Arcane Sliver', 'The Shrine of Dath\'Remar', 'Ruins of Silvermoon'}
local notes = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 'You should find an item while doing this quest which starts "Tainted Arcane Sliver"', nil, nil, nil, nil}
local ourquests = {}
for i,v in ipairs(quests) do
	if actions[i] == "ACCEPT" then ourquests[v] = true end
end

local icons = setmetatable({
	ACCEPT = "Interface\\Icons\\Spell_ChargePositive",
	COMPLETE = "Interface\\Icons\\Ability_DualWield",
	TURNIN = "Interface\\Icons\\Spell_ChargeNegative",
	RUN = "Interface\\Icons\\Ability_Rogue_Sprint",
	MAP = "Interface\\Icons\\Ability_Spy",
	FLY = "Interface\\Icons\\Ability_Druid_FlightForm",
}, {__index = function() return "Interface\\Icons\\INV_Misc_QuestionMark" end})

local f = CreateFrame("Button", nil, UIParent)
f:SetPoint("CENTER")
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

local function SetText(i)
	icon:SetTexture(icons[actions[i]])
	text:SetText(quests[i]..(notes[i] and " [?]" or ""))

	-- Un-watch the last item if it's completed
	if i > 1 and actions[i-1] == "COMPLETE" then
		local qi = GetQuestLogIndexByName("  "..quests[i-1])
		if qi and select(7, GetQuestLogTitle(qi)) == 1 then
			RemoveQuestWatch(qi)
			QuestLog_Update()
			QuestWatch_Update()
		end
	end

	-- Watch the next quests to complete, or skip if this quest is complete
	if actions[i] == "COMPLETE" then
		local qi = GetQuestLogIndexByName("  "..quests[i])
		if qi and select(7, GetQuestLogTitle(qi)) == 1 then return NextItem() end

		local j = i
		repeat
			local qi = GetQuestLogIndexByName("  "..quests[j])
			if qi then AddQuestWatch(qi) end
			j = j + 1
		until not actions[j] or actions[j] ~= "COMPLETE"
		QuestLog_Update()
		QuestWatch_Update()
	end

	-- Skip if we have the quest we're supposted to accept
	if actions[i] == "ACCEPT" and GetQuestLogIndexByName("  "..quests[i]) then return NextItem() end

	if i > 1 then
		oldsize = f:GetWidth()
		newsize = 44 + text:GetWidth()
		icon:SetAlpha(0)
		text:SetAlpha(0)
		elapsed = 0
		f2:SetPoint("LEFT", f, "LEFT", 0, 0)
		f2:SetAlpha(1)
		icon2:SetTexture(icons[actions[i-1]])
		text2:SetText(quests[i-1])
		f2:Show()
	else
		f:SetWidth(44 + text:GetWidth())
	end
end

SetText(1)

function NextItem()
	current = current + 1
	if current > #actions then
		current = #actions
	else
		SetText(current)
	end
end

f:SetScript("OnClick", function(self, btn)
	if btn == "RightButton" then
		current = current - 1
		current = current == 0 and 1 or current
		SetText(current)
	else NextItem() end
end)

f:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)

f:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

f:SetScript("OnEvent", function(self, event, a1)
	if event == "CHAT_MSG_SYSTEM" then
		local _, _, quest = a1:find("Quest accepted: (.*)")
		if quest and actions[current] == "ACCEPT" and quests[current] == quest then return NextItem() end

		local _, _, questc = a1:find("(.*) completed.")
		if questc and actions[current] == "TURNIN" and quests[current] == questc then return NextItem() end
	else
		if actions[current] ~= "COMPLETE" then return end
		local i = GetQuestLogIndexByName("  "..quests[current])
		if i and select(7, GetQuestLogTitle(i)) == 1 then return NextItem() end

		if event == "QUEST_LOG_UPDATE" then
			if actions[current] == "COMPLETE" then
				local qi = GetQuestLogIndexByName("  "..quests[current])
				if qi then
					AddQuestWatch(qi)
					QuestLog_Update()
					QuestWatch_Update()
				end
			elseif actions[current] == "TURNIN" then
				if not GetQuestLogIndexByName("  "..quests[current]) then return NextItem() end
			end
		end
	end
end)
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:RegisterEvent("QUEST_LOG_UPDATE")
f:RegisterEvent("QUEST_WATCH_UPDATE")

local notlisted = CreateFrame("Frame", nil, QuestFrame)
notlisted:SetWidth(32)
notlisted:SetHeight(32)
notlisted:SetPoint("TOPLEFT", 70, -45)
notlisted:RegisterEvent("QUEST_DETAIL")
notlisted:SetScript("OnEvent", function(self)
	local quest = GetTitleText()
	if quest and ourquests[quest] then self:Hide()
	else self:Show() end
end)

local nltex = notlisted:CreateTexture()
nltex:SetAllPoints()
nltex:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
