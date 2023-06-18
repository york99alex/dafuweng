if Spawner == nil then
	Spawner = class({})
end
local public = Spawner

LinkLuaModifier("modifier_elite_1", "modifiers/elite/modifier_elite_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_elite_2", "modifiers/elite/modifier_elite_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_elite_3", "modifiers/elite/modifier_elite_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_elite_4", "modifiers/elite/modifier_elite_4.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_elite_5", "modifiers/elite/modifier_elite_5.lua", LUA_MODIFIER_MOTION_NONE)

local WaveEliteModifiers = WeightPool(WAVE_ELITE_MODIFIERS)
local BossAuraModifiers = WeightPool(BOSS_AURA_MODIFIERS)
local EndlessUnits = WeightPool(ENDLESS_UNITS)
local EndlessBosses = WeightPool(ENDLESS_BOSSES)

function public:init(bReload)
	if not bReload then
		self.Round = 1
		self.ActualRound = 1
		self.NextRoundTime = -1

		self.PlayerMissing = {}
		self.PlayerGoldCreeps = {}
		self.bRoshanRound = false
		self.bRoshanKilled = false
		self.iRoshanKills = 0

		self.bIsEndless = false

		self.EndlessRound = 1
		self.EndlessRoundUnit = {}
		self.EndlessRoundBonusHealth = 0
	end

	-- 普通波数信息
	self.WaveKv = shallowcopy(KeyValues.WaveKv)
	for k, v in pairs(self.WaveKv) do
		if type(v) == "table" and v.UnitList ~= nil then
			local list = string.split(v.UnitList, " | ")
			local total = 0
			local unitListWeightPool = WeightPool()
			for _, unitName in pairs(list) do
				unitListWeightPool:Set(unitName, v[unitName] or 1)
			end
			v.TotalWeight = total
			v.UnitListWeightPool = unitListWeightPool
		end
	end

	-- 无尽波数信息
	self.EndlessKv = shallowcopy(KeyValues.EndlessKv)
	for k, v in pairs(self.EndlessKv) do
		if type(v) == "table" and v.UnitList ~= nil then
			local list = string.split(v.UnitList, ",")
			local total = 0
			local unitListWeightPool = WeightPool()
			for _, unitName in pairs(list) do
				unitListWeightPool:Set(unitName, v[unitName] or 1)
			end
			v.TotalWeight = total
			v.UnitListWeightPool = unitListWeightPool
		end
	end
	-- 怪物诞生点
	self.Spawner = {
		Entities:FindByName(nil, "player_0_spawner"),
		Entities:FindByName(nil, "player_1_spawner"),
		Entities:FindByName(nil, "player_2_spawner"),
		Entities:FindByName(nil, "player_3_spawner"),
	}
	-- 拐角的所有目标拐角
	self.Corner = {
		["player_0_spawner"] = {"corner_0_1"},
		["corner_0_1"] = {"corner_0_2"},
		["player_1_spawner"] = {"corner_1_1"},
		["corner_1_1"] = {"corner_1_2"},
		["player_2_spawner"] = {"corner_2_1"},
		["corner_2_1"] = {"corner_2_2"},
		["player_3_spawner"] = {"corner_3_1"},
		["corner_3_1"] = {"corner_3_2"},

		["corner_inner_top_left"] = {"corner_0_2", "corner_inner_middle_left"},
		["corner_0_2"] = {"corner_inner_top_middle", "corner_inner_top_left"},
		["corner_inner_top_middle"] = {"corner_inner_top_right", "corner_0_2", "corner_outer_top_middle"},
		["corner_inner_top_right"] = {"corner_1_2", "corner_inner_top_middle"},
		["corner_1_2"] = {"corner_inner_middle_right", "corner_inner_top_right"},
		["corner_inner_middle_right"] = {"corner_inner_bottom_right", "corner_1_2", "corner_outer_middle_right"},
		["corner_inner_bottom_right"] = {"corner_3_2", "corner_inner_middle_right"},
		["corner_3_2"] = {"corner_inner_bottom_middle", "corner_inner_bottom_right"},
		["corner_inner_bottom_middle"] = {"corner_inner_bottom_left", "corner_3_2", "corner_outer_bottom_middle"},
		["corner_inner_bottom_left"] = {"corner_2_2", "corner_inner_bottom_middle"},
		["corner_2_2"] = {"corner_inner_middle_left", "corner_inner_bottom_left"},
		["corner_inner_middle_left"] = {"corner_inner_top_left", "corner_2_2", "corner_outer_middle_left"},

		["corner_outer_top_left"] = {"corner_outer_top_middle", "corner_outer_middle_left"},
		["corner_outer_top_middle"] = {"corner_outer_top_right", "corner_outer_top_left", "corner_inner_top_middle"},
		["corner_outer_top_right"] = {"corner_outer_middle_right", "corner_outer_top_middle"},
		["corner_outer_middle_right"] = {"corner_outer_bottom_right", "corner_outer_top_right", "corner_inner_middle_right"},
		["corner_outer_bottom_right"] = {"corner_outer_bottom_middle", "corner_outer_middle_right"},
		["corner_outer_bottom_middle"] = {"corner_outer_bottom_left", "corner_outer_bottom_right", "corner_inner_bottom_middle"},
		["corner_outer_bottom_left"] = {"corner_outer_middle_left", "corner_outer_bottom_middle"},
		["corner_outer_middle_left"] = {"corner_outer_top_left", "corner_outer_bottom_left", "corner_inner_middle_left"},
	}
	self.RoshanCorner = {
		["player_0_spawner"] = {"corner_0_1"},
		["corner_0_1"] = {"corner_0_2"},
		["corner_0_2"] = {"corner_0_1"},
		["player_1_spawner"] = {"corner_1_1"},
		["corner_1_1"] = {"corner_1_2"},
		["corner_1_2"] = {"corner_1_1"},
		["player_2_spawner"] = {"corner_2_1"},
		["corner_2_1"] = {"corner_2_2"},
		["corner_2_2"] = {"corner_2_1"},
		["player_3_spawner"] = {"corner_3_1"},
		["corner_3_1"] = {"corner_3_2"},
		["corner_3_2"] = {"corner_3_1"},
	}

	GameEvent("custom_npc_first_spawned", Dynamic_Wrap(public, "OnNPCFirstSpawned"), public)
	GameEvent("entity_killed", Dynamic_Wrap(public, "OnUnitKilled"), public)
	GameEvent("entity_hurt", Dynamic_Wrap(public, "OnEntityHurt"), public)
	GameEvent("game_rules_state_change", Dynamic_Wrap(public, "OnGameRulesStateChange"), public)

	self:UpdateNetTables()
