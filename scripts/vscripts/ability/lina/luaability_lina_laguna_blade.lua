require("Ability/LuaAbility")
----技能：神灭斩    英雄：莉娜
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_lina_laguna_blade then
    LuaAbility_lina_laguna_blade = class({}, nil, LuaAbility)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_lina_laguna_blade:constructor()
    self.__base__.constructor(self)
end

----选择目标时
function LuaAbility_lina_laguna_blade:CastFilterResultTarget(hTarget)
    if not self:isCanCast(hTarget) then
        return UF_FAIL_CUSTOM
    end

    ----不能是自己
    if hTarget == self:GetCaster() then
        self.m_strCastError = "LuaAbilityError_SelfCant"
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end

----开始技能效果
function LuaAbility_lina_laguna_blade:OnSpellStart()
    local eTarget = self:GetCursorTarget()
    local eCaster = self:GetCaster()

    ----特效
    EmitGlobalSound("Ability.PreLightStrikeArray")
    local nPtclID = AMHC:CreateParticle("particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf"
    , PATTACH_POINT, false, eCaster, 1)
    ParticleManager:SetParticleControl(nPtclID, 0, eCaster:GetAbsOrigin())
    ParticleManager:SetParticleControl(nPtclID, 1, eTarget:GetAbsOrigin())

    ----对玩家造成伤害
    local nDamage = self:GetSpecialValueFor("damage")
    AMHC:Damage(eCaster, eTarget, nDamage, self:GetAbilityDamageType(), self)


    local oPlayer = PlayerManager:getPlayer(eCaster:GetPlayerOwnerID())
    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = self })
    ----设置冷却
    AbilityManager:setRoundCD(oPlayer, self)
end