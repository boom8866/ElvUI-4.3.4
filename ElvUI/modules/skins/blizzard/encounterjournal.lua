local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local _G = _G
local select, unpack, pairs = select, unpack, pairs

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.encounterjournal ~= true then return end

	local EJ = _G["EncounterJournal"]
	EJ:StripTextures(true)
	EJ:SetTemplate("Transparent")

	EJ.inset:StripTextures(true)

	EJ.navBar:StripTextures(true)
	EJ.navBar:CreateBackdrop("Default")
	EJ.navBar.backdrop:Point("TOPLEFT", -2, 0)
	EJ.navBar.backdrop:Point("BOTTOMRIGHT")

	EJ.navBar.overlay:StripTextures(true)

	S:HandleEditBox(EJ.searchBox)

	S:HandleCloseButton(EncounterJournalCloseButton)

	--NavBar
	S:HandleButton(EJ.navBar.home, true)

	local function navButtonFrameLevel(self)
		for i = 1, #self.navList do
			local navButton = self.navList[i];
			local lastNav = self.navList[i-1];
			if(navButton and lastNav) then
				navButton:SetFrameLevel(lastNav:GetFrameLevel() - 2);
				navButton:ClearAllPoints();
				navButton:Point("LEFT", lastNav, "RIGHT", 1, 0);
			end
		end
	end

	hooksecurefunc("NavBar_AddButton", function(self)
		if(self:GetParent():GetName() == "HelpFrameKnowledgebase") then return; end

		local navButton = self.navList[#self.navList];

		if(not navButton.skinned) then
			S:HandleButton(navButton, true);
			navButton.skinned = true;

			navButton:HookScript("OnClick", function()
				navButtonFrameLevel(self);
			end)
		end

		navButtonFrameLevel(self);
	end)

	--Instance Selection Frame
	local InstanceSelect = EJ.instanceSelect
	InstanceSelect.bg:Kill()
	S:HandleDropDownBox(InstanceSelect.tierDropDown)
	S:HandleScrollBar(InstanceSelect.scroll.ScrollBar, 4)

	--Dungeon/Raid Tabs
	local function onEnable(self)
		self:Height(self.storedHeight)
	end

	local instanceTabs = {
		InstanceSelect.dungeonsTab,
		InstanceSelect.raidsTab
	}

	for _, instanceTab in pairs(instanceTabs) do
		instanceTab:StripTextures()
		instanceTab:CreateBackdrop("Default", true)
		instanceTab.backdrop:Point("TOPLEFT", -10, -1)
		instanceTab.backdrop:Point("BOTTOMRIGHT", 10, -1)
		instanceTab.backdrop:SetFrameLevel(instanceTab:GetFrameLevel() - 1)
		instanceTab:Height(instanceTab.storedHeight)

		instanceTab:HookScript("OnEnable", onEnable)
		instanceTab:HookScript("OnEnter", S.SetModifiedBackdrop)
		instanceTab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	InstanceSelect.raidsTab:Point("BOTTOMRIGHT", EncounterJournalInstanceSelect, "TOPRIGHT", -41, -45)

	--Encounter Info Frame
	local EncounterInfo = EJ.encounter.info

	EncounterJournalEncounterFrameInfoBG:Kill()

	EncounterInfo.difficulty:StripTextures()
	S:HandleButton(EncounterInfo.difficulty)
	EncounterInfo.difficulty:Width(100)
	EncounterInfo.difficulty:Point("TOPRIGHT", -5, -7)

	EncounterJournalEncounterFrameInfoResetButton:StripTextures()
	S:HandleButton(EncounterJournalEncounterFrameInfoResetButton)

	EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexCoord(0.90625000, 0.94726563, 0.00097656, 0.02050781)

	EncounterJournalEncounterFrameModelFrameShadow:Hide()
	EncounterJournalEncounterFrameModelFrame:CreateBackdrop("Transparent", true)

	local scrollFrames = {
		EncounterInfo.overviewScroll,
		EncounterInfo.lootScroll,
		EncounterInfo.detailsScroll
	}

	for _, scrollFrame in pairs(scrollFrames) do
		scrollFrame:CreateBackdrop("Transparent", true)
	end

	EncounterInfo.lootScroll.filter:StripTextures()
	EncounterInfo.lootScroll.filter:Point("TOPLEFT", EncounterJournalEncounterFrameInfo, "TOPRIGHT", -351, -7)
	S:HandleButton(EncounterInfo.lootScroll.filter)

	EncounterInfo.detailsScroll.child.description:SetTextColor(1, 1, 1)

	--Boss Tab
	EncounterJournalEncounterFrameInfoBossTab:StripTextures()
	EncounterJournalEncounterFrameInfoBossTab:SetTemplate("Transparent")
	EncounterJournalEncounterFrameInfoBossTab:Size(45, 40)
	EncounterJournalEncounterFrameInfoBossTab:Point("TOPLEFT", EncounterJournalEncounterFrameInfo, "TOPRIGHT", E.PixelMode and 7 or 9, 40)

	EncounterJournalEncounterFrameInfoBossTab.icon = EncounterJournalEncounterFrameInfoBossTab:CreateTexture(nil, "OVERLAY");
	EncounterJournalEncounterFrameInfoBossTab.icon:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoBossTab.icon:SetTexCoord(0.902, 0.996, 0.269, 0.311)
	EncounterJournalEncounterFrameInfoBossTab.icon:SetInside()
	EncounterJournalEncounterFrameInfoBossTab.icon:SetDesaturated(false)

	--Loot Tab
	EncounterJournalEncounterFrameInfoLootTab:StripTextures()
	EncounterJournalEncounterFrameInfoLootTab:SetTemplate("Transparent")
	EncounterJournalEncounterFrameInfoLootTab:Size(45, 40)
	EncounterJournalEncounterFrameInfoLootTab:Point("TOP", EncounterJournalEncounterFrameInfoBossTab, "BOTTOM", 0, -10)

	EncounterJournalEncounterFrameInfoLootTab.icon = EncounterJournalEncounterFrameInfoLootTab:CreateTexture(nil, "OVERLAY");
	EncounterJournalEncounterFrameInfoLootTab.icon:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoLootTab.icon:SetTexCoord(0.632, 0.726, 0.618, 0.660)
	EncounterJournalEncounterFrameInfoLootTab.icon:SetInside()
	EncounterJournalEncounterFrameInfoLootTab.icon:SetDesaturated(true)

	EncounterJournalEncounterFrameInfoBossTab:HookScript("OnClick", function()
		EncounterJournalEncounterFrameInfoBossTab.icon:SetDesaturated(false)
		EncounterJournalEncounterFrameInfoLootTab.icon:SetDesaturated(true)
	end)

	EncounterJournalEncounterFrameInfoLootTab:HookScript("OnClick", function()
		EncounterJournalEncounterFrameInfoLootTab.icon:SetDesaturated(false)
		EncounterJournalEncounterFrameInfoBossTab.icon:SetDesaturated(true)
	end)

	--Encounter Instance Frame
	local EncounterInstance = EJ.encounter.instance

	EncounterInstance:CreateBackdrop("Transparent", true)

	EncounterInstance.loreScroll.child.lore:SetTextColor(1, 1, 1)

	EncounterJournalEncounterFrameInfoLootScrollFrameClassFilterClearFrame:StripTextures()

	EncounterJournalEncounterFrameInstanceFrameMapButton:StripTextures();
	S:HandleButton(EncounterJournalEncounterFrameInstanceFrameMapButton)
	EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
	EncounterJournalEncounterFrameInstanceFrameMapButton:Point("TOPLEFT", EncounterJournalEncounterFrameInstanceFrame, "TOPLEFT", 505, 36)
	EncounterJournalEncounterFrameInstanceFrameMapButton:Size(50, 30)

	EncounterJournalEncounterFrameInstanceFrameMapButtonText:ClearAllPoints()
	EncounterJournalEncounterFrameInstanceFrameMapButtonText:Point("CENTER")

	--Class Filter Frame
	EncounterJournalEncounterFrameInfoLootScrollFrameClassFilterFrame:StripTextures()
	EncounterJournalEncounterFrameInfoLootScrollFrameClassFilterFrame:SetTemplate("Transparent")

	for i = 1, 10 do
		local button =  _G["EncounterJournalEncounterFrameInfoLootScrollFrameClassFilterFrameClass"..i];
		local edge = _G["EncounterJournalEncounterFrameInfoLootScrollFrameClassFilterFrameClass"..i.."BevelEdge"];
		local shadow = _G["EncounterJournalEncounterFrameInfoLootScrollFrameClassFilterFrameClass"..i.."Shadow"];
		local icon = button:GetNormalTexture();
		local pushed = button:GetPushedTexture();
		local highlight = button:GetHighlightTexture();

		S:HandleButton(button);
		button:StyleButton(nil, true);

		icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes");
		pushed:SetTexture("Interface\\WorldStateFrame\\Icons-Classes");
		highlight:SetTexture();

		edge:Kill();
		shadow:Kill();
	end

	--Dungeon/raid selection buttons
	local function SkinDungeons()
		local b1 = EncounterJournalInstanceSelectScrollFrameScrollChildInstanceButton1
		if(b1 and not b1.isSkinned) then
			S:HandleButton(b1)
			b1.bgImage:SetInside()
			b1.bgImage:SetTexCoord(.08, .6, .08, .6)
			b1.bgImage:SetDrawLayer("ARTWORK")
			b1.isSkinned = true
		end

		for i = 1, 100 do
			local b = _G["EncounterJournalInstanceSelectScrollFrameinstance"..i]
			if(b and not b.isSkinned) then
				S:HandleButton(b)
				b.bgImage:SetInside()
				b.bgImage:SetTexCoord(0.08,.6,0.08,.6)
				b.bgImage:SetDrawLayer("ARTWORK")
				b.isSkinned = true
			end
		end
	end
	hooksecurefunc("EncounterJournal_ListInstances", SkinDungeons)
	EncounterJournal_ListInstances()

	--Boss selection buttons
	local function SkinBosses()
		local bossIndex = 1;
		local _, _, bossID = EJ_GetEncounterInfoByIndex(bossIndex);
		local bossButton;

		while bossID do
			bossButton = _G["EncounterJournalBossButton"..bossIndex];
			if(bossButton and not bossButton.isSkinned) then
				S:HandleButton(bossButton)
				bossButton.creature:ClearAllPoints()
				bossButton.creature:Point("TOPLEFT", 1, -4)
				bossButton.isSkinned = true
			end

			bossIndex = bossIndex + 1;
			_, _, bossID = EJ_GetEncounterInfoByIndex(bossIndex);
		end
	end
	hooksecurefunc("EncounterJournal_DisplayInstance", SkinBosses)

	--Loot buttons
	local items = EncounterJournal.encounter.info.lootScroll.buttons
	for i = 1, #items do
		local item = items[i]

		item:CreateBackdrop("Default")
		item.backdrop:Point("TOPLEFT", 0, -4)
		item.backdrop:Point("BOTTOMRIGHT", -2, E.PixelMode and 1 or -1)

		item.boss:SetTextColor(1, 1, 1)
		item.boss:ClearAllPoints()
		item.boss:Point("BOTTOMLEFT", 4, 4)
		item.boss:SetParent(item.backdrop)

		item.slot:SetTextColor(1, 1, 1)
		item.slot:SetParent(item.backdrop)

		item.armorType:SetTextColor(1, 1, 1)
		item.armorType:ClearAllPoints()
		item.armorType:Point("BOTTOMRIGHT", item.name, "TOPLEFT", 264, -25)
		item.armorType:SetParent(item.backdrop)

		item.bossTexture:SetAlpha(0)
		item.bosslessTexture:SetAlpha(0)

		item.icon:Size(38)
		if i == 1 then
			item.icon:Point("TOPLEFT", E.PixelMode and 2 or 3, -(E.PixelMode and 5 or 6))
		else
			item.icon:Point("TOPLEFT", E.PixelMode and 1 or 2, -(E.PixelMode and 5 or 6))
		end
		S:HandleIcon(item.icon)
		item.icon:SetDrawLayer("OVERLAY")
		item.icon:SetParent(item.backdrop)

		item.name:SetParent(item.backdrop)

		if(i == 1) then
			item:ClearAllPoints()
			item:Point("TOPLEFT", EncounterInfo.lootScroll.scrollChild, "TOPLEFT", 5, 0)
		end
	end

	--Abilities Info (From Aurora)
	local function SkinAbilitiesInfo()
		local index = 1
		local header = _G["EncounterJournalInfoHeader"..index]
		while header do
			if(not header.isSkinned) then
				header.flashAnim.Play = E.noop

				header.descriptionBG:SetAlpha(0)
				header.descriptionBGBottom:SetAlpha(0)
				for i = 4, 18 do
					select(i, header.button:GetRegions()):SetTexture("")
				end

				header.description:SetTextColor(1, 1, 1)
				header.button.title:SetTextColor(unpack(E.media.rgbvaluecolor))
				header.button.title.SetTextColor = E.noop
				header.button.expandedIcon:SetTextColor(1, 1, 1)
				header.button.expandedIcon.SetTextColor = E.noop

				S:HandleButton(header.button)

				header.button.bg = CreateFrame("Frame", nil, header.button)
				header.button.bg:SetOutside(header.button.abilityIcon)
				header.button.bg:SetFrameLevel(header.button.bg:GetFrameLevel() - 1)
				header.button.abilityIcon:SetTexCoord(.08, .92, .08, .92)

				header.isSkinned = true
			end

			if(header.button.abilityIcon:IsShown()) then
				header.button.bg:Show()
			else
				header.button.bg:Hide()
			end

			index = index + 1
			header = _G["EncounterJournalInfoHeader"..index]
		end
	end
	hooksecurefunc("EncounterJournal_ToggleHeaders", SkinAbilitiesInfo)

	--Search Frame
	EncounterJournalSearchResultsScrollFrame:StripTextures();
	EncounterJournalSearchResultsScrollFrameScrollChild:StripTextures();

	for i = 1, 9 do
		local button = _G["EncounterJournalSearchResultsScrollFrameButton"..i]
		local icon = _G["EncounterJournalSearchResultsScrollFrameButton"..i.."Icon"]

		button:StripTextures();
		button:SetTemplate("Default")
		button:StyleButton()
		button:CreateBackdrop()
		button.backdrop:SetOutside(icon)

		icon:Point("TOPLEFT", 2, -7)
		icon:SetParent(button.backdrop)
	end

	hooksecurefunc("EncounterJournal_SearchUpdate", function()
		local scrollFrame = EncounterJournal.searchResults.scrollFrame;
		local offset = HybridScrollFrame_GetOffset(scrollFrame);
		local results = scrollFrame.buttons;
		local result, index;
		local numResults = EJ_GetNumSearchResults();

		for i = 1, #results do
			result = results[i];
			index = offset + i;
			if(index <= numResults) then
				local _, icon = EncounterJournal_GetSearchDisplay(index);

				result.icon:SetTexCoord(unpack(E.TexCoords))
				result.icon.SetTexCoord = E.noop;
			end
		end
	end)

	for i = 1, 5 do
		local button = _G["EncounterJournalSearchBoxSearchButton"..i]
		local icon = _G["EncounterJournalSearchBoxSearchButton"..i.."Icon"]

		button:CreateBackdrop()
		button:StripTextures();
		button:StyleButton()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:Point("TOPLEFT", 1, -4)
	end

	S:HandleButton(EncounterJournalSearchBoxShowALL)

	EncounterJournalSearchResults:StripTextures();
	EncounterJournalSearchResults:SetTemplate("Transparent")

	S:HandleScrollBar(EncounterJournalSearchResultsScrollFrameScrollBar)
	S:HandleCloseButton(EncounterJournalSearchResultsCloseButton)

	S:HandleScrollBar(EncounterJournalInstanceSelectScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInfoLootScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar, 4)
end

S:AddCallbackForAddon("Blizzard_EncounterJournal", "EncounterJournal", LoadSkin);