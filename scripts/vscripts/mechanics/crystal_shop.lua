if CrystalShop == nil then
	CrystalShop= class({})
end
local public = CrystalShop

function public:init(bReload)
	if not bReload then
		self.playerCrystalShop = {}

		self.wItems = WeightPool()
		for sItemName, tValues in pairs(KeyValues.CrystalShopKv) do
			self.wItems:Set(sItemName, tValues.Weight)
		end
	end

	GameEvent("game_rules_state_change", Dynamic_Wrap(public, "OnGameRulesStateChange"), public)
	CustomUIEvent("PurchaseCrystalShopItem", Dynamic_Wrap(public, "OnPurchaseCrystalShopItem"), public)

	self:UpdateNetTables()
end

function public:UpdateNetTables()
	CustomNetTables:SetTableValue("common", "crystal_shop", {
		stock_time = self.fStockTime,
	})
	CustomNetTables:SetTableValue("common", "player_crystal_shop", self.playerCrystalShop)
end

function public:GetCrystalCost(sItemName)
	if KeyValues.CrystalShopKv[sItemName] == nil or KeyValues.CrystalShopKv[sItemName].CrystalCost == nil then
		return 0
	end
	return KeyValues.CrystalShopKv[sItemName].CrystalCost
end

function public:HasStock(iPlayerID, sItemName)
	return self.playerCrystalShop[iPlayerID][sItemName] ~= nil and self.playerCrystalShop[iPlayerID][sItemName].iStock ~= nil and self.playerCrystalShop[iPlayerID][sItemName].iStock > 0
end

function public:Stock()
	local iCountingMode = GameMode:GetCountingMode()

	if iCountingMode == COUNTING_MODE_TEAM then
		local iPlayerCount = DotaTD:GetValidPlayerCount()
		local boundStockAmount = CRYSTAL_SHOP_STOCK_AMOUNT[iPlayerCount]

		local tItemNames = {}
		for i = 1, RandomInt(boundStockAmount.min, boundStockAmount.max), 1 do
			local sItemName = self.wItems:Random()
			table.insert(tItemNames, sItemName)
		end

		DotaTD:EachPlayer(function(n, iPlayerID)
			for k, v in pairs(self.playerCrystalShop[iPlayerID]) do
				v.iStock = 0
			end

			for i, sItemName in pairs(tItemNames) do
				if self.playerCrystalShop[iPlayerID][sItemName] ~= nil and self.playerCrystalShop[iPlayerID][sItemName].iStock ~= nil then
					self.playerCrystalShop[iPlayerID][sItemName].iStock = self.playerCrystalShop[iPlayerID][sItemName].iStock + 1
				end
			end
		end)
	elseif iCountingMode == COUNTING_MODE_PERSONAL then
		local boundStockAmount = CRYSTAL_SHOP_STOCK_AMOUNT[1]

		DotaTD:EachPlayer(function(n, iPlayerID)
			for k, v in pairs(self.playerCrystalShop[iPlayerID]) do
				v.iStock = 0
			end

			for i = 1, RandomInt(boundStockAmount.min, boundStockAmount.max), 1 do
				local sItemName = self.wItems:Random()
				if self.playerCrystalShop[iPlayerID][sItemName] ~= nil and self.playerCrystalShop[iPlayerID][sItemName].iStock ~= nil then
					self.playerCrystalShop[iPlayerID][sItemName].iStock = self.playerCrystalShop[iPlayerID][sItemName].iStock + 1
				end
			end
		end)
	end
end

--[[
	各个UI事件
]]--
-- 购买水晶商店物品
function public:OnPurchaseCrystalShopItem(eventSourceIndex, events)
	local iPlayerID = events.PlayerID
	local hUnit = EntIndexToHScript(events.unit or -1)
	local sItemName = events.itemName
	if hUnit ~= nil and sItemName ~= nil and hUnit:GetMainControllingPlayer() == iPlayerID then
		local iCrystalCost = self:GetCrystalCost(sItemName)
		local iGoldCost = GetItemCost(sItemName)
		if GameRules:IsGamePaused() then
			ErrorMessage(iPlayerID, "dota_hud_error_game_is_paused")
			return
		end
		if not hUnit:IsAlive() then
			ErrorMessage(iPlayerID, "dota_hud_error_unit_dead")
			return
		end
		if not self:HasStock(iPlayerID, sItemName) then
			ErrorMessage(iPlayerID, "dota_hud_error_item_out_of_stock")
			return 
		end
		if PlayerData:GetCrystal(iPlayerID) < iCrystalCost then
			ErrorMessage(iPlayerID, "dota_hud_error_not_enough_crystal", "General.CastFail_NoMana")
			return
		end
		if PlayerResource:GetGold(iPlayerID) < iGoldCost then
			ErrorMessage(iPlayerID, "dota_hud_error_not_enough_gold", "General.NoGold")
			return
		end
		PlayerResource:ModifyGold(iPlayerID, -iGoldCost, false, DOTA_ModifyGold_PurchaseItem)
		PlayerData:ModifyCrystal(iPlayerID, -iCrystalCost)

		local hItem = CreateItem(sItemName, nil, hUnit)

		hUnit:AddItem(hItem)
		if hItem:GetParent() ~= hUnit and hItem:GetContainer() == nil then
			hItem:SetParent(hUnit, "")
			CreateItemOnPositionSync(hUnit:GetAbsOrigin()+Vector(RandomFloat(-50, 50), RandomFloat(-50, 50), 0), hItem)
		end

		local iCountingMode = GameMode:GetCountingMode()

		if iCountingMode == COUNTING_MODE_TEAM then
			DotaTD:EachPlayer(function(n, iPlayerID)
				if self.playerCrystalShop[iPlayerID][sItemName] ~= nil and self.playerCrystalShop[iPlayerID][sItemName].iStock ~= nil then
					self.playerCrystalShop[iPlayerID][sItemName].iStock = self.playerCrystalShop[iPlayerID][sItemName].iStock - 1
				end
			end)
		elseif iCountingMode == COUNTING_MODE_PERSONAL then
			self.playerCrystalShop[iPlayerID][sItemName].iStock = self.playerCrystalShop[iPlayerID][sItemName].iStock - 1
		end
		self:UpdateNetTables()
	end
end

--[[
	监听
]]--
function public:OnGameRulesStateChange()
	local state = GameRules:State_Get()

	if state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		DotaTD:EachPlayer(function(n, iPlayerID)
			self.playerCrystalShop[iPlayerID] = {}

			for sItemName, tValues in pairs(KeyValues.CrystalShopKv) do
				self.playerCrystalShop[iPlayerID][sItemName] = {
					iCrystalCost = tValues.CrystalCost or 0,
					iGoldCost = GetItemCost(sItemName),
					iStock = 0,
				}
			end
		end)
	elseif state == DOTA_GAMERULES_STATE_PRE_GAME then
		self.fStockTime = GameRules:GetGameTime() + CRYSTAL_SHOP_OPEN_TIME
		GameRules:GetGameModeEntity():GameTimer(CRYSTAL_SHOP_OPEN_TIME, function()
			self:Stock()

			self.fStockTime = self.fStockTime + CRYSTAL_SHOP_STOCK_TIME

			self:UpdateNetTables()

			return CRYSTAL_SHOP_STOCK_TIME
		end)

		self:UpdateNetTables()
	end
end



return public