

local TourGuide = TourGuide
local hadquest


TourGuide.TrackEvents = {"CHAT_MSG_LOOT", "CHAT_MSG_SYSTEM", "QUEST_WATCH_UPDATE", "QUEST_LOG_UPDATE", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "MINIMAP_ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "PLAYER_LEVEL_UP", "ADDON_LOADED"}


function TourGuide:ADDON_LOADED(event, addon)
	if addon ~= "Blizzard_TrainerUI" then return end

	self:UnregisterEvent("ADDON_LOADED")

	local f = CreateFrame("Frame", nil, ClassTrainerFrame)
	f:SetScript("OnShow", function() if self:GetObjectiveInfo() == "TRAIN" then self:SetTurnedIn() end end)
end


function TourGuide:PLAYER_LEVEL_UP(event, newlevel)
	local level = self:GetObjectiveTag("LV")
	self:Debug(1, "PLAYER_LEVEL_UP", newlevel, level)
	if level and newlevel >= level then self:SetTurnedIn() end
end


function TourGuide:ZONE_CHANGED()
	local action, quest = self:GetObjectiveInfo()
	if (action == "RUN" or action == "FLY" or action == "HEARTH" or action == "BOAT") and (GetSubZoneText() == quest or GetZoneText() == quest) then
		self:DebugF(1, "Detected zone change %q - %q", action, quest)
		self:SetTurnedIn()
	end
end
TourGuide.ZONE_CHANGED_INDOORS = TourGuide.ZONE_CHANGED
TourGuide.MINIMAP_ZONE_CHANGED = TourGuide.ZONE_CHANGED
TourGuide.ZONE_CHANGED_NEW_AREA = TourGuide.ZONE_CHANGED


function TourGuide:CHAT_MSG_SYSTEM(event, msg)
	local action, quest = self:GetObjectiveInfo()

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
	if self:GetObjectiveInfo() == "COMPLETE" then self:UpdateStatusFrame() end
end


function TourGuide:QUEST_LOG_UPDATE(event)
	local action, _, logi, complete = self:GetObjectiveInfo(), self:GetObjectiveStatus()
	self:Debug(10, "QUEST_LOG_UPDATE", action, logi, complete)

	if (self.updatedelay and not logi) or action == "ACCEPT" or action == "COMPLETE" and complete then self:UpdateStatusFrame() end
end


function TourGuide:CHAT_MSG_LOOT(event, msg)
	local action, quest = self:GetObjectiveInfo()
	local lootitem, lootqty = self:GetObjectiveTag("L")
	local _, _, itemid, name = msg:find("^You .*Hitem:(%d+).*(%[.+%])")
	self:Debug(10, event, action, quest, lootitem, lootqty, itemid, name)

	if action == "BUY" and name and name == quest
	or (action == "BUY" or action == "NOTE") and lootitem and itemid == lootitem and (GetItemCount(lootitem) + 1) >= lootqty then
		return self:SetTurnedIn()
	end
end


function TourGuide:UI_INFO_MESSAGE(event, msg)
	if msg == ERR_NEWTAXIPATH and self:GetObjectiveInfo() == "GETFLIGHTPOINT" then
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
