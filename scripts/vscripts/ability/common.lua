function Save(table, key, value)
    if type(table) ~= "table" then return end
    table.abilitydata = table.abilitydata or {}
    table.abilitydata[key] = value
end
function Load(table, key)
    if type(table) ~= "table" then return end
    table.abilitydata = table.abilitydata or {}
    return table.abilitydata[key]
end
if TABLE == nil then TABLE = {} end
function SaveByPlayerID(playerID, key, value)
    if TABLE[playerID] == nil then TABLE[playerID] = {} end
    TABLE[playerID][key] = value
end
function LoadByPlayerID(playerID, key)
    if TABLE[playerID] == nil then TABLE[playerID] = {} end
    return TABLE[playerID][key]
end
-- CDOTA_Buff
function CDOTA_Buff:CanRefresh()
    local ability = self:GetAbility()
    return IsValid(ability) and not ability.bNoRefresh
end
function CDOTA_Buff:GetAbilitySpecialValueFor(szName)
    local ability = self:GetAbility()
    if not IsValid(ability) then
        return self[szName] or 0
    end
    return ability:GetSpecialValueFor(szName)
end
function CDOTA_Buff:GetAbilityLevel()
    local ability = self:GetAbility()
    if not IsValid(ability) then
        return 0
    end
    return ability:GetLevel()
end
-- -- 技能冷却
-- function SetCooldownReduction(hUnit, fPercentage, key)
-- 	if hUnit.cooldownReductions == nil then hUnit.cooldownReductions = {} end
-- 	key = key or DoUniqueString("CooldownReduction")
-- 	hUnit.cooldownReductions[key] = fPercentage
-- 	if IsServer() then
-- 		hUnit:RemoveModifierByName("modifier_cooldown_reduction")
-- 		local hModifier = hUnit:AddNewModifier(hUnit, nil, "modifier_cooldown_reduction", nil)
-- 		if hModifier then
-- 			hModifier:SetDuration(GetCooldownReduction(hUnit), true)
-- 		end
-- 	end
-- 	return key
-- end
-- function GetCooldownReduction(hUnit)
-- 	if hUnit.cooldownReductions == nil then hUnit.cooldownReductions = {} end
-- 	local fValue = 0
-- 	for key, v in pairs(hUnit.cooldownReductions) do
-- 		fValue = 1-(1-fValue)*math.max(1-v*0.01, 0)
-- 	end
-- 	return fValue*100
-- end
-- -- 技能暴击
-- function SetSpellCriticalStrike(unit, chance, damage, key)
-- 	if unit.spellCriticalStrikes == nil then unit.spellCriticalStrikes = {} end
-- 	key = key or DoUniqueString("SpellCriticalStrike")
-- 	if chance == nil or chance <= 0 then
-- 		unit.spellCriticalStrikes[key] = nil
-- 	else
-- 		unit.spellCriticalStrikes[key] = {
-- 			spell_crit_chance = chance,
-- 			spell_crit_damage = damage,
-- 		}
-- 	end
-- 	return key
-- end
-- function GetSpellCriticalStrike(unit)
-- 	if unit.spellCriticalStrikes == nil then unit.spellCriticalStrikes = {} end
-- 	local crit_damage = 0
-- 	for key, data in pairs(unit.spellCriticalStrikes) do
-- 		if PRD(unit, data.spell_crit_chance, key) then
-- 			crit_damage = math.max(crit_damage, data.spell_crit_damage)
-- 		end
-- 	end
-- 	return crit_damage
-- end
-- -- 技能暴击额外百分比
-- function SetSpellCriticalStrikeDamage(unit, value, key)
-- 	if unit.spellCriticalStrikeDamage == nil then unit.spellCriticalStrikeDamage = {} end
-- 	key = key or DoUniqueString("SpellCriticalStrikeDamage")
-- 	unit.spellCriticalStrikeDamage[key] = value
-- 	return key
-- end
-- function GetSpellCriticalStrikeDamage(unit)
-- 	if unit.spellCriticalStrikeDamage == nil then unit.spellCriticalStrikeDamage = {} end
-- 	local value = 0
-- 	for key, v in pairs(unit.spellCriticalStrikeDamage) do
-- 		value = value + v
-- 	end
-- 	return value
-- end
-- -- 暴击额外百分比
-- function SetCriticalStrikeDamage(unit, value, key)
-- 	if unit.criticalStrikeDamage == nil then unit.criticalStrikeDamage = {} end
-- 	key = key or DoUniqueString("CriticalStrikeDamage")
-- 	unit.criticalStrikeDamage[key] = value
-- 	return key
-- end
-- function GetCriticalStrikeDamage(unit)
-- 	if unit.criticalStrikeDamage == nil then unit.criticalStrikeDamage = {} end
-- 	local value = 0
-- 	for key, v in pairs(unit.criticalStrikeDamage) do
-- 		value = value + v
-- 	end
-- 	return value
-- end
-- 无视魔抗
function SetIgnoreMagicResistanceValue(unit, value, key)
    if unit.ignoreMagicResistanceValues == nil then unit.ignoreMagicResistanceValues = {} end
    key = key or DoUniqueString("IgnoreMagicResistanceValue")
    unit.ignoreMagicResistanceValues[key] = value
    return key
