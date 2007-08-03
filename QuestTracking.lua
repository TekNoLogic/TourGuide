

local TourGuide = TourGuide
local hadquest


TourGuide.turnedin = {}

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...) if self[event] then self[event](TourGuide, event, ...) end end)


function f:CHAT_MSG_SYSTEM(event, a1)
	local _, _, quest = a1:find("Quest accepted: (.*)")
	if quest and self.actions[self.current] == "ACCEPT" and self.quests[self.current] == quest then return self:UpdateStatusFrame() end

	local _, _, questc = a1:find("(.*) completed.")
	if questc and self.actions[self.current] == "TURNIN" and self.quests[self.current] == questc then
		self.turnedin[questc] = true
		return self:UpdateStatusFrame()
	end
end


function f:QUEST_COMPLETE(event)
	if self.actions[self.current] == "TURNIN" and GetQuestLogIndexByName("  "..self.quests[self.current]) then hadquest = self.quests[self.current]
	else hadquest = nil end
end


function f:UNIT_QUEST_LOG_UPDATE(event, unit)
	if unit ~= "player" then return end

	if hadquest == self.quests[self.current] and not GetQuestLogIndexByName("  "..self.quests[self.current]) then self:UpdateStatusFrame() end
	hadquest = nil
end


function f:QUEST_WATCH_UPDATE(event)
	if self.actions[self.current] ~= "COMPLETE" then return end
	local i = self.current
	repeat
		local qi = GetQuestLogIndexByName("  "..self.quests[i])
		if qi and select(7, GetQuestLogTitle(qi)) == 1 then RemoveQuestWatch(qi) end
		i = i + 1
	until self.actions[i] ~= "COMPLETE"
	QuestLog_Update()
	QuestWatch_Update()

	local i = GetQuestLogIndexByName("  "..self.quests[self.current])
	if i and select(7, GetQuestLogTitle(i)) == 1 then return self:UpdateStatusFrame() end
end


local turninquest
function f:QUEST_FINISHED()
	if self.actions[self.current] == "TURNIN" and GetQuestLogIndexByName("  "..self.quests[self.current]) then turninquest = self.quests[self.current]
	else turninquest = nil end
end


function f:QUEST_LOG_UPDATE(event)
	if self.actions[self.current] == "ACCEPT" then return self:UpdateStatusFrame() end
	if self.actions[self.current] == "TURNIN" and turninquest == self.quests[self.current] and not GetQuestLogIndexByName("  "..turninquest) then
		TourGuide.turnedin[turninquest] = true
		return self:UpdateStatusFrame()
	end
	if self.actions[self.current] ~= "COMPLETE" then return end

	local i = self.current
	repeat
		local qi = GetQuestLogIndexByName("  "..self.quests[i])
		if qi and select(7, GetQuestLogTitle(qi)) == 1 then RemoveQuestWatch(qi) end
		i = i + 1
	until self.actions[i] ~= "COMPLETE"
	QuestLog_Update()
	QuestWatch_Update()

	local i = GetQuestLogIndexByName("  "..self.quests[self.current])
	if i and select(7, GetQuestLogTitle(i)) == 1 then return self:UpdateStatusFrame() end

	if self.actions[self.current] == "COMPLETE" then
		local qi = GetQuestLogIndexByName("  "..self.quests[self.current])
		if qi then
			AddQuestWatch(qi)
			QuestLog_Update()
			QuestWatch_Update()
		end
	elseif self.actions[self.current] == "TURNIN" then
		if not GetQuestLogIndexByName("  "..self.quests[self.current]) then return self:UpdateStatusFrame() end
	end
end


for i in pairs(f) do f:RegisterEvent(i) end

