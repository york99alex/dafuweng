require("Ability/LuaAbility")
----路径技能：河道寒流减甲
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == path_13_hujia then
    path_13_hujia = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_path_13_hujia_L1", "Ability/path/path_13_hujia.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_13_hujia_L2", "Ability/path/path_13_hujia.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_13_hujia_L3", "Ability/path/path_13_hujia.lua", LUA_MODIFIER_MOTION_NONE)
    -- if PrecacheItems then
    --     table.insert(PrecacheItems, "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf")
    -- end
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function path_13_hujia:constructor()
    path_13_hujia.__base__.constructor(self)
end
function path_13_hujia:GetIntrinsicModifierName()
    return "modifier_" .. self:GetAbilityName() .. "_L" .. self:GetLevel()
end

----默认buff
modifier_path_13_hujia_L1 = class({})
function modifier_path_13_hujia_L1:IsHidden()
    return false
end
function modifier_path_13_hujia_L1:IsDebuff()
    return false
end
function modifier_path_13_hujia_L1:IsPurgable()
    return false
end
function modifier_path_13_hujia_L1:GetTexture()
    return "path13"
end
function modifier_path_13_hujia_L1:OnDestroy()
    if IsClient() then
        return
    end
    self:GetParent():RemoveModifierByName("modifier_ignore_armor")
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
function modifier_path_13_hujia_L1:OnCreated(kv)
    if not IsValid(self) then
        return
    end
    if not IsValid(self:GetAbility()) then
        return
    end
    self.ignore_armor = self:GetAbility():GetSpecialValueFor("ignore_armor")
    if IsServer() then
        self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ignore_armor", {})
    end
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
-- function modifier_path_13_hujia_L1:GetBonusNightVision()
--     if IsClient() then
--         return self.ignore_armor
--     end
-- end
function modifier_path_13_hujia_L1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
    -- MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }
    return funcs
end

function modifier_path_13_hujia_L1:GetBonusDayVision()
    return self.ignore_armor
end
modifier_path_13_hujia_L2 = class({}, nil, modifier_path_13_hujia_L1)
modifier_path_13_hujia_L3 = class({}, nil, modifier_path_13_hujia_L1)