
local OptionHouse = LibStub("OptionHouse-1.1")


local myfaction = UnitFactionGroup("player")
local L = TOURGUIDE_LOCALE
TOURGUIDE_LOCALE = nil

TourGuide = DongleStub("Dongle-1.0"):New("TourGuide")
if tekDebug then TourGuide:EnableDebug(10, tekDebug:GetFrame("TourGuide")) end
TourGuide.guides = {}
TourGuide.guidelist = {}
TourGuide.nextzones = {}
TourGuide.Locale = L


TourGuide.icons = setmetatable({
	ACCEPT = "Interface\\GossipFrame\\AvailableQuestIcon",
	COMPLETE = "Interface\\Icons\\Ability_DualWield",
	TURNIN = "Interface\\GossipFrame\\ActiveQuestIcon",
	KILL = "Interface\\Icons\\Ability_Creature_Cursed_02",
	RUN = "Interface\\Icons\\Ability_Tracking",
	MAP = "Interface\\Icons\\Ability_Spy",
	FLY = "Interface\\Icons\\Ability_Druid_FlightForm",
	TRAIN = "Interface\\GossipFrame\\trainerGossipIcon",
	SETHEARTH = "Interface\\AddOns\\TourGuide\\resting.tga",
	HEARTH = "Interface\\Icons\\INV_Misc_Rune_01",
	NOTE = "Interface\\Icons\\INV_Misc_Note_01",
	GRIND = "Interface\\Icons\\INV_Stone_GrindingStone_05",
	USE = "Interface\\Icons\\INV_Misc_Bag_08",
	BUY = "Interface\\Icons\\INV_Misc_Coin_01",
	BOAT = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
	GETFLIGHTPOINT = "Interface\\Icons\\Ability_Hunter_EagleEye",
}, {__index = function() return "Interface\\Icons\\INV_Misc_QuestionMark" end})


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
	self:RegisterEvent("QUEST_COMPLETE", "UpdateStatusFrame")
	self:RegisterEvent("QUEST_DETAIL", "UpdateStatusFrame")
	self.TrackEvents = nil
	self:UpdateStatusFrame()
end


function TourGuide:RegisterGuide(name, nextzone, faction, sequencefunc)
	if faction ~= myfaction then return end
	self.guides[name] = sequencefunc
	self.nextzones[name] = nextzone
	table.insert(self.guidelist, name)
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
	name = name:gsub(L.PART_GSUB, "")
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


function TourGuide:GetObjectiveInfo(i)
	i = i or self.current
	if not self.actions[i] then return end

	return self.actions[i], self.quests[i]:gsub("@.*@", ""), self.quests[i] -- Action, display name, full name
end


function TourGuide:GetObjectiveStatus(i)
	i = i or self.current
	if not self.actions[i] then return end

	return self.turnedin[self.quests[i]], self:GetQuestDetails(self.quests[i]) -- turnedin, logi, complete
end


function TourGuide:SetTurnedIn(i, value, noupdate)
	if not i then
		i = self.current
		value = true
	end

	if value then value = true else value = nil end -- Cleanup to minimize savedvar data

	self.turnedin[self.quests[i]] = value
	self:DebugF(1, "Set turned in %q = %s", self.quests[i], tostring(value))
	if not noupdate then self:UpdateStatusFrame()
	else self.updatedelay = true end
end


function TourGuide:CompleteQuest(name, noupdate)
	if not self.current then
		self:DebugF(1, "Cannot complete %q, no guide loaded", name)
		return
	end

	local i = self.current
	local action, quest
	repeat
		action, quest = self:GetObjectiveInfo(i)
		if action == "TURNIN" and not self:GetObjectiveStatus(i) and name == quest:gsub(L.PART_GSUB, "") then
			self:DebugF(1, "Saving quest turnin %q", quest)
			return self:SetTurnedIn(i, true, noupdate)
		end
		i = i + 1
	until not action
	self:DebugF(1, "Quest %q not found!", name)
end
