require("Ability/LuaAbility")
----技能：真龙烈焰    英雄：龙骑士
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
LinkLuaModifier("modifier_dragon_knight_breathe_fire_debuff_0", "Ability/dragon_knight/LuaAbility_dragon_knight_breathe_fire.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dragon_knight_breathe_fire_debuff_2", "Ability/dragon_knight/LuaAbility_dragon_knight_breathe_fire.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dragon_knight_breathe_fire_debuff_01", "Ability/dragon_knight/LuaAbility_dragon_knight_breathe_fire.lua", LUA_MODIFIER_MOTION_NONE)
if PrecacheItems then
    table.insert(PrecacheItems, "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf")
    table.insert(PrecacheItems, "particles/custom/abilitys/dragon_knight/dragon_knight_breathe_fire_0.vpcf")
    table.insert(PrecacheItems, "particles/custom/abilitys/dragon_knight/dragon_knight_breathe_fire_2.vpcf")
end

if nil == LuaAbility_dragon_knight_breathe_fire then
    LuaAbility_dragon_knight_breathe_fire = class({}, nil, LuaAbility)
end
local this = LuaAbility_dragon_knight_breathe_fire
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function this:constructor()
    this.__base__.constructor(self)
end

---- 定义技能的施法距离
function this:GetCastRange(vLocation, hTarget)
    if IsClient() then
        local tabPlayerInfo = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self:GetCaster():GetPlayerOwnerID())
        if not tabPlayerInfo then
            return
        end
        require('Path/PathManager')
        require('Ability/AbilityManager')

        local tabPathID = {}

        local range = math.floor(self:GetSpecialValueFor('range') / 2)
        ----火龙翻倍范围
        local nDargonLevel = self:GetCaster():GetModifierStackCount('modifier_dragon_knight_elder_dragon_form_bg', self:GetCaster()) - 1
        if 1 == nDargonLevel then
            range = range * 2
        end

        local q, h = PathManager:getVertexPathID(tabPlayerInfo.nPathCurID)
        for i = 1, range do
            local nPathID = PathManager:getNextPathID(tabPlayerInfo.nPathCurID, i)
            table.insert(tabPathID, nPathID)
            if q == nPathID then
                break
            end
        end
        for i = 1, range do
            local nPathID = PathManager:getNextPathID(tabPlayerInfo.nPathCurID, -i)
            table.insert(tabPathID, nPathID)
            if h == nPathID then
                break
            end
        end

        AbilityManager:showAbltMark(self, self:GetCaster(), tabPathID)
    end
    return 0
end

----选择目标时
function this:CastFilterResultTarget(hTarget)
    if not self:isCanCast(hTarget) then
        return UF_FAIL_CUSTOM
    end
    self.m_eTarget = hTarget
    return UF_SUCCESS
end

