
local OptionHouse = DongleStub("OptionHouse-1.0")


local myfaction = UnitFactionGroup("player")

TourGuide = DongleStub("Dongle-1.0"):New("TourGuide")
if tekDebug then TourGuide:EnableDebug(1, tekDebug:GetFrame("TourGuide")) end
TourGuide.guides = {}
TourGuide.guidelist = {}
TourGuide.nextzones = {}


TourGuide.icons = setmetatable({
	ACCEPT = "Interface\\GossipFrame\\AvailableQuestIcon",
	COMPLETE = "Interface\\Icons\\Ability_DualWield",
	TURNIN = "Interface\\GossipFrame\\ActiveQuestIcon",
	RUN = "Interface\\Icons\\Ability_Tracking",
	MAP = "Interface\\Icons\\Ability_Spy",
	FLY = "Interface\\Icons\\Ability_Druid_FlightForm",
	TRAIN = "Interface\\GossipFrame\\trainerGossipIcon",
	SETHEARTH = "Interface\\Icons\\Spell_Holy_ElunesGrace",
	HEARTH = "Interface\\Icons\\INV_Misc_Rune_01",
	NOTE = "Interface\\Icons\\INV_Misc_Note_01",
	GRIND = "Interface\\Icons\\INV_Stone_GrindingStone_05",
	USE = "Interface\\Icons\\INV_Misc_Bag_08",
	BUY = "Interface\\Icons\\INV_Misc_Coin_01",
	BOAT = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
	GETFLIGHTPOINT = "Interface\\Icons\\Spell_Nature_GiftoftheWaterSpirit",
}, {__index = function() return "Interface\\Icons\\INV_Misc_QuestionMark" end})


local actiontypes = {
	A = "ACCEPT",
	C = "COMPLETE",
	T = "TURNIN",
	R = "RUN",
	t = "TRAIN",
	H = "HEARTH",
	h = "SETHEARTH",
	G = "GRIND",
	F = "FLY",
	f = "GETFLIGHTPOINT",
	N = "NOTE",
	B = "BUY",
	b = "BOAT",
	U = "USE",
}


function TourGuide:Initialize()
	self.db = self:InitializeDB("TourGuideAlphaDB", {
		char = {
			turnedin = {},
			cachedturnins = {},
		},
	})
	self.turnedin = self.db.char.turnedin
	self.cachedturnins = self.db.char.cachedturnins

	self.db.char.currentguide = self.db.char.currentguide or self.guidelist[1]
	self:LoadGuide(self.db.char.currentguide)
	self:PositionStatusFrame()
end


function TourGuide:Enable()
	local _, title = GetAddOnInfo("TourGuide")
	local author, version = GetAddOnMetadata("TourGuide", "Author"), GetAddOnMetadata("TourGuide", "Version")
	local oh = OptionHouse:RegisterAddOn("Tour Guide", title, author, version)
	oh:RegisterCategory("Guides", TourGuide, "CreateGuidesPanel")
	oh:RegisterCategory("Objectives", TourGuide, "CreateObjectivePanel")

	for _,event in pairs(self.TrackEvents) do self:RegisterEvent(event) end
	self.TrackEvents = nil
	self:UpdateStatusFrame()
end


function TourGuide:RegisterGuide(name, nextzone, faction, sequencefunc)
	if faction ~= myfaction then return end
	self.guides[name] = sequencefunc
	self.nextzones[name] = nextzone
	table.insert(self.guidelist, name)
end


function TourGuide:LoadGuide(name)
	if not name then return end

	self.db.char.currentguide = name
	if not self.guides[name] then self.db.char.currentguide = self.guidelist[1] end
	self:DebugF(1, "Loading guide: %s", name)
	self:ParseObjectives(self.guides[self.db.char.currentguide]())
end


function TourGuide:LoadNextGuide()
	local name = self.nextzones[self.db.char.currentguide]
	if not name then return end

	for i,quest in ipairs(self.quests) do self.turnedin[quest] = nil end -- Clean out old completed objectives, to avoid conflicts

	self:LoadGuide(name)
	self:UpdateGuidesPanel()
	return true
end


function TourGuide:GetQuestLogIndexByName(name)
	name = name or self.quests[self.current]
	name = name:gsub("%s%(Part %d+%)", "")
	for i=1,GetNumQuestLogEntries() do
		if GetQuestLogTitle(i) == name then return i end
	end
