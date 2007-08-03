
TourGuide = DongleStub("Dongle-1.0"):New("TourGuide")


TourGuide.icons = setmetatable({
	ACCEPT = "Interface\\GossipFrame\\AvailableQuestIcon",
	COMPLETE = "Interface\\Icons\\Ability_DualWield",
	TURNIN = "Interface\\GossipFrame\\ActiveQuestIcon",
	RUN = "Interface\\Icons\\Ability_Rogue_Sprint",
	MAP = "Interface\\Icons\\Ability_Spy",
	FLY = "Interface\\Icons\\Ability_Druid_FlightForm",
}, {__index = function() return "Interface\\Icons\\INV_Misc_QuestionMark" end})


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


function TourGuide:GetObjectiveInfo(i)
	local action, quest, note = self.actions[i], self.quests[i], self.notes[i]
	if not action then return end

	local itemstarted = self.itemstartedquests[quest]
	local logi, complete = self:GetQuestDetails(quest)

	return action, quest, note, logi, complete, itemstarted
end


function TourGuide:Initialize()
	self:UpdateStatusFrame()
end
