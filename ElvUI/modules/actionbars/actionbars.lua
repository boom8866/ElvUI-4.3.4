local E, L, V, P, G = unpack(select(2, ...));
local AB = E:NewModule('ActionBars', 'AceHook-3.0', 'AceEvent-3.0');

local _G = _G;
local pairs, select, unpack = pairs, select, unpack;
local ceil = math.ceil;
local format, gsub, split = string.format, string.gsub, string.split;

local hooksecurefunc = hooksecurefunc;
local CreateFrame = CreateFrame;
local UnitHealth = UnitHealth;
local UnitHealthMax = UnitHealthMax;
local UnitCastingInfo = UnitCastingInfo;
local UnitChannelInfo = UnitChannelInfo;
local UnitAffectingCombat = UnitAffectingCombat;
local UnitExists = UnitExists;
local VehicleExit = VehicleExit;
local PetDismiss = PetDismiss;
local CanExitVehicle = CanExitVehicle;
local MainMenuBarVehicleLeaveButton_OnEnter = MainMenuBarVehicleLeaveButton_OnEnter;
local RegisterStateDriver = RegisterStateDriver;
local UnregisterStateDriver = UnregisterStateDriver;
local GameTooltip_Hide = GameTooltip_Hide;
local InCombatLockdown = InCombatLockdown;
local ClearOverrideBindings = ClearOverrideBindings;
local GetBindingKey = GetBindingKey;
local SetOverrideBindingClick = SetOverrideBindingClick;
local SetClampedTextureRotation = SetClampedTextureRotation;
local SetModifiedClick = SetModifiedClick;
local GetNumFlyouts, GetFlyoutInfo = GetNumFlyouts, GetFlyoutInfo;
local GetFlyoutID = GetFlyoutID;
local GetMouseFocus = GetMouseFocus;
local SetCVar = SetCVar;
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS;

local LAB = LibStub("LibActionButton-1.0");
local LSM = LibStub("LibSharedMedia-3.0");

local Masque = LibStub("Masque", true)
local MasqueGroup = Masque and Masque:Group("ElvUI", "ActionBars")

local UIHider

AB["handledBars"] = {};
AB["handledbuttons"] = {};
AB["barDefaults"] = {
	["bar1"] = {
		['page'] = 1,
		['bindButtons'] = "ACTIONBUTTON",
		['conditions'] = "[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
		['position'] = "BOTTOM,ElvUIParent,BOTTOM,0,4",
	},
	["bar2"] = {
		['page'] = 5,
		['bindButtons'] = "MULTIACTIONBAR2BUTTON",
		['conditions'] = "",
		['position'] = "BOTTOM,ElvUI_Bar1,TOP,0,2",
	},
	["bar3"] = {
		['page'] = 6,
		['bindButtons'] = "MULTIACTIONBAR1BUTTON",
		['conditions'] = "",
		['position'] = "LEFT,ElvUI_Bar1,RIGHT,4,0",
	},
	["bar4"] = {
		['page'] = 4,
		['bindButtons'] = "MULTIACTIONBAR4BUTTON",
		['conditions'] = "",
		['position'] = "RIGHT,ElvUIParent,RIGHT,-4,0",
	},
	["bar5"] = {
		['page'] = 3,
		['bindButtons'] = "MULTIACTIONBAR3BUTTON",
		['conditions'] = "",
		['position'] = "RIGHT,ElvUI_Bar1,LEFT,-4,0",
	},
	["bar6"] = {
		['page'] = 2,
		['bindButtons'] = "ELVUIBAR6BUTTON",
		['conditions'] = "",
		['position'] = "BOTTOM,ElvUI_Bar2,TOP,0,2",
	}
};

AB.customExitButton = {
	func = function()
		if(UnitExists("vehicle")) then
			VehicleExit();
		else
			PetDismiss();
		end
	end,
	texture = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
	tooltip = LEAVE_VEHICLE
};