end

function TourGuide:GetQuestDetails(name)
	if not name then return end

	local i = self:GetQuestLogIndexByName(name)
	local complete = i and select(7, GetQuestLogTitle(i)) == 1
	return i, complete
end


function TourGuide:FindBagSlot(itemid)
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
	local hasitem = action == "ITEM" and self.questitems[i] and self:FindBagSlot(self.questitems[i])

	return action, quest:gsub("@.*@", ""), note, logi, complete, hasitem, self.turnedin[quest], quest, self.useitems[i], self.optional[i]
end


local myclass = UnitClass("player")
local titlematches = {"For", "A", "The", "Or", "In", "Then", "From", "To"}
local function ParseQuests(...)
	local accepts, turnins, completes = {}, {}, {}
	local uniqueid = 1
	local actions, notes, quests, items, useitems, optionals = {}, {}, {}, {}, {}, {}
	local i = 1

	for j=1,select("#", ...) do
		local text = select(j, ...)
		local _, _, class = text:find("|C|([^|]+)|")

		if text ~= "" and (not class or class == myclass) then
			local _, _, action, quest = text:find("^(%a) ([^|]*)")
			assert(actiontypes[action], "Unknown action: "..text)
			quest = quest:trim()
			if not (action == "I" or action == "A" or action =="C" or action =="T") then
				quest = quest.."@"..uniqueid.."@"
				uniqueid = uniqueid + 1
			end

			actions[i], quests[i] = actiontypes[action], quest

			local _, _, note = string.find(text, "|N|([^|]+)|")
			if note then notes[i] = note end

			local _, _, item = string.find(text, "|I|(%d+)|")
			if item then items[i] = item end

			local _, _, useitem = string.find(text, "|U|(%d+)|")
			if useitem then useitems[i] = useitem end

			if string.find(text, "|O|") then optionals[i] = true end

			i = i + 1

			-- Debuggery
			if action == "A" then accepts[quest] = true
			elseif action == "T" then turnins[quest] = true
			elseif action == "C" then completes[quest] = true end

			if action == "A" or action == "C" or action == "T" then
				-- Catch bad Title Case
				for _,word in pairs(titlematches) do
					if quest:find("[^:]%s"..word.."%s") or quest:find("[^:]%s"..word.."$") or quest:find("[^:]%s"..word.."@") then
						TourGuide:DebugF(1, "%s %s -- Contains bad title case", action, quest)
					end
				end
			end
			local _, _, comment = string.find(text, "(|.|[^|]+)$")
			if comment then TourGuide:Debug(1, "Unclosed comment: ".. comment) end
		end
	end

	-- More debug
	for quest in pairs(accepts) do if not turnins[quest] then TourGuide:DebugF(1, "Quest has no 'turnin' objective: %s", quest) end end
	for quest in pairs(turnins) do if not accepts[quest] then TourGuide:DebugF(1, "Quest has no 'accept' objective: %s", quest) end end
	for quest in pairs(completes) do if not accepts[quest] and not turnins[quest] then TourGuide:DebugF(1, "Quest has no 'accept' and 'turnin' objectives: %s", quest) end end

	return actions, notes, quests, items, useitems, optionals
end


function TourGuide:ParseObjectives(text)
	self.actions, self.notes, self.quests, self.questitems, self.useitems, self.optional = ParseQuests(string.split("\n", text))
end


function TourGuide:SetTurnedIn(i, value)
	if not i then
		i = self.current
		value = true
	end

	if value then value = true else value = nil end -- Cleanup to minimize savedvar data

	self.turnedin[self.quests[i]] = value
	self:DebugF(1, "Set turned in %q = %s", self.quests[i], tostring(value))
	self:UpdateStatusFrame()
end


function TourGuide:CompleteQuest(name)
	local i = self.current + 1
	repeat
		action, quest, note, logi, complete, hasitem, turnedin, fullquestname = self:GetObjectiveInfo(i)
		if action == "TURNIN" and not turnedin and name == quest:gsub("%s%(Part %d+%)", "") then
			self:DebugF(1, "Saving early quest turnin %q", quest)
			return self:SetTurnedIn(i, true)
		end
		i = i + 1
	until not action
	self:DebugF(1, "Quest %q not found!", name)
end