end
function public:UpdateNetTables()
	local round = self.bIsEndless and self.EndlessRound or self.Round
	local roundData = self:GetRoundData(round-1)
	local nextRoundData = self:GetRoundData(round)
	local table = {
		is_endless = self.bIsEndless,
		round = self:GetActualRound(),
		round_title = roundData ~= nil and roundData.RoundTitle or "",
		round_description = roundData ~= nil and roundData.RoundDescription or "",
		next_round_wait_time = nextRoundData ~= nil and nextRoundData.WaitTime or -1,
		next_round_title = nextRoundData ~= nil and nextRoundData.RoundTitle or "",
		next_round_description = nextRoundData ~= nil and nextRoundData.RoundDescription or "",
		next_round_time = self.NextRoundTime,
	}
	CustomNetTables:SetTableValue("common", "round_info", table)
end
function public:GetRoundData(round)
	if self.bIsEndless then
		return self.EndlessKv[self.EndlessRoundUnit[round] or -1]
	end
	return self.WaveKv["Round"..round]
end
function public:GetNowRoundData()
	local round = self.bIsEndless and self.EndlessRound or self.Round
	return self:GetRoundData(math.max(round-1, 1))
end
function public:IsEndless()
	return self.bIsEndless
end
function public:IsRoshanRound()
	return self.bRoshanRound
