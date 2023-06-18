if Draw == nil then
	Draw = class({})
end

local public = Draw

function public:init(bReload)
	if not bReload then
		self.PlayerCardSelectionList = {}
		self.PlayerDiscards = {}

		self.tDealCards = {}
		self.iDealCardsCount = 0
	end

	self.tData = {}
	for name, keyValues in pairs(KeyValues.DrawKv) do
		local data = {
			number = keyValues.number,
			reservoir = keyValues.reservoir,
		}
		if keyValues.itemCost ~= nil then
			data.itemCost = string.split(keyValues.itemCost, " | ")
		end
		self.tData[name] = data
	end

	GameEvent("game_rules_state_change", Dynamic_Wrap(public, "OnGameRulesStateChange"), public)
	GameEvent("custom_npc_first_spawned", Dynamic_Wrap(public, "OnNPCFirstSpawned"), public)
	GameEvent("entity_killed", Dynamic_Wrap(public, "OnUnitKilled"), public)

	CustomUIEvent("CardSelected", Dynamic_Wrap(public, "OnCardSelected"), public)

	--[[
	local tRaritys = {}
	local tOneRaritys = {}
	local tCards = {}
	local iCount = 100000
	local data = {
		number = 3,
		reservoir = "draw_card_2"
	}
	
	local sCard = "t04"

	for n = 1, iCount, 1 do
		local t = {
			n = false,
			r = false,
			sr = false,
			ssr = false,
		}
		for i = 1, data.number, 1 do
			local itemName = DotaTD:DrawReservoir(data.reservoir)
			local cardName = DotaTD:AbilityNameToCardName(itemName)
			while TableFindKey(selectionList, cardName) ~= nil or TableFindKey(self.PlayerDiscards[playerID], cardName) ~= nil do
				itemName = DotaTD:DrawReservoir(data.reservoir)
				cardName = DotaTD:AbilityNameToCardName(itemName)
			end
			local rarity = DotaTD:GetCardRarity(cardName)
			tRaritys[rarity] = (tRaritys[rarity] or 0) + 1
			tCards[cardName] = (tCards[cardName] or 0) + 1
			t[rarity] = true
		end
		for rarity, v in pairs(t) do
			if v then
				tOneRaritys[rarity] = (tOneRaritys[rarity] or 0) + 1
			end
		end
	end

	for rarity, n in pairs(tRaritys) do
		print(rarity, n, tostring(n/(iCount*data.number)*100).."%")
	end

	print("------------")

	for rarity, n in pairs(tOneRaritys) do
		print(rarity, n, tostring(n/iCount*100).."%")
	end

	print("------------")

	local count = tCards[sCard] or 0
	print(sCard, count, tostring(count/(iCount)*100).."%")
	]]--

	self:UpdateNetTables()
end

function public:UpdateNetTables()
	CustomNetTables:SetTableValue("common", "player_card_selection_list", self.PlayerCardSelectionList)
	CustomNetTables:SetTableValue("common", "deal_cards", self.tDealCards)
end

-- 抽卡
function public:DrawCard(playerID, name)
	self:SelectCard(playerID, "")

	local data = self.tData[name]
	local selectionList = {}

	for i = 1, data.number, 1 do
		local itemName = DotaTD:DrawReservoir(data.reservoir)
		local cardName = DotaTD:AbilityNameToCardName(itemName)
		while TableFindKey(selectionList, cardName) ~= nil or TableFindKey(self.PlayerDiscards[playerID], cardName) ~= nil do
			itemName = DotaTD:DrawReservoir(data.reservoir)
			cardName = DotaTD:AbilityNameToCardName(itemName)
		end
		table.insert(selectionList, cardName)
	end

	self.PlayerCardSelectionList[playerID] = selectionList
	self:UpdateNetTables()
end

-- 选卡
function public:SelectCard(playerID, cardName)
	if TableFindKey(self.PlayerCardSelectionList[playerID], cardName) ~= nil then
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if not IsValid(hero) or not hero:IsAlive() then
			return
		end
		local itemName = DotaTD:CardNameToAbilityName(cardName)

		local item = CreateItem(itemName, nil, hero)
		item:SetPurchaseTime(0)

		hero:AddItem(item)
		if item:GetParent() ~= hero and item:GetContainer() == nil then
			item:SetParent(hero, "")
			CreateItemOnPositionSync(hero:GetAbsOrigin()+Vector(RandomFloat(-50, 50), RandomFloat(-50, 50), 0), item)
		end

		Notification:Combat({
			player_id = playerID,
			string_unit_name = cardName,
			message = "#Custom_Draw",
		})

		if DotaTD:GetCardRarity(cardName) == "ssr" then
			Notification:Upper({
				player_id = playerID,
				string_unit_name = cardName,
				message = "#Custom_Draw",
			})
			CustomGameEventManager:Send_ServerToAllClients("show_drawing", {name=cardName})
		elseif DotaTD:GetCardRarity(cardName) == "sr" then
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "show_drawing", {name=cardName})
		end

		self.PlayerDiscards[playerID] = {}
		for k, v in pairs(self.PlayerCardSelectionList[playerID]) do
			if v ~= cardName then
				table.insert(self.PlayerDiscards[playerID], v)
			end
		end
		self.PlayerCardSelectionList[playerID] = {}
		self:UpdateNetTables()
	elseif #self.PlayerCardSelectionList[playerID] > 0 then
		local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
		if not IsValid(hHero) or not hHero:IsAlive() then
			return
		end
		-- 自动卖掉最贵的
		local iMax = 0
		for iIndex, sCardName in pairs(self.PlayerCardSelectionList[playerID]) do
			local sItemName = DotaTD:CardNameToAbilityName(sCardName)
			local iGoldCost = GetItemCost(sItemName)
			if iGoldCost > iMax then
				iMax = iGoldCost
			end
		end

		local iGold = iMax/2
		hHero:ModifyGold(iGold, false, DOTA_ModifyGold_SellItem)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, hHero, iGold, nil)

		self.PlayerDiscards[playerID] = {}
		for k, v in pairs(self.PlayerCardSelectionList[playerID]) do
			table.insert(self.PlayerDiscards[playerID], v)
		end
		self.PlayerCardSelectionList[playerID] = {}
		self:UpdateNetTables()
	end