function AB:PositionAndSizeBar(barName)
	local buttonSpacing = E:Scale(self.db[barName].buttonspacing);
	local backdropSpacing = E:Scale((self.db[barName].backdropSpacing or self.db[barName].buttonspacing));
	local buttonsPerRow = self.db[barName].buttonsPerRow;
	local numButtons = self.db[barName].buttons;
	local size = E:Scale(self.db[barName].buttonsize);
	local point = self.db[barName].point;
	local numColumns = ceil(numButtons / buttonsPerRow);
	local widthMult = self.db[barName].widthMult;
	local heightMult = self.db[barName].heightMult;
	local bar = self["handledBars"][barName];

	bar.db = self.db[barName];
	bar.db.position = nil;

	if(numButtons < buttonsPerRow) then
		buttonsPerRow = numButtons;
	end

	if(numColumns < 1) then
		numColumns = 1;
	end

 	if(self.db[barName].backdrop == true) then
 		bar.backdrop:Show();
 	else
 		bar.backdrop:Hide();
 		--Set size multipliers to 1 when backdrop is disabled
 		widthMult = 1;
 		heightMult = 1;
	end

 	local barWidth = (size * (buttonsPerRow * widthMult)) + ((buttonSpacing * (buttonsPerRow - 1)) * widthMult) + (buttonSpacing * (widthMult-1)) + ((self.db[barName].backdrop == true and (E.Border + backdropSpacing) or E.Spacing)*2);
	local barHeight = (size * (numColumns * heightMult)) + ((buttonSpacing * (numColumns - 1)) * heightMult) + (buttonSpacing * (heightMult-1)) + ((self.db[barName].backdrop == true and (E.Border + backdropSpacing) or E.Spacing)*2);

	bar:Width(barWidth);
	bar:Height(barHeight);

	bar.mouseover = self.db[barName].mouseover;

	local horizontalGrowth, verticalGrowth;
	if(point == "TOPLEFT" or point == "TOPRIGHT") then
		verticalGrowth = "DOWN";
	else
		verticalGrowth = "UP";
	end

	if(point == "BOTTOMLEFT" or point == "TOPLEFT") then
		horizontalGrowth = "RIGHT";
	else
		horizontalGrowth = "LEFT";
	end

	if(self.db[barName].mouseover) then
		bar:SetAlpha(0);
	else
		bar:SetAlpha(self.db[barName].alpha);
	end

	if(self.db[barName].inheritGlobalFade) then
		bar:SetParent(self.fadeParent);
	else
		bar:SetParent(E.UIParent);
	end

	local button, lastButton, lastColumnButton;
	local firstButtonSpacing = (self.db[barName].backdrop == true and (E.Border + backdropSpacing) or E.Spacing);
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		button = bar.buttons[i];
		lastButton = bar.buttons[i-1];
		lastColumnButton = bar.buttons[i-buttonsPerRow];
		button:SetParent(bar);
		button:ClearAllPoints();
		button:Size(size);
		button:SetAttribute("showgrid", 1);
		ActionButton_ShowGrid(button);

		if self.db[barName].mouseover == true then
			bar:SetAlpha(0);
			if not self.hooks[bar] then
				self:HookScript(bar, 'OnEnter', 'Bar_OnEnter');
				self:HookScript(bar, 'OnLeave', 'Bar_OnLeave');
			end

			if not self.hooks[button] then
				self:HookScript(button, 'OnEnter', 'Button_OnEnter');
				self:HookScript(button, 'OnLeave', 'Button_OnLeave');
			end
		else
			bar:SetAlpha(1);
			if self.hooks[bar] then
				self:Unhook(bar, 'OnEnter');
				self:Unhook(bar, 'OnLeave');
			end

			if self.hooks[button] then
				self:Unhook(button, 'OnEnter');
				self:Unhook(button, 'OnLeave');
			end
		end

		if(i == 1) then
			local x, y;
			if(point == "BOTTOMLEFT") then
				x, y = firstButtonSpacing, firstButtonSpacing;
			elseif(point == "TOPRIGHT") then
				x, y = -firstButtonSpacing, -firstButtonSpacing;
			elseif(point == "TOPLEFT") then
				x, y = firstButtonSpacing, -firstButtonSpacing;
			else
				x, y = -firstButtonSpacing, firstButtonSpacing;
			end

			button:Point(point, bar, point, x, y);
		elseif((i - 1) % buttonsPerRow == 0) then
			local x = 0;
			local y = -buttonSpacing;
			local buttonPoint, anchorPoint = "TOP", "BOTTOM";
			if(verticalGrowth == "UP") then
				y = buttonSpacing;
				buttonPoint = "BOTTOM";
				anchorPoint = "TOP";
			end
			button:Point(buttonPoint, lastColumnButton, anchorPoint, x, y);
		else
			local x = buttonSpacing;
			local y = 0;
			local buttonPoint, anchorPoint = "LEFT", "RIGHT";
			if(horizontalGrowth == "LEFT") then
				x = -buttonSpacing;
				buttonPoint = "RIGHT";
				anchorPoint = "LEFT";
			end

			button:Point(buttonPoint, lastButton, anchorPoint, x, y);
		end

		if(i > numButtons) then
			button:Hide();
		else
			button:Show();
		end

		self:StyleButton(button, nil, MasqueGroup and E.private.actionbar.masque.actionbars and true or nil);
	end

	if self.db[barName].enabled or not bar.initialized then
		if(not self.db[barName].mouseover) then
			bar:SetAlpha(self.db[barName].alpha);
		end

		local page = self:GetPage(barName, self["barDefaults"][barName].page, self["barDefaults"][barName].conditions);
		bar:Show()
		RegisterStateDriver(bar, "visibility", self.db[barName].visibility);
		RegisterStateDriver(bar, "page", page);

		if(not bar.initialized) then
			bar.initialized = true;
			AB:PositionAndSizeBar(barName);
			return
		end
		E:EnableMover(bar.mover:GetName())
	else
		E:DisableMover(bar.mover:GetName())
		bar:Hide()
		UnregisterStateDriver(bar, "visibility");
	end

	E:SetMoverSnapOffset('ElvAB_'..bar.id, bar.db.buttonspacing / 2)

	if MasqueGroup and E.private.actionbar.masque.actionbars then MasqueGroup:ReSkin() end