end
function public:GetActualRound()
	if self.bIsEndless then
		return self.EndlessRound
	end
	return self.ActualRound
end
function public:GetPlayerMissingCount(iPlayerID)
	local iMissingCount = 0
	for i = #self.PlayerMissing[iPlayerID], 1, -1 do
		local hUnit = self.PlayerMissing[iPlayerID][i]
		if IsValid(hUnit) then
			iMissingCount = iMissingCount + (hUnit:IsConsideredHero() and 5 or 1)
		else
			table.remove(self.PlayerMissing[iPlayerID], i)
		end
	end
	return iMissingCount
end
function public:StartRoundTimer()
	local roundData = self:GetRoundData(self.Round)
	if roundData ~= nil then
		--触发回合转换事件 0表示不是无尽模式 加入无尽模式之后可以传1
		FireGameEvent("custom_round_changed", {round=self.ActualRound, endless=0})

		if self.Round == 1 then
			GameRules:GetGameModeEntity():GameTimer(roundData.WaitTime-10, function()
				EmitGlobalSound("Round.FirstWave")
			end)
		end

		-- 肉山前通知
		if self.ActualRound == 55 and self.Round == 66 then
			local iPlayerCount = DotaTD:GetValidPlayerCount()
			local iRoshanCount = iPlayerCount
			CustomNetTables:SetTableValue("common", "roshan_info", {roshan_count=iRoshanCount})
		end

		self.NextRoundTime = GameRules:GetGameTime() + roundData.WaitTime
		GameRules:GetGameModeEntity():GameTimer(roundData.WaitTime, function()
			EmitGlobalSound("Round.WaveStart")
			self:StartWaveTimer(self.Round)

			self.Round = self.Round + 1

			if not (roundData.ExcludingRound and roundData.ExcludingRound == 1) then
				self.ActualRound = self.ActualRound + 1
			end

			self:StartRoundTimer()
		end)
	else
		-- 肉山击杀倒计时
		self.NextRoundTime = GameRules:GetGameTime() + ROSHAN_COUNTDOWN_TIME
		-- 处理肉山事件
		self:RoshanEvent()
		
		GameRules:GetGameModeEntity():GameTimer(ROSHAN_COUNTDOWN_TIME, function()
			local countingMode = GameMode:GetCountingMode()
			local difficulty = GameMode:GetDifficulty()
			if self.iRoshanKills >= DotaTD:GetValidPlayerCount() then
				CustomGameEventManager:Send_ServerToAllClients("all_roshan_killed", {success=true})
				DotaTD:EachPlayer(function(n, playerID)
					-- 解锁难度
					if Service:GetPlayerHighestLevel(playerID) <= GameMode:GetDifficulty() then
						Service:RequestPlayerUpdateHighestLevel(playerID, GameMode:GetDifficulty()+1)
					end
				end)

				if DIFFICULTY_SETTINGS.HAS_ENDLESS[difficulty] == 1 then
					-- 开启无尽
					self:StartEndless()
				else
					DotaTD:Victory()
				end
			else
				DotaTD:Defeat()
			end
		end)
	end
	self:UpdateNetTables()
