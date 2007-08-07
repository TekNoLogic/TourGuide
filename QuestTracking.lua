

local TourGuide = TourGuide
local hadquest


TourGuide.TrackEvents = {"CHAT_MSG_LOOT", "CHAT_MSG_SYSTEM", "QUEST_COMPLETE", "UNIT_QUEST_LOG_UPDATE", "QUEST_WATCH_UPDATE", "QUEST_FINISHED", "QUEST_LOG_UPDATE",
	"ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "MINIMAP_ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA"}


function TourGuide:ZONE_CHANGED(...)
	local action, quest, note, logi, complete, hasitem, turnedin, fullquestname = self:GetCurrentObjectiveInfo()
	if (action == "RUN" or action == "FLY" or action == "HEARTH") and (GetSubZoneText() == quest or GetZoneText() == quest) then self:SetTurnedIn() end
end
TourGuide.ZONE_CHANGED_INDOORS = TourGuide.ZONE_CHANGED
TourGuide.MINIMAP_ZONE_CHANGED = TourGuide.ZONE_CHANGED
TourGuide.ZONE_CHANGED_NEW_AREA = TourGuide.ZONE_CHANGED


function TourGuide:CHAT_MSG_SYSTEM(event, msg)
	local action, quest, note, logi, complete, hasitem, turnedin, fullquestname = self:GetCurrentObjectiveInfo()

	if action == "SETHEARTH" then
		local _, _, loc = msg:find("(.*) is now your home.")
		if loc and loc == quest then return self:SetTurnedIn() end
	end

	if action == "ACCEPT" then
		local _, _, text = msg:find("Quest accepted: (.*)")
		if text and quest == text then return self:UpdateStatusFrame() end
	end

	local _, _, text = msg:find("(.*) completed.")
	if not text then return end

	if quest == text then return self:SetTurnedIn() end

	local i = 1
	repeat
		action, quest, note, logi, complete, hasitem, turnedin, fullquestname = self:GetObjectiveInfo(i)
		if action == "ACCEPT" and not turnedin and text == quest then
			self.turnedin[fullquestname] = true
			return self:UpdateStatusFrame()
		end
		i = i + 1
	until not action
end


function TourGuide:QUEST_COMPLETE(event)
	local action, quest, note, logi, complete, hasitem, turnedin = self:GetCurrentObjectiveInfo()
	if (action == "TURNIN" or action == "ITEM") and logi then hadquest = quest
	else hadquest = nil end
end


function TourGuide:UNIT_QUEST_LOG_UPDATE(event, unit)
	if unit ~= "player" then return end

	local action, quest, note, logi, complete, hasitem, turnedin = self:GetCurrentObjectiveInfo()
	if hadquest == quest and not logi and action == "ITEM" then self:SetTurnedIn()
	elseif hadquest == quest and not logi then self:UpdateStatusFrame() end
	hadquest = nil
end


function TourGuide:QUEST_WATCH_UPDATE(event)
	local action, quest, note, logi, complete, hasitem, turnedin = self:GetCurrentObjectiveInfo()
	if action == "COMPLETE" then self:UpdateStatusFrame() end
end


local turninquest
function TourGuide:QUEST_FINISHED()
	local action, quest, note, logi, complete, hasitem, turnedin = self:GetCurrentObjectiveInfo()
	if action == "TURNIN" and logi then turninquest = quest
	else turninquest = nil end
end


function TourGuide:QUEST_LOG_UPDATE(event)
	local action, quest, note, logi, complete, hasitem, turnedin, fullquestname = self:GetCurrentObjectiveInfo()

	if action == "ACCEPT" then return self:UpdateStatusFrame()
	elseif action == "TURNIN" and turninquest == quest and not logi then return self:SetTurnedIn()
	elseif action == "COMPLETE" and complete then return self:UpdateStatusFrame() end
end


function TourGuide:CHAT_MSG_LOOT(event, msg)
	local action, quest = self:GetCurrentObjectiveInfo()

	if action == "BUY" then
		local _, _, name = msg:find("^You receive item: .*(%[.+%])")
		if name and name == quest then return self:SetTurnedIn() end
	end
end