end

function AB:CreateBar(id)
	local bar = CreateFrame("Frame", "ElvUI_Bar" .. id, E.UIParent, "SecureHandlerStateTemplate");
	local point, anchor, attachTo, x, y = split(",", self["barDefaults"]["bar" .. id].position);
	bar:Point(point, anchor, attachTo, x, y);
	bar.id = id;
	bar:CreateBackdrop("Default");
	bar:SetFrameStrata("LOW");
	local offset = E.Spacing;
	bar.backdrop:SetPoint("TOPLEFT", bar, "TOPLEFT", offset, -offset);
	bar.backdrop:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -offset, offset);
	bar.buttons = {};
	bar.bindButtons = self["barDefaults"]["bar" .. id].bindButtons;
	self:HookScript(bar, "OnEnter", "Bar_OnEnter");
	self:HookScript(bar, "OnLeave", "Bar_OnLeave");

	for i = 1, 12 do
		bar.buttons[i] = LAB:CreateButton(i, format(bar:GetName() .. "Button%d", i), bar, nil);
		bar.buttons[i]:SetState(0, "action", i);
		for k = 1, 11 do
			bar.buttons[i]:SetState(k, "action", (k - 1) * 12 + i);
		end

		if(i == 12) then
			bar.buttons[i]:SetState(11, "custom", AB.customExitButton);
		end

		if MasqueGroup and E.private.actionbar.masque.actionbars then
			bar.buttons[i]:AddToMasque(MasqueGroup)
		end

		self:HookScript(bar.buttons[i], "OnEnter", "Button_OnEnter");
		self:HookScript(bar.buttons[i], "OnLeave", "Button_OnLeave");
	end
	self:UpdateButtonConfig(bar, bar.bindButtons);

	bar:SetAttribute("_onstate-page", [[
		if(newstate ~= 0) then
			self:SetAttribute("state", newstate);
			control:ChildUpdate("state", newstate);
		else
			local newCondition = self:GetAttribute("newCondition");
			if(newCondition) then
				newstate = SecureCmdOptionParse(newCondition);
				self:SetAttribute("state", newstate);
				control:ChildUpdate("state", newstate);
			end
		end
	]]);

	self["handledBars"]["bar" .. id] = bar;
	E:CreateMover(bar, "ElvAB_" .. id, L["Bar "] .. id, nil, nil, nil,"ALL,ACTIONBARS");
	self:PositionAndSizeBar("bar" .. id);
	return bar;
end

function AB:PLAYER_REGEN_ENABLED()
	self:UpdateButtonSettings();
	self:UnregisterEvent("PLAYER_REGEN_ENABLED");
end

local function Vehicle_OnEvent(self)
	if(CanExitVehicle() and not E.db.general.minimap.icons.vehicleLeave.hide) then
		self:Show();
		self:GetNormalTexture():SetVertexColor(1, 1, 1);
		self:EnableMouse(true);
	else
		self:Hide();
	end
end

local function Vehicle_OnClick()
	VehicleExit();
end

function AB:UpdateVehicleLeave()
	local button = LeaveVehicleButton
	if not button then return end

	local pos = E.db.general.minimap.icons.vehicleLeave.position or "BOTTOMLEFT"
	local scale = 26 * (E.db.general.minimap.icons.vehicleLeave.scale or 1)
	button:ClearAllPoints()
	button:Point(pos, Minimap, pos, E.db.general.minimap.icons.vehicleLeave.xOffset or 2, E.db.general.minimap.icons.vehicleLeave.yOffset or 2)
	button:SetSize(scale, scale)
end

function AB:CreateVehicleLeave()
	local vehicle = CreateFrame("Button", "LeaveVehicleButton", E.UIParent);
	vehicle:Size(26);
	vehicle:SetFrameStrata("HIGH");
	vehicle:Point("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 2, 2);
	vehicle:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit");
	vehicle:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit");
	vehicle:SetHighlightTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit");
	vehicle:SetTemplate("Default");
	vehicle:RegisterForClicks("AnyUp");

	vehicle:SetScript("OnClick", Vehicle_OnClick);
	vehicle:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter);
	vehicle:SetScript("OnLeave", GameTooltip_Hide);
	vehicle:RegisterEvent("PLAYER_ENTERING_WORLD");
	vehicle:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	vehicle:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR");
	vehicle:RegisterEvent("UNIT_ENTERED_VEHICLE");
	vehicle:RegisterEvent("UNIT_EXITED_VEHICLE");
	vehicle:RegisterEvent("VEHICLE_UPDATE");
	vehicle:SetScript("OnEvent", Vehicle_OnEvent);

	self:UpdateVehicleLeave();

	vehicle:Hide();