end
function GetIgnoreMagicResistanceValue(unit)
    if unit.ignoreMagicResistanceValues == nil then unit.ignoreMagicResistanceValues = {} end
    local value = 0
    for key, v in pairs(unit.ignoreMagicResistanceValues) do
        value = 1 - (1 - value) * (1 - v)
    end
    return value
end
-- 某种类型伤害增加（DAMAGE_TYPE_NONE为所有类型伤害增加）
function SetOutgoingDamagePercent(unit, damage_type, percent, key)
    if unit.outgoingDamagePercents == nil then unit.outgoingDamagePercents = {} end
    if unit.outgoingDamagePercents[damage_type] == nil then unit.outgoingDamagePercents[damage_type] = {} end
    key = key or DoUniqueString("OutgoingDamagePercent")
    unit.outgoingDamagePercents[damage_type][key] = percent
    if IsServer() then
        unit:RemoveModifierByName("modifier_physical_damage_percent")
        local physical_modifier = unit:AddNewModifier(unit, nil, "modifier_physical_damage_percent", nil)
        if physical_modifier then
            physical_modifier:SetDuration((GetOutgoingDamagePercent(unit, DAMAGE_TYPE_PHYSICAL) - 100), true)
        end
        unit:RemoveModifierByName("modifier_magical_damage_percent")
        local magical_modifier = unit:AddNewModifier(unit, nil, "modifier_magical_damage_percent", nil)
        if magical_modifier then
            magical_modifier:SetDuration((GetOutgoingDamagePercent(unit, DAMAGE_TYPE_MAGICAL) - 100), true)
        end
    end
    return key
end
function GetOutgoingDamagePercent(unit, damage_type)
    if unit.outgoingDamagePercents == nil then unit.outgoingDamagePercents = {} end
    if unit.outgoingDamagePercents[damage_type] == nil then unit.outgoingDamagePercents[damage_type] = {} end
    local value = 100
    for key, v in pairs(unit.outgoingDamagePercents[damage_type]) do
        value = value * math.max(1 + v * 0.01, 0)
    end
    return value
end
-- -- 技能冷却
-- function SetStatusResistance(hUnit, fValue, key)
-- 	if hUnit.statusResistances == nil then hUnit.statusResistances = {} end
-- 	key = key or DoUniqueString("StatusResistance")
-- 	hUnit.statusResistances[key] = fValue
-- 	if IsServer() then
-- 		hUnit:RemoveModifierByName("modifier_status_resistance")
-- 		local hModifier = hUnit:AddNewModifier(hUnit, nil, "modifier_status_resistance", nil)
-- 		if hModifier then
-- 			hModifier:SetDuration(GetStatusResistance(hUnit), true)
-- 		end
-- 	end
-- 	return key
-- end
-- function GetStatusResistance(hUnit)
-- 	if hUnit.statusResistances == nil then hUnit.statusResistances = {} end
-- 	local fValue = 0
-- 	for key, v in pairs(hUnit.statusResistances) do
-- 		fValue = 1-(1-fValue)*math.max(1-v, 0)
-- 	end
-- 	return fValue
-- end
function AddModifierEvents(modifier_event, modifier, hUnit)
    if hUnit ~= nil then
        if hUnit.tModifierEvents == nil then
            hUnit.tModifierEvents = {}
        end
        if hUnit.tModifierEvents[modifier_event] == nil then
            hUnit.tModifierEvents[modifier_event] = {}
        end
        table.insert(hUnit.tModifierEvents[modifier_event], modifier)
        return #(hUnit.tModifierEvents[modifier_event])
    else
        if _G.tModifierEvents == nil then
            _G.tModifierEvents = {}
        end
        if tModifierEvents[modifier_event] == nil then
            tModifierEvents[modifier_event] = {}
        end
        table.insert(tModifierEvents[modifier_event], modifier)
        return #tModifierEvents[modifier_event]
    end
end
function RemoveModifierEvents(modifier_event, modifier, hUnit)
    if hUnit ~= nil then
        if hUnit.tModifierEvents == nil then
            hUnit.tModifierEvents = {}
        end
        if hUnit.tModifierEvents[modifier_event] == nil then
            hUnit.tModifierEvents[modifier_event] = {}
        end
        ArrayRemove(hUnit.tModifierEvents[modifier_event], modifier)
    else
        if _G.tModifierEvents == nil then
            _G.tModifierEvents = {}
        end
        if tModifierEvents[modifier_event] == nil then
            tModifierEvents[modifier_event] = {}
        end
        ArrayRemove(tModifierEvents[modifier_event], modifier)
    end