end

-- 打开卡片
function public:OpenCard(hUnit, sName)
	local tData = self.tData[sName]
	local iPlayerID = hUnit:GetPlayerOwnerID()

	local sDrawedItemName = DotaTD:DrawReservoir(tData.reservoir)

	local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
	local hItem = CreateItem(sDrawedItemName, nil, hHero)
	hItem:SetPurchaseTime(0)

	hUnit:AddItem(hItem)
	if hItem:GetParent() ~= hUnit then
		hItem:SetParent(hUnit, "")
		CreateItemOnPositionSync(hUnit:GetAbsOrigin()+Vector(RandomFloat(-50, 50), RandomFloat(-50, 50), 0), hItem)
	end

	Notification:Combat({
		player_id = iPlayerID,
		string_chest = "DOTA_Tooltip_Ability_"..sName,
		string_item = "DOTA_Tooltip_Ability_"..sDrawedItemName,
		message = "#Custom_OpenChest",
	})
	if Items:GetItemRarity(hItem) >= 4 then
		Notification:Upper({
			string_chest = "DOTA_Tooltip_Ability_"..sName,
			string_item = "DOTA_Tooltip_Ability_"..sDrawedItemName,
			message = "#Custom_OpenChest",
		})
	end

	return true
end

-- 打开箱子
function public:OpenChest(hKeyUnit, hChestUnit, sName)
	local tData = self.tData[sName]
	local iKeyPlayerID = hKeyUnit:GetPlayerOwnerID()
	local iChestPlayerID = hChestUnit:GetPlayerOwnerID()

	if tData.itemCost ~= nil and #tData.itemCost > 0 then
		local bIsKeyUsed = false
		for iIndex, sItemName in pairs(tData.itemCost) do
			for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9, 1 do
				local hItem = hChestUnit:GetItemInSlot(i)
				if hItem ~= nil and hItem:GetName() == sItemName then
					hItem:SpendCharge()
					bIsKeyUsed = true
					break
				end
			end
			if bIsKeyUsed then
				break
			end
		end
		if not bIsKeyUsed then
			ErrorMessage(iKeyPlayerID, "dota_hud_error_no_key")
			return false
		end
	end

	local tRewardUnit = {
		[1] = {iPlayerID = iKeyPlayerID, hHero = PlayerResource:GetSelectedHeroEntity(iKeyPlayerID), hUnit = hKeyUnit},
		[2] = {iPlayerID = iChestPlayerID, hHero = PlayerResource:GetSelectedHeroEntity(iChestPlayerID), hUnit = hChestUnit}
	}

	for _, tUnitInfo in ipairs(tRewardUnit) do
		local sDrawedItemName = DotaTD:DrawReservoir(tData.reservoir)
	
		local hItem = CreateItem(sDrawedItemName, nil, tUnitInfo.hHero)
		hItem:SetPurchaseTime(0)
	
		tUnitInfo.hUnit:AddItem(hItem)
		if hItem:GetParent() ~= tUnitInfo.hUnit then
			hItem:SetParent(tUnitInfo.hUnit, "")
			CreateItemOnPositionSync(tUnitInfo.hUnit:GetAbsOrigin()+Vector(RandomFloat(-50, 50), RandomFloat(-50, 50), 0), hItem)
		end
	
		Notification:Combat({
			player_id = tUnitInfo.iPlayerID,
			string_chest = "DOTA_Tooltip_Ability_"..sName,
			string_item = "DOTA_Tooltip_Ability_"..sDrawedItemName,
			message = "#Custom_OpenChest",
		})
		if Items:GetItemRarity(hItem) >= 4 then
			Notification:Upper({
				player_id = tUnitInfo.iPlayerID,
				string_chest = "DOTA_Tooltip_Ability_"..sName,
				string_item = "DOTA_Tooltip_Ability_"..sDrawedItemName,
				message = "#Custom_OpenChest",
			})
		end
	end

	return true