end

function AB:ReassignBindings(event)
	if(event == "UPDATE_BINDINGS") then
		self:UpdatePetBindings();
		self:UpdateStanceBindings();
	end

	self:UnregisterEvent("PLAYER_REGEN_DISABLED");

	if(InCombatLockdown()) then return; end	
	for _, bar in pairs(self["handledBars"]) do
		if(not bar) then return; end

		ClearOverrideBindings(bar);
		for i = 1, #bar.buttons do
			local button = (bar.bindButtons .. "%d"):format(i);
			local real_button = (bar:GetName() .. "Button%d"):format(i);
			for k = 1, select("#", GetBindingKey(button)) do
				local key = select(k, GetBindingKey(button));
				if(key and key ~= "") then
					SetOverrideBindingClick(bar, false, key, real_button);
				end
			end
		end
	end
end

function AB:RemoveBindings()
	if(InCombatLockdown()) then return; end
	for _, bar in pairs(self["handledBars"]) do
		if(not bar) then return; end

		ClearOverrideBindings(bar);
	end

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "ReassignBindings");
end

function AB:UpdateBar1Paging()
	if(self.db.bar6.enabled) then
		AB.barDefaults.bar1.conditions = "[bonusbar:5] 11; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;";
	else
		AB.barDefaults.bar1.conditions = "[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;";
	end

	if((E.private.actionbar.enable ~= true or InCombatLockdown()) or not self.isInitialized) then return; end
	local bar2Option = InterfaceOptionsActionBarsPanelBottomRight;
	local bar3Option = InterfaceOptionsActionBarsPanelBottomLeft;
	local bar4Option = InterfaceOptionsActionBarsPanelRightTwo;
	local bar5Option = InterfaceOptionsActionBarsPanelRight;

	if((self.db.bar2.enabled and not bar2Option:GetChecked()) or (not self.db.bar2.enabled and bar2Option:GetChecked())) then
		bar2Option:Click()
	end

	if((self.db.bar3.enabled and not bar3Option:GetChecked()) or (not self.db.bar3.enabled and bar3Option:GetChecked())) then
		bar3Option:Click()
	end

	if(not self.db.bar5.enabled and not self.db.bar4.enabled) then
		if(bar4Option:GetChecked()) then
			bar4Option:Click();
		end

		if(bar5Option:GetChecked()) then
			bar5Option:Click();
		end
	elseif(not self.db.bar5.enabled) then
		if(not bar5Option:GetChecked()) then
			bar5Option:Click();
		end

		if(not bar4Option:GetChecked()) then
			bar4Option:Click();
		end
	elseif((self.db.bar4.enabled and not bar4Option:GetChecked()) or (not self.db.bar4.enabled and bar4Option:GetChecked())) then
		bar4Option:Click();
	elseif((self.db.bar5.enabled and not bar5Option:GetChecked()) or (not self.db.bar5.enabled and bar5Option:GetChecked())) then
		bar5Option:Click();
	end
end

function AB:UpdateButtonSettingsForBar(barName)
	local bar = self["handledBars"][barName];
	self:UpdateButtonConfig(bar, bar.bindButtons);
end

function AB:UpdateButtonSettings()
	if(E.private.actionbar.enable ~= true) then return; end
	if(InCombatLockdown()) then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return; end

	for button, _ in pairs(self["handledbuttons"]) do
		if(button) then
			self:StyleButton(button, button.noBackdrop, button.useMasque)
			self:StyleFlyout(button);
		else
			self["handledbuttons"][button] = nil;
		end
	end

	self:UpdatePetBindings();
	self:UpdateStanceBindings();
	for _, bar in pairs(self["handledBars"]) do
		self:UpdateButtonConfig(bar, bar.bindButtons);
	end

	for i = 1, 6 do
		self:PositionAndSizeBar("bar" .. i);
	end
	self:AdjustMaxStanceButtons()
	self:PositionAndSizeBarPet();
	self:PositionAndSizeBarShapeShift();
end

function AB:GetPage(bar, defaultPage, condition)
	local page = self.db[bar]["paging"][E.myclass];
	if(not condition) then condition = ""; end
	if not page then
		page = ''
	elseif page:match('[\n\r]') then
		page = page:gsub('[\n\r]','')
	end
	if(page) then
		condition = condition .. " " .. page;
	end
	condition = condition .. " " .. defaultPage;

	return condition;
end