end
function public:StartWaveTimer(round, count, eliteCount, eliteMaxCount)
	local roundData = self:GetRoundData(round)
	if roundData ~= nil then
		count = (count or 0) + 1

		local difficulty = GameMode:GetDifficulty()
		local hpPercentage = DIFFICULTY_SETTINGS.ENEMY_HP_PERCENTAGE[difficulty]
		local hpPercentageRoshan = DIFFICULTY_SETTINGS.ROSHAN_HP_PERCENTAGE[difficulty]
		local eliteChance = WAVE_ELITE_CHANCE[difficulty]

		if eliteCount == nil then
			eliteCount = {}
			eliteMaxCount = {}
		end

		-- 创建单位
		DotaTD:EachPlayer(function(n, playerID)
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			if not hero:IsAlive() then return false end

			if eliteCount[playerID] == nil then eliteCount[playerID] = 0 end
			if eliteMaxCount[playerID] == nil then
				local index = 0
				local missingCount = #self.PlayerMissing[playerID]
				if missingCount > 10 and missingCount <= 20 then
					index = 1
				elseif missingCount <= 30 then
					index = 2
				elseif missingCount > 30 then
					index = 3
				end
				eliteMaxCount[playerID] = WAVE_ELITE_MAX_COUNT[difficulty][index]
			end

			local spawner = self.Spawner[n]
			local unitName = roundData.UnitListWeightPool:Random()
			CreateUnitByNameAsync(unitName, spawner:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
				unit.Spawner_spawnerPlayerID = playerID

				unit:AddNewModifier(unit, nil, "modifier_wave", nil)

				-- 朝向
				local forward = Rotation2D(Vector(-1,0,0), math.rad(playerID*-90))
				unit:SetForwardVector(forward)

				-- 经验
				unit.deathXP = unit:GetDeathXP()
				unit:SetDeathXP(0)

				if unit:HasModifier("modifier_wave_gold") then
					-- 打金怪处理
					table.insert(self.PlayerGoldCreeps[playerID], unit)
				else
					-- 肉山
					if unit:GetUnitName() == "wave_55" then
						local maxHealth = unit:GetMaxHealth()*hpPercentageRoshan*0.01
						unit:SetMaxHealth(maxHealth)
						unit:SetHealth(maxHealth)
						FireGameEvent("custom_roshan_health_change", {CurrentHealth = unit:GetHealth(), MaxHealth = unit:GetMaxHealth(), PlayerID=playerID})
					else
						local maxHealth = unit:GetMaxHealth()*hpPercentage*0.01
						unit:SetMaxHealth(maxHealth)
						unit:SetHealth(maxHealth)
		
						-- 数量
						table.insert(self.PlayerMissing[playerID], unit)
						FireGameEvent("custom_missing_count_change", {MissingCount = self:GetPlayerMissingCount(playerID), PlayerID=playerID})
						self:UpdateNetTables()

						-- 精英怪处理
						if not unit:IsConsideredHero() then
							if eliteCount[playerID] < eliteMaxCount[playerID] and RollPercentage(eliteChance) then
								eliteCount[playerID] = eliteCount[playerID] + 1
								local modifierName = WaveEliteModifiers:Random()
								unit:AddNewModifier(unit, nil, modifierName, nil)

								FireGameEvent("custom_elite_spawned", {iEntityIndex=unit:entindex(), iPlayerID=playerID, iRound=round, sModifierName=modifierName})
							end
						end

						-- Boss处理
						if unit:IsConsideredHero() then
							local pszAbilityName = BossAuraModifiers:Random()
							unit:AddAbility(pszAbilityName):SetLevel(self:GetActualRound() / 5)
						end
					end
				end

				unit:SetContextThink(DoUniqueString("Order"), function()
					if not GameRules:IsGamePaused() then
						self:CornerTurning(unit, spawner:GetName())
						return
					end
					return 0
				end, 0)
			end)
		end)

		if count < roundData.SpawnCount then
			local time = GameRules:GetGameTime() + roundData.SpawnTick
			GameRules:GetGameModeEntity():GameTimer(roundData.SpawnTick, function()
				self:StartWaveTimer(round, count, eliteCount, eliteMaxCount)
			end)
		end
	end
end

function public:SummonedWave(hCaster, hUnit)
	local iPlayerID = hCaster.Spawner_spawnerPlayerID

	hUnit.Spawner_targetCornerName = hCaster.Spawner_targetCornerName
	hUnit.Spawner_lastCornerName = hCaster.Spawner_lastCornerName
	hUnit.Spawner_spawnerPlayerID = hCaster.Spawner_spawnerPlayerID

	hUnit:AddNewModifier(hUnit, nil, "modifier_wave", nil)

	hUnit.deathXP = hUnit:GetDeathXP()
	hUnit:SetDeathXP(0)

	table.insert(self.PlayerMissing[iPlayerID], hUnit)
	FireGameEvent("custom_missing_count_change", {MissingCount = self:GetPlayerMissingCount(iPlayerID), PlayerID=iPlayerID})
	self:UpdateNetTables()

	hUnit:SetContextThink(DoUniqueString("Order"), function()
		if not GameRules:IsGamePaused() then
			self:MoveOrder(hUnit)
			return
		end
		return 0
	end, 0)
