local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local _G = _G;
local unpack, select = unpack, select;

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetItemInfo = GetItemInfo;
local GetItemQualityColor = GetItemQualityColor;
local GetTradePlayerItemLink = GetTradePlayerItemLink;
local GetTradeTargetItemLink = GetTradeTargetItemLink;

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trade ~= true then return end

	local TradeFrame = _G["TradeFrame"]
	TradeFrame:StripTextures(true)
	TradeFrame:Height(493)

	TradeFrame:CreateBackdrop("Transparent")
	TradeFrame.backdrop:Point("TOPLEFT", 10, -4)
	TradeFrame.backdrop:Point("BOTTOMRIGHT", -16, 35)

	S:HandleButton(TradeFrameTradeButton, true)
	S:HandleButton(TradeFrameCancelButton, true)

	S:HandleCloseButton(TradeFrameCloseButton, TradeFrame.backdrop)

	S:HandleEditBox(TradePlayerInputMoneyFrameGold)
	S:HandleEditBox(TradePlayerInputMoneyFrameSilver)
	S:HandleEditBox(TradePlayerInputMoneyFrameCopper)

	TradeFrameTradeButton:ClearAllPoints()
	TradeFrameTradeButton:Point("BOTTOMRIGHT", TradeFrame, "BOTTOMRIGHT", -105, 40)

	for i = 1, MAX_TRADE_ITEMS do
		local player = _G["TradePlayerItem"..i]
		local recipient = _G["TradeRecipientItem"..i]
		local playerButton = _G["TradePlayerItem"..i.."ItemButton"]
		local playerButtonIcon = _G["TradePlayerItem"..i.."ItemButtonIconTexture"]
		local recipientButton = _G["TradeRecipientItem"..i.."ItemButton"]
		local recipientButtonIcon = _G["TradeRecipientItem"..i.."ItemButtonIconTexture"]

		player:StripTextures()
		recipient:StripTextures()

		playerButton:StripTextures()
		playerButton:StyleButton()
		playerButton:SetTemplate("Default", true)

		playerButtonIcon:SetInside()
		playerButtonIcon:SetTexCoord(unpack(E.TexCoords))

		recipientButton:StripTextures()
		recipientButton:StyleButton()
		recipientButton:SetTemplate("Default", true)

		recipientButtonIcon:SetInside()
		recipientButtonIcon:SetTexCoord(unpack(E.TexCoords))

		playerButton.bg = CreateFrame("Frame", nil, playerButton)
		playerButton.bg:SetTemplate("Default")
		playerButton.bg:Point("TOPLEFT", playerButton, "TOPRIGHT", 4, 0)
		playerButton.bg:Point("BOTTOMRIGHT", _G["TradePlayerItem"..i.."NameFrame"], "BOTTOMRIGHT", 0, 14)
		playerButton.bg:SetFrameLevel(playerButton:GetFrameLevel() - 3)

		recipientButton.bg = CreateFrame("Frame", nil, recipientButton)
		recipientButton.bg:SetTemplate("Default")
		recipientButton.bg:Point("TOPLEFT", recipientButton, "TOPRIGHT", 4, 0)
		recipientButton.bg:Point("BOTTOMRIGHT", _G["TradeRecipientItem"..i.."NameFrame"], "BOTTOMRIGHT", 0, 14)
		recipientButton.bg:SetFrameLevel(recipientButton:GetFrameLevel() - 3)
	end

	TradeHighlightPlayerTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerMiddle:SetTexture(0, 1, 0, 0.2)

	TradeHighlightPlayer:SetFrameStrata("HIGH")
	TradeHighlightPlayer:Point("TOPLEFT", TradeFrame, 23, -100)

	TradeHighlightPlayerEnchantTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerEnchantBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerEnchantMiddle:SetTexture(0, 1, 0, 0.2)

	TradeHighlightPlayerEnchant:SetFrameStrata("HIGH")

	TradeHighlightRecipientTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientMiddle:SetTexture(0, 1, 0, 0.2)

	TradeHighlightRecipient:SetFrameStrata("HIGH")
	TradeHighlightRecipient:Point("TOPLEFT", TradeFrame, 192, -100)

	TradeHighlightRecipientEnchantTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientEnchantBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientEnchantMiddle:SetTexture(0, 1, 0, 0.2)

	TradeHighlightRecipientEnchant:SetFrameStrata("HIGH")

	hooksecurefunc("TradeFrame_UpdatePlayerItem", function(id)
		local tradeItemButton = _G["TradePlayerItem"..id.."ItemButton"]
		local tradeItemName = _G["TradePlayerItem"..id.."Name"]
		local link = GetTradePlayerItemLink(id)

		if link then
			local quality = select(3, GetItemInfo(link))

			tradeItemName:SetTextColor(GetItemQualityColor(quality))
			if quality and quality > 1 then
				tradeItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				tradeItemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor))
 			end
		else
			tradeItemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor))
 		end
	end)

	hooksecurefunc("TradeFrame_UpdateTargetItem", function(id)
		local tradeItemButton = _G["TradeRecipientItem"..id.."ItemButton"]
		local tradeItemName = _G["TradeRecipientItem"..id.."Name"]
		local link = GetTradeTargetItemLink(id)

		if link then
			local quality = select(3, GetItemInfo(link))

			tradeItemName:SetTextColor(GetItemQualityColor(quality))
			if quality and quality > 1 then
				tradeItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				tradeItemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor))
 			end
		else
			tradeItemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor))
 		end
	end)
end

S:AddCallback("Trade", LoadSkin);