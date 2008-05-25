

--~ TourGuideQuestHistoryDB

local TourGuide = TourGuide
local L = TourGuide.Locale
local hadquest


local turnedinquests, currentquests, oldquests, titles, firstscan, abandoning = {}, {}, {}, {}, true
TourGuide.turnedinquests = turnedinquests
local qids = setmetatable({}, {
	__index = function(t,i)
		local v = tonumber(i:match("|Hquest:(%d+):"))
		t[i] = v
		return v
	end,
})

function TourGuide:QuestID_QUEST_LOG_UPDATE()
	currentquests, oldquests = oldquests, currentquests
	for i in pairs(currentquests) do currentquests[i] = nil end

	for i=1,GetNumQuestLogEntries() do
		local link = GetQuestLink(i)
		local qid = link and qids[link]
		if qid then
			currentquests[qid] = true
			titles[qid] = GetQuestLogTitle(i)
		end
	end

	if firstscan then
		local function helper(...)
			for i=1,select("#", ...) do
				local val = tonumber((select(i, ...)))
				if val then turnedinquests[val] = true end
			end
		end
		helper(string.split(",", TourGuideQuestHistoryDB or ""))
		firstscan = nil
		return
	end

	for qid in pairs(oldquests) do
		if not currentquests[qid] then
			local action = abandoning and "Abandoned quest" or "Completed quest"
			if not abandoning then turnedinquests[qid] = true end
			abandoning = nil
			self:Debug(1, action, qid, titles[qid])
			-- Callback
		end
	end

	for qid in pairs(currentquests) do
		if not oldquests[qid] then
			self:Debug(1, "Accepted quest", qid, titles[qid])
			-- Callback
		end
	end
end


function TourGuide:Disable()
	local temp = {}
	for i in pairs(turnedinquests) do table.insert(temp, i) end
	TourGuideQuestHistoryDB = string.join(",", unpack(temp))
end


local orig = AbandonQuest
function AbandonQuest(...)
	abandoning = true
	return orig(...)
end

