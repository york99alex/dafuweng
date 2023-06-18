require("Ability/LuaAbility")
----技能：割裂    英雄：血魔
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_bloodseeker_rupture then
    LuaAbility_bloodseeker_rupture = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_bloodseeker_rupture_bg", "Ability/bloodseeker/LuaAbility_bloodseeker_rupture.lua", LUA_MODIFIER_MOTION_NONE)
    if PrecacheItems then
        table.insert(PrecacheItems, "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf")
    end
end
local this = LuaAbility_bloodseeker_rupture
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function this:constructor()
    this.__base__.constructor(self)
end

----选择目标时
function this:CastFilterResultTarget(hTarget)
    if not IsValid(hTarget) then
        return UF_FAIL_CUSTOM
    end
    if not self:isCanCast(hTarget) then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
function this:isCanCastSelf()
    return false
end

----开始技能效果
function this:OnSpellStart()
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    local eTarget = self:GetCursorTarget()
    if not oPlayer or not IsValid(eTarget) then
        return
    end

    ----音效
    EmitGlobalSound("hero_bloodseeker.rupture.cast")

    ----添加buff
    AbilityManager:setCopyBuff('modifier_bloodseeker_rupture_bg'
    , eTarget, self:GetCaster(), self)

    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = self })
    ----设置冷却
    AbilityManager:setRoundCD(oPlayer, self)
end

----割裂buff
modifier_bloodseeker_rupture_bg = class({})
function modifier_bloodseeker_rupture_bg:IsHidden()
    return false
end
function modifier_bloodseeker_rupture_bg:IsPurgable()
    return true ----可净化
end
function modifier_bloodseeker_rupture_bg:IsDebuff()
    return true
end
function modifier_bloodseeker_rupture_bg:GetEffectName()
    return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end
function modifier_bloodseeker_rupture_bg:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end
function modifier_bloodseeker_rupture_bg:OnDestroy()
    if IsServer() then
        EventManager:unregister("Event_Move", self.onEvent_Move, self)
        EventManager:unregister("Event_ItemHuiXueByRound", self.onEvent_ItemHuiXueByRound, self)
        EventManager:unregister("Event_HuiXue", self.onEvent_HuiXue, self)

    end
end
function modifier_bloodseeker_rupture_bg:OnCreated(kv)
    self.m_nDamage = self:GetAbility():GetSpecialValueFor("damage")
    self.m_nDuration = self:GetAbility():GetSpecialValueFor("duration")
    if IsClient() or not self:GetParent():IsRealHero() then
        return
    end
    self.oPlayer = PlayerManager:getPlayer(self:GetParent():GetPlayerOwnerID())
    if not self.oPlayer then
        return
    end
    self.m_typeDamage = self:GetAbility():GetAbilityDamageType()

    ----计算BUFF生命周期
    self.m_nRound = self.m_nDuration
    AbilityManager:judgeBuffRound(self:GetCaster():GetPlayerOwnerID(), self)

    ----监听移动
    EventManager:register("Event_Move", self.onEvent_Move, self)
    ----监听恢血
    EventManager:register("Event_ItemHuiXueByRound", self.onEvent_ItemHuiXueByRound, self, -5000)
    ----监听吸血
    EventManager:register("Event_HuiXue", self.onEvent_HuiXue, self, -5000)
end

----监听移动扣血
function modifier_bloodseeker_rupture_bg:onEvent_Move(tEvent)
    if tEvent.entity ~= self:GetParent() then
        return
    end
    local player = PlayerManager:getPlayer(tEvent.entity:GetPlayerOwnerID())
    local tEventID = {}
    table.insert(tEventID, EventManager:register("Event_CurPathChange", function(tEvent2)
        if tEvent2.player == player then
            local nDamage = self:GetParent():GetHealth() * self.m_nDamage * 0.01
            AMHC:Damage(self:GetCaster(), self:GetParent(), nDamage, self.m_typeDamage, self:GetAbility())
            return
        end
    end))
    table.insert(tEventID, EventManager:register("Event_MoveEnd", function(tEvent2)
        if tEvent2.entity == tEvent.entity then
            EventManager:unregisterByIDs(tEventID)
            return
        end
    end))
end
----监听恢血
function modifier_bloodseeker_rupture_bg:onEvent_ItemHuiXueByRound(tEvent)
    if tEvent.entity ~= self:GetParent() then
        return
    end
    tEvent.nHuiXue = tEvent.nHuiXue * 0.5
end
----监听吸血
function modifier_bloodseeker_rupture_bg:onEvent_HuiXue(tEvent)
    if tEvent.entity ~= self:GetParent() then
        return
    end
    tEvent.flAmount = tEvent.flAmount * 0.5
end

function modifier_bloodseeker_rupture_bg:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
    }
end

function modifier_bloodseeker_rupture_bg:GetBonusDayVision()
    return self.m_nDuration
end