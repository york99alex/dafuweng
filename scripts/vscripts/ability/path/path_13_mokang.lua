require("Ability/LuaAbility")
----路径技能：河道寒流减魔抗
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == path_13_mokang then
    path_13_mokang = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_path_13_mokang", "Ability/path/path_13_mokang.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_13_mokang_L1", "Ability/path/path_13_mokang.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_13_mokang_L2", "Ability/path/path_13_mokang.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_13_mokang_L3", "Ability/path/path_13_mokang.lua", LUA_MODIFIER_MOTION_NONE)
    -- if PrecacheItems then
    --     table.insert(PrecacheItems, "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf")
    -- end
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function path_13_mokang:constructor()
    path_13_mokang.__base__.constructor(self)
end
function path_13_mokang:GetIntrinsicModifierName()
    return "modifier_" .. self:GetAbilityName() .. "_L" .. self:GetLevel()
end

----默认buff
modifier_path_13_mokang_L1 = class({})

function modifier_path_13_mokang_L1:IsHidden()
    return false
end

function modifier_path_13_mokang_L1:IsDebuff()
    return false
end

function modifier_path_13_mokang_L1:IsPurgable()
    return false
end

function modifier_path_13_mokang_L1:GetTexture()
    return "path13"
end
-- function modifier_path_13_mokang_L1:GetEffectName()
--     return "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf"
-- end
-- function modifier_path_13_mokang_L1:GetEffectAttachType()
--     return PATTACH_OVERHEAD_FOLLOW
-- end
function modifier_path_13_mokang_L1:OnDestroy()
    if IsClient() then
        return
    end
    if self.key then
        SetIgnoreMagicResistanceValue(self:GetParent(), nil, self.key)
    end
    if self.oPlayer then
        for _, eBZ in pairs(self.oPlayer.m_tabBz) do
            if IsValid(eBZ) then
                eBZ:RemoveModifierByName(self:GetName())
            end
        end
    end
    if self.unUpdateBZBuffByCreate then
        self:unUpdateBZBuffByCreate()
    end
end

function modifier_path_13_mokang_L1:OnCreated(kv)
    if not IsValid(self) then
        return
    end
    if not IsValid(self:GetAbility()) then
        return
    end
    self.ignore_resistance = self:GetAbility():GetSpecialValueFor("ignore_resistance")
    self.key = SetIgnoreMagicResistanceValue(self:GetParent(), self.ignore_resistance * 0.01)
    if IsClient() or not self:GetParent():IsRealHero() then
        return
    end
    self.oPlayer = PlayerManager:getPlayer(self:GetParent():GetPlayerID())
    if not self.oPlayer then
        return
    end
    ----给玩家全部兵卒buff
    Timers:CreateTimer(0.1, function()
        if IsValid(self) and IsValid(self:GetAbility()) then
            for _, eBZ in pairs(self.oPlayer.m_tabBz) do
                eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self:GetName(), {})
            end
            self.unUpdateBZBuffByCreate = AbilityManager:updataBZBuffByCreate(self.oPlayer, self:GetAbility(), function(eBZ)
                if IsValid(self) then
                    eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self:GetName(), {})
                end
            end)
        end
    end)
end

function modifier_path_13_mokang_L1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
    -- MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }
    return funcs
end

function modifier_path_13_mokang_L1:GetBonusDayVision()
    return self.ignore_resistance
end
-- function modifier_path_13_mokang_L1:GetBonusNightVision()
--     if IsClient() then
--         return self.ignore_resistance
--     end
-- end
modifier_path_13_mokang_L2 = class({}, nil, modifier_path_13_mokang_L1)
modifier_path_13_mokang_L3 = class({}, nil, modifier_path_13_mokang_L1)