local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local _G = _G
local unpack, pairs, select = unpack, pairs, select

local GetCurrencyListSize = GetCurrencyListSize
local GetNumFactions = GetNumFactions
local hooksecurefunc = hooksecurefunc
local CharacterFrameExpandButton = CharacterFrameExpandButton

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.character ~= true then return end

	CharacterFrameInset:StripTextures()
	CharacterFrameInsetRight:StripTextures()

	CharacterFramePortrait:Kill()

	CharacterFrame:StripTextures()
	CharacterFrame:SetTemplate("Transparent")

	CharacterModelFrame:StripTextures()
	CharacterModelFrame:CreateBackdrop("Default")
	CharacterModelFrame.backdrop:Point("TOPLEFT", -1, 1)
	CharacterModelFrame.backdrop:Point("BOTTOMRIGHT", 1, -2)
	CharacterModelFrameBackgroundOverlay:SetTexture(0, 0, 0, 0.6)

	S:HandleCloseButton(CharacterFrameCloseButton)

	local slots = {
		"HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"ShirtSlot",
		"TabardSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"MainHandSlot",
		"SecondaryHandSlot",
		"RangedSlot"
	}

	for _, slot in pairs(slots) do
		local icon = _G["Character"..slot.."IconTexture"]
		local cooldown = _G["Character"..slot.."Cooldown"];
		local popout = _G["Character" .. slot .. "PopoutButton"];

		slot = _G["Character"..slot]
		slot:StripTextures()
		slot:StyleButton(false)
		slot.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])
		slot:SetTemplate("Default", true, true);
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside();

		slot:SetFrameLevel(PaperDollFrame:GetFrameLevel() + 2);

		if(cooldown) then
			E:RegisterCooldown(cooldown);
		end

		if(popout) then
			popout:StripTextures();
			popout:SetTemplate();
			popout:HookScript("OnEnter", S.SetModifiedBackdrop);
			popout:HookScript("OnLeave", S.SetOriginalBackdrop);

			popout.icon = popout:CreateTexture(nil, "ARTWORK");
			popout.icon:Size(14);
			popout.icon:Point("CENTER");
			popout.icon:SetTexture([[Interface\Buttons\SquareButtonTextures]])

			if(slot.verticalFlyout) then
				popout:Size(27, 11);
				SquareButton_SetIcon(popout, "DOWN");
				popout:Point("TOP", slot, "BOTTOM", 0, 5);
			else
				popout:Size(11, 27);
				SquareButton_SetIcon(popout, "RIGHT");
				popout:Point("LEFT", slot, "RIGHT", -5, 0);
			end
		end
	end

	local function SkinItemFlyouts(button)
		button.icon = _G[button:GetName() .. "IconTexture"];

		button:GetNormalTexture():SetTexture(nil);
		button:SetTemplate("Default");
		button:StyleButton(false);

		button.icon:SetInside();
		button.icon:SetTexCoord(unpack(E.TexCoords));

		local cooldown = _G[button:GetName() .."Cooldown"];
		if(cooldown) then
			E:RegisterCooldown(cooldown);
		end

		local location = button.location;
		if(not location) then return; end
		if(location and location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION) then return; end

		local id = EquipmentManager_GetItemInfoByLocation(location);
		local _, _, quality = GetItemInfo(id);
		local r, g, b = GetItemQualityColor(quality);

		button:SetBackdropBorderColor(r, g, b);
 	end
 	hooksecurefunc("EquipmentFlyout_DisplayButton", SkinItemFlyouts);

	hooksecurefunc("EquipmentFlyout_Show", function(self)
		EquipmentFlyoutFrameButtons:StripTextures()
		EquipmentFlyoutFrameHighlight:Kill()
		if(self.verticalFlyout) then
			EquipmentFlyoutFrame.buttonFrame:Point("TOPLEFT", self.popoutButton, "BOTTOMLEFT", -10, 0);
		else
			EquipmentFlyoutFrame.buttonFrame:Point("TOPLEFT", self.popoutButton, "TOPRIGHT", 0, 10);
		end
	end)

	hooksecurefunc("EquipmentFlyoutPopoutButton_SetReversed", function(self, isReversed)
		if(self:GetParent().verticalFlyout) then
			if(isReversed) then
				SquareButton_SetIcon(self, "UP");
			else
				SquareButton_SetIcon(self, "DOWN");
			end
		else
			if(isReversed) then
				SquareButton_SetIcon(self, "LEFT");
			else
				SquareButton_SetIcon(self, "RIGHT");
			end
		end
	end);

	local function ColorItemBorder()
		for _, slot in pairs(slots) do
			local target = _G["Character"..slot]
			local slotId, _, _ = GetInventorySlotInfo(slot)
			local itemId = GetInventoryItemID("player", slotId)

			if(itemId) then
				local rarity = GetInventoryItemQuality("player", slotId);
				if(rarity and rarity > 1) then
					target:SetBackdropBorderColor(GetItemQualityColor(rarity))
				else
					target:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				end
			else
				target:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			end
		end
	end

	local CheckItemBorderColor = CreateFrame("Frame")
	CheckItemBorderColor:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	CheckItemBorderColor:SetScript("OnEvent", ColorItemBorder)
	CharacterFrame:HookScript("OnShow", ColorItemBorder)
	ColorItemBorder()

	CharacterFrameExpandButton:Size(CharacterFrameExpandButton:GetWidth() - 5, CharacterFrameExpandButton:GetHeight() - 5)
	S:HandleNextPrevButton(CharacterFrameExpandButton)

	hooksecurefunc("CharacterFrame_Collapse", function()
		CharacterFrameExpandButton:SetNormalTexture(nil);
		CharacterFrameExpandButton:SetPushedTexture(nil);
		CharacterFrameExpandButton:SetDisabledTexture(nil);
		SquareButton_SetIcon(CharacterFrameExpandButton, "RIGHT")
	end)

	hooksecurefunc("CharacterFrame_Expand", function()
		CharacterFrameExpandButton:SetNormalTexture(nil);
		CharacterFrameExpandButton:SetPushedTexture(nil);
		CharacterFrameExpandButton:SetDisabledTexture(nil);
		SquareButton_SetIcon(CharacterFrameExpandButton, "LEFT");
	end)

	if(GetCVar("characterFrameCollapsed") ~= "0") then
		SquareButton_SetIcon(CharacterFrameExpandButton, "RIGHT")
	else
		SquareButton_SetIcon(CharacterFrameExpandButton, "LEFT");
	end

	-- Control Frame
	CharacterModelFrameControlFrame:StripTextures()
	CharacterModelFrameControlFrame:Size(123, 23)

	local controlbuttons = {
		"CharacterModelFrameControlFrameZoomInButton",
		"CharacterModelFrameControlFrameZoomOutButton",
		"CharacterModelFrameControlFramePanButton",
		"CharacterModelFrameControlFrameRotateLeftButton",
		"CharacterModelFrameControlFrameRotateRightButton",
		"CharacterModelFrameControlFrameRotateResetButton"
	}

	for i = 1, #controlbuttons do
		S:HandleButton(_G[controlbuttons[i]])
		_G[controlbuttons[i].."Bg"]:Hide()
	end

	CharacterModelFrameControlFrameZoomOutButton:Point("LEFT", "CharacterModelFrameControlFrameZoomInButton", "RIGHT", 2, 0)
	CharacterModelFrameControlFramePanButton:Point("LEFT", "CharacterModelFrameControlFrameZoomOutButton", "RIGHT", 2, 0)
	CharacterModelFrameControlFrameRotateLeftButton:Point("LEFT", "CharacterModelFrameControlFramePanButton", "RIGHT", 2, 0)
	CharacterModelFrameControlFrameRotateRightButton:Point("LEFT", "CharacterModelFrameControlFrameRotateLeftButton", "RIGHT", 2, 0)
	CharacterModelFrameControlFrameRotateResetButton:Point("LEFT", "CharacterModelFrameControlFrameRotateRightButton", "RIGHT", 2, 0)

	--Titles
	PaperDollTitlesPane:HookScript("OnShow", function(self)
		for x, object in pairs(PaperDollTitlesPane.buttons) do
			object.BgTop:SetTexture(nil)
			object.BgBottom:SetTexture(nil)
			object.BgMiddle:SetTexture(nil)

			object.Check:SetTexture(nil)
			object.text:FontTemplate()
			object.text.SetFont = E.noop
			object:StyleButton()
			object.SelectedBar:SetTexture(0, 0.7, 1, 0.75)
			object.SelectedBar:SetInside()
			object.Stripe:SetInside()
		end
	end)

	S:HandleScrollBar(PaperDollTitlesPaneScrollBar)

	--Equipement Manager
	PaperDollEquipmentManagerPane:StripTextures()

	PaperDollEquipmentManagerPane:HookScript("OnShow", function(self)
		for _, object in pairs(PaperDollEquipmentManagerPane.buttons) do
			object.BgTop:SetTexture(nil)
			object.BgBottom:SetTexture(nil)
			object.BgMiddle:SetTexture(nil)
			object.Check:SetTexture(nil)

			object.SelectedBar:SetTexture(0, 0.7, 1, 0.75)
			object.SelectedBar:SetInside()
			object.HighlightBar:SetTexture(1, 1, 1, 0.30)
			object.HighlightBar:SetInside()
			object.Stripe:SetInside()

			object:CreateBackdrop("Default")
			object.backdrop:Point("TOPLEFT", object.icon, -1, 1)
			object.backdrop:Point("BOTTOMRIGHT", object.icon, 1, -1)

			object.icon:SetTexCoord(unpack(E.TexCoords))
			object.icon:SetParent(object.backdrop)
			object.icon:SetPoint("LEFT", object, "LEFT", 1, 0)
			object.icon.SetPoint = E.noop
			object.icon:Size(40)
			object.icon.SetSize = E.noop
		end
	end)

	S:HandleButton(PaperDollEquipmentManagerPaneEquipSet)
	PaperDollEquipmentManagerPaneEquipSet:Point("TOPLEFT", PaperDollEquipmentManagerPane, "TOPLEFT", 8, 0)
	PaperDollEquipmentManagerPaneEquipSet:Width(PaperDollEquipmentManagerPaneEquipSet:GetWidth() - 8)
	PaperDollEquipmentManagerPaneEquipSet.ButtonBackground:SetTexture(nil)

	S:HandleButton(PaperDollEquipmentManagerPaneSaveSet)
	PaperDollEquipmentManagerPaneSaveSet:Point("LEFT", PaperDollEquipmentManagerPaneEquipSet, "RIGHT", 4, 0)
	PaperDollEquipmentManagerPaneSaveSet:Width(PaperDollEquipmentManagerPaneSaveSet:GetWidth() - 8)

	S:HandleScrollBar(PaperDollEquipmentManagerPaneScrollBar)

	--Equipement Manager Popup
	S:HandleIconSelectionFrame(GearManagerDialogPopup, NUM_GEARSET_ICONS_SHOWN, "GearManagerDialogPopupButton", frameNameOverride)

	S:HandleScrollBar(GearManagerDialogPopupScrollFrameScrollBar)

	GearManagerDialogPopupScrollFrame:CreateBackdrop("Transparent")
	GearManagerDialogPopupScrollFrame.backdrop:Point("TOPLEFT", 51, 2)
	GearManagerDialogPopupScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, 4)

	GearManagerDialogPopup:Point("TOPLEFT", PaperDollFrame, "TOPRIGHT", 1, 0)

	--Bottom Tabs
	for i = 1, 4 do
		S:HandleTab(_G["CharacterFrameTab"..i])
	end

	--Character Tabs
	PaperDollSidebarTabs:StripTextures()

	local function FixSidebarTabCoords()
		for i = 1, #PAPERDOLL_SIDEBARS do
			local tab = _G["PaperDollSidebarTab"..i]
			if(tab) then
				tab.Highlight:SetTexture(1, 1, 1, 0.3)
				tab.Highlight:Point("TOPLEFT", 3, -4)
				tab.Highlight:Point("BOTTOMRIGHT", -1, 0)
				tab.Hider:SetTexture(0.4, 0.4, 0.4, 0.4)
				tab.Hider:Point("TOPLEFT", 3, -4)
				tab.Hider:Point("BOTTOMRIGHT", -1, 0)
				tab.TabBg:Kill()

				if(i == 1) then
					for x = 1, tab:GetNumRegions() do
						local region = select(x, tab:GetRegions())
						region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
						region.SetTexCoord = E.noop
					end
				end
				tab:CreateBackdrop("Default")
				tab.backdrop:Point("TOPLEFT", 1, -2)
				tab.backdrop:Point("BOTTOMRIGHT", 1, -2)	
			end
		end
	end
	hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", FixSidebarTabCoords)

	--Stat Panels
	CharacterStatsPane:StripTextures()

	S:HandleScrollBar(CharacterStatsPaneScrollBar)

	for i = 1, 7 do
		_G["CharacterStatsPaneCategory"..i]:StripTextures()
	end

	hooksecurefunc("PaperDollFrame_SetResistance", function(statFrame, unit, resistanceIndex)
		local _, resistance = UnitResistance(unit, resistanceIndex);
		local resistanceNameShort = _G["SPELL_SCHOOL"..resistanceIndex.."_CAP"];
		local resistanceName = _G["RESISTANCE"..resistanceIndex.."_NAME"];
		local resistanceIconCode = "|TInterface\\PaperDollInfoFrame\\SpellSchoolIcon"..(resistanceIndex+1)..":13:13:0:0:64:64:4:55:4:55|t";

		_G[statFrame:GetName().."Label"]:SetText(resistanceIconCode.." "..format(STAT_FORMAT, resistanceNameShort));
		statFrame.tooltip = resistanceIconCode.." "..HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, resistanceName).." "..resistance..FONT_COLOR_CODE_CLOSE;
	end)

	--Reputation
	ReputationFrame:StripTextures(true)

	ReputationListScrollFrame:StripTextures()
	S:HandleScrollBar(ReputationListScrollFrameScrollBar)

	for i = 1, NUM_FACTIONS_DISPLAYED do
		local factionRow = _G["ReputationBar" .. i];
		local factionBar = _G["ReputationBar" .. i .. "ReputationBar"];
		local factionButton = _G["ReputationBar" .. i .. "ExpandOrCollapseButton"];

		factionRow:StripTextures(true);

		factionBar:StripTextures();
		factionBar:CreateBackdrop("Default");
		factionBar:SetStatusBarTexture(E["media"].normTex);
		E:RegisterStatusBar(factionBar);

		factionButton:SetNormalTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
		factionButton.SetNormalTexture = function() end
		factionButton:GetNormalTexture():SetInside()
		factionButton:SetHighlightTexture(nil)

		factionRow.War = factionRow:CreateTexture(nil, "OVERLAY")
		factionRow.War:SetTexture("Interface\\Buttons\\UI-CheckBox-SwordCheck")
		factionRow.War:Size(30)
		factionRow.War:Point("RIGHT", 32, -7)
	end

	local function UpdateFaction()
		local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame)
		local numFactions = GetNumFactions()

		for i = 1, NUM_FACTIONS_DISPLAYED, 1 do
			local Bar = _G["ReputationBar"..i]
			local Button = _G["ReputationBar"..i.."ExpandOrCollapseButton"]
			local factionIndex = factionOffset + i

			if factionIndex <= numFactions then
				local _, _, _, _, _, _, atWarWith, canToggleAtWar, isHeader, isCollapsed = GetFactionInfo(factionIndex)

				if isCollapsed then
					Button:GetNormalTexture():SetTexCoord(0, 0.4375, 0, 0.4375)
				else
					Button:GetNormalTexture():SetTexCoord(0.5625, 1, 0, 0.4375)
				end

				if atWarWith and canToggleAtWar and (not isHeader) then
					Bar.War:Show()
				else
					Bar.War:Hide()
				end
			end
		end
	end
	hooksecurefunc("ReputationFrame_Update", UpdateFaction)

	ReputationDetailFrame:StripTextures()
	ReputationDetailFrame:SetTemplate("Transparent")
	ReputationDetailFrame:Point("TOPLEFT", ReputationFrame, "TOPRIGHT", 1, 0)

	S:HandleCheckBox(ReputationDetailMainScreenCheckBox)
	S:HandleCheckBox(ReputationDetailInactiveCheckBox)

	S:HandleCheckBox(ReputationDetailAtWarCheckBox)
	ReputationDetailAtWarCheckBox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-SwordCheck")

	S:HandleCloseButton(ReputationDetailCloseButton)
	ReputationDetailCloseButton:Point("TOPRIGHT", 3, 4)

	--Currency
	TokenFrame:HookScript("OnShow", function()
		for i = 1, GetCurrencyListSize() do
			local button = _G["TokenFrameContainerButton"..i]

			if(button) then
				button.highlight:Kill()
				button.categoryMiddle:Kill()	
				button.categoryLeft:Kill()	
				button.categoryRight:Kill()

				button.icon:SetTexCoord(unpack(E.TexCoords))
			end
		end
		TokenFramePopup:StripTextures()
		TokenFramePopup:SetTemplate("Transparent")
		TokenFramePopup:Point("TOPLEFT", TokenFrame, "TOPRIGHT", 1, 0)
	end)

	S:HandleScrollBar(TokenFrameContainerScrollBar)

	S:HandleCheckBox(TokenFramePopupInactiveCheckBox)
	S:HandleCheckBox(TokenFramePopupBackpackCheckBox)

	S:HandleCloseButton(TokenFramePopupCloseButton)
	TokenFramePopupCloseButton:Point("TOPRIGHT", 3, 4)

	--Pet
	PetModelFrame:CreateBackdrop("Transparent")

	PetPaperDollFrameExpBar:StripTextures()
	PetPaperDollFrameExpBar:CreateBackdrop("Default")
	PetPaperDollFrameExpBar:SetStatusBarTexture(E["media"].normTex)

	S:HandleRotateButton(PetModelFrameRotateRightButton)
	S:HandleRotateButton(PetModelFrameRotateLeftButton)

	PetModelFrameRotateRightButton:ClearAllPoints()
	PetModelFrameRotateRightButton:Point("LEFT", PetModelFrameRotateLeftButton, "RIGHT", 4, 0)

	local xtex = PetPaperDollPetInfo:GetRegions()
	xtex:SetTexCoord(.12, .63, .15, .55)

	PetPaperDollPetInfo:CreateBackdrop("Default")
	PetPaperDollPetInfo:Size(24)

	PetPaperDollPetModelBg:SetDesaturated(true)
end

S:AddCallback("Character", LoadSkin);