function AB:StyleButton(button, noBackdrop, useMasque)
	local name = button:GetName();
	local icon = _G[name.."Icon"];
	local count = _G[name.."Count"];
	local flash = _G[name.."Flash"];
	local hotkey = _G[name.."HotKey"];
	local border  = _G[name.."Border"];
	local macroName = _G[name.."Name"];
	local normal = _G[name.."NormalTexture"];
	local normal2 = button:GetNormalTexture()
	local shine = _G[name.."Shine"];
	local buttonCooldown = _G[name.."Cooldown"];
	local color = self.db.fontColor

	if not button.noBackdrop then
		button.noBackdrop = noBackdrop;
	end

	if not button.useMasque then
		button.useMasque = useMasque;
	end

	if(flash) then flash:SetTexture(nil); end
	if(normal) then normal:SetTexture(nil); normal:Hide(); normal:SetAlpha(0); end
	if(normal2) then normal2:SetTexture(nil); normal2:Hide(); normal2:SetAlpha(0); end

	if border and not button.useMasque then
		border:Kill();
	end

	if(count) then
		count:ClearAllPoints();
		count:Point("BOTTOMRIGHT", 0, 2);
		count:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);
		count:SetTextColor(color.r, color.g, color.b);
	end

	if not button.noBackdrop and not button.backdrop and not button.useMasque then
		button:CreateBackdrop("Default", true);
		button.backdrop:SetAllPoints();
	end

	if(icon) then
		icon:SetTexCoord(unpack(E.TexCoords));
		icon:SetInside();
	end

	if(shine) then
		shine:SetAllPoints();
	end

	if(self.db.hotkeytext) then
		hotkey:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);
		hotkey:SetTextColor(color.r, color.g, color.b);
	end

	if(macroName) then
		if(self.db.macrotext) then
			macroName:Show();
			macroName:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);
			macroName:ClearAllPoints();
			macroName:Point("BOTTOM", 2, 2);
			macroName:SetJustifyH("CENTER");
		else
			macroName:Hide()
		end
	end

	--Extra Action Button
	if(button.style) then
		--button.style:SetParent(button.backdrop);
		button.style:SetDrawLayer('BACKGROUND', -7);
	end

	button.FlyoutUpdateFunc = AB.StyleFlyout
	self:FixKeybindText(button);

	if not button.useMasque then
		button:StyleButton();
	else
		button:StyleButton(true, true, true)
	end

	if(not self.handledbuttons[button]) then
		E:RegisterCooldown(buttonCooldown)

		self.handledbuttons[button] = true;
	end
end

function AB:Bar_OnEnter(bar)
	if(bar:GetParent() == self.fadeParent) then
		if(not self.fadeParent.mouseLock) then
			E:UIFrameFadeIn(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1)
		end
	elseif(bar.mouseover) then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
	end
end

function AB:Bar_OnLeave(bar)
	if(bar:GetParent() == self.fadeParent) then
		if(not self.fadeParent.mouseLock) then
			E:UIFrameFadeOut(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1 - self.db.globalFadeAlpha)
		end
	elseif(bar.mouseover) then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
	end
end

function AB:Button_OnEnter(button)
	local bar = button:GetParent()
	if(bar:GetParent() == self.fadeParent) then
		if(not self.fadeParent.mouseLock) then
			E:UIFrameFadeIn(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1)
		end
	elseif(bar.mouseover) then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
	end
end

function AB:Button_OnLeave(button)
	local bar = button:GetParent()
	if(bar:GetParent() == self.fadeParent) then
		if(not self.fadeParent.mouseLock) then
			E:UIFrameFadeOut(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1 - self.db.globalFadeAlpha)
		end
	elseif(bar.mouseover) then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
	end
end

function AB:BlizzardOptionsPanel_OnEvent()
	InterfaceOptionsActionBarsPanelBottomRightText:SetFormattedText(L["Remove Bar %d Action Page"], 2);
	InterfaceOptionsActionBarsPanelBottomLeftText:SetFormattedText(L["Remove Bar %d Action Page"], 3);
	InterfaceOptionsActionBarsPanelRightTwoText:SetFormattedText(L["Remove Bar %d Action Page"], 4);
	InterfaceOptionsActionBarsPanelRightText:SetFormattedText(L["Remove Bar %d Action Page"], 5);

	InterfaceOptionsActionBarsPanelBottomRight:SetScript("OnEnter", nil);
	InterfaceOptionsActionBarsPanelBottomLeft:SetScript("OnEnter", nil);
	InterfaceOptionsActionBarsPanelRightTwo:SetScript("OnEnter", nil);
	InterfaceOptionsActionBarsPanelRight:SetScript("OnEnter", nil);
end

function AB:FadeParent_OnEvent()
	local cur, max = UnitHealth("player"), UnitHealthMax("player")
	local cast, channel = UnitCastingInfo("player"), UnitChannelInfo("player")
	local target, focus = UnitExists("target"), UnitExists("focus")
	local combat = UnitAffectingCombat("player")
	if(cast or channel) or (cur ~= max) or (target or focus) or combat then
		self.mouseLock = true
		E:UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	else
		self.mouseLock = false
		E:UIFrameFadeOut(self, 0.2, self:GetAlpha(), 1 - AB.db.globalFadeAlpha)
	end
end

