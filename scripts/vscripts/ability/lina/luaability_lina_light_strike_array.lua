require("Ability/LuaAbility")
----技能：光击阵    英雄：莉娜
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_lina_light_strike_array then
    LuaAbility_lina_light_strike_array = class({
        mTargetpath = nil,
    }, nil, LuaAbility)
    LinkLuaModifier("modifier_luaAbility_lina_light_strike_array", "Ability/lina/LuaAbility_lina_light_strike_array.lua", LUA_MODIFIER_MOTION_NONE)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_lina_light_strike_array:constructor()
    self.__base__.constructor(self)
end

----选择无目标时
---- function LuaAbility_lina_light_strike_array:CastFilterResult()
----     if not self:isCanCast() then
----         return UF_FAIL_CUSTOM
----     end
----     return UF_SUCCESS
---- end
----选择目标地点时
----@param 目标地点vector
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function LuaAbility_lina_light_strike_array:CastFilterResultLocation(vLocation)
    if not self:isCanCast() then
        return UF_FAIL_CUSTOM
    end
    if IsServer() and PathManager and PathManager.m_tabPaths then
        local path = PathManager:getClosePath(vLocation)
        local dis = (vLocation - path.m_entity:GetAbsOrigin()):Length2D()
        if dis < 150 then
            self.mTargetPath = path
            return UF_SUCCESS
        end
        self.m_strCastError = "LuaAbilityError_TargetPath"
        return UF_FAIL_CUSTOM
    else
        return UF_SUCCESS
    end
end

----开始施法
function LuaAbility_lina_light_strike_array:OnAbilityPhaseStart()
    EmitGlobalSound("Ability.PreLightStrikeArray")
    if IsServer() then
        self._GS = GMManager.m_typeState
        -- GMManager:setState(GS_Wait)
        self._YieldStateCO = GSManager:yieldState()
        GSManager:setState(GS_Wait)
    end
    return true
end

----开始技能效果
function LuaAbility_lina_light_strike_array:OnSpellStart()
    ----重置状态
    if self._GS then
        -- if GS_Wait == GMManager.m_typeState
        -- or GS_DeathClearing == GMManager.m_typeState then
        --     GMManager:setState(self._GS)
        -- end
        self._GS = nil
    end
    GSManager:resumeState(self._YieldStateCO)

    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    local nRange = self:GetSpecialValueFor("range")

    ----特效
    local path = PathManager:getNextPath(self.mTargetPath, -math.floor((nRange - 1) * 0.5))
    for i = 1, nRange do
        if path and path.m_entity then
            local nPtclID = AMHC:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf"
            , PATTACH_POINT, false, oPlayer.m_eHero, 1)
            ParticleManager:SetParticleControl(nPtclID, 0, path.m_entity:GetAbsOrigin())
            ParticleManager:SetParticleControl(nPtclID, 1, Vector(150, 1, 1))
        end
        path = PathManager:getNextPath(path, 1)
    end

    ----获取施法位置作用格数内的玩家
    local tabPlayer = {}
    PlayerManager:findRangePlayer(tabPlayer, self.mTargetPath, nRange, nil, function(player)
        if player == oPlayer
        or not self:checkTarget(player.m_eHero)
        or 0 < bit.band(PS_AbilityImmune + PS_Die + PS_InPrison + PS_AtkMonster, player.m_typeState) then
            return false    ----排除
        end
        return true
    end)

    ----对玩家造成伤害
    self:atk(tabPlayer)

    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = self })

    ----设置冷却
    AbilityManager:setRoundCD(oPlayer, self)
end
function LuaAbility_lina_light_strike_array:atk(tabPlayer)
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())

    ----获取伤害数值
    local nDamage = self:GetSpecialValueFor("light_strike_array_damage")
    local nDuration = self:GetSpecialValueFor("light_strike_array_stun_duration")

    ----造成伤害
    for k, v in pairs(tabPlayer) do
        local player = v
        AMHC:Damage(self:GetCaster(), player.m_eHero, nDamage, self:GetAbilityDamageType(), self)
        ----设置眩晕回合
        player:setPass(nDuration)
        ----设置眩晕BUFF
        for _, eBZ in pairs(player.m_tabBz) do
            AbilityManager:setCopyBuff('modifier_luaAbility_lina_light_strike_array'
            , eBZ, self:GetCaster(), self)
        end
        local buff = AbilityManager:setCopyBuff('modifier_luaAbility_lina_light_strike_array'
        , player.m_eHero, self:GetCaster(), self)
        ----兵卒创建更新buff
        if buff then
            buff.unUpdateBZBuffByCreate = AbilityManager:updataBZBuffByCreate(player, nil, function(eBZ)
                AbilityManager:setCopyBuff('modifier_luaAbility_lina_light_strike_array'
                , eBZ, self:GetCaster(), self)
            end)
        end
        ----监听结束
        -- EventManager:register("Event_PlayerRoundBegin", function(tabEvent)
        --     if tabEvent.oPlayer == oPlayer then
        --         ----移除buff
        --         for _, v in pairs(player.m_tabBz) do
        --             if IsValid(v) then
        --                 v:RemoveModifierByNameAndCaster("modifier_luaAbility_lina_light_strike_array", self:GetCaster())
        --             end
        --         end
        --         if IsValid(player.m_eHero) then
        --             player.m_eHero:RemoveModifierByNameAndCaster("modifier_luaAbility_lina_light_strike_array", self:GetCaster())
        --         end
        --         unUpdateBZBuffByCreate()
        --         return true
        --     end
        -- end)
    end
end

----指示器
function LuaAbility_lina_light_strike_array:GetCastRange(vLocation, eTarget)
    return 0
end

----眩晕buff
modifier_luaAbility_lina_light_strike_array = class({})
function modifier_luaAbility_lina_light_strike_array:IsDebuff()
    return true
end
function modifier_luaAbility_lina_light_strike_array:IsStunDebuff()
    return true
end
function modifier_luaAbility_lina_light_strike_array:IsPurgable()
    return false
end
function modifier_luaAbility_lina_light_strike_array:GetTexture()
    return "lina_light_strike_array"
end
function modifier_luaAbility_lina_light_strike_array:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end
function modifier_luaAbility_lina_light_strike_array:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_luaAbility_lina_light_strike_array:OnCreated(kv)
    self.m_nDuration = self:GetAbility():GetSpecialValueFor("light_strike_array_stun_duration")
    if IsServer() and IsValid(self:GetCaster()) then
        self.m_nRound = self.m_nDuration
        AbilityManager:judgeBuffRound(self:GetCaster():GetPlayerOwnerID(), self)

        ----兵卒被晕结束攻城
        if self:GetParent().m_bBZ and self:GetParent().m_path then
            if nil ~= self:GetParent().m_path.m_nPlayerIDGCLD then
                self:GetParent().m_path:atkCityEnd(false)
            end
        end
    end
end
function modifier_luaAbility_lina_light_strike_array:OnDestroy()
    if self.unUpdateBZBuffByCreate then
        self.unUpdateBZBuffByCreate()
    end
end
function modifier_luaAbility_lina_light_strike_array:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
    }
    return funcs
end
function modifier_luaAbility_lina_light_strike_array:GetOverrideAnimation(params)
    return ACT_DOTA_DISABLED
end
function modifier_luaAbility_lina_light_strike_array:GetBonusDayVision()
    return self.m_nDuration
end
function modifier_luaAbility_lina_light_strike_array:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
    }
    return state
end