end

--[[
	无尽相关
]]--
function public:StartEndless()
	self.bIsEndless = true

	DotaTD:EachPlayer(function(n, playerID)
		for k, v in pairs(self.PlayerMissing[playerID]) do
			v:RemoveModifierByName("modifier_wave")
			v:ForceKill(false)
			v:RemoveSelf()
		end
		self.PlayerMissing[playerID] = {}
		FireGameEvent("custom_missing_count_change", {MissingCount = self:GetPlayerMissingCount(playerID), PlayerID=playerID})
		self:UpdateNetTables()

		for k, v in pairs(self.PlayerGoldCreeps[playerID]) do
			v:RemoveModifierByName("modifier_wave")
			v:ForceKill(false)
			v:RemoveSelf()
		end
		self.PlayerGoldCreeps[playerID] = {}
	end)

	self:StartEndlessRoundTimer(ENDLESS_PREPARE_TIME)
end
function public:StartEndlessRoundTimer(fRoundTime)
	FireGameEvent("custom_round_changed", {round=self.EndlessRound, endless=1})

	if self.EndlessRound % 5 == 0 then
		self.EndlessRoundUnit[self.EndlessRound] = EndlessBosses:Random()
		self.EndlessRoundBonusHealth = self.EndlessRoundBonusHealth * (1 + ENDLESS_HEALTH_GROW_COEFFICIENT_Y * 0.01)
	else
		self.EndlessRoundUnit[self.EndlessRound] = EndlessUnits:Random()
		self.EndlessRoundBonusHealth = self.EndlessRoundBonusHealth + ENDLESS_HEALTH_GROW_COEFFICIENT_X
	end

	self.NextRoundTime = GameRules:GetGameTime() + fRoundTime
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("RoundTimer"), function()
		if GameRules:GetGameTime() >= self.NextRoundTime then
			self:StartEndlessWaveTimer(self.EndlessRound)

			self.EndlessRound = self.EndlessRound + 1

			self:StartEndlessRoundTimer(ENDLESS_ROUND_TIME)
			return
		end
		return 0
	end, 0)

	self:UpdateNetTables()
end
function public:StartEndlessWaveTimer(round, count)
	local roundData = self:GetRoundData(round)
	if roundData ~= nil then
		count = (count or 0) + 1

		local difficulty = GameMode:GetDifficulty()
		local hpPercentage = DIFFICULTY_SETTINGS.ENEMY_HP_PERCENTAGE[difficulty]
		--local fEndlessGrow = (1+ENDLESS_HEALTH_GROW_PERCENTAGE*0.01*round)

		-- 创建单位
		DotaTD:EachPlayer(function(n, playerID)
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			if not hero:IsAlive() then return false end

			local spawner = self.Spawner[n]
			local unitName = roundData.UnitListWeightPool:Random()
			CreateUnitByNameAsync(unitName, spawner:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
				unit.Spawner_spawnerPlayerID = playerID

				local maxHealth = unit:GetMaxHealth()*hpPercentage*0.01
				--maxHealth = maxHealth * fEndlessGrow
				maxHealth = maxHealth + self.EndlessRoundBonusHealth
				unit:SetMaxHealth(maxHealth)
				unit:SetHealth(maxHealth)

				unit:AddNewModifier(unit, nil, "modifier_wave", nil)

				-- 朝向
				local forward = Rotation2D(Vector(-1,0,0), math.rad(playerID*-90))
				unit:SetForwardVector(forward)

				-- 经验
				unit.deathXP = unit:GetDeathXP()
				unit:SetDeathXP(0)

				-- 数量
				table.insert(self.PlayerMissing[playerID], unit)
				FireGameEvent("custom_missing_count_change", {MissingCount = self:GetPlayerMissingCount(playerID), PlayerID=playerID})
				self:UpdateNetTables()

				-- Boss处理
				if unit:IsConsideredHero() then
					-- local pszAbilityName = BossAuraModifiers:Random()
					-- local ability = unit:AddAbility(pszAbilityName)
					-- ability:SetLevel(ability:GetMaxLevel())
				end
				
				unit:SetContextThink(DoUniqueString("Order"), function()
					if not GameRules:IsGamePaused() then
						self:CornerTurning(unit, spawner:GetName())
						return
					end
					return 0
				end, 0)
			end)
		end)

		if count < roundData.SpawnCount then
			local time = GameRules:GetGameTime() + roundData.SpawnTick
			GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("WaveTimer"), function()
				if GameRules:GetGameTime() >= time then
					self:StartEndlessWaveTimer(round, count)
					return
				end
				return 0
			end, 0)
		end
	end
