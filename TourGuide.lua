
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
	SETHEARTH = "Interface\\AddOns\\TourGuide\\resting.tga",
	HEARTH = "Interface\\Icons\\INV_Misc_Rune_01",
	NOTE = "Interface\\Icons\\INV_Misc_Note_01",
	USE = "Interface\\Icons\\INV_Misc_Bag_08",
	BUY = "Interface\\Icons\\INV_Misc_Coin_01",
	BOAT = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
	GETFLIGHTPOINT = "Interface\\Icons\\Ability_Hunter_EagleEye",
	PET = "Interface\\Icons\\Ability_Hunter_BeastCall02",
}, {__index = function() return "Interface\\Icons\\INV_Misc_QuestionMark" end})


function TourGuide:Initialize()
	self.db = self:InitializeDB("TourGuideAlphaDB", {
		char = {
			hearth = "Unknown",
			turnedin = {},
			turnins = {},
			cachedturnins = {},
			trackquests = true,
			completion = {},
			currentguide = "No Guide",
			petskills = {},
		},
	})
	if self.db.char.turnedin then self.db.char.turnedin = nil end -- Purge old table if present
	self.cachedturnins = self.db.char.cachedturnins

	self.db.char.currentguide = self.db.char.currentguide or self.guidelist[1]
	self:LoadGuide(self.db.char.currentguide)
	self:PositionStatusFrame()
end


function TourGuide:Enable()
	self.Enable = nil -- Dongle likes to call Enable multiple times if we bug LightHeaded... so we need to nil out to ensure we are only called once
	if TomTom and TomTom.version ~= "SVN" and (tonumber(TomTom.version) or 0) < 120 then self:Print("Your version of TomTom is out of date.  TourGuide waypoints may not work correctly.") end

	for _,event in pairs(self.TrackEvents) do self:RegisterEvent(event) end
	self:RegisterEvent("QUEST_COMPLETE", "UpdateStatusFrame")
	self:RegisterEvent("QUEST_DETAIL", "UpdateStatusFrame")
	self.TrackEvents = nil
	self:QuestID_QUEST_LOG_UPDATE()
	self:UpdateStatusFrame()
end


function TourGuide:RegisterGuide(name, nextzone, faction, sequencefunc)
	if faction ~= myfaction then return end
	self.guides[name] = sequencefunc
	self.nextzones[name] = nextzone
	table.insert(self.guidelist, name)
end


function TourGuide:LoadNextGuide()
	self:LoadGuide(self.nextzones[self.db.char.currentguide] or "No Guide", true)
	self:UpdateGuidesPanel()
	return true
end


local firstcall = true
function TourGuide:GetQuestLogIndexByName(name)
	name = name or self.quests[self.current]
	name = name:gsub(L.PART_GSUB, "")
	for i=1,GetNumQuestLogEntries() do
		local title, _, _, _, isHeader = GetQuestLogTitle(i)
		if firstcall and not isHeader then
			firstcall = nil
			if string.sub(title, 1, 1) == "[" then self:Print("Another addon, most likely a \"Quest Level\" addon, is preventing TourGuide's quest detection from working correctly.") end
		end
		if not isHeader and title == name then return i end
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

	local qid = self:GetObjectiveTag("QID", i)

	return qid and self.turnedinquests[qid] or self.turnedin[self.quests[i]], self:GetQuestDetails(self.quests[i]) -- turnedin, logi, complete
end


function TourGuide:SetTurnedIn(i, value, noupdate)
	if not i then
		i = self.current
		value = true
	end

	if value then value = true else value = nil end -- Cleanup to minimize savedvar data

	local qid = self:GetObjectiveTag("QID", i)
	if qid then self.turnedinquests[qid] = value end
	self.turnedin[self.quests[i]] = value
	self:DebugF(1, "Set turned in %q = %s", self.quests[i], tostring(value))
	if not noupdate then self:UpdateStatusFrame()
	else self.updatedelay = i end
end


function TourGuide:CompleteQuest(name)
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
			return self:SetTurnedIn(i, true, true)
		end
		i = i + 1
	until not action
	self:DebugF(1, "Quest %q not found!", name)
end


---------------------------------
--      Utility Functions      --
---------------------------------

function TourGuide.ColorGradient(perc)
	if perc >= 1 then return 0,1,0
	elseif perc <= 0 then return 1,0,0 end

	local segment, relperc = math.modf(perc*2)
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, 1,0,0, 1,0.82,0, 0,1,0)
	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end


function TourGuide:DumpLoc()
	if IsShiftKeyDown() then
		if not self.db.global.savedpoints then self:Print("No saved points")
		else for t in string.gmatch(self.db.global.savedpoints, "([^\n]+)") do self:Print(t) end end
	elseif IsControlKeyDown() then
		self.db.global.savedpoints = nil
		self:Print("Saved points cleared")
	else
		local _, _, x, y = DongleStub("Astrolabe-0.4"):GetCurrentPlayerPosition()
		local s = string.format("%s, %s, (%.2f, %.2f) -- %s %s", GetZoneText(), GetSubZoneText(), x*100, y*100, self:GetObjectiveInfo())
		self.db.global.savedpoints = (self.db.global.savedpoints or "") .. s .. "\n"
		self:Print(s)
	end
end