end
-- if IsClient() then
-- 	_G.DAMAGE_TYPE_ALL = 7
-- 	_G.DAMAGE_TYPE_HP_REMOVAL = 8
-- 	_G.DAMAGE_TYPE_MAGICAL = 2
-- 	_G.DAMAGE_TYPE_NONE = 0
-- 	_G.DAMAGE_TYPE_PHYSICAL = 1
-- 	_G.DAMAGE_TYPE_PURE = 4
-- 	function C_DOTA_BaseNPC:GetPrimaryAttribute()
--         if self:HasModifier("modifier_primary_attribute") then
--             return self:GetModifierStackCount("modifier_primary_attribute", self)
--         end
--         return DOTA_ATTRIBUTE_INVALID
-- 	end
--     function C_DOTA_BaseNPC:GetStrength()
-- 		return self:GetModifierStackCount("modifier_strength", self)
-- 	end
-- 	function C_DOTA_BaseNPC:GetAgility()
-- 		return self:GetModifierStackCount("modifier_agility", self)
-- 	end
-- 	function C_DOTA_BaseNPC:GetIntellect()
-- 		return self:GetModifierStackCount("modifier_intellect", self)
-- 	end
-- 	function C_DOTA_BaseNPC:GetCastRangeBonus()
-- 		local bonus = 0
-- 		return bonus
-- 	end
-- 	function C_DOTA_BaseNPC:GetStatusResistanceFactor()
-- 		return 1 - GetStatusResistance(self)
-- 	end
-- end
-- if IsServer() then
-- 	--[[d 
-- 		在范围内搜素拥有Modifier的单位的单位组
-- 	]]--
-- 	function FindUnitsInRadiusByModifierName(sModifierName, iTeamNumber, vPosition, fRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder)
-- 		local tUnits = FindUnitsInRadius(iTeamNumber, vPosition, nil, fRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, false)
-- 		for i = #tUnits, 1, -1 do
-- 			local hUnit = tUnits[i]
-- 			if not hUnit:HasModifier(sModifierName) then
-- 				table.remove(tUnits, i)
-- 			end
-- 		end
-- 		return tUnits
-- 	end
-- 	--[[d 
-- 		中毒效果
-- 		hCaster -- 施法者
-- 		hAbility -- 技能
-- 		fDPS -- 中毒伤害
-- 		fDuration -- 持续时间
-- 	]]--
-- 	function CDOTA_BaseNPC:Poisoning(hCaster, hAbility, fDPS, fDuration)
-- 		local tModifiers = self:FindAllModifiersByName("modifier_poisoning")
-- 		local fInterval
-- 		for _, hModifier in pairs(tModifiers) do
-- 			if hModifier:GetAbility():GetAbilityName() == hAbility:GetAbilityName() then
-- 				fDPS = fDPS + (hModifier.fDPS or 0)
-- 				fInterval = math.max(hModifier.fTime - GameRules:GetGameTime(), 0)
-- 				hModifier:Destroy()
-- 			else
-- 				hModifier:SetDuration(fDuration, true)
-- 			end
-- 		end
-- 		self:AddNewModifier(hCaster, hAbility, "modifier_poisoning", {
-- 			fDPS = fDPS,
-- 			fInterval = fInterval,
-- 			duration = fDuration,
-- 		})
-- 	end
-- 	--[[d 
-- 		流血效果
-- 		hCaster -- 施法者
-- 		hAbility -- 技能
-- 		funcDamgeCallback -- 伤害回调函数，参量(hUnit)，返回number，每移动触发距离后会调用一次该函数获取伤害值
-- 		iDamageType -- 伤害类型
-- 		fDuration -- 持续时间
-- 		fTriggerDistance -- 选填，触发移动距离，不填默认100
-- 	]]--
-- 	function CDOTA_BaseNPC:Bleeding(hCaster, hAbility, funcDamgeCallback, iDamageType, fDuration, fTriggerDistance)
-- 		local tModifiers = self:FindAllModifiersByName("modifier_bleeding")
-- 		local vLastPosition
-- 		local fDistance
-- 		for _, hModifier in pairs(tModifiers) do
-- 			if hModifier:GetAbility():GetAbilityName() == hAbility:GetAbilityName() then
-- 				vLastPosition = hModifier.vLastPosition
-- 				fDistance = hModifier.fDistance
-- 				hModifier:Destroy()
-- 				break
-- 			end
-- 		end
-- 		local hModifier = self:AddNewModifier(hCaster, hAbility, "modifier_bleeding", {
-- 			iDamageType = iDamageType,
-- 			vLastPosition = vLastPosition,
-- 			fDistance = fDistance,
-- 			fTriggerDistance = fTriggerDistance,
-- 			duration = fDuration,
-- 		})
-- 		if IsValid(hModifier) then
-- 			hModifier.funcDamgeCallback = funcDamgeCallback
-- 		end
-- 	end
-- 	function CDOTA_BaseNPC:IsAbilityReady(ability)
-- 		local behavior = ability:GetBehavior()
-- 		if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE) ~= DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE and self:IsStunned() then
-- 			return false
-- 		end
-- 		if self:IsSilenced() or self:IsHexed() or self:IsCommandRestricted() then
-- 			return false
-- 		end
-- 		if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL) ~= DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL and self:IsChanneling() then
-- 			return false
-- 		end
-- 		if not ability:IsActivated() then
-- 			return false
-- 		end
-- 		if not ability:IsCooldownReady() then
-- 			return false
-- 		end
-- 		if not ability:IsOwnersGoldEnough(self:GetPlayerOwnerID()) then
-- 			return false
-- 		end
-- 		-- 灵魂之戒使用
-- 		if ability:GetManaCost(-1) > 0 then
-- 			if self:HasItemInInventory("item_soul_ring_custom") then
-- 				for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
-- 					local item = self:GetItemInSlot(i)
-- 					if item ~= nil and item:GetName() == "item_soul_ring_custom" and item:IsFullyCastable() then
-- 						ExecuteOrderFromTable({
-- 							UnitIndex = self:entindex(),
-- 							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
-- 							AbilityIndex = item:entindex(),
-- 						})
-- 						break
-- 					end
-- 				end
-- 			end
-- 		end
-- 		if not ability:IsOwnersManaEnough() then
-- 			return false
-- 		end
-- 		return ability:IsFullyCastable()
-- 	end
-- 	ATTACK_STATE_NOT_USECASTATTACKORB = 1 -- 不触发攻击法球
-- 	ATTACK_STATE_NOT_PROCESSPROCS = 2 -- 不触发攻击特效
-- 	ATTACK_STATE_SKIPCOOLDOWN = 8 -- 无视攻击间隔
-- 	ATTACK_STATE_IGNOREINVIS = 16 -- 不触发破影一击
-- 	ATTACK_STATE_NOT_USEPROJECTILE = 32 -- 没有攻击弹道
-- 	ATTACK_STATE_FAKEATTACK = 64 -- 假攻击
-- 	ATTACK_STATE_NEVERMISS = 128 -- 攻击不会丢失
-- 	ATTACK_STATE_NO_CLEAVE = 256 -- 没有分裂攻击
-- 	ATTACK_STATE_NO_EXTENDATTACK = 512 -- 没有触发额外攻击
-- 	ATTACK_STATE_SKIPCOUNTING = 1024 -- 不减少各种攻击计数
-- 	ATTACK_STATE_CRIT = 2048 -- 暴击，暴击技能里添加，Attack里加入无效
-- 	function CDOTA_BaseNPC:Attack(hTarget, iAttackState)
-- 		local modifier = ATTACK_SYSTEM_DUMMY:AddNewModifier(ATTACK_SYSTEM_DUMMY, nil, "modifier_attack_system", {iAttacker=self:entindex(), iAttackState=iAttackState})
-- 		local bUseCastAttackOrb = (bit.band(iAttackState, ATTACK_STATE_NOT_USECASTATTACKORB) ~= ATTACK_STATE_NOT_USECASTATTACKORB)
-- 		local bProcessProcs = (bit.band(iAttackState, ATTACK_STATE_NOT_PROCESSPROCS) ~= ATTACK_STATE_NOT_PROCESSPROCS)
-- 		local bSkipCooldown = (bit.band(iAttackState, ATTACK_STATE_SKIPCOOLDOWN) == ATTACK_STATE_SKIPCOOLDOWN)
-- 		local bIgnoreInvis = (bit.band(iAttackState, ATTACK_STATE_IGNOREINVIS) == ATTACK_STATE_IGNOREINVIS)
-- 		local bUseProjectile = (bit.band(iAttackState, ATTACK_STATE_NOT_USEPROJECTILE) ~= ATTACK_STATE_NOT_USEPROJECTILE)
-- 		local bFakeAttack = (bit.band(iAttackState, ATTACK_STATE_FAKEATTACK) == ATTACK_STATE_FAKEATTACK)
-- 		local bNeverMiss = (bit.band(iAttackState, ATTACK_STATE_NEVERMISS) == ATTACK_STATE_NEVERMISS)
-- 		if not bFakeAttack and bProcessProcs and bUseCastAttackOrb then
-- 			local params = {
-- 				attacker = self,
-- 				target = hTarget,
-- 			}
-- 			if self.tModifierEvents and self.tModifierEvents[MODIFIER_EVENT_ON_ATTACK_START] then
-- 				local tModifiers = self.tModifierEvents[MODIFIER_EVENT_ON_ATTACK_START]
-- 				for i = #tModifiers, 1, -1 do
-- 					local hModifier = tModifiers[i]
-- 					if IsValid(hModifier) and hModifier.OnAttackStart_AttackSystem then
-- 						hModifier:OnAttackStart_AttackSystem(params)
-- 					end
-- 				end
-- 			end
-- 			if tModifierEvents and tModifierEvents[MODIFIER_EVENT_ON_ATTACK_START] then
-- 				local tModifiers = tModifierEvents[MODIFIER_EVENT_ON_ATTACK_START]
-- 				for i = #tModifiers, 1, -1 do
-- 					local hModifier = tModifiers[i]
-- 					if IsValid(hModifier) and hModifier.OnAttackStart_AttackSystem then
-- 						hModifier:OnAttackStart_AttackSystem(params)
-- 					end
-- 				end
-- 			end
-- 		end
-- 		self:PerformAttack(hTarget, bUseCastAttackOrb, bProcessProcs, bSkipCooldown, bIgnoreInvis, bUseProjectile, bFakeAttack, bNeverMiss)
-- 		return modifier.record
-- 	end
-- 	function CDOTA_BaseNPC:AttackFilter(iRecord, ...)
-- 		local bool = false
-- 		if self.ATTACK_SYSTEM == nil then self.ATTACK_SYSTEM = {} end
-- 		for i, iAttackState in pairs({...}) do
-- 			bool = bool or (bit.band(self.ATTACK_SYSTEM[iRecord] or 0, iAttackState) == iAttackState)
-- 		end
-- 		return bool
-- 	end
-- 	-- 在暴击效果里插入
-- 	function CDOTA_BaseNPC:Crit(iRecord)
-- 		if self.ATTACK_SYSTEM == nil then self.ATTACK_SYSTEM = {} end
-- 		if self.ATTACK_SYSTEM[iRecord] ~= nil then
-- 			if bit.band(self.ATTACK_SYSTEM[iRecord], ATTACK_STATE_CRIT) ~= ATTACK_STATE_CRIT then
-- 				self.ATTACK_SYSTEM[iRecord] = self.ATTACK_SYSTEM[iRecord] + ATTACK_STATE_CRIT
-- 			end
-- 		else
-- 			local modifier = ATTACK_SYSTEM_DUMMY:AddNewModifier(self, nil, "modifier_attack_system", {iAttacker=self:entindex(), iAttackState=ATTACK_STATE_CRIT, iRecord=iRecord})
-- 			self.ATTACK_SYSTEM[iRecord] = ATTACK_STATE_CRIT
-- 		end
-- 	end
-- 	function CDOTA_BaseNPC:GetStatusResistanceFactor()
-- 		return 1 - GetStatusResistance(self)
-- 	end
-- 	function CDOTA_BaseNPC:GetCastRangeBonus()
-- 		local bonus = 0
-- 		return bonus
-- 	end
-- 	function PfromC(c)
-- 		if c == 0 then return 1 end
-- 		local pProcOnN = 0
-- 		local pProcByN = 0
-- 		local sumNpProcOnN = 0
-- 		local maxFails = math.ceil(1/c)
-- 		for N = 1, maxFails, 1 do
--             pProcOnN = math.min(1, N*c)*(1-pProcByN)
--             pProcByN = pProcByN + pProcOnN
--             sumNpProcOnN = sumNpProcOnN + N * pProcOnN
-- 		end
-- 		return 1/sumNpProcOnN
-- 	end
-- 	function CfromP(p)
-- 		local Cupper = p
-- 		local Clower = 0
-- 		local Cmid
-- 		local p1
-- 		local p2 = 1
-- 		while true do
-- 			Cmid = (Cupper+Clower)/2
-- 			p1 = PfromC(Cmid)
-- 			if math.abs(p1 - p2) <= 0 then break end
-- 			if p1 > p then
--                 Cupper = Cmid
-- 			else
--                 Clower = Cmid
-- 			end
--             p2 = p1
-- 		end
-- 		return Cmid
-- 	end
-- 	PSEUDO_RANDOM_C = {}
-- 	for i = 0, 100 do
-- 		local C = CfromP(i*0.01)
-- 		PSEUDO_RANDOM_C[i] = C
-- 	end
-- 	function PRD_C(chance)
-- 		chance = math.max(math.min(chance, 100), 0)
-- 		return PSEUDO_RANDOM_C[math.floor(chance)]
-- 	end
-- 	function PRD(table, chance, pseudo_random_recording)
-- 		if table.PSEUDO_RANDOM_RECORDING_LIST == nil then table.PSEUDO_RANDOM_RECORDING_LIST = {} end
-- 		local N = table.PSEUDO_RANDOM_RECORDING_LIST[pseudo_random_recording] or 1
-- 		local C = PRD_C(chance)
-- 		if RandomFloat(0, 1) <= C*N then
-- 			table.PSEUDO_RANDOM_RECORDING_LIST[pseudo_random_recording] = 1
-- 			return true
-- 		end
-- 		table.PSEUDO_RANDOM_RECORDING_LIST[pseudo_random_recording] = N + 1
-- 		return false
-- 	end
-- 	function CDOTA_BaseNPC:ReplaceItem(old_item,new_item)
-- 		if type(old_item) ~= "table" then return end
-- 		if type(new_item) == "string" then
-- 			new_item = CreateItem(new_item, old_item:GetPurchaser(), old_item:GetPurchaser())
-- 		end
-- 		if type(new_item) ~= "table" then return end
-- 		new_item:SetPurchaseTime(old_item:GetPurchaseTime())
-- 		new_item:SetCurrentCharges(old_item:GetCurrentCharges())
-- 		new_item:SetItemState(old_item:GetItemState())
-- 		local index1 = 0
-- 		for index = 0, 11 do
-- 			local item = self:GetItemInSlot(index)
-- 			if item and item == old_item then
-- 				index1 = index
-- 				break
-- 			end
-- 		end
-- 		self:RemoveItem(old_item)
-- 		self:AddItem(new_item)
-- 		for index2 = 0, 11 do
-- 			local item = self:GetItemInSlot(index2)
-- 			if item and item == new_item then
-- 				self:SwapItems(index2, index1)
-- 				break
-- 			end
-- 		end
-- 		return new_item
-- 	end
-- 	function StringToVector(str)
-- 		local table = string.split(str," ")
-- 		return Vector(tonumber(table[1]),tonumber(table[2]),tonumber(table[3])) or nil
-- 	end
-- 	--[[d 
-- 		获取一定范围内单位最多的点
-- 		搜索点，搜索范围，队伍，范围，队伍过滤，类型过滤，特殊过滤
-- 	]]--
-- 	function GetMostTargetsPosition(search_position, search_radius, team_number, radius, team_filter, type_filter, flag_filter, order)
-- 		local first_targets = FindUnitsInRadius(team_number, search_position, nil, search_radius, team_filter, type_filter, flag_filter, order or FIND_ANY_ORDER, false)
-- 		local position
-- 		local max = 0
-- 		for n, first_target in pairs(first_targets) do
-- 			local second_targets = FindUnitsInRadius(team_number, first_target:GetAbsOrigin(), nil, radius, team_filter, type_filter, flag_filter, FIND_ANY_ORDER, false)
-- 			if #second_targets > max then
-- 				max = #second_targets
-- 				position = GetGroundPosition(first_target:GetAbsOrigin(), first_target)
-- 			end
-- 		end
-- 		return position
-- 	end
-- 	--[[d 
-- 		获取弹射目标
-- 		现在目标，队伍，选择位置，范围，队伍过滤，类型过滤，特殊过滤，选择方式，单位记录表，是否可以弹射回来（缺省false）
-- 	]]--
-- 	function GetBounceTarget(last_target, team_number, position, radius, team_filter, type_filter, flag_filter, order, unit_table, can_bounce_bounced_unit)
-- 		local first_targets = FindUnitsInRadius(team_number, position, nil, radius, team_filter, type_filter, flag_filter, order, false)
-- 		for i = #first_targets, 1, -1 do
-- 			local unit = first_targets[i]
-- 			if unit == last_target then
-- 				table.remove(first_targets,i)
-- 			end
-- 		end
-- 		local second_targets = {}
-- 		for k,v in pairs(first_targets) do
-- 			second_targets[k] = v
-- 		end
-- 		if unit_table and type(unit_table) == "table" then
-- 			for i = #first_targets, 1, -1 do
-- 				if TableFindKey(unit_table, first_targets[i]) then
-- 					table.remove(first_targets, i)
-- 				end
-- 			end
-- 		end
-- 		local first_target = first_targets[1]
-- 		local second_target = second_targets[1]
-- 		if can_bounce_bounced_unit ~= nil and type(can_bounce_bounced_unit) == "boolean" and can_bounce_bounced_unit == true then
-- 			return first_target or second_target
-- 		else
-- 			return first_target
-- 		end
-- 	end
-- 	ONLY_REFLECT_ABILITIES = {}
-- 	function IsAbilityOnlyReflect(ability)
-- 		if ability == nil then return false end
-- 		return TableFindKey(ONLY_REFLECT_ABILITIES, ability:GetName()) ~= nil
-- 	end
-- 	function IsReflectSpellAbility(ability)
-- 		if ability == nil then return false end
-- 		return ability:IsStolen() and ability:IsHidden()
-- 	end
-- 	function ReflectSpell(caster, target, ability)
-- 		if IsReflectSpellAbility(ability) then
-- 			return 
-- 		end
-- 		local sAbilityName = ability:GetAbilityName()
-- 		local hAbility
-- 		caster.reflectSpellAbilities = caster.reflectSpellAbilities or {max_count = 5}
-- 		for i, ab in ipairs(caster.reflectSpellAbilities) do
-- 			if ab:GetAbilityName() == sAbilityName then
-- 				hAbility = ab
-- 			end
-- 		end
-- 		if hAbility == nil then
-- 			hAbility = caster:AddAbility(sAbilityName)
-- 			table.insert(caster.reflectSpellAbilities, 1, hAbility)
-- 			if IsValid(caster.reflectSpellAbilities[caster.reflectSpellAbilities.max_count+1]) then
-- 				caster.reflectSpellAbilities[caster.reflectSpellAbilities.max_count+1]:RemoveSelf()
-- 				caster.reflectSpellAbilities[caster.reflectSpellAbilities.max_count+1] = nil
-- 			end
-- 		end
-- 		hAbility:SetStolen(true)
-- 		hAbility:SetHidden(true)
-- 		hAbility:SetLevel(ability:GetLevel())
-- 		caster:RemoveModifierByName(hAbility:GetIntrinsicModifierName() or "")
-- 		hAbility.GetIntrinsicModifierName = function(self) return "" end
-- 		local hRecordTarget = caster:GetCursorCastTarget()
-- 		caster:SetCursorCastTarget(target)
-- 		hAbility:OnSpellStart()
-- 		caster:SetCursorCastTarget(hRecordTarget)
-- 	end
-- 	function CreateIllusion(hUnit, vLocation, bFindClearSpace, hNPCOwner, hUnitOwner, iTeamNumber, fDuration, fOutgoingDamage, fIncomingDamage)
-- 		local illusion = CreateUnitByName(hUnit:GetUnitName(), vLocation, bFindClearSpace, hNPCOwner, hUnitOwner, iTeamNumber)
-- 		Attributes:Register(illusion)
-- 		Items:SetUnitQualificationLevel(illusion, 5)
-- 		illusion:MakeIllusion()
-- 		illusion:SetForwardVector(hUnit:GetForwardVector())
-- 		if hUnitOwner ~= nil then
-- 			illusion:SetControllableByPlayer(hUnitOwner:GetPlayerOwnerID(), false)
-- 		end
-- 		local iLevel = hUnit:GetLevel()
-- 		for i = illusion:GetLevel(), iLevel-1 do
-- 			illusion:LevelUp(false)
-- 		end
-- 		local hUpgradeInfos = deepcopy(KeyValues.TowerUpgradesKv[hUnit:GetUnitName()])
-- 		if hUpgradeInfos and hUpgradeInfos[tostring(iLevel-1)] then
-- 			local hUpgradeInfo = hUpgradeInfos[tostring(iLevel-1)]
-- 			illusion:SetBaseStrength(0)
-- 			illusion:SetBaseAgility(0)
-- 			illusion:SetBaseIntellect(0)
-- 			if hUpgradeInfo.AttackDamageMin ~= nil then
-- 				illusion:SetBaseDamageMin(tonumber(hUpgradeInfo.AttackDamageMin))
-- 			end
-- 			if hUpgradeInfo.AttackDamageMax ~= nil then
-- 				illusion:SetBaseDamageMax(tonumber(hUpgradeInfo.AttackDamageMax))
-- 			end
-- 			if hUpgradeInfo.AttackRate ~= nil then
-- 				illusion:SetBaseAttackTime(hUpgradeInfo.AttackRate)
-- 			end
-- 			if hUpgradeInfo.AttackCapabilities ~= nil then
-- 				illusion:SetAttackCapability(AttackCapabilityS2I[hUpgradeInfo.AttackCapabilities])
-- 			end
-- 			if hUpgradeInfo.ProjectileModel ~= nil then
-- 				illusion:SetRangedProjectileName(hUpgradeInfo.ProjectileModel)
-- 			end
-- 			if hUpgradeInfo.Model ~= nil then
-- 				illusion:SetModel(hUpgradeInfo.Model)
-- 				illusion:SetOriginalModel(hUpgradeInfo.Model)
-- 			end
-- 			if hUpgradeInfo.ModelScale ~= nil then
-- 				illusion:SetModelScale(hUpgradeInfo.ModelScale)
-- 			end
-- 			if hUpgradeInfo.StatusHealth ~= nil then
-- 				illusion:SetHPGain(hUpgradeInfo.StatusHealth-illusion:GetMaxHealth())
-- 			end
-- 			if hUpgradeInfo.StatusMana ~= nil then
-- 				illusion:SetManaGain(hUpgradeInfo.StatusMana-illusion:GetMaxMana())
-- 			end
-- 			if hUpgradeInfo.AttributeBaseStrength ~= nil then
-- 				illusion:SetBaseStrength(hUpgradeInfo.AttributeBaseStrength)
-- 			end
-- 			if hUpgradeInfo.AttributeBaseAgility ~= nil then
-- 				illusion:SetBaseAgility(hUpgradeInfo.AttributeBaseAgility)
-- 			end
-- 			if hUpgradeInfo.AttributeBaseIntelligence ~= nil then
-- 				illusion:SetBaseIntellect(hUpgradeInfo.AttributeBaseIntelligence)
-- 			end
-- 			if hUpgradeInfo.LevelupAbilities ~= nil then
-- 				for sKey, sAbilityName in pairs(hUpgradeInfo.LevelupAbilities) do
-- 					local hAbility = illusion:FindAbilityByName(sAbilityName)
-- 					if hAbility then
-- 						hAbility:UpgradeAbility(true)
-- 					end
-- 				end
-- 			end
-- 			-- 阻止CreatureLevelUp升级技能
-- 			local hAbilities = {}
-- 			for i = 0, illusion:GetAbilityCount()-1, 1 do
-- 				local hAbility = illusion:GetAbilityByIndex(i)
-- 				if hAbility then
-- 					hAbilities[i] = {
-- 						iLevel = hAbility:GetLevel(),
-- 						bAutoCastState = hAbility:GetAutoCastState(),
-- 						bToggleState = hAbility:GetToggleState(),
-- 					}
-- 					hAbility.bNoRefresh = true
-- 				end
-- 			end
-- 			if illusion.fBaseManaRegen == nil then
-- 				illusion.fBaseManaRegen = illusion:GetManaRegen() - illusion:GetBonusManaRegen()
-- 			end
-- 			local fManaPercent = illusion:GetMana()/illusion:GetMaxMana()
-- 			local fHealthPercent = illusion:GetHealth()/illusion:GetMaxHealth()
-- 			illusion:CreatureLevelUp(1)
-- 			illusion:SetHPGain(0)
-- 			illusion:SetManaGain(0)
-- 			illusion:CreatureLevelUp(-1)
-- 			illusion:SetBaseManaRegen(illusion.fBaseManaRegen)
-- 			illusion:SetHealth(fHealthPercent*illusion:GetMaxHealth())
-- 			illusion:SetMana(fManaPercent*illusion:GetMaxMana())
-- 			for i, tData in pairs(hAbilities) do
-- 				local hAbility = illusion:GetAbilityByIndex(i)
-- 				if hAbility then
-- 					hAbility:SetLevel(tData.iLevel)
-- 					if hAbility:GetAutoCastState() ~= tData.bAutoCastState then hAbility:ToggleAutoCast() end
-- 					if hAbility:GetToggleState() ~= tData.bToggleState then hAbility:ToggleAbility() end
-- 					if tData.iLevel == 0 then
-- 						illusion:RemoveModifierByName(hAbility:GetIntrinsicModifierName() or "")
-- 					end
-- 					hAbility.bNoRefresh = false
-- 				end
-- 			end
-- 		end
-- 		if hUnit:IsBuilding() then
-- 			illusion.IsBuilding = function(self)
-- 				return true
-- 			end
-- 		end
-- 		for i = 0, hUnit:GetAbilityCount()-1 do
-- 			local ability = hUnit:GetAbilityByIndex(i)
-- 			if ability ~= nil then 
-- 				local illusion_ability = illusion:FindAbilityByName(ability:GetAbilityName())
-- 				if illusion_ability == nil then
-- 					illusion_ability = illusion:AddAbility(ability:GetAbilityName())
-- 				end
-- 				if illusion_ability ~= nil then
-- 					while illusion_ability:GetLevel() < ability:GetLevel() do
-- 						illusion_ability:UpgradeAbility(true)
-- 					end
-- 				end
-- 			end
-- 		end
-- 		for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
-- 			local item = illusion:GetItemInSlot(i)
-- 			if item ~= nil then
-- 				item:RemoveSelf()
-- 			end
-- 		end
-- 		for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
-- 			local item = hUnit:GetItemInSlot(i)
-- 			if item ~= nil then
-- 				local illusion_item = CreateItem(item:GetName(), illusion, illusion)
-- 				illusion:AddItem(illusion_item)
-- 				for j = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
-- 					local _item = illusion:GetItemInSlot(j)
-- 					if _item == illusion_item then
-- 						if i ~= j then illusion:SwapItems(i, j) end
-- 						break
-- 					end
-- 				end
-- 				illusion_item:EndCooldown()
-- 				illusion_item:SetPurchaser(nil)
-- 				illusion_item:SetShareability(ITEM_FULLY_SHAREABLE)
-- 				illusion_item:SetPurchaseTime(item:GetPurchaseTime())
-- 				illusion_item:SetCurrentCharges(item:GetCurrentCharges())
-- 				illusion_item:SetItemState(item:GetItemState())
-- 				if illusion_item:GetToggleState() ~= item:GetToggleState() then
-- 					illusion_item:ToggleAbility()
-- 				end
-- 				if illusion_item:GetAutoCastState() ~= item:GetAutoCastState() then
-- 					illusion_item:ToggleAutoCast()
-- 				end
-- 			end
-- 		end
-- 		local modifiers = hUnit:FindAllModifiers()
-- 		for i, modifier in pairs(modifiers) do
-- 			if modifier.AllowIllusionDuplicate and modifier:AllowIllusionDuplicate() then
-- 				local illusion_modifier = illusion:AddNewModifier(modifier:GetCaster(), modifier:GetAbility(), modifier:GetName(), nil)
-- 			end
-- 		end
-- 		illusion:AddNewModifier(hUnitOwner, nil, "modifier_illusion", {duration = fDuration, outgoing_damage = fOutgoingDamage, incoming_damage = fIncomingDamage})
-- 		illusion:SetHealth(hUnit:GetHealth())
-- 		illusion:SetMana(hUnit:GetMana())
-- 		local particleID = ParticleManager:CreateParticle("particles/generic_gameplay/illusion_created.vpcf", PATTACH_ABSORIGIN_FOLLOW, illusion)
-- 		ParticleManager:ReleaseParticleIndex(particleID)
-- 		return illusion
-- 	end
-- 	function FireModifiersEvent(eventName, data)
-- 		local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, -1, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, 0, false)
-- 		for _, unit in pairs(units) do
-- 			local modifiers = unit:FindAllModifiers()
-- 			for n, modifier in pairs(modifiers) do
-- 				if modifier[eventName] then
-- 					modifier[eventName](modifier, data)
-- 				end
-- 			end
-- 		end
-- 	end
-- 	function CDOTA_BaseNPC:GetSummoner()
-- 		return self.hSummoner
-- 	end
-- 	function CDOTA_BaseNPC:FireSummonned(unit)
-- 		self.hSummoner = unit
-- 		self.IsSummoned = function(self)
-- 			return true
-- 		end
-- 		FireModifiersEvent("OnSummonned", {
-- 			unit = unit,
-- 			target = self,
-- 		})
-- 	end
-- 	function CDOTA_BaseNPC:FireTeleported(position)
-- 		FireModifiersEvent("OnTeleported", {
-- 			unit = self,
-- 			position = position,
-- 		})
-- 	end
-- end
