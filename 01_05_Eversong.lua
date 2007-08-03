
local TourGuide = TourGuide
local _, class = UnitClass("player")

local questsequence = class == "WARLOCK" and
[[A Reclaiming Sunstrider Isle
C Reclaiming Sunstrider Isle
T Reclaiming Sunstrider Isle
A Unfortunate Measures
A Warlock Training
T Warlock Training
A Windows to the Source
t Train (Level 2)
A Well Watcher Solanian
T Well Watcher Solanian
A The Shrine of Dath'Remar
A Solanian's Belongings
A A Fistful of Slivers
A Thirst Unending
C Unfortunate Measures
T Unfortunate Measures
A Report to Lanthan Perilon
T Report to Lanthan Perilon
A Aggression
C Aggression
C The Shrine of Dath'Remar
C Thirst Unending
C A Fistful of Slivers
C Solanian's Belongings
T Thirst Unending
T A Fistful of Slivers
t Train (Level 4)
T The Shrine of Dath'Remar
T Solanian's Belongings
T Aggression
C Windows to the Source
A Felendren the Banished
C Felendren the Banished
T Windows to the Source
T Felendren the Banished
A Aiding The Outrunners
T Tainted Arcane Sliver
R Ruins of Silvermoon]]
	or
[[A Reclaiming Sunstrider Isle
C Reclaiming Sunstrider Isle
T Reclaiming Sunstrider Isle
A Unfortunate Measures
A YOUR CLASS QUEST
T YOUR CLASS QUEST
t Train (Level 2)
A Well Watcher Solanian
T Well Watcher Solanian
A The Shrine of Dath'Remar
A Solanian's Belongings
A A Fistful of Slivers
A Thirst Unending
C Unfortunate Measures
T Unfortunate Measures
A Report to Lanthan Perilon
T Report to Lanthan Perilon
A Aggression
C Aggression
C The Shrine of Dath'Remar
C Thirst Unending
C A Fistful of Slivers
C Solanian's Belongings
T Thirst Unending
T A Fistful of Slivers
t Train (Level 4)
T The Shrine of Dath'Remar
T Solanian's Belongings
T Aggression
A Felendren the Banished
C Felendren the Banished
T Felendren the Banished
A Aiding The Outrunners
T Tainted Arcane Sliver
R Ruins of Silvermoon]]


local actiontypes = {
	A = "ACCEPT",
	C = "COMPLETE",
	T = "TURNIN",
	R = "RUN",
	t = "TRAIN",
}


local function ParseActions(a1, ...)
	if select(1, ...) then return actiontypes[string.char(a1:byte())], ParseActions(...)
	else return actiontypes[string.char(a1:byte())] end
end


local function ParseQuests(a1, ...)
	if select(1, ...) then return a1:sub(3), ParseQuests(...)
	else return a1:sub(3) end
end


local function ParseSequence(...)
	return {ParseActions(...)}, {ParseQuests(...)}
end


local actions, quests = ParseSequence(string.split("\n", questsequence))


local itemstartedquests = {["Tainted Arcane Sliver"] = 20483}
local notes = {["Felendren the Banished"] = 'You should find an item while doing this quest which starts "Tainted Arcane Sliver"'}


TourGuide.itemstartedquests = itemstartedquests
TourGuide.quests = quests
TourGuide.actions = actions
TourGuide.notes = notes

