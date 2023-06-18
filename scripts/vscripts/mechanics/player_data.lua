
if PlayerData== nil then
	PlayerData = class({})
end
local public = PlayerData

-- DPS_COUNT_SECOND = 5
UI_INTERVAL = 0.5

--这个大写的值实际上不是常量  每秒往前计算  由游戏时间整除上面的DPS计算时间得到
-- CURRENT_SECOND = 0

function public:init(bReload)
	if not bReload then
		self.playerDatas = {}
		self.playerRoundDamage = {}
	end

	GameEvent("entity_hurt", Dynamic_Wrap(public, "OnEntityHurt"), public)
	GameEvent("entity_killed", Dynamic_Wrap(public, "OnEntityKilled"), public)
	GameEvent("game_rules_state_change", Dynamic_Wrap(public, "OnGameRulesStateChange"), public)
	GameEvent("custom_missing_count_change", Dynamic_Wrap(public, "OnMissingCountChange"), public)
	GameEvent("custom_round_changed", Dynamic_Wrap(public, "OnRoundChanged"), public)
	GameEvent("custom_roshan_health_change", Dynamic_Wrap(public, "OnRoshanHealthChange"), public)

	self:UpdateNetTables()
end


function public:UpdateNetTables()
	-- 肉山血条
	if Spawner:IsRoshanRound() then
		return
	end

	local state = GameRules:State_Get()
	if state >= DOTA_GAMERULES_STATE_PRE_GAME then
		local iCountingMode = GameMode:GetCountingMode()

		if iCountingMode == COUNTING_MODE_PERSONAL then
			DotaTD:EachPlayer(function(n, iPlayerID)
				local iMissingCount = self.playerDatas[iPlayerID].statisticalMissing
				local iMaxMissingCount = PLAYER_MAX_MISSING_COUNT[0]
				local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
				if hHero:IsAlive() and (iMissingCount >= iMaxMissingCount and not self.playerDatas[iPlayerID].is_warning) then
					self.playerDatas[iPlayerID].is_warning = true
					self.playerDatas[iPlayerID].warning_time = GameRules:GetGameTime() + WARNING_TIME
					hHero:SetContextThink("MissingCount", function()
						if GameRules:GetGameTime() >= self.playerDatas[iPlayerID].warning_time then
							DotaTD:MakePlayerLose(hHero)
							return nil
						end
						return 0
					end, 0)
				elseif not hHero:IsAlive() or (iMissingCount < iMaxMissingCount and self.playerDatas[iPlayerID].is_warning) then
					self.playerDatas[iPlayerID].is_warning = false
					self.playerDatas[iPlayerID].warning_time = -1
					hHero:SetContextThink("MissingCount", nil, 0)
				end
			end)
		elseif iCountingMode == COUNTING_MODE_TEAM then
			local iMissingCount = 0
			local iPlayerCount = 0

			DotaTD:EachPlayer(function(n, iPlayerID)
				iMissingCount = iMissingCount + self.playerDatas[iPlayerID].missingCount
				local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
				if IsValid(hHero) and hHero:IsAlive() then
					iPlayerCount = iPlayerCount + 1
				end
			end)

			local iMaxMissingCount = PLAYER_MAX_MISSING_COUNT[iPlayerCount]

			DotaTD:EachPlayer(function(n, iPlayerID)
				local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
				if iMissingCount >= iMaxMissingCount and not self.playerDatas[iPlayerID].is_warning then
					self.playerDatas[iPlayerID].is_warning = true
					self.playerDatas[iPlayerID].warning_time = GameRules:GetGameTime() + WARNING_TIME
					hHero:SetContextThink("MissingCount", function()
						if GameRules:GetGameTime() >= self.playerDatas[iPlayerID].warning_time then
							DotaTD:Defeat()
							return nil
						end
						return 0
					end, 0)
				elseif iMissingCount < iMaxMissingCount and self.playerDatas[iPlayerID].is_warning then
					self.playerDatas[iPlayerID].is_warning = false
					self.playerDatas[iPlayerID].warning_time = 0
					hHero:SetContextThink("MissingCount", nil, 0)
				end
			end)
		end
	end

	CustomNetTables:SetTableValue("player_data", "player_datas", self.playerDatas)
end

function public:SetCrystal(iPlayerID, iCrystal)
	self.playerDatas[iPlayerID].crystal = iCrystal
end

function public:ModifyCrystal(iPlayerID, iCrystal)
	self.playerDatas[iPlayerID].crystal = self.playerDatas[iPlayerID].crystal + iCrystal
end

function public:GetCrystal(iPlayerID)
	return self.playerDatas[iPlayerID].crystal
end

function public:SetExtraGold(iPlayerID, iExtraGold)
	self.playerDatas[iPlayerID].extra_gold = iExtraGold
end

function public:ModifyExtraGold(iPlayerID, iExtraGold)
	self.playerDatas[iPlayerID].extra_gold = self.playerDatas[iPlayerID].extra_gold + iExtraGold
