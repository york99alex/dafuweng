if GameMode == nil then
	GameMode = class({})
end
local public = GameMode

local BenefitCrit = WeightPool(BENEFIT_CRIT_WEIGHT)

function public:init(bReload)
	if not bReload then
		self.CountingMode = COUNTING_MODE_TEAM
		self.Difficulty = DIFFICULTY_EASY
		self.iBenefitRound = 0

		self.GameModeSelectionEndTime = -1

		self.playerGameModeSelection = {}
	end

	GameEvent("game_rules_state_change", Dynamic_Wrap(public, "OnGameRulesStateChange"), public)
	GameEvent("custom_npc_first_spawned", Dynamic_Wrap(public, "OnNPCFirstSpawned"), public)
	GameEvent("custom_round_changed", Dynamic_Wrap(public, "OnRoundChanged"), public)

	CustomUIEvent("PlayerSelectGameMode", Dynamic_Wrap(public, "OnPlayerSelectGameMode"), public)

	self:UpdateNetTables()
end
function public:UpdateNetTables()
	local gameModeInfo = {
		game_mode_selection_end_time = self.GameModeSelectionEndTime,
		counting_mode = self.CountingMode,
		difficulty = self.Difficulty,
	}
	CustomNetTables:SetTableValue("common", "game_mode_info", gameModeInfo)
	CustomNetTables:SetTableValue("common", "player_game_mode_selection", self.playerGameModeSelection)
end
function public:GetCountingMode()
	return self.CountingMode
end
function public:SetCountingMode(countingMode)
	self.CountingMode = countingMode or self.CountingMode
	self:UpdateNetTables()
end
function public:GetDifficulty()
	return self.Difficulty
end
function public:SetDifficulty(difficulty)
	self.Difficulty = difficulty or self.Difficulty
	self:UpdateNetTables()
end
function public:StartGameModeSelection()
	self.GameModeSelectionEndTime = GameRules:GetGameTime() + GAME_MODE_SELECTION_TIME
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("GameModeSelectionTimer"), function()
		if GameRules:GetGameTime() >= self.GameModeSelectionEndTime then
			self:FinishGameModeSelection()
			return nil
		end
		if not Service:IsChecked() then
			self.GameModeSelectionEndTime = self.GameModeSelectionEndTime + GameRules:GetGameFrameTime()
			self:UpdateNetTables()
		end
		return 0
	end, 0)
end
function public:FinishGameModeSelection()
	self.GameModeSelectionEndTime = -1

	local countingModeVotes = {
		[COUNTING_MODE_TEAM] = 0,
		[COUNTING_MODE_PERSONAL] = 0,
	}
	local difficultyVotes = {
		[DIFFICULTY_EASY] = 0,
		[DIFFICULTY_NORMAL] = 0,
		[DIFFICULTY_HARD] = 0,
		[DIFFICULTY_EXPERT] = 0,
		[DIFFICULTY_CRAZY] = 0,
	}

	DotaTD:EachPlayer(function(n, playerID)
		local countingMode = self.playerGameModeSelection[playerID].counting_mode
		local difficulty = self.playerGameModeSelection[playerID].difficulty

		countingModeVotes[countingMode] = countingModeVotes[countingMode] + 1
		difficultyVotes[difficulty] = difficultyVotes[difficulty] + 1

		local player = PlayerResource:GetPlayer(playerID)
		if player ~= nil then
			player:SetSelectedHero(FORCE_PICKED_HERO)
		end
	end)

	-- 计数，优先团队模式
	local countingMode = 0
	for i = 0, COUNTING_MODE_LAST-1, 1 do
		if countingModeVotes[i] > countingModeVotes[countingMode] then
			countingMode = i
		end
	end
	self:SetCountingMode(countingMode)

	-- 难度，优先高难度
	local difficulty = DIFFICULTY_LAST-1
	for i = DIFFICULTY_LAST-1, 0, -1 do
		if difficultyVotes[i] > difficultyVotes[difficulty] then
			difficulty = i
		end
	end
	self:SetDifficulty(difficulty)