end

-- 移动命令
function public:MoveOrder(unit)
	if unit.Spawner_targetCornerName == nil then
		print("error: unit doesn't have target corner")
		return
	end
	local corner = Entities:FindByName(nil, unit.Spawner_targetCornerName)
	if corner then
		unit:MoveToPosition(corner:GetAbsOrigin())
	else
		print("error: can not find corner")
	end
end

-- 到拐角拐弯
function public:CornerTurning(unit, cornerName)
	if unit.Spawner_lastCornerName == cornerName then
		return
	end
	local targetCorners
	if unit:GetUnitName() == "wave_55" then
		targetCorners = self.RoshanCorner[cornerName]
	else
		targetCorners = shallowcopy(self.Corner[cornerName])
		if unit.Spawner_lastCornerName ~= nil then
			local key = TableFindKey(targetCorners, unit.Spawner_lastCornerName)
			if key ~= nil then
				table.remove(targetCorners, key)
			end
		end
	end
	unit.Spawner_targetCornerName = targetCorners[RandomInt(1, #targetCorners)]
	self:MoveOrder(unit)
	unit.Spawner_lastCornerName = cornerName
end
-- 打金
function public:CheckGoldCreeps()
	local startCalc = true
	for playerID, goldCreeps in pairs(self.PlayerGoldCreeps) do
		for i, goldCreep in pairs(goldCreeps) do
			if goldCreep:IsAlive() then
				startCalc = false
				break
			end
		end
	end

	if startCalc then
		local damageInfo = {}
		for playerID, goldCreeps in pairs(self.PlayerGoldCreeps) do
			local damage
			for i, goldCreep in pairs(goldCreeps) do
				damage = (damage or 0) + (goldCreep.totalDamage or 0)
			end
			if damage ~= nil then
				table.insert(damageInfo, {
					playerID = playerID,
					damage = damage,
				})
			end
		end
	
		table.sort(damageInfo, function(a, b) return a.damage > b.damage end)

		Notification:Combat({teamnumber = -1, message = "#Custom_DividingLine"})
		Notification:Combat({teamnumber = -1, message = "#Custom_WaveGold"})

		local tPlayerIDs = {}
		for n, info in ipairs(damageInfo) do
			local totalDamage = info.damage
			local playerID = info.playerID
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			local round = math.max(self:GetActualRound()-1, 1)

			table.insert(tPlayerIDs, playerID)
	
			local a = 0.025
			local b = round*50
			local c = 0.035
			local d = 30000
			local bounty = 0

			if totalDamage <= d then
				bounty = c*totalDamage + b
			else
				bounty = a*(totalDamage-d) + c*d + b
			end

			-- 第一名
			if n == 1 and damageInfo[2] ~= nil then
				local extra = (totalDamage-damageInfo[2].damage)*0.01 + 100 + round*10
				bounty = bounty + extra
			end

			hero:ModifyGold(bounty, false, DOTA_ModifyGold_Unspecified)
			PlayerData.playerDatas[playerID].statistics.wave_gold = PlayerData.playerDatas[playerID].statistics.wave_gold + bounty

			local gameEvent = {}
			gameEvent["player_id"] = playerID
			gameEvent["int_value"] = bounty
			gameEvent["locstring_value"] = tostring(Round(totalDamage))
			gameEvent["teamnumber"] = -1
			gameEvent["message"] = "#Custom_WaveGold_"..n
			Notification:Combat(gameEvent)

			if n == 1 then
				Notification:Upper(gameEvent)
			end

			SendOverheadEventMessage(PlayerResource:GetPlayer(playerID), OVERHEAD_ALERT_GOLD, hero, bounty, nil)
			hero:EmitSound("General.CoinsBig")
		end
		Notification:Combat({teamnumber = -1, message = "#Custom_DividingLine"})

		-- 发牌
		Draw:DealCards(tPlayerIDs)

		for playerID, goldCreeps in pairs(self.PlayerGoldCreeps) do
			self.PlayerGoldCreeps[playerID] = {}
		end
	end
end
-- 肉山事件
function public:RoshanEvent()
	--EmitGlobalSound("Round.Roshan.Start")
	self.bRoshanRound = true
	EmitGlobalSound("Round.Roshan.Battle")
	local replay_1 = ROSHAN_COUNTDOWN_TIME - 40
	local replay_2 = ROSHAN_COUNTDOWN_TIME - 80
	local remind_30 = ROSHAN_COUNTDOWN_TIME - 30
	local remind_15 = ROSHAN_COUNTDOWN_TIME - 15
	local remind_10 = ROSHAN_COUNTDOWN_TIME - 10
	local remind_05 = ROSHAN_COUNTDOWN_TIME - 5
	local time = 0
	GameRules:GetGameModeEntity():GameTimer(0, function()
		if time < ROSHAN_COUNTDOWN_TIME then
			CustomNetTables:SetTableValue("common", "roshan_time_remaining", {time=ROSHAN_COUNTDOWN_TIME-time})
			if time == replay_1 then
				EmitGlobalSound("Round.Roshan.Battle")
			elseif time == replay_2 then
				EmitGlobalSound("Round.Roshan.Battle")
			elseif time == remind_30 then
				EmitGlobalSound("Round.Roshan.TimerSec30")
			elseif time == remind_15 then
				EmitGlobalSound("Round.Roshan.TimerSec15")
			elseif time == remind_10 then
				EmitGlobalSound("Round.Roshan.TimerSec10")
			elseif time == remind_05 then
				EmitGlobalSound("Round.Roshan.TimerSec05")
			end
			time = time + 1
			return 1
		else
			EmitGlobalSound("Round.Roshan.End")
			EmitGlobalSound("Round.Roshan.TimerOut")
			local difficulty = GameMode:GetDifficulty()
			if DIFFICULTY_SETTINGS.HAS_ENDLESS[difficulty] == 1 then
				CustomNetTables:SetTableValue("common", "endless_notification", {duration=60})
			end
			self.bRoshanRound = false
		end
	end)
end

-- 道具：炸弹
function public:PropBomb(vPosition, hAbility)
	local hHero = hAbility:GetCaster()
	local iKillCount = hAbility:GetSpecialValueFor("kill_count")
	local iPlayerID = hHero:GetPlayerOwnerID()

	local playerMissing = {}
	for iPlayerID, missing in pairs(self.PlayerMissing) do
		playerMissing[iPlayerID] = {}
		for k, unit in pairs(missing) do
			playerMissing[iPlayerID][k] = unit
		end
	end

	for i = iKillCount, 1, -1 do
		local bHasUnit = false
		for k, v in pairs(playerMissing) do
			if #v > 0 then
				bHasUnit = true
			end
		end
		if not bHasUnit then
			break
		end
		local tMissing = playerMissing[iPlayerID]
		while #tMissing == 0 do
			tMissing = RandomValue(playerMissing)
		end

		local hUnit = GetRandomElement(tMissing)
		ArrayRemove(tMissing, hUnit)
		if IsValid(hUnit) then
			local tInfo = {
				Ability = hAbility,
				EffectName = "particles/builder_bomb_fireworksrockets_single.vpcf",
				vSourceLoc = vPosition,
				iMoveSpeed = 1500,
				Target = hUnit,
			}
			ProjectileManager:CreateTrackingProjectile(tInfo)
		end
	end
end

--[[
	监听
]]--
function public:OnUnitKilled(events)
	local unit = EntIndexToHScript(events.entindex_killed)
	local attacker = EntIndexToHScript(events.entindex_attacker)

	if unit and unit:HasModifier("modifier_wave") and not unit:HasModifier("modifier_wave_gold") then
		local playerID = unit.Spawner_spawnerPlayerID
		local deathXP = unit.deathXP
		local heroes = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, XP_RANGE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS+DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, 0, false)
		for i = #heroes, 1, -1 do
			if not heroes[i]:HasModifier("modifier_building") or heroes[i].GetBuilding == nil or not heroes[i]:GetBuilding():IsHero() then
				table.remove(heroes, i)
			end
		end
		local n = #heroes
		for i, hero in pairs(heroes) do
			local hBuilding = hero:GetBuilding()
			if hBuilding then
				hBuilding:AddXP(math.ceil(deathXP/n))
			end
		end

		ArrayRemove(self.PlayerMissing[playerID], unit)
		FireGameEvent("custom_missing_count_change", {MissingCount = self:GetPlayerMissingCount(playerID), PlayerID=playerID})
		self:UpdateNetTables()

		if unit:GetUnitName() == "wave_55" then
			self.iRoshanKills = self.iRoshanKills + 1
			-- 肉山击杀通知
			local gameEvent = {}
			gameEvent["player_id"] = playerID
			gameEvent["int_value"] = GameRules:GetGameTime() - self.NextRoundTime + ROSHAN_COUNTDOWN_TIME
			gameEvent["teamnumber"] = -1
			gameEvent["message"] = "#Custom_KillRoshan"
			Notification:Combat(gameEvent)
		end
	end

	if unit:HasModifier("modifier_wave_gold") then
		self:CheckGoldCreeps()
	end

	-- 玩家死亡
	if unit:IsRealHero() and unit:HasModifier("modifier_builder") then
		local playerID = unit:GetPlayerOwnerID()

		for k, v in pairs(self.PlayerMissing[playerID]) do
			v:RemoveModifierByName("modifier_wave")
			v:ForceKill(false)
			v:RemoveSelf()
		end
		self.PlayerMissing[playerID] = {}
		FireGameEvent("custom_missing_count_change", {MissingCount = self:GetPlayerMissingCount(playerID), PlayerID=playerID})
		self:UpdateNetTables()

		for k, v in pairs(self.PlayerGoldCreeps[playerID]) do
			v:RemoveModifierByName("modifier_wave")
			v:ForceKill(false)
			v:RemoveSelf()
		end
		self.PlayerGoldCreeps[playerID] = {}
	end
end
function public:OnEntityHurt(events)
	local unit = EntIndexToHScript(events.entindex_killed)
	local attacker = EntIndexToHScript(events.entindex_attacker)
	local damage = events.damage

	if unit:HasModifier("modifier_wave_gold") then
		unit.totalDamage = (unit.totalDamage or 0) + damage
	end

	if unit:GetUnitName() == "wave_55" then
		local iPlayerID = unit.Spawner_spawnerPlayerID
		FireGameEvent("custom_roshan_health_change", {CurrentHealth = unit:GetHealth(), MaxHealth = unit:GetMaxHealth(), PlayerID=iPlayerID})
	end
end
function public:OnGameRulesStateChange()
	local state = GameRules:State_Get()

	if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		DotaTD:EachPlayer(function(n, playerID)
			self.PlayerMissing[playerID] = {}
			self.PlayerGoldCreeps[playerID] = {}
		end)

		self:StartRoundTimer()
	end
end

function public:OnNPCFirstSpawned(events)
	local spawnedUnit = EntIndexToHScript( events.entindex )
	if spawnedUnit == nil then return end

	if spawnedUnit:GetUnitName() == "wave_gold" then
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_wave_gold", nil)
	end

	if spawnedUnit:GetUnitName() == "wave_55" then
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_wave_roshan", nil)
	end
end

return public