end

-- 发牌
function public:TakeCard(iPlayerID, iCardIndex)
	local tPlayerIDs = self.tDealCards.player_ids

	if tPlayerIDs[1] ~= iPlayerID then return end

	ArrayRemove(tPlayerIDs, iPlayerID)

	local tCards = self.tDealCards.cards
	if iCardIndex == nil then
		iCardIndex = RandomInt(1, #tCards)
		while tCards[iCardIndex].player_id ~= -1 do
			iCardIndex = RandomInt(1, #tCards)
		end
	end

	tCards[iCardIndex].player_id = iPlayerID

	local sCardName = tCards[iCardIndex].card_name
	local sItemName = DotaTD:CardNameToAbilityName(sCardName)

	local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
	local hItem = CreateItem(sItemName, nil, hHero)
	hItem:SetPurchaseTime(0)

	hHero:AddItem(hItem)
	if hItem:GetParent() ~= hHero and hItem:GetContainer() == nil then
		hItem:SetParent(hHero, "")
		CreateItemOnPositionSync(hHero:GetAbsOrigin()+Vector(RandomFloat(-50, 50), RandomFloat(-50, 50), 0), hItem)
	end

	Notification:Combat({
		player_id = iPlayerID,
		string_unit_name = sCardName,
		message = "#Custom_Draw",
	})

	GameRules:GetGameModeEntity():StopTimer("Draw_DealCards")

	self:DealCardsEachPlayer(tPlayerIDs, tCards)
end
function public:DealCardsEachPlayer(tPlayerIDs, tCards)
	if #tPlayerIDs == 0 or #tCards == 0 then
		self.tDealCards = {}
		self:UpdateNetTables()
		return
	end

	local iPlayerID = tPlayerIDs[1]
	local fTime = GameRules:GetGameTime() + DEAL_CARDS_TIME
	GameRules:GetGameModeEntity():GameTimer("Draw_DealCards", DEAL_CARDS_TIME, function()
		self:TakeCard(iPlayerID)
	end)

	self.tDealCards = {
		countdown_time = fTime,
		player_ids = tPlayerIDs,
		cards = tCards,
	}
	self:UpdateNetTables()
end
function public:DealCards(tPrecedence)
	-- if type(tPrecedence) ~= "table" or #tPrecedence == 0 then
	-- 	return
	-- end

	-- self.iDealCardsCount = self.iDealCardsCount + 1
	-- local sReservoir = DEAL_CARDS_RESERVOIRS[self.iDealCardsCount]
	-- local iCardAmount = DEAL_CARDS_AMOUNT[DotaTD:GetValidPlayerCount()]

	-- local tCards = {}

	-- for i = 1, iCardAmount, 1 do
	-- 	local sItemName = DotaTD:DrawReservoir(sReservoir)
	-- 	local sCardName = DotaTD:AbilityNameToCardName(sItemName)
	-- 	table.insert(tCards, {
	-- 		card_name = sCardName,
	-- 		player_id = -1,
	-- 	})
	-- end

	-- self:DealCardsEachPlayer(tPrecedence, tCards)
end

--[[
	各个UI事件
]]--
function public:OnCardSelected( eventSourceIndex, events )
	local playerID = events.PlayerID
	local cardName = events.card_name or ""

	self:SelectCard(playerID, cardName)
end
--[[
	监听
]]--
function public:OnGameRulesStateChange()
	local state = GameRules:State_Get()

	if state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		DotaTD:EachPlayer(function(n, playerID)
			self.PlayerCardSelectionList[playerID] = {}
			self.PlayerDiscards[playerID] = {}
		end)

		self:UpdateNetTables()
	elseif state == DOTA_GAMERULES_STATE_PRE_GAME then
		DotaTD:EachPlayer(function(n, playerID)
			self:DrawCard(playerID, "builder_start_pick")
		end)
	end
end
function public:OnNPCFirstSpawned(events)
	local spawnedUnit = EntIndexToHScript(events.entindex)
	if spawnedUnit == nil then return end

	if spawnedUnit:IsRealHero() then
		if spawnedUnit:GetUnitLabel() == "builder" then
			local builder_draw_card_1 = spawnedUnit:FindAbilityByName("builder_draw_card_1")
			builder_draw_card_1:UpgradeAbility(true)
			local builder_draw_card_2 = spawnedUnit:FindAbilityByName("builder_draw_card_2")
			builder_draw_card_2:UpgradeAbility(true)
			local builder_draw_card_3 = spawnedUnit:FindAbilityByName("builder_draw_card_3")
			builder_draw_card_3:UpgradeAbility(true)
		end
	end
end
function public:OnUnitKilled( events )
	local unit = EntIndexToHScript(events.entindex_killed)
	local attacker = EntIndexToHScript(events.entindex_attacker)

	-- 玩家死亡
	if unit:IsRealHero() and unit:HasModifier("modifier_builder") then
		local playerID = unit:GetPlayerOwnerID()

		self.PlayerCardSelectionList[playerID] = {}
		self:UpdateNetTables()
	end
end

return public