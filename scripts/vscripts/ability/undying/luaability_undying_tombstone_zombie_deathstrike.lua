require("Ability/LuaAbility")

LinkLuaModifier("modifier_luaability_undying_tombstone_zombie_deathstrike", "Ability/undying/LuaAbility_undying_tombstone_zombie_deathstrike.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_luaability_undying_tombstone_zombie_deathstrike_debuff", "Ability/undying/LuaAbility_undying_tombstone_zombie_deathstrike.lua", LUA_MODIFIER_MOTION_NONE)

if LuaAbility_undying_tombstone_zombie_deathstrike == nil then
    LuaAbility_undying_tombstone_zombie_deathstrike = class({}, nil, LuaAbility)
end
function LuaAbility_undying_tombstone_zombie_deathstrike:GetIntrinsicModifierName()
    return "modifier_luaability_undying_tombstone_zombie_deathstrike"
end
modifier_luaability_undying_tombstone_zombie_deathstrike = class({})
function modifier_luaability_undying_tombstone_zombie_deathstrike:IsHidden()
    return true
end
function modifier_luaability_undying_tombstone_zombie_deathstrike:IsDebuff()
    return false
end
function modifier_luaability_undying_tombstone_zombie_deathstrike:IsPurgable()
    return false
end
function modifier_luaability_undying_tombstone_zombie_deathstrike:OnCreated(params)
    if not IsServer() then
        return
    end
end
function modifier_luaability_undying_tombstone_zombie_deathstrike:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK
    }
end
function modifier_luaability_undying_tombstone_zombie_deathstrike:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end
function modifier_luaability_undying_tombstone_zombie_deathstrike:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_move_speed")
end
function modifier_luaability_undying_tombstone_zombie_deathstrike:OnAttack(params)
    if not IsServer() then
        return
    end
    if params.attacker ~= self:GetParent() then
        return
    end
    if not IsValid(params.target) then
        return
    end
    params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_luaability_undying_tombstone_zombie_deathstrike_debuff", {
        duration = self:GetAbility():GetSpecialValueFor("duration")
    })
end

modifier_luaability_undying_tombstone_zombie_deathstrike_debuff = class({})
function modifier_luaability_undying_tombstone_zombie_deathstrike_debuff:IsHidden()
    return false
end
function modifier_luaability_undying_tombstone_zombie_deathstrike_debuff:IsDebuff()
    return true
end
function modifier_luaability_undying_tombstone_zombie_deathstrike_debuff:IsPurgable()
    return true
end
function modifier_luaability_undying_tombstone_zombie_deathstrike_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end
function modifier_luaability_undying_tombstone_zombie_deathstrike_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.slow * self:GetStackCount()
end
function modifier_luaability_undying_tombstone_zombie_deathstrike_debuff:OnCreated(params)
    self:OnRefresh(params)
end
function modifier_luaability_undying_tombstone_zombie_deathstrike_debuff:OnRefresh(params)
    if not IsValid(self:GetAbility()) then
        return
    end
    self.slow = self:GetAbility():GetSpecialValueFor("slow")
    if IsServer() then
        self:IncrementStackCount()
        self.hTarget = self:GetParent()
        local sTimer = Timers:CreateTimer(
        params.duration,
        function()
            if IsValid(self) then
                self:DecrementStackCount()
            end
        end
        )
        if not self.tTimers then
            self.tTimers = {}
        end
        table.insert(self.tTimers, sTimer)
    end
end
function modifier_luaability_undying_tombstone_zombie_deathstrike_debuff:OnDestroy()
    if IsServer() then
        for _, sTimer in ipairs(self.tTimers) do
            Timers:RemoveTimer(sTimer)
        end
    end
end