end
--[[
	各个UI事件
]]--
function public:OnPlayerSelectGameMode( eventSourceIndex, data )
	local playerID = data.PlayerID

	local countingMode = data.counting_mode
	if countingMode ~= nil then
		self.playerGameModeSelection[playerID].counting_mode = countingMode
		self.playerGameModeSelection[playerID].is_default_counting_mode = 0
	end

	local difficulty = data.difficulty
	if difficulty ~= nil then
		self.playerGameModeSelection[playerID].difficulty = difficulty
		self.playerGameModeSelection[playerID].is_default_difficulty = 0
	end

	local allFinishSelected = true
	for playerID, gameModeSelection in pairs(self.playerGameModeSelection) do
		if gameModeSelection.is_default_difficulty == 1 or gameModeSelection.is_default_counting_mode == 1 then
			allFinishSelected = false
		end
	end
	if allFinishSelected and (self.GameModeSelectionEndTime - GameRules:GetGameTime()) > 5 then
		self.GameModeSelectionEndTime = GameRules:GetGameTime() + GAME_MODE_SELECTION_LOCK_TIME
	end

	self:UpdateNetTables()
end
--[[
	监听
]]--
function public:OnGameRulesStateChange()
	local state = GameRules:State_Get()

	if state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		DotaTD:EachPlayer(function(n, playerID)
			self.playerGameModeSelection[playerID] = {
				difficulty = DIFFICULTY_EASY,
				counting_mode = COUNTING_MODE_TEAM,
				is_default_difficulty = 1,
				is_default_counting_mode = 0,
			}
		end)

		self:StartGameModeSelection()

		self:UpdateNetTables()
	end

	if state == DOTA_GAMERULES_STATE_PRE_GAME then
		local difficulty = self:GetDifficulty()
		local startingGold = DIFFICULTY_SETTINGS.STARTING_GOLD[difficulty]
		DotaTD:EachPlayer(function(n, playerID)
			PlayerResource:SetGold(playerID, startingGold, false)
		end)
	end
end

function public:OnNPCFirstSpawned(events)
	local spawnedUnit = EntIndexToHScript( events.entindex )
	if spawnedUnit == nil then return end

	if spawnedUnit:IsRealHero() then
	end
end

function public:OnRoundChanged(events)
	local bIsEndless = events.endless == 1

	if bIsEndless then return end

	local iRound = math.max(events.round-1, 1)
	local iDifficulty = self:GetDifficulty()
	local benefitFactor = DIFFICULTY_SETTINGS.BENEFIT_FACTOR[iDifficulty]

	local iTargetRound = self.iBenefitRound+BENEFIT_ROUND

	if iRound >= iTargetRound then
		self.iBenefitRound = iTargetRound+BENEFIT_ROUND

		DotaTD:EachPlayer(function(n, iPlayerID)
			local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
			if not hHero:IsAlive() then return false end

			local iIndex = math.floor(iRound/BENEFIT_ROUND)

			local sPercent = BenefitCrit:Random()
			local iGold = BENEFIT_GOLD[math.min(iIndex, #BENEFIT_GOLD)]*tonumber(sPercent)*0.01*benefitFactor
			local tReservoir = BENEFIT_RESERVOIR[math.min(iIndex, #BENEFIT_RESERVOIR)]

			hHero:ModifyGold(iGold, false, DOTA_ModifyGold_GameTick)

			for _, sPoolName in pairs(tReservoir) do
				local sItemName = DotaTD:DrawPool(sPoolName)
				local hItem = CreateItem(sItemName, nil, hHero)
				hItem:SetPurchaseTime(0)
		
				hHero:AddItem(hItem)
				if hItem:GetParent() ~= hHero and hItem:GetContainer() == nil then
					hItem:SetParent(hHero, "")
					CreateItemOnPositionSync(hHero:GetAbsOrigin()+Vector(RandomFloat(-50, 50), RandomFloat(-50, 50), 0), hItem)
				end
			end
		
			local gameEvent = {}
			gameEvent["player_id"] = hHero:GetPlayerOwnerID()
			gameEvent["int_value"] = iGold
			gameEvent["locstring_value"] = sPercent
			gameEvent["teamnumber"] = -1
			gameEvent["message"] = "#Custom_ReceiveBenefit"
			Notification:Combat(gameEvent)
		
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, hHero, iGold, nil)
			hHero:EmitSound("General.CoinsBig")
		end)
	end
end

return public