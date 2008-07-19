
local TourGuide = TourGuide


local frame = CreateFrame("Button", "TourGuideItemFrame", UIParent, "SecureActionButtonTemplate")
frame:SetFrameStrata("LOW")
frame:SetHeight(36)
frame:SetWidth(36)
frame:SetPoint("BOTTOMRIGHT", QuestWatchFrame, "TOPRIGHT", -62, 10)
frame:Hide()


local itemicon = frame:CreateTexture(nil, "ARTWORK")
itemicon:SetWidth(24) itemicon:SetHeight(24)
itemicon:SetTexture("Interface\\Icons\\INV_Misc_Bag_08")
itemicon:SetAllPoints(frame)


frame:RegisterForClicks("anyUp")
frame:HookScript("OnClick", function() if TourGuide:GetObjectiveInfo() == "USE" then TourGuide:SetTurnedIn() end end)


local texture, item
local function PLAYER_REGEN_ENABLED(self)
	if texture then
		itemicon:SetTexture(texture)
		frame:SetAttribute("type1", "item")
		frame:SetAttribute("item1", "item:"..item)
		frame:Show()
		texture = nil
	else
		frame:SetAttribute("item1", nil)
		frame:Hide()
	end
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end
frame:SetScript("OnEvent", PLAYER_REGEN_ENABLED)


function TourGuide:SetUseItem(tex, use)
	texture, item = tex, use
	if InCombatLockdown() then frame:RegisterEvent("PLAYER_REGEN_ENABLED") else PLAYER_REGEN_ENABLED(frame) end
end


frame:RegisterForDrag("LeftButton")
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(frame)
	frame:StopMovingOrSizing()
	TourGuide:Debug(1, "Item frame moved", GetUIParentAnchor(frame))
	TourGuide.db.profile.itemframepoint, TourGuide.db.profile.itemframex, TourGuide.db.profile.itemframey = GetUIParentAnchor(frame)
end)


function TourGuide:PositionItemFrame()
	if self.db.profile.itemframepoint then
		frame:ClearAllPoints()
		frame:SetPoint(self.db.profile.itemframepoint, self.db.profile.itemframex, self.db.profile.itemframey)
	end
	self.PositionItemFrame = nil
end
