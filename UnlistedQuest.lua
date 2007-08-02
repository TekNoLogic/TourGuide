
local TourGuide = TourGuide

local notlisted = CreateFrame("Frame", nil, QuestFrame)
notlisted:SetWidth(32)
notlisted:SetHeight(32)
notlisted:SetPoint("TOPLEFT", 70, -45)
notlisted:RegisterEvent("QUEST_DETAIL")
notlisted:RegisterEvent("QUEST_COMPLETE")
notlisted:SetScript("OnEvent", function(self, event)
	if event == "QUEST_COMPLETE" then return self:Hide() end
	local quest = GetTitleText()
	if quest and TourGuide.ourquests[quest] then self:Hide()
	else self:Show() end
end)

local nltex = notlisted:CreateTexture()
nltex:SetAllPoints()
nltex:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