----选择目标地点时
function this:CastFilterResultLocation(vLocation)
    if not self:isCanCast() then
        return UF_FAIL_CUSTOM
    end
    if IsServer() then
        local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
        if oPlayer then
            local path = PathManager:getClosePath(vLocation)
            ----距离
            local dis = (vLocation - path.m_entity:GetAbsOrigin()):Length2D()
            if dis > 150 then
                self.m_strCastError = "LuaAbilityError_TargetPath"
                return UF_FAIL_CUSTOM
            end

            dis = math.floor(self:GetSpecialValueFor('range') / 2)
            ----火龙翻倍范围
            local nDargonLevel = self:GetCaster():GetModifierStackCount('modifier_dragon_knight_elder_dragon_form_bg', self:GetCaster()) - 1
            if 1 == nDargonLevel then
                dis = dis * 2
            end

            local pathQ, pathH = PathManager:getVertexPath(oPlayer.m_pathCur)
            local tPathsQ = {}
            local tPathsH = {}

            for i = 1, dis do
                table.insert(tPathsQ, PathManager:getNextPath(oPlayer.m_pathCur, i))
                if pathQ == tPathsQ[#tPathsQ] then
                    break
                end
            end
            for _, path2 in pairs(tPathsQ) do
                if path2 == path then
                    self.m_nFow = 1
                    self.m_pathTarget = tPathsQ[#tPathsQ]
                    return UF_SUCCESS
                end
            end

            for i = 1, dis do
                table.insert(tPathsH, PathManager:getNextPath(oPlayer.m_pathCur, -i))
                if pathH == tPathsH[#tPathsH] then
                    break
                end
            end
            for _, path2 in pairs(tPathsH) do
                if path2 == path then
                    self.m_nFow = -1
                    self.m_pathTarget = tPathsH[#tPathsH]
                    return UF_SUCCESS
                end
            end

            self.m_strCastError = "LuaAbilityError_Range"
            return UF_FAIL_CUSTOM
        end
    end
    return UF_SUCCESS
end

----开始技能效果
function this:OnSpellStart()
    if not self.m_pathTarget
    -- and not self.m_eTarget
        then
        return
    end
    local hCaster = self:GetCaster()
    local oPlayer = PlayerManager:getPlayer(hCaster:GetPlayerOwnerID())
    if not oPlayer then
        return
    end

    local damage = self:GetSpecialValueFor('damage')
    local start_radius = self:GetSpecialValueFor('start_radius')
    local end_radius = self:GetSpecialValueFor('end_radius')

    local range = math.floor(self:GetSpecialValueFor('range') / 2)
    local nDargonLevel = self:GetCaster():GetModifierStackCount('modifier_dragon_knight_elder_dragon_form_bg', self:GetCaster()) - 1

    local speed = self:GetSpecialValueFor('speed')
    local fDis = (self.m_pathTarget.m_entity:GetAbsOrigin() - hCaster:GetAbsOrigin()):Length2D()
    local vDir = (self.m_pathTarget.m_entity:GetAbsOrigin() - hCaster:GetAbsOrigin()):Normalized()

    local info = {
        EffectName = 'particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf',
        Ability = self,
        vSpawnOrigin = hCaster:GetAbsOrigin(),
        fStartRadius = start_radius,
        fEndRadius = end_radius,
        vVelocity = vDir * speed,
        fDistance = fDis,
        Source = hCaster,
    }
    if 0 == nDargonLevel then
        info.EffectName = 'particles/custom/abilitys/dragon_knight/dragon_knight_breathe_fire_0.vpcf'
    elseif 2 == nDargonLevel then
        info.EffectName = 'particles/custom/abilitys/dragon_knight/dragon_knight_breathe_fire_2.vpcf'
    end
    ProjectileManager:CreateLinearProjectile(info)
    EmitGlobalSound("Hero_DragonKnight.BreathFire")

    ----获取伤害目标
    local tTargets = {}
    local i = 0
    for n = #PathManager.m_tabPaths, 1, -1 do
        i = i + self.m_nFow
        local path = PathManager:getNextPath(oPlayer.m_pathCur, i)
        tTargets = concat(path:getJoinEnt(), tTargets)
        if path == self.m_pathTarget then
            break
        end
    end

    removeRepeat(tTargets)
    removeAll(tTargets, function(v)
        return not self:checkTarget(v)
    end)
    ----伤害
    for _, hTarget in pairs(tTargets) do
        local nDamage = damage
        local hDebuff1 = hTarget:FindModifierByName('modifier_dragon_knight_elder_dragon_form_debuff_1')
        if IsValid(hDebuff1) then
            local hAblt = hCaster:FindAbilityByName('LuaAbility_dragon_knight_elder_dragon_form')
            if IsValid(hAblt) then
                nDamage = nDamage + hAblt:GetSpecialValueFor('deuff_fire_damage') * hDebuff1:GetStackCount()
                print("hAblt:GetSpecialValueFor('deuff_fire_damage') * hDebuff1:GetStackCount()=" .. hAblt:GetSpecialValueFor('deuff_fire_damage') * hDebuff1:GetStackCount())
                hDebuff1:Destroy()
            end
        end
        AMHC:Damage(hCaster, hTarget, nDamage, self:GetAbilityDamageType(), self, 1)

        ----额外Debuff
        AbilityManager:setCopyBuff('modifier_dragon_knight_breathe_fire_debuff_' .. (nDargonLevel < 0 and '01' or nDargonLevel)
        , hTarget, self:GetCaster(), self)
    end

    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = self })
    ----设置冷却
    AbilityManager:setRoundCD(oPlayer, self)
end

--Debuff
----毒
if not modifier_dragon_knight_breathe_fire_debuff_0 then
    modifier_dragon_knight_breathe_fire_debuff_0 = class({})
end
function modifier_dragon_knight_breathe_fire_debuff_0:IsDebuff()
    return true
end
function modifier_dragon_knight_breathe_fire_debuff_0:IsPurgable()
    return true ----可净化
end
function modifier_dragon_knight_breathe_fire_debuff_0:OnCreated(kv)
    self.deuff_armor_sub = self:GetAbility():GetSpecialValueFor('deuff_armor_sub')
    self.deuff_move_speed_sub = self:GetAbility():GetSpecialValueFor('deuff_move_speed_sub')
    ----计算BUFF生命周期
    self.m_nRound = self:GetAbility():GetSpecialValueFor('duration')
    if IsServer() then
        AbilityManager:judgeBuffRound(self:GetCaster():GetPlayerOwnerID(), self)
    end
end
function modifier_dragon_knight_breathe_fire_debuff_0:OnRefresh(kv)
    self.deuff_armor_sub = self:GetAbility():GetSpecialValueFor('deuff_armor_sub')
    self.deuff_move_speed_sub = self:GetAbility():GetSpecialValueFor('deuff_move_speed_sub')
    self.m_nRound = self:GetAbility():GetSpecialValueFor('duration')
end
function modifier_dragon_knight_breathe_fire_debuff_0:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end
function modifier_dragon_knight_breathe_fire_debuff_0:OnTooltip()
    return self.m_nRound
end
function modifier_dragon_knight_breathe_fire_debuff_0:GetModifierPhysicalArmorBonus()
    return self.deuff_armor_sub
end
----冰
if not modifier_dragon_knight_breathe_fire_debuff_2 then
    modifier_dragon_knight_breathe_fire_debuff_2 = class({}, nil, modifier_dragon_knight_breathe_fire_debuff_0)
end
function modifier_dragon_knight_breathe_fire_debuff_2:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end
function modifier_dragon_knight_breathe_fire_debuff_2:GetModifierMoveSpeedBonus_Percentage()
    return self.deuff_move_speed_sub
end
----人
if not modifier_dragon_knight_breathe_fire_debuff_01 then
    modifier_dragon_knight_breathe_fire_debuff_01 = class({}, nil, modifier_dragon_knight_breathe_fire_debuff_0)
end
function modifier_dragon_knight_breathe_fire_debuff_01:GetEffectName()
    return 'particles/generic_gameplay/generic_silenced.vpcf'
end
function modifier_dragon_knight_breathe_fire_debuff_01:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_dragon_knight_breathe_fire_debuff_01:CheckState()
    local state = {
        [MODIFIER_STATE_SILENCED] = true,
    }
    return state
end