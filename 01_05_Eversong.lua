
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
	"Aiding The Outrunners",
	"Tainted Arcane Sliver",
	"Ruins of Silvermoon"
}
local questorder = {1, 1, 1, 2, 3, 3, 4, 4, 5, 6, 7, 8, 2, 2, 9, 9, 10, 10, 5, 8, 7, 6, 8, 7, 5, 6, 10, 11, 11, 11, 12, 13, 14}
local actions    = {A, C, T, A, A, T, A, T, A, A, A, A, C, T, A, T,  A,  C, C, C, C, C, T, T, T, T,  T,  A,  C,  T,  A,  T, 'RUN'}
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
	notes[29], notes[28] = notes[28], nil
end

local ourquests = {}
for i,v in pairs(questnames) do ourquests[v] = true end


TourGuide.itemstartedquests = itemstartedquests
TourGuide.ourquests = ourquests
TourGuide.quests = quests
TourGuide.actions = actions
TourGuide.notes = notes


TourGuide:SetText(1)