end

function public:GetExtraGold(iPlayerID)
	return self.playerDatas[iPlayerID].extra_gold
end

function public:CreateLineupTable(hBuilding)
	local hUnit = hBuilding:GetUnitEntity()
	local tHeroes = {}

	tHeroes.name = hUnit:GetUnitName() -- 名字
	tHeroes.build_round = hBuilding:GetBuildRound() -- 建造回合
	tHeroes.damage = hBuilding:GetTotalDamage() -- 伤害

	local tItems = {}
	local iItemWorth = 0
	for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9, 1 do
		local hItem = hUnit:GetItemInSlot(i)
		local sItemName = ""
		if IsValid(hItem) then
			sItemName = hItem:GetName()
			iItemWorth = iItemWorth + GetItemCost(hItem:GetName())
		end
		tItems[i] = sItemName
	end
	tHeroes.items = tItems -- 物品列表
	tHeroes.item_worth = iItemWorth -- 物品价值

	-- 特殊modifier记录
	local tSpecial = {}
	for _, sModifierName in pairs(KeyValues.PermanentModifiersKv) do
		local hModifier = hUnit:FindModifierByName(sModifierName)
		if IsValid(hModifier) and hModifier:GetStackCount() > 0 then
			tSpecial[sModifierName] = hModifier:GetStackCount()
		end
	end
	tHeroes.special = tSpecial

	return tHeroes
end

function public:SaveLineup(iPlayerID)
	local tStatistics = self.playerDatas[iPlayerID].statistics

	tStatistics.heroes = {}
	tStatistics.nonheroes = {}
	BuildSystem:EachBuilding(iPlayerID,function(hBuilding)
		if hBuilding:IsHero() then
			local tHeroes = self:CreateLineupTable(hBuilding)
			table.insert(tStatistics.heroes, tHeroes)
		else
			local tNonheroes = self:CreateLineupTable(hBuilding)
			table.insert(tStatistics.nonheroes, tNonheroes)
		end
	end)

	local funcSort = function(a, b)
		return a.build_round < b.build_round
	end

	table.sort(tStatistics.heroes, funcSort)
	table.sort(tStatistics.nonheroes, funcSort)
end

--[[
	监听
]]--
function public:OnGameRulesStateChange()
	local state = GameRules:State_Get()

	if state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		local tEnts = {
			Entities:FindByName(nil, "player_avatar_0"),
			Entities:FindByName(nil, "player_avatar_1"),
			Entities:FindByName(nil, "player_avatar_2"),
			Entities:FindByName(nil, "player_avatar_3"),
		}
		for n, hEnt in pairs(tEnts) do
			hEnt:AddCSSClasses("player_position_"..n)
			hEnt:IgnoreUserInput()
		end
	
		DotaTD:EachPlayer(function(n, iPlayerID)
			local vPosition = tEnts[n]:GetAbsOrigin()
			-- 初始化玩家数据
			self.playerDatas[iPlayerID] = {
				playerPosition_x = vPosition.x,
				playerPosition_y = vPosition.y,
				playerPosition_z = vPosition.z,
				playerPositionNumber = n,
				
				extra_gold = 0,
				kills = 0,
				missingCount = 0,
				statisticalMissing = 0,
				crystal = 0,
				is_warning = false,
				warning_time = -1,

				statistics = {
					gold = 0,
					wave_gold = 0,
					damage = 0.0,
					crystal = 0,
					end_round = 0,
					end_round_wave_name = "",
					end_round_title = "",
					end_round_description = "",
					is_endless = false,
					heroes = {
						-- [1] = {
						-- 	name = "",
						-- 	items = [],
						-- 	item_worth = 0.0,
						-- 	build_round = 0,
						-- 	damage = 0.0,
						-- 	special = {
						-- 		k = v,
						-- 	}
						-- },
					},
					nonheroes = {},

					-- 未处理
					time_kill_roshan = 0.0,
					gold_draw_card = 0,
				}
			}
			self.playerRoundDamage[iPlayerID] = {}
		end)

		self:UpdateNetTables()

		GameRules:GetGameModeEntity():GameTimer(UI_INTERVAL, function()
			self:UpdateNetTables()
			return UI_INTERVAL
		end)
	end
end

