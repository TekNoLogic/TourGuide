
TourGuide = DongleStub("Dongle-1.0"):New("TourGuide")


TourGuide.icons = setmetatable({
	ACCEPT = "Interface\\GossipFrame\\AvailableQuestIcon",
	COMPLETE = "Interface\\Icons\\Ability_DualWield",
	TURNIN = "Interface\\GossipFrame\\ActiveQuestIcon",
	RUN = "Interface\\Icons\\Ability_Tracking",
	MAP = "Interface\\Icons\\Ability_Spy",
	FLY = "Interface\\Icons\\Ability_Druid_FlightForm",
	TRAIN = "Interface\\GossipFrame\\trainerGossipIcon",
	SETHOME = "Interface\\Icons\\Spell_Holy_ElunesGrace",
	HEARTH = "Interface\\Icons\\INV_Misc_Rune_01",
	GRIND = "Interface\\Icons\\INV_Stone_GrindingStone_05",
	ITEM = "Interface\\Icons\\INV_Misc_Bag_08",
}, {__index = function() return "Interface\\Icons\\INV_Misc_QuestionMark" end})


local actiontypes = {
	A = "ACCEPT",
	C = "COMPLETE",
	T = "TURNIN",
	R = "RUN",
	t = "TRAIN",
	h = "SETHOME",
	H = "HEARTH",
	G = "GRIND",
	I = "ITEM",
}


function TourGuide:Enable()
	self:UpdateStatusFrame()
end


function TourGuide:GetQuestLogIndexByName(name)
	name = name or self.quests[self.current]
	for i=1,GetNumQuestLogEntries() do
		if GetQuestLogTitle(i) == name then return i end
	end
end

function TourGuide:GetQuestDetails(name)
	local i = self:GetQuestLogIndexByName(name)
	local complete = i and select(7, GetQuestLogTitle(i)) == 1
	return i, complete
end


local function FindBagSlot(itemid)
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			local item = GetContainerItemLink(bag, slot)
			if item and string.find(item, "item:"..itemid) then return bag, slot end
		end
	end
end


function TourGuide:GetCurrentObjectiveInfo()
	return self:GetObjectiveInfo(self.current)
end


function TourGuide:GetObjectiveInfo(i)
	local action, quest, note = self.actions[i], self.quests[i], self.notes[i]
	if not action then return end


	local logi, complete = self:GetQuestDetails(quest)
	local hasitem = action == "ITEM" and self.questitems[i] and FindBagSlot(self.questitems[i])

	return action, quest:gsub("@.*@", ""), note, logi, complete, hasitem, self.turnedin[quest]
end


local function ParseQuests(...)
	local actions, notes, quests, items = {}, {}, {}, {}

	for i=1,select("#", ...) do
		local text = select(i, ...)
		local _, _, action, quest = text:find("^(%a) ([^|]*)")
		local _, _, detailtype, detail = string.find(text, "|(.)|([^|]+)|")
		quest = quest:trim()

		actions[i], quests[i] = actiontypes[action], quest
		if detailtype == "N" then notes[i] = detail end
		if action == "I" then items[i] = select(3, string.find(text, "|I|(%d+)|")) end
	end

	return actions, notes, quests, items
end


function TourGuide:ParseObjectives(text)
	self.actions, self.notes, self.quests, self.questitems = ParseQuests(string.split("\n", text))
end


function TourGuide:SetTurnedIn(i, value)
	self.turnedin[self.quests[i]] = value
	self:UpdateOHPanel()
	self:UpdateStatusFrame()
end
