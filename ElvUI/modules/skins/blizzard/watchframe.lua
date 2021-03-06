local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local unpack = unpack;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.watchframe ~= true) then return end

	WatchFrameCollapseExpandButton:StripTextures();
	S:HandleCloseButton(WatchFrameCollapseExpandButton);
	WatchFrameCollapseExpandButton.backdrop:SetAllPoints();
	WatchFrameCollapseExpandButton:Size(16);
	WatchFrameCollapseExpandButton.text:SetText("-");
	WatchFrameCollapseExpandButton.text:Point("CENTER")
	WatchFrameCollapseExpandButton:SetFrameStrata("MEDIUM");
	WatchFrameCollapseExpandButton:Point("TOPRIGHT", -20, 0)
	WatchFrameHeader:Point("TOPLEFT", 0, -3)

	WatchFrameLines:StripTextures();

	hooksecurefunc("WatchFrame_Expand", function()
		WatchFrameCollapseExpandButton.text:SetText("-");

		WatchFrame:Width(WATCHFRAME_EXPANDEDWIDTH)
	end)

	hooksecurefunc("WatchFrame_Collapse", function()
		WatchFrameCollapseExpandButton.text:SetText("+");

		WatchFrame:Width(WATCHFRAME_EXPANDEDWIDTH)
	end)

	hooksecurefunc("WatchFrame_Update", function()
		local questIndex;
		local numQuestWatches = GetNumQuestWatches();

		for i = 1, numQuestWatches do
			questIndex = GetQuestIndexForWatch(i);
			if(questIndex) then
				local title, level = GetQuestLogTitle(questIndex);
				local color = GetQuestDifficultyColor(level);

				for j = 1, #WATCHFRAME_QUESTLINES do
					if(WATCHFRAME_QUESTLINES[j].text:GetText() == title) then
						WATCHFRAME_QUESTLINES[j].text:SetTextColor(color.r, color.g, color.b);
						WATCHFRAME_QUESTLINES[j].color = color;
					end
				end
			end
		end

		for i = 1, WATCHFRAME_NUM_ITEMS do
			local button = _G["WatchFrameItem"..i];
			local icon = _G["WatchFrameItem"..i.."IconTexture"];
			local normal = _G["WatchFrameItem"..i.."NormalTexture"];
			local cooldown = _G["WatchFrameItem"..i.."Cooldown"];
			if(not button.skinned) then
				button:CreateBackdrop();
				button.backdrop:SetAllPoints();
				button:StyleButton();
				button:Size(25)

				normal:SetAlpha(0);
				icon:SetInside();
				icon:SetTexCoord(unpack(E.TexCoords));

				E:RegisterCooldown(cooldown);
				button.skinned = true;
			end
		end

		for i = 1, 2 do
			local popUp = _G["WatchFrameAutoQuestPopUp"..i]
			if(popUp and popUp.isSkinned ~= true) then

				_G["WatchFrameAutoQuestPopUp"..i.."ScrollChildBg"]:Kill();
				_G["WatchFrameAutoQuestPopUp"..i.."ScrollChildQuestIconBg"]:Kill();
				_G["WatchFrameAutoQuestPopUp"..i.."ScrollChildFlash"]:Kill();
				_G["WatchFrameAutoQuestPopUp"..i.."ScrollChildShine"]:Kill();
				_G["WatchFrameAutoQuestPopUp"..i.."ScrollChildIconShine"]:Kill();
				_G["WatchFrameAutoQuestPopUp"..i.."ScrollChildFlashIconFlash"]:Kill();
				_G["WatchFrameAutoQuestPopUp"..i.."ScrollChildBorderBotLeft"]:Kill();
				_G["WatchFrameAutoQuestPopUp"..i.."ScrollChildBorderBotRight"]:Kill();
				_G["WatchFrameAutoQuestPopUp"..i.."ScrollChildBorderBottom"]:Kill();
				_G["WatchFrameAutoQuestPopUp"..i.."ScrollChildBorderLeft"]:Kill();
				_G["WatchFrameAutoQuestPopUp"..i.."ScrollChildBorderRight"]:Kill();
				_G["WatchFrameAutoQuestPopUp"..i.."ScrollChildBorderTop"]:Kill();
				_G["WatchFrameAutoQuestPopUp"..i.."ScrollChildBorderTopLeft"]:Kill();
				_G["WatchFrameAutoQuestPopUp"..i.."ScrollChildBorderTopRight"]:Kill();

				popUp:CreateBackdrop("Transparent", nil, true);
				popUp.backdrop:Point("TOPLEFT", 0, -2)
				popUp.backdrop:Point("BOTTOMRIGHT", 0, 2)
				popUp.backdrop:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor))

				popUp.isSkinned = true
			end
		end
	end)

	hooksecurefunc("WatchFrameLinkButtonTemplate_Highlight", function(self, onEnter)
		for i = self.startLine, self.lastLine do
			if(not self.lines[i]) then return; end
			if(self.lines[i].color) then
				if(onEnter) then
					self.lines[i].text:SetTextColor(1, 0.80, 0.10);
				else
					self.lines[i].text:SetTextColor(self.lines[i].color.r, self.lines[i].color.g, self.lines[i].color.b);
				end
			end
		end
	end)
end

S:AddCallback("WatchFrame", LoadSkin)