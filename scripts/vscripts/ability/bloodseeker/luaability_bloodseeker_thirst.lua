require("Ability/LuaAbility")
----技能：焦渴    英雄：血魔
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_bloodseeker_thirst then
    LuaAbility_bloodseeker_thirst = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_bloodseeker_thirst_bg", "Ability/bloodseeker/LuaAbility_bloodseeker_thirst.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_bloodseeker_thirst_bg_active", "Ability/bloodseeker/LuaAbility_bloodseeker_thirst.lua", LUA_MODIFIER_MOTION_NONE)
    if PrecacheItems then
        table.insert(PrecacheItems, "particles/units/heroes/hero_bloodseeker/bloodseeker_thirst_owner.vpcf")
    end
end
local this = LuaAbility_bloodseeker_thirst
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function this:constructor()
    this.__base__.constructor(self)
end
function this:GetIntrinsicModifierName()
    return "modifier_bloodseeker_thirst_bg"
end

----检测buff
modifier_bloodseeker_thirst_bg = class({})
function modifier_bloodseeker_thirst_bg:IsHidden()
    return true
end
function modifier_bloodseeker_thirst_bg:IsPurgable()
    return false
end
function modifier_bloodseeker_thirst_bg:OnDestroy()
    self:StartIntervalThink(-1)
end
function modifier_bloodseeker_thirst_bg:OnCreated(kv)
    if IsClient()
    -- or not self:GetParent():IsRealHero() 
        then
        return
    end
    -- self.oPlayer = PlayerManager:getPlayer(self:GetParent():GetPlayerOwnerID())
    -- if not self.oPlayer then
    --     return
    -- end
    self.min_bonus_pct = self:GetAbility():GetSpecialValueFor("min_bonus_pct")
    self:StartIntervalThink(1)
end
function modifier_bloodseeker_thirst_bg:OnIntervalThink()
    ----计算低于触发血量阈值的单位数量
    local nCount = 0
    for _, player in pairs(PlayerManager.m_tabPlayers) do
        if IsValid(player.m_eHero) and not player.m_bDie and self.min_bonus_pct >= player.m_eHero:GetHealthPercent() then
            nCount = nCount + 1
        end
        for _, eBZ in pairs(player.m_tabBz) do
            if IsValid(eBZ) and self.min_bonus_pct >= eBZ:GetHealthPercent() then
                nCount = nCount + 1
            end
        end
    end
    ----更新buff
    self:updataBuff(self:GetParent(), nCount)
    -- self:updataBuff(self.oPlayer.m_eHero, nCount)
    -- for _, v in pairs(self.oPlayer.m_tabBz) do
    -- self:updataBuff(v, nCount)
    -- end
end
function modifier_bloodseeker_thirst_bg:updataBuff(entity, nStack)
    if not IsValid(entity) then
        return
    end
    if 0 < nStack then
        local buff = entity:FindModifierByNameAndCaster("modifier_bloodseeker_thirst_bg_active", self:GetParent())
        if not buff then
            buff = entity:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_bloodseeker_thirst_bg_active", {})
        end
        if buff then
            buff:SetStackCount(nStack)
            buff:OnRefresh()
        end
    else
        entity:RemoveModifierByNameAndCaster("modifier_bloodseeker_thirst_bg_active", self:GetParent())
    end
end

----焦渴buff
modifier_bloodseeker_thirst_bg_active = class({})
function modifier_bloodseeker_thirst_bg_active:IsHidden()
    return false
end
function modifier_bloodseeker_thirst_bg_active:IsPurgable()
    return false
end
function modifier_bloodseeker_thirst_bg_active:GetEffectName()
    return "particles/units/heroes/hero_bloodseeker/bloodseeker_thirst_owner.vpcf"
end
function modifier_bloodseeker_thirst_bg_active:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end
function modifier_bloodseeker_thirst_bg_active:OnCreated(kv)
    self.bonus_movement_speed = self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
    self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    -- ListenToGameEvent("dota_portrait_ability_layout_changed", Dynamic_Wrap(self, 'On_dota_portrait_ability_layout_changed'), self)
end
function modifier_bloodseeker_thirst_bg_active:OnRefresh()
    self.bonus_movement_speed = self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
    self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    -- ListenToGameEvent("dota_portrait_ability_layout_changed", Dynamic_Wrap(self, 'On_dota_portrait_ability_layout_changed'), self)
end
function modifier_bloodseeker_thirst_bg_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end
function modifier_bloodseeker_thirst_bg_active:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_movement_speed * self:GetStackCount()
end
function modifier_bloodseeker_thirst_bg_active:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_attack_speed * self:GetStackCount()
end
-- function modifier_bloodseeker_thirst_bg_active:On_dota_portrait_ability_layout_changed()
-- end