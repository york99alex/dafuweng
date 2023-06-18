if PrecacheItems then
    table.insert(PrecacheItems, "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf")
end

require("Ability/lina/LuaAbility_lina_laguna_blade")
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----卡牌莉娜神灭斩
if nil == Card_HERO_LINA_laguna_blade then
    Card_HERO_LINA_laguna_blade = class({
        m_tabAbltInfo = nil      ----卡牌技能信息
    }, nil, Card)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function Card_HERO_LINA_laguna_blade:constructor(tInfo, nPlayerID)
    Card_HERO_LINA_laguna_blade.__base__.constructor(self, tInfo, nPlayerID)
    self.m_typeCast = TCardCast_Target
    self.m_tabAbltInfo = KeyValues.AbilitiesKv["LuaAbility_lina_laguna_blade"]
    self.m_nManaCost = tonumber(self.m_tabAbltInfo["AbilityManaCost"])
    self.m_nManaCostBase = self.m_nManaCost
end

----选择目标单位时
----@param 目标单位
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function Card_HERO_LINA_laguna_blade:CastFilterResultTarget(hTarget)
    self.m_eTarget = hTarget

    if not self:CanUseCard(hTarget) then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

----返回伤害类型
function Card_HERO_LINA_laguna_blade:GetAbilityDamageType()
    return load("return " .. self.m_tabAbltInfo["AbilityUnitDamageType"])()
end

----卡牌释放
function Card_HERO_LINA_laguna_blade:OnSpellStart()
    local eTarget = self:GetCursorTarget()
    local eCaster = self:GetCaster()

    local vForward = eCaster:GetForwardVector()
    eCaster:SetForwardVector(eTarget:GetAbsOrigin() - eCaster:GetForwardVector())

    ----抬手动作
    local nAnmt = _G[self.m_tabAbltInfo["AbilityCastAnimation"]]
    eCaster:StartGesture(nAnmt)

    Timers:CreateTimer(self.m_tabAbltInfo["AbilityCastPoint"], function()
        ----特效
        EmitGlobalSound("Ability.PreLightStrikeArray")
        local nPtclID = AMHC:CreateParticle("particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf"
        , PATTACH_POINT, false, eCaster, 1)
        ParticleManager:SetParticleControl(nPtclID, 0, eCaster:GetAbsOrigin())
        ParticleManager:SetParticleControl(nPtclID, 1, eTarget:GetAbsOrigin())

        ----对玩家造成伤害
        local nDamage = 1000
        AMHC:Damage(eCaster, eTarget, nDamage, self:GetAbilityDamageType(), self)

        ----转回朝向
        Timers:CreateTimer(0.1, function()
            eCaster:SetForwardVector(vForward)
        end)

    end)
end