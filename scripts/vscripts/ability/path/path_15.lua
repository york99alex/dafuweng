require("Ability/LuaAbility")
----路径技能：夜魇
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == path_15 then
    path_15 = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_path_15", "Ability/path/path_15.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_15_L1", "Ability/path/path_15.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_15_L2", "Ability/path/path_15.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_15_L3", "Ability/path/path_15.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_15_chenmo", "Ability/path/path_15.lua", LUA_MODIFIER_MOTION_NONE)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function path_15:constructor()
    path_15.__base__.constructor(self)
end
function path_15:GetIntrinsicModifierName()
    return "modifier_" .. self:GetAbilityName() .. "_L" .. self:GetLevel()
end

----默认buff
modifier_path_15_L1 = class({})
function modifier_path_15_L1:IsHidden()
    return false
end
function modifier_path_15_L1:IsDebuff()
    return false
end
function modifier_path_15_L1:IsPurgable()
    return false
end
function modifier_path_15_L1:GetTexture()
    return "path15"
end
function modifier_path_15_L1:OnDestroy()
    if self.oPlayer then
        for _, eBZ in pairs(self.oPlayer.m_tabBz) do
            if IsValid(eBZ) then
                eBZ:RemoveModifierByName(self:GetName())
                eBZ:RemoveModifierByName("modifier_path_15_chenmo")
            end
        end
    end
    if self.unUpdateBZBuffByCreate then
        self:unUpdateBZBuffByCreate()
    end
    if self.tEventID then
        for _, nID in pairs(self.tEventID) do
            EventManager:unregisterByID(nID)
        end
    end
end
function modifier_path_15_L1:OnCreated(kv)
    if not IsValid(self) then
        return
    end
    if not IsValid(self:GetAbility()) then
        return
    end
    self.gongsu = self:GetAbility():GetSpecialValueFor("gongsu")
    self.yisu = self:GetAbility():GetSpecialValueFor("yisu")
    if IsClient() or not self:GetParent():IsRealHero() then
        return
    end
    self.oPlayer = PlayerManager:getPlayer(self:GetParent():GetPlayerID())
    if not self.oPlayer then
        return
    end

    ----给玩家兵卒buff
    Timers:CreateTimer(0.1, function()
        if IsValid(self) and IsValid(self:GetAbility()) then
            for _, eBZ in pairs(self.oPlayer.m_tabBz) do
                local oBuff = eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self:GetName(), {})
                if oBuff and 3 == self:GetAbility():GetLevel() and TP_DOMAIN_4 == eBZ.m_path.m_typePath then
                    oBuff:SetStackCount(2)
                    eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), "modifier_path_15" .. "_chenmo", {})
                end
            end
            self.unUpdateBZBuffByCreate = AbilityManager:updataBZBuffByCreate(self.oPlayer, self:GetAbility(), function(eBZ)
                if IsValid(self) then
                    local oBuff = eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self:GetName(), {})
                    if oBuff and 3 == self:GetAbility():GetLevel() and TP_DOMAIN_4 == eBZ.m_path.m_typePath then
                        oBuff:SetStackCount(2)
                        eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), "modifier_path_15" .. "_chenmo", {})
                    end
                end
            end)
        end
    end)
end

function modifier_path_15_L1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_path_15_L1:GetModifierAttackSpeedBonus_Constant(params)
    return self.gongsu
end

function modifier_path_15_L1:GetModifierMoveSpeedBonus_Constant()
    return self.yisu
end
modifier_path_15_L2 = class({}, nil, modifier_path_15_L1)
modifier_path_15_L3 = class({}, nil, modifier_path_15_L1)
modifier_path_15_chenmo = class({})

function modifier_path_15_chenmo:IsDebuff()
    return true
end

function modifier_path_15_chenmo:IsPurgable()
    return false
end

function modifier_path_15_chenmo:GetTexture()
    return "path15"
end