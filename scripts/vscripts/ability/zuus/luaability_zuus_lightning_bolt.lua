require("Ability/LuaAbility")
----技能：雷击    英雄：宙斯
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_zuus_lightning_bolt then
    LuaAbility_zuus_lightning_bolt = class({}, nil, LuaAbility)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_zuus_lightning_bolt:constructor()
    self.__base__.constructor(self)
end

function LuaAbility_zuus_lightning_bolt:GetCastRange(vLocation, hTarget)
    return 0
end

----选择目标时
function LuaAbility_zuus_lightning_bolt:CastFilterResultTarget(hTarget)
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
function LuaAbility_zuus_lightning_bolt:OnSpellStart()
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    local eTarget = self:GetCursorTarget()
    local nDamage = self:GetSpecialValueFor("damage")

    ----释放闪电
    local nPtclID = AMHC:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf"
    , PATTACH_POINT, false, eTarget, 2)
    ParticleManager:SetParticleControl(nPtclID, 0, eTarget:GetAbsOrigin() + Vector(0, 0, 2000))
    ParticleManager:SetParticleControl(nPtclID, 1, eTarget:GetAbsOrigin())
    nPtclID = AMHC:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_lb_cfx_il.vpcf"
    , PATTACH_POINT, false, eTarget, 2)
    EmitGlobalSound("Hero_Zuus.LightningBolt")

    ----对玩家造成伤害
    AMHC:Damage(self:GetCaster(), eTarget, nDamage, self:GetAbilityDamageType(), self)

    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = self })

    ----设置冷却
    AbilityManager:setRoundCD(oPlayer, self)
end