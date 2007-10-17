

local actiontypes = {
	A = "ACCEPT",
	C = "COMPLETE",
	T = "TURNIN",
	K = "KILL",
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


function TourGuide:GetObjectiveTag(tag, i)
	self:Debug(11, "GetObjectiveTag", tag, i)
	i = i or self.current
	local tags = self.tags[i]
	if not tags then return end

	if tag == "O" then return tags:find("|O|")
	elseif tag == "L" then
		local _, _, lootitem, lootqty = tags:find("|L|(%d+)%s?(%d*)|")
		lootqty = tonumber(lootqty) or 1

		return lootitem, lootqty
	end

	return select(3, tags:find("|"..tag.."|([^|]*)|?"))
end


local myclass = UnitClass("player")
local titlematches = {"For", "A", "The", "Or", "In", "Then", "From", "To"}
local function ParseQuests(...)
	local accepts, turnins, completes = {}, {}, {}
	local uniqueid = 1
	local actions, quests, tags = {}, {}, {}
	local i, haserrors = 1, false

	for j=1,select("#", ...) do
		local text = select(j, ...)
		local _, _, class = text:find("|C|([^|]+)|")

		if text ~= "" and (not class or class == myclass) then
			local _, _, action, quest, tag = text:find("^(%a) ([^|]*)(.*)")
			assert(actiontypes[action], "Unknown action: "..text)
			quest = quest:trim()
			if not (action == "A" or action =="C" or action =="T") then
				quest = quest.."@"..uniqueid.."@"
				uniqueid = uniqueid + 1
			end

			actions[i], quests[i], tags[i] = actiontypes[action], quest, tag

			i = i + 1

			-- Debuggery
			if not string.find(text, "|NODEBUG|") then
				if action == "A" then accepts[quest] = true
				elseif action == "T" then turnins[quest] = true
				elseif action == "C" then completes[quest] = true end

				if action == "A" or action == "C" or action == "T" then
					-- Catch bad Title Case
					for _,word in pairs(titlematches) do
						if quest:find("[^:]%s"..word.."%s") or quest:find("[^:]%s"..word.."$") or quest:find("[^:]%s"..word.."@") then
							TourGuide:DebugF(1, "%s %s -- Contains bad title case", action, quest)
							haserrors = true
						end
					end

					if quest:find("[“”’]") then
						TourGuide:DebugF(1, "%s %s -- Contains bad char", action, quest)
						haserrors = true
					end
				end

				local _, _, comment = string.find(text, "(|[NLUC]V?|[^|]+)$") or string.find(text, "(|[NLUC]V?|[^|]+) |[NLUC]V?|")
				if comment then
					TourGuide:Debug(1, "Unclosed comment: ".. comment)
					haserrors = true
				end
			end
		end
	end

	-- More debug
	for quest in pairs(accepts) do if not turnins[quest] then TourGuide:DebugF(1, "Quest has no 'turnin' objective: %s", quest) end end
	for quest in pairs(turnins) do if not accepts[quest] then TourGuide:DebugF(1, "Quest has no 'accept' objective: %s", quest) end end
	for quest in pairs(completes) do if not accepts[quest] and not turnins[quest] then TourGuide:DebugF(1, "Quest has no 'accept' and 'turnin' objectives: %s", quest) end end

	if haserrors and TourGuide:IsDebugEnabled() then TourGuide:Print("This guide contains errors") end

	return actions, quests, tags
end


function TourGuide:LoadGuide(name)
	if not name then return end

	self.db.char.currentguide = name
	if not self.guides[name] then self.db.char.currentguide = self.guidelist[1] end
	self:DebugF(1, "Loading guide: %s", name)
	self.guidechanged = true
	local _, _, zonename = name:find("^(.*) %(.*%)$")
	self.zonename = zonename
	self.actions, self.quests, self.tags = ParseQuests(string.split("\n", self.guides[self.db.char.currentguide]()))
end