function public:OnEntityHurt(events)
	local hVictim = EntIndexToHScript(events.entindex_killed)
	local hAttacker = EntIndexToHScript(events.entindex_attacker)

	if IsValid(hAttacker) then
		local damage = events.damage
		local iPlayerID = hAttacker:GetPlayerOwnerID()

		if PlayerResource:IsValidPlayerID(iPlayerID) then
			local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
			if hAttacker:IsSummoned() then
				hAttacker = IsValid(hAttacker:GetSummoner()) and hAttacker:GetSummoner() or hAttacker
			end
			if hHero ~= hAttacker then
				-- 伤害
				self.playerDatas[iPlayerID].statistics.damage = self.playerDatas[iPlayerID].statistics.damage + damage
				-- self:UpdateNetTables()

				if hAttacker:IsBuilding() and hAttacker.GetBuilding ~= nil then
					local hBuilding = hAttacker:GetBuilding()
					local tRoundDamage = self.playerRoundDamage[iPlayerID]
					local iIndex = #tRoundDamage
					tRoundDamage[iIndex][hBuilding:GetUnitEntityName()] = (tRoundDamage[iIndex][hBuilding:GetUnitEntityName()] or 0) + damage
					hBuilding:ModifyTotalDamage(damage)
				end
			end

			if hVictim:HasModifier("modifier_wave_gold") then
				self.playerDatas[iPlayerID].statistics.wave_gold = self.playerDatas[iPlayerID].statistics.wave_gold + damage
			end

		end
	end
end

function public:OnEntityKilled(events)
	local hVictim = EntIndexToHScript(events.entindex_killed)
	local hAttacker = EntIndexToHScript(events.entindex_attacker)

	if IsValid(hAttacker) and IsValid(hVictim) and (hAttacker ~= hVictim) then
		local iPlayerID = hAttacker:GetPlayerOwnerID()
		if PlayerResource:IsValidPlayerID(iPlayerID) then
			-- 统计漏怪
			if hVictim:HasModifier("modifier_wave") then
				local count = hVictim:IsConsideredHero() and 5 or 1
				self.playerDatas[iPlayerID].statisticalMissing = math.max(self.playerDatas[iPlayerID].statisticalMissing - count, 0)
			end
			-- 击杀
			local factor = hVictim:IsConsideredHero() and 5 or 1
			self.playerDatas[iPlayerID].kills = self.playerDatas[iPlayerID].kills + factor
			
			-- 掉落水晶
			if not hVictim:IsSummoned() and RollPercentage(CRYSTAL_DROP_CHANCE) then
				local fAmount = CRYSTAL_DROP_AMOUNT
				self.playerDatas[iPlayerID].crystal = self.playerDatas[iPlayerID].crystal + fAmount

				self.playerDatas[iPlayerID].statistics.crystal = self.playerDatas[iPlayerID].statistics.crystal + fAmount

				-- 掉落特效
				local hPlayer = PlayerResource:GetPlayer(iPlayerID)
				if hPlayer ~= nil then
					local iParticleID = ParticleManager:CreateParticleForPlayer("particles/generic_gameplay/lasthit_crystal_local.vpcf", PATTACH_CUSTOMORIGIN, nil, hPlayer)
					ParticleManager:SetParticleControlEnt(iParticleID, 1, hVictim, PATTACH_CUSTOMORIGIN_FOLLOW, nil, hVictim:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(iParticleID)

					local vColor = Vector(158, 188, 186)
					local fDuration = 2
					local iNumber = math.ceil(fAmount)
					local iParticleID = ParticleManager:CreateParticleForPlayer("particles/msg_fx/msg_goldbounty.vpcf", PATTACH_CUSTOMORIGIN, nil, hPlayer)
					ParticleManager:SetParticleControlEnt(iParticleID, 0, hVictim, PATTACH_OVERHEAD_FOLLOW, nil, hVictim:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(iParticleID, 1, Vector(0, iNumber, 0))
					ParticleManager:SetParticleControl(iParticleID, 2, Vector(fDuration, #tostring(iNumber)+1, 0))
					ParticleManager:SetParticleControl(iParticleID, 3, vColor)
					ParticleManager:ReleaseParticleIndex(iParticleID)
				end
			end
		end
	end
end

function public:OnMissingCountChange(events)
	local iPlayerID = events.PlayerID
	local iMissingCount = events.MissingCount


	local iChanged = iMissingCount - self.playerDatas[iPlayerID].missingCount

	-- 统计漏怪
	if iChanged > 0 then
		self.playerDatas[iPlayerID].statisticalMissing = self.playerDatas[iPlayerID].statisticalMissing + iChanged
	end
	-- 漏怪
	self.playerDatas[iPlayerID].missingCount = iMissingCount
end

function public:OnRoundChanged(events)

	DotaTD:EachPlayer(function(n, iPlayerID)
		if #self.playerRoundDamage[iPlayerID] > 0 then
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(iPlayerID), "show_round_damage", self.playerRoundDamage[iPlayerID][#self.playerRoundDamage[iPlayerID]])
		end
	end)

	DotaTD:EachPlayer(function(n, iPlayerID)
		local iIndex = #self.playerRoundDamage[iPlayerID] + 1
		self.playerRoundDamage[iPlayerID][iIndex] = {}
	end)
end

function public:OnRoshanHealthChange(events)
	-- 肉山血条
	if not Spawner:IsRoshanRound() then
		return
	end
	local iPlayerID = events.PlayerID
	local CurrentHealth = events.CurrentHealth
	local MaxHealth = events.MaxHealth
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(iPlayerID)), "roshan_health_change", {CurrentHealth=CurrentHealth, MaxHealth=MaxHealth})
end

return public