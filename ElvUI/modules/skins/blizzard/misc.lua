local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local UnitIsUnit = UnitIsUnit
local IsAddOnLoaded = IsAddOnLoaded

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.misc ~= true then return end

	-- ESC/Menu Buttons
	GameMenuFrame:StripTextures()
	GameMenuFrame:CreateBackdrop("Transparent")

	local BlizzardMenuButtons = {
		"Options",
		"UIOptions",
		"Keybindings",
		"Macros",
		"AddOns",
		"Logout",
		"Quit",
		"Continue",
		"Help"
	}

	for i = 1, #BlizzardMenuButtons do
		local ElvuiMenuButtons = _G["GameMenuButton"..BlizzardMenuButtons[i]]
		if ElvuiMenuButtons then
			S:HandleButton(ElvuiMenuButtons)
		end
	end

	if IsAddOnLoaded("OptionHouse") then
		S:HandleButton(GameMenuButtonOptionHouse)
	end

	-- Static Popups
	for i = 1, 4 do
		local staticPopup = _G["StaticPopup"..i]
		local itemFrame = _G["StaticPopup"..i.."ItemFrame"]
		local itemFrameBox = _G["StaticPopup"..i.."EditBox"]
		local itemFrameTexture = _G["StaticPopup"..i.."ItemFrameIconTexture"]
		local itemFrameNormal = _G["StaticPopup"..i.."ItemFrameNormalTexture"]
		local itemFrameName = _G["StaticPopup"..i.."ItemFrameNameFrame"]
		local closeButton = _G["StaticPopup"..i.."CloseButton"]

		staticPopup:SetTemplate("Transparent")

		S:HandleEditBox(itemFrameBox)
		itemFrameBox.backdrop:Point("TOPLEFT", -2, -4)
		itemFrameBox.backdrop:Point("BOTTOMRIGHT", 2, 4)

		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"])

		closeButton:StripTextures()
		S:HandleCloseButton(closeButton)

		itemFrame:GetNormalTexture():Kill()
		itemFrame:SetTemplate()
		itemFrame:StyleButton()

		itemFrameTexture:SetTexCoord(unpack(E.TexCoords))
		itemFrameTexture:SetInside()

		itemFrameNormal:SetAlpha(0)

		itemFrameName:Kill()

		for j = 1, 3 do
			S:HandleButton(_G["StaticPopup"..i.."Button"..j])
		end
	end

	-- Graveyard Button
	do
		GhostFrame:StripTextures(true)
		GhostFrame:SetTemplate("Transparent")
		GhostFrame:ClearAllPoints()
		GhostFrame:Point("TOP", E.UIParent, "TOP", 0, -150)

		GhostFrame:HookScript("OnEnter", S.SetModifiedBackdrop)
		GhostFrame:HookScript("OnLeave", S.SetOriginalBackdrop)

		GhostFrameContentsFrame:CreateBackdrop()
		GhostFrameContentsFrame.backdrop:SetOutside(GhostFrameContentsFrameIcon)
		GhostFrameContentsFrame.SetPoint = E.noop

		GhostFrameContentsFrameIcon:SetTexCoord(unpack(E.TexCoords))
		GhostFrameContentsFrameIcon:SetParent(GhostFrameContentsFrame.backdrop)
	end

	-- Other Frames
	TicketStatusFrameButton:SetTemplate("Transparent")

	AutoCompleteBox:SetTemplate("Transparent")

	ConsolidatedBuffsTooltip:SetTemplate("Transparent")

	StreamingIcon:ClearAllPoints()
	StreamingIcon:Point("TOP", UIParent, "TOP", 0, -100)

	if GetLocale() == "koKR" then
		S:HandleButton(GameMenuButtonRatings)

		RatingMenuFrame:SetTemplate("Transparent")
		RatingMenuFrameHeader:Kill()
		S:HandleButton(RatingMenuButtonOkay)
	end

	-- BNToast Frame
	BNToastFrame:SetTemplate("Transparent")

	BNToastFrameCloseButton:Size(32)
	BNToastFrameCloseButton:Point("TOPRIGHT", "BNToastFrame", 4, 4)

	S:HandleCloseButton(BNToastFrameCloseButton)

	-- ReadyCheck Frame
	ReadyCheckFrame:SetTemplate("Transparent")
	ReadyCheckFrame:Size(290, 85)

	S:HandleButton(ReadyCheckFrameYesButton)
	ReadyCheckFrameYesButton:ClearAllPoints()
	ReadyCheckFrameYesButton:Point("LEFT", ReadyCheckFrame, 15, -20)
	ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)

	S:HandleButton(ReadyCheckFrameNoButton)
	ReadyCheckFrameNoButton:ClearAllPoints()
	ReadyCheckFrameNoButton:Point("RIGHT", ReadyCheckFrame, -15, -20)
	ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)

	ReadyCheckFrameText:ClearAllPoints()
	ReadyCheckFrameText:Point("TOP", 0, -5)
	ReadyCheckFrameText:SetParent(ReadyCheckFrame)
	ReadyCheckFrameText:SetTextColor(1, 1, 1)

	ReadyCheckListenerFrame:SetAlpha(0)

	ReadyCheckFrame:HookScript("OnShow", function(self) -- bug fix, don't show it if initiator
		if UnitIsUnit("player", self.initiator) then
			self:Hide()
		end
	end)

	-- Coin PickUp Frame
	CoinPickupFrame:StripTextures()
	CoinPickupFrame:SetTemplate("Transparent")

	S:HandleButton(CoinPickupOkayButton)
	S:HandleButton(CoinPickupCancelButton)

	-- Stack Split Frame
	StackSplitFrame:SetTemplate("Transparent")
	StackSplitFrame:GetRegions():Hide()

	StackSplitFrame.bg1 = CreateFrame("Frame", nil, StackSplitFrame)
	StackSplitFrame.bg1:SetTemplate("Transparent")
	StackSplitFrame.bg1:Point("TOPLEFT", 10, -15)
	StackSplitFrame.bg1:Point("BOTTOMRIGHT", -10, 55)
	StackSplitFrame.bg1:SetFrameLevel(StackSplitFrame.bg1:GetFrameLevel() - 1)

	S:HandleButton(StackSplitOkayButton)
	S:HandleButton(StackSplitCancelButton)

	-- Opacity Frame
	OpacityFrame:StripTextures()
	OpacityFrame:SetTemplate("Transparent")

	S:HandleSliderFrame(OpacityFrameSlider)

	-- Declension frame
	if GetLocale() == "ruRU" then
		DeclensionFrame:SetTemplate("Transparent")

		S:HandleNextPrevButton(DeclensionFrameSetPrev)
		S:HandleNextPrevButton(DeclensionFrameSetNext)
		S:HandleButton(DeclensionFrameOkayButton)
		S:HandleButton(DeclensionFrameCancelButton)

		for i = 1, RUSSIAN_DECLENSION_PATTERNS do
			local editBox = _G["DeclensionFrameDeclension"..i.."Edit"]
			if editBox then
				editBox:StripTextures()
				S:HandleEditBox(editBox)
			end
		end
	end

	-- Role Check Popup
	RolePollPopup:SetTemplate("Transparent")

	S:HandleCloseButton(RolePollPopupCloseButton)

	S:HandleButton(RolePollPopupAcceptButton)

	local roleCheckIcons = {
		"RolePollPopupRoleButtonTank",
		"RolePollPopupRoleButtonHealer",
		"RolePollPopupRoleButtonDPS"
	}

	for i = 1, #roleCheckIcons do
		_G[roleCheckIcons[i]]:StripTextures()
		_G[roleCheckIcons[i]]:CreateBackdrop()
		_G[roleCheckIcons[i]].backdrop:Point("TOPLEFT", 7, -7)
		_G[roleCheckIcons[i]].backdrop:Point("BOTTOMRIGHT", -7, 7)

		_G[roleCheckIcons[i]].icon = _G[roleCheckIcons[i]]:CreateTexture(nil, "ARTWORK")
		_G[roleCheckIcons[i]].icon:SetTexCoord(unpack(E.TexCoords))
		_G[roleCheckIcons[i]].icon:SetInside(_G[roleCheckIcons[i]].backdrop)
	end

	RolePollPopupRoleButtonTank:Point("TOPLEFT", 32, -35)

	RolePollPopupRoleButtonTank.icon:SetTexture("Interface\\Icons\\Ability_Defend")
	RolePollPopupRoleButtonHealer.icon:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
	RolePollPopupRoleButtonDPS.icon:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")

	hooksecurefunc("RolePollPopup_Show", function()
		local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles("player")
		if canBeTank then
			RolePollPopupRoleButtonTank.icon:SetDesaturated(false)
		else
			RolePollPopupRoleButtonTank.icon:SetDesaturated(true)
		end
		if canBeHealer then
			RolePollPopupRoleButtonHealer.icon:SetDesaturated(false)
		else
			RolePollPopupRoleButtonHealer.icon:SetDesaturated(true)
		end
		if canBeDamager then
			RolePollPopupRoleButtonDPS.icon:SetDesaturated(false)
		else
			RolePollPopupRoleButtonDPS.icon:SetDesaturated(true)
		end
	end)

	-- Report Player
	ReportCheatingDialog:StripTextures()
	ReportCheatingDialog:SetTemplate("Transparent")

	ReportCheatingDialogCommentFrame:StripTextures()

	S:HandleEditBox(ReportCheatingDialogCommentFrameEditBox)
	S:HandleButton(ReportCheatingDialogReportButton)
	S:HandleButton(ReportCheatingDialogCancelButton)

	ReportPlayerNameDialog:StripTextures()
	ReportPlayerNameDialog:SetTemplate("Transparent")

	ReportPlayerNameDialogCommentFrame:StripTextures()

	S:HandleEditBox(ReportPlayerNameDialogCommentFrameEditBox)
	S:HandleButton(ReportPlayerNameDialogCancelButton)
	S:HandleButton(ReportPlayerNameDialogReportButton)

	-- Cinematic Popup
	CinematicFrameCloseDialog:StripTextures()
	CinematicFrameCloseDialog:SetTemplate("Transparent")

	CinematicFrameCloseDialog:SetScale(UIParent:GetScale())

	S:HandleButton(CinematicFrameCloseDialogConfirmButton)
	S:HandleButton(CinematicFrameCloseDialogResumeButton)

	-- Level Up Popup
	LevelUpDisplaySpellFrame:CreateBackdrop()
	LevelUpDisplaySpellFrame.backdrop:SetOutside(LevelUpDisplaySpellFrameIcon)

	LevelUpDisplaySpellFrameIcon:SetTexCoord(unpack(E.TexCoords))
	LevelUpDisplaySpellFrameSubIcon:SetTexCoord(unpack(E.TexCoords))

	LevelUpDisplaySide:HookScript("OnShow", function(self)
		for i = 1, #self.unlockList do
			local button = _G["LevelUpDisplaySideUnlockFrame"..i]

			if not button.isSkinned then
				button.icon:SetTexCoord(unpack(E.TexCoords))

				button.isSkinned = true
			end
		end
	end)

	-- Channel Pullout Frame
	ChannelPullout:SetTemplate("Transparent")

	ChannelPulloutBackground:Kill()

	S:HandleTab(ChannelPulloutTab)
	ChannelPulloutTab:Size(107, 26)
	ChannelPulloutTabText:Point("LEFT", ChannelPulloutTabLeft, "RIGHT", 0, 4)

	S:HandleCloseButton(ChannelPulloutCloseButton)
	ChannelPulloutCloseButton.backdrop:SetAllPoints()
	ChannelPulloutCloseButton:Size(15)

	-- Dropdown Menu
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
		for i = 1, UIDROPDOWNMENU_MAXLEVELS do
			_G["DropDownList"..i.."Backdrop"]:SetTemplate("Transparent", true)
			_G["DropDownList"..i.."MenuBackdrop"]:SetTemplate("Transparent", true)
			for j = 1, UIDROPDOWNMENU_MAXBUTTONS do
				_G["DropDownList"..i.."Button"..j.."Highlight"]:SetTexture(1, 1, 1, 0.3)
			end
		end
	end)

	-- Compact Raid Frame Manager
	CompactRaidFrameManager:StripTextures()
	CompactRaidFrameManager:SetTemplate("Transparent")

	CompactRaidFrameManagerDisplayFrame:StripTextures()
	CompactRaidFrameManagerDisplayFrameFilterOptions:StripTextures()

	S:HandleButton(CompactRaidFrameManagerDisplayFrameHiddenModeToggle)
	S:HandleButton(CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll)
	S:HandleButton(CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck)
	S:HandleButton(CompactRaidFrameManagerDisplayFrameLockedModeToggle)
	S:HandleButton(CompactRaidFrameManagerDisplayFrameConvertToRaid)
	S:HandleButton(CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleDamager)
	S:HandleButton(CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleHealer)
	S:HandleButton(CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleTank)
	S:HandleButton(CompactRaidFrameManagerToggleButton)

	S:HandleCheckBox(CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton)

	S:HandleDropDownBox(CompactRaidFrameManagerDisplayFrameProfileSelector)

	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleTankSelectedHighlight:SetTexture(1, 1, 0, 0.3)
	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleHealerSelectedHighlight:SetTexture(1, 1, 0, 0.3)
	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleDamagerSelectedHighlight:SetTexture(1, 1, 0, 0.3)

	for i = 1, 8 do
		S:HandleButton(_G["CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup"..i])
		_G["CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup"..i.."SelectedHighlight"]:SetTexture(1, 1, 0, 0.3)
	end

	CompactRaidFrameManagerToggleButton:Size(15, 40)
	CompactRaidFrameManagerToggleButton:Point("RIGHT", -3, -15)

	CompactRaidFrameManagerToggleButton.icon = CompactRaidFrameManagerToggleButton:CreateTexture(nil, "ARTWORK")
	CompactRaidFrameManagerToggleButton.icon:Size(14)
	CompactRaidFrameManagerToggleButton.icon:Point("CENTER")
	CompactRaidFrameManagerToggleButton.icon:SetTexture([[Interface\Buttons\SquareButtonTextures]])
	SquareButton_SetIcon(CompactRaidFrameManagerToggleButton, "RIGHT")

	hooksecurefunc("CompactRaidFrameManager_Expand", function()
		SquareButton_SetIcon(CompactRaidFrameManagerToggleButton, "LEFT")
	end)

	hooksecurefunc("CompactRaidFrameManager_Collapse", function()
		SquareButton_SetIcon(CompactRaidFrameManagerToggleButton, "RIGHT")
	end)

	-- Chat Menu
	local ChatMenus = {
		"ChatMenu",
		"EmoteMenu",
		"LanguageMenu",
		"VoiceMacroMenu"
	}

	for i = 1, #ChatMenus do
		if _G[ChatMenus[i]] == _G["ChatMenu"] then
			_G[ChatMenus[i]]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent", true)
				self:SetBackdropColor(unpack(E["media"].backdropfadecolor))
				self:ClearAllPoints()
				self:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30)
			end)
		else
			_G[ChatMenus[i]]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent", true)
				self:SetBackdropColor(unpack(E["media"].backdropfadecolor))
			end)
		end
	end

	for i = 1, 32 do
		_G["ChatMenuButton"..i]:StyleButton()
		_G["EmoteMenuButton"..i]:StyleButton()
		_G["LanguageMenuButton"..i]:StyleButton()
		_G["VoiceMacroMenuButton"..i]:StyleButton()
	end
end

S:AddCallback("SkinMisc", LoadSkin)