
local NextItem
local current = 1
local _, class = UnitClass("player")

local A, C, T = "ACCEPT", "COMPLETE", "TURNIN"
local itemstartedquests = {["Tainted Arcane Sliver"] = 20483}
local questnames = {
	"Reclaiming Sunstrider Isle",
	"Unfortunate Measures",
	"YOUR CLASS QUEST",
	"Well Watcher Solanian",
	"The Shrine of Dath'Remar",
	"Solanian's Belongings",
	"A Fistful of Slivers",
	"Thirst Unending",
	"Report to Lanthan Perilon",
	"Aggression",
	"Felendren the Banished",
	"Tainted Arcane Sliver",
	"Ruins of Silvermoon"
}
local questorder = {1, 1, 1, 2, 3, 3, 4, 4, 5, 6, 7, 8, 8, 7, 2, 6, 8, 7, 2, 6, 9, 9, 10, 10, 5, 10, 11, 11, 11, 12, 5, 13}
local actions    = {A, C, T, A, A, T, A, T, A, A, A, A, C, C, C, C, T, T, T, T, A, T,  A,  C, C,  T,  A,  C,  T,  T, T, 'RUN'}
local notes = {[28] = 'You should find an item while doing this quest which starts "Tainted Arcane Sliver"'}
local quests = setmetatable({}, {__index = function(t,i)
	local v = questorder[i] and questnames[questorder[i]]
	t[i] = v
	return v
end})

if class == "WARLOCK" then
	questnames[3] = "Warlock Training"
	questnames[14] = "Windows to the Source"
	table.insert(questorder, 7, 14)
	table.insert(actions,    7,  A)
	table.insert(questorder, 29, 14)
	table.insert(actions,    29,  C)
	table.insert(questorder, 32, 14)
	table.insert(actions,    32,  T)

end

local ourquests = {}
for i,v in pairs(questnames) do ourquests[v] = true end

local icons = setmetatable({
	ACCEPT = "Interface\\GossipFrame\\AvailableQuestIcon",
	COMPLETE = "Interface\\Icons\\Ability_DualWield",
	TURNIN = "Interface\\GossipFrame\\ActiveQuestIcon",
	RUN = "Interface\\Icons\\Ability_Rogue_Sprint",
	MAP = "Interface\\Icons\\Ability_Spy",
	FLY = "Interface\\Icons\\Ability_Druid_FlightForm",
}, {__index = function() return "Interface\\Icons\\INV_Misc_QuestionMark" end})

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
			if qi and select(7, GetQuestLogTitle(qi)) == 1 then RemoveQuestWatch(qi)
			elseif qi then AddQuestWatch(qi) end
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

function NextItem()
	current = current + 1
	if current > #actions then
		current = #actions
	else
		SetText(current)
	end
end

SetText(1)

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

local hadquest
f:SetScript("OnEvent", function(self, event, a1)
	if event == "CHAT_MSG_SYSTEM" then
		local _, _, quest = a1:find("Quest accepted: (.*)")
		if quest and actions[current] == "ACCEPT" and quests[current] == quest then return NextItem() end

		local _, _, questc = a1:find("(.*) completed.")
		if questc and actions[current] == "TURNIN" and quests[current] == questc then return NextItem() end

	elseif event == "QUEST_COMPLETE" then
		if actions[current] == "TURNIN" and GetQuestLogIndexByName("  "..quests[current]) then hadquest = quests[current]
		else hadquest = nil end

	elseif event == "UNIT_QUEST_LOG_UPDATE" and a1 == "player" then
		if hadquest == quests[current] and not GetQuestLogIndexByName("  "..quests[current]) then NextItem() end
		hadquest = nil

	else
		if actions[current] ~= "COMPLETE" then return end
		local i = current
		repeat
			local qi = GetQuestLogIndexByName("  "..quests[i])
			if qi and select(7, GetQuestLogTitle(qi)) == 1 then RemoveQuestWatch(qi) end
			i = i + 1
		until actions[i] ~= "COMPLETE"
		QuestLog_Update()
		QuestWatch_Update()

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
f:RegisterEvent("QUEST_COMPLETE")
f:RegisterEvent("UNIT_QUEST_LOG_UPDATE")

local notlisted = CreateFrame("Frame", nil, QuestFrame)
notlisted:SetWidth(32)
notlisted:SetHeight(32)
notlisted:SetPoint("TOPLEFT", 70, -45)
notlisted:RegisterEvent("QUEST_DETAIL")
notlisted:RegisterEvent("QUEST_COMPLETE")
notlisted:SetScript("OnEvent", function(self, event)
	if event == "QUEST_COMPLETE" then return self:Hide() end
	local quest = GetTitleText()
	if quest and ourquests[quest] then self:Hide()
	else self:Show() end
end)

local nltex = notlisted:CreateTexture()
nltex:SetAllPoints()
nltex:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