function AB:IconIntroTracker_Toggle()
	if self.db.addNewSpells then
		IconIntroTracker:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
		IconIntroTracker:Show()
		IconIntroTracker:SetParent(UIParent)
	else
		IconIntroTracker:UnregisterAllEvents()
		IconIntroTracker:Hide()
		IconIntroTracker:SetParent(UIHider)
	end
end

function AB:DisableBlizzard()
	UIHider = CreateFrame("Frame");
	UIHider:Hide();

	MultiBarBottomLeft:SetParent(UIHider);
	MultiBarBottomRight:SetParent(UIHider);
	MultiBarLeft:SetParent(UIHider);
	MultiBarRight:SetParent(UIHider);

	for i = 1, 12 do
		_G["ActionButton" .. i]:Hide();
		_G["ActionButton" .. i]:UnregisterAllEvents();
		_G["ActionButton" .. i]:SetAttribute("statehidden", true);

		_G["MultiBarBottomLeftButton" .. i]:Hide();
		_G["MultiBarBottomLeftButton" .. i]:UnregisterAllEvents();
		_G["MultiBarBottomLeftButton" .. i]:SetAttribute("statehidden", true);

		_G["MultiBarBottomRightButton" .. i]:Hide();
		_G["MultiBarBottomRightButton" .. i]:UnregisterAllEvents();
		_G["MultiBarBottomRightButton" .. i]:SetAttribute("statehidden", true);

		_G["MultiBarRightButton" .. i]:Hide();
		_G["MultiBarRightButton" .. i]:UnregisterAllEvents();
		_G["MultiBarRightButton" .. i]:SetAttribute("statehidden", true);

		_G["MultiBarLeftButton" .. i]:Hide();
		_G["MultiBarLeftButton" .. i]:UnregisterAllEvents();
		_G["MultiBarLeftButton" .. i]:SetAttribute("statehidden", true);

		if(_G["VehicleMenuBarActionButton" .. i]) then
			_G["VehicleMenuBarActionButton" .. i]:Hide();
			_G["VehicleMenuBarActionButton" .. i]:UnregisterAllEvents();
			_G["VehicleMenuBarActionButton" .. i]:SetAttribute("statehidden", true);
 		end

		_G["BonusActionButton"..i]:Hide();
		_G["BonusActionButton"..i]:UnregisterAllEvents();
		_G["BonusActionButton"..i]:SetAttribute("statehidden", true);
	end

	MultiCastActionBarFrame.ignoreFramePositionManager = true;

	MainMenuBar:UnregisterAllEvents();
	MainMenuBar:Hide();
	MainMenuBar:SetParent(UIHider);

	MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED");
	MainMenuBarArtFrame:UnregisterEvent("ADDON_LOADED");
	MainMenuBarArtFrame:Hide();
	MainMenuBarArtFrame:SetParent(UIHider);

	ShapeshiftBarFrame:UnregisterAllEvents();
	ShapeshiftBarFrame:Hide();
	ShapeshiftBarFrame:SetParent(UIHider);

	BonusActionBarFrame:UnregisterAllEvents();
	BonusActionBarFrame:Hide();
	BonusActionBarFrame:SetParent(UIHider);

	PossessBarFrame:UnregisterAllEvents();
	PossessBarFrame:Hide();
	PossessBarFrame:SetParent(UIHider);

	PetActionBarFrame:UnregisterAllEvents();
	PetActionBarFrame:Hide();
	PetActionBarFrame:SetParent(UIHider);

	VehicleMenuBar:UnregisterAllEvents();
	VehicleMenuBar:Hide();
	VehicleMenuBar:SetParent(UIHider);

	self:IconIntroTracker_Toggle()

	InterfaceOptionsCombatPanelActionButtonUseKeyDown:SetScale(0.0001);
	InterfaceOptionsCombatPanelActionButtonUseKeyDown:SetAlpha(0);

	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:EnableMouse(false);
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0);

	InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetScale(0.0001);
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetAlpha(0);
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetScale(0.0001);
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetAlpha(0);

	InterfaceOptionsActionBarsPanelLockActionBars:SetScale(0.0001);
	InterfaceOptionsActionBarsPanelLockActionBars:SetAlpha(0);

	InterfaceOptionsStatusTextPanelXP:SetAlpha(0);
	InterfaceOptionsStatusTextPanelXP:SetScale(0.0001);

	self:SecureHook("BlizzardOptionsPanel_OnEvent");

	if(PlayerTalentFrame) then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED"); end);
	end
end

