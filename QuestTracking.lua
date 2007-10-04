

local TourGuide = TourGuide
local hadquest


TourGuide.TrackEvents = {"CHAT_MSG_LOOT", "CHAT_MSG_SYSTEM", "QUEST_WATCH_UPDATE", "QUEST_LOG_UPDATE",
	"ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "MINIMAP_ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA"}


function TourGuide:ZONE_CHANGED(...)
	local action, quest, note, logi, complete, hasitem, turnedin, fullquestname = self:GetCurrentObjectiveInfo()
	if (action == "RUN" or action == "FLY" or action == "HEARTH" or action == "BOAT") and (GetSubZoneText() == quest or GetZoneText() == quest) then
		self:DebugF(1, "Detected zone change %q - %q", action, quest)
		self:SetTurnedIn()
	end
end
TourGuide.ZONE_CHANGED_INDOORS = TourGuide.ZONE_CHANGED
TourGuide.MINIMAP_ZONE_CHANGED = TourGuide.ZONE_CHANGED
TourGuide.ZONE_CHANGED_NEW_AREA = TourGuide.ZONE_CHANGED


function TourGuide:CHAT_MSG_SYSTEM(event, msg)
	local action, quest, note, logi, complete, hasitem, turnedin, fullquestname = self:GetCurrentObjectiveInfo()

	if action == "SETHEARTH" then
		local _, _, loc = msg:find("(.*) is now your home.")
		if loc and loc == quest then
			self:DebugF(1, "Detected setting hearth to %q", loc)
			return self:SetTurnedIn()
		end
	end

	if action == "ACCEPT" then
		local _, _, text = msg:find("Quest accepted: (.*)")
		if text and quest:gsub("%s%(Part %d+%)", "") == text then
			self:DebugF(1, "Detected quest accept %q", quest)
			return self:UpdateStatusFrame()
		end
	end
end


function TourGuide:QUEST_WATCH_UPDATE(event)
	if self:GetCurrentObjectiveInfo() == "COMPLETE" then self:UpdateStatusFrame() end
end


function TourGuide:QUEST_LOG_UPDATE(event)
	self:Debug(10, "QUEST_LOG_UPDATE")
	local action, quest, note, logi, complete, hasitem, turnedin, fullquestname = self:GetCurrentObjectiveInfo()

	if self.updatedelay or action == "ACCEPT" or action == "COMPLETE" and complete then self:UpdateStatusFrame() end
end


function TourGuide:CHAT_MSG_LOOT(event, msg)
	local action, quest, _, _, _, _, _, _, _, _, lootitem, lootqty = self:GetCurrentObjectiveInfo()
	local _, _, itemid, name = msg:find("^You .*Hitem:(%d+).*(%[.+%])")
	self:Debug(10, event, msg:gsub("|","||"), action, quest, lootitem, lootqty, itemid, name)

	if action == "BUY" and name and name == quest
	or (action == "BUY" or action == "NOTE") and lootitem and itemid == lootitem and (GetItemCount(lootitem) + 1) >= lootqty then
		return self:SetTurnedIn()
	end
end


function TourGuide:UI_INFO_MESSAGE(event, msg)
	local action, quest = self:GetCurrentObjectiveInfo()

	if msg == ERR_NEWTAXIPATH and action == "GETFLIGHTPOINT" then
		self:Debug(1, "Discovered flight point")
		self:SetTurnedIn()
	end
end


local orig = GetQuestReward
GetQuestReward = function(...)
	local quest = GetTitleText()
	TourGuide:Debug(10, "GetQuestReward", quest)
	TourGuide:CompleteQuest(quest, true)

	return orig(...)
end