function AB:UpdateButtonConfig(bar, buttonName)
	if(InCombatLockdown()) then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return; end
	if(not bar.buttonConfig) then bar.buttonConfig = {hideElements = {}, colors = {}}; end
	bar.buttonConfig.hideElements.macro = self.db.macrotext;
	bar.buttonConfig.hideElements.hotkey = self.db.hotkeytext;
	bar.buttonConfig.showGrid = self.db["bar" .. bar.id].showGrid;
	bar.buttonConfig.clickOnDown = self.db.keyDown;
	SetModifiedClick("PICKUPACTION", self.db.movementModifier);
	bar.buttonConfig.colors.range = E:GetColorTable(self.db.noRangeColor);
	bar.buttonConfig.colors.mana = E:GetColorTable(self.db.noPowerColor);
	bar.buttonConfig.colors.usable = E:GetColorTable(self.db.usableColor);
	bar.buttonConfig.colors.notUsable = E:GetColorTable(self.db.notUsableColor);

	for i, button in pairs(bar.buttons) do
		bar.buttonConfig.keyBoundTarget = format(buttonName .. "%d", i);
		button.keyBoundTarget = bar.buttonConfig.keyBoundTarget;
		button.postKeybind = AB.FixKeybindText;
		if(E.db.actionbar.selfcast) then
			button:SetAttribute("unit2", "player");
		else
			button:SetAttribute("unit2", "target");
		end
		button:SetAttribute("buttonlock", self.db.lockActionBars)
		button:SetAttribute("checkselfcast", true);
		button:SetAttribute("checkfocuscast", true);

		button:UpdateConfig(bar.buttonConfig)
	end
end

function AB:FixKeybindText(button)
	local hotkey = _G[button:GetName() .. "HotKey"];
	local text = hotkey:GetText();

	if(text) then
		text = gsub(text, "SHIFT%-", L["KEY_SHIFT"]);
		text = gsub(text, "ALT%-", L["KEY_ALT"]);
		text = gsub(text, "CTRL%-", L["KEY_CTRL"]);
		text = gsub(text, "BUTTON", L["KEY_MOUSEBUTTON"]);
		text = gsub(text, "MOUSEWHEELUP", L["KEY_MOUSEWHEELUP"]);
		text = gsub(text, "MOUSEWHEELDOWN", L["KEY_MOUSEWHEELDOWN"]);
		text = gsub(text, "NUMPAD", L["KEY_NUMPAD"]);
		text = gsub(text, "PAGEUP", L["KEY_PAGEUP"]);
		text = gsub(text, "PAGEDOWN", L["KEY_PAGEDOWN"]);
		text = gsub(text, "SPACE", L["KEY_SPACE"]);
		text = gsub(text, "INSERT", L["KEY_INSERT"]);
		text = gsub(text, "HOME", L["KEY_HOME"]);
		text = gsub(text, "DELETE", L["KEY_DELETE"]);
		text = gsub(text, "MOUSEWHEELUP", L["KEY_MOUSEWHEELUP"]);
		text = gsub(text, "MOUSEWHEELDOWN", L["KEY_MOUSEWHEELDOWN"]);
		text = gsub(text, "NMULTIPLY", "*");
		text = gsub(text, "NMINUS", "N-");
		text = gsub(text, "NPLUS", "N+");

		hotkey:SetText(text);
	end

	if not button.useMasque then
		hotkey:ClearAllPoints()
		hotkey:Point("TOPRIGHT", 0, -3);
	end
end

local buttons = 0
local function SetupFlyoutButton()
	for i = 1, buttons do
		if(_G["SpellFlyoutButton"..i]) then
			AB:StyleButton(_G["SpellFlyoutButton"..i], nil, MasqueGroup and E.private.actionbar.masque.actionbars and true or nil)
			_G["SpellFlyoutButton"..i]:StyleButton()
			_G["SpellFlyoutButton"..i]:HookScript('OnEnter', function(self)
				local parent = self:GetParent()
				local parentAnchorButton = select(2, parent:GetPoint())
				if(not AB["handledbuttons"][parentAnchorButton]) then return end

				local parentAnchorBar = parentAnchorButton:GetParent()
				AB:Bar_OnEnter(parentAnchorBar)
			end)
			_G["SpellFlyoutButton"..i]:HookScript('OnLeave', function(self)
				local parent = self:GetParent()
				local parentAnchorButton = select(2, parent:GetPoint())
				if(not AB["handledbuttons"][parentAnchorButton]) then return end

				local parentAnchorBar = parentAnchorButton:GetParent()
				AB:Bar_OnLeave(parentAnchorBar)
			end)

			if MasqueGroup and E.private.actionbar.masque.actionbars then
				MasqueGroup:RemoveButton(_G["SpellFlyoutButton"..i])
				MasqueGroup:AddButton(_G["SpellFlyoutButton"..i])
			else
				_G["SpellFlyoutButton"..i]:SetTemplate("Default")
				_G["SpellFlyoutButton"..i]:SetBackdropColor(0, 0, 0, 0)
				_G["SpellFlyoutButton"..i].backdropTexture:SetAlpha(0)
			end
		end
	end

	SpellFlyout:HookScript("OnEnter", function(self)
		local anchorButton = select(2, self:GetPoint())
		if(not AB["handledbuttons"][anchorButton]) then return end

		local parentAnchorBar = anchorButton:GetParent()
		AB:Bar_OnEnter(parentAnchorBar)
	end)

	SpellFlyout:HookScript("OnLeave", function(self)
		local anchorButton = select(2, self:GetPoint())
		if(not AB["handledbuttons"][anchorButton]) then return end

		local parentAnchorBar = anchorButton:GetParent()
		AB:Bar_OnLeave(parentAnchorBar)
	end)
end

function AB:StyleFlyout(button)
	if(not button.FlyoutArrow) then return; end
	if(not LAB.buttonRegistry[button]) then return; end
	if(not button.FlyoutBorder) then return; end

	local combat = InCombatLockdown();

	button.FlyoutBorder:SetAlpha(0);
	button.FlyoutBorderShadow:SetAlpha(0);

	SpellFlyoutHorizontalBackground:SetAlpha(0);
	SpellFlyoutVerticalBackground:SetAlpha(0);
	SpellFlyoutBackgroundEnd:SetAlpha(0);

	for i = 1, GetNumFlyouts() do
		local x = GetFlyoutID(i);
		local _, _, numSlots, isKnown = GetFlyoutInfo(x);
		if(isKnown) then
			if(numSlots > buttons) then
				buttons = numSlots;
			end
		end
	end

	if button:GetParent() and button:GetParent():GetParent() and button:GetParent():GetParent():GetName() and button:GetParent():GetParent():GetName() == "SpellBookSpellIconsFrame" then
 		return
	end

	local arrowDistance
	if((SpellFlyout:IsShown() and SpellFlyout:GetParent() == button) or GetMouseFocus() == button) then
		arrowDistance = 5
	else
		arrowDistance = 2
	end

	local actionbar = button:GetParent()
 	if(actionbar) then
 		local direction = actionbar.db and actionbar.db.flyoutDirection or "AUTOMATIC"
		local point = E:GetScreenQuadrant(actionbar)
		if(point == "UNKNOWN") then return end

		if ((direction == "AUTOMATIC" and strfind(point, "TOP")) or direction == "DOWN") then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("BOTTOM", button, "BOTTOM", 0, -arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 180)
			if(not combat) then button:SetAttribute("flyoutDirection", "DOWN") end
		elseif ((direction == "AUTOMATIC" and point == "RIGHT") or direction == "LEFT") then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("LEFT", button, "LEFT", -arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 270)
			if(not combat) then button:SetAttribute("flyoutDirection", "LEFT") end
		elseif ((direction == "AUTOMATIC" and point == "LEFT") or direction == "RIGHT") then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("RIGHT", button, "RIGHT", arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 90)
			if(not combat) then button:SetAttribute("flyoutDirection", "RIGHT") end
		elseif ((direction == "AUTOMATIC" and (point == "CENTER" or strfind(point, "BOTTOM"))) or direction == "UP") then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("TOP", button, "TOP", 0, arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 0)
			if(not combat) then button:SetAttribute("flyoutDirection", "UP") end
		end
	end
end

local color;
function AB:LAB_ButtonUpdate(button)
	color = AB.db.fontColor;
	button.count:SetTextColor(color.r, color.g, color.b);
	button.hotkey:SetTextColor(color.r, color.g, color.b);
end
LAB.RegisterCallback(AB, "OnButtonUpdate", AB.LAB_ButtonUpdate);

function AB:Initialize()
	self.db = E.db.actionbar;
	if(E.private.actionbar.enable ~= true) then return; end
	E.ActionBars = AB;

	self.fadeParent = CreateFrame("Frame", "Elv_ABFade", UIParent);
	self.fadeParent:SetAlpha(1 - self.db.globalFadeAlpha);
	self.fadeParent:RegisterEvent("PLAYER_REGEN_DISABLED");
	self.fadeParent:RegisterEvent("PLAYER_REGEN_ENABLED");
	self.fadeParent:RegisterEvent("PLAYER_TARGET_CHANGED");
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_START");
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_STOP");
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
	self.fadeParent:RegisterEvent("UNIT_HEALTH");
	self.fadeParent:RegisterEvent("PLAYER_FOCUS_CHANGED");
	self.fadeParent:SetScript("OnEvent", self.FadeParent_OnEvent);

	self:DisableBlizzard();

	self:SetupExtraButton();
	self:SetupMicroBar();
	self:UpdateBar1Paging()

	for i = 1, 6 do
		self:CreateBar(i);
	end

	self:CreateBarPet();
	self:CreateBarShapeShift();
	self:CreateVehicleLeave();

	self:UpdateButtonSettings()

	if(E.myclass == "SHAMAN") then
		self:CreateTotemBar();
	end

	self:LoadKeyBinder();
	self:RegisterEvent("UPDATE_BINDINGS", "ReassignBindings");
	self:ReassignBindings();

	SetCVar("lockActionBars", (self.db.lockActionBars == true and 1 or 0))
	LOCK_ACTIONBAR = (self.db.lockActionBars == true and "1" or "0")

	SpellFlyout:HookScript("OnShow", SetupFlyoutButton);
end

local function InitializeCallback()
	AB:Initialize()
end

E:RegisterModule(AB:GetName(), InitializeCallback)