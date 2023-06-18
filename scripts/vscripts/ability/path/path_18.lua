require("Ability/LuaAbility")
----路径技能：
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == path_18 then
    path_18 = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_path_18", "Ability/path/path_18.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_18_L1", "Ability/path/path_18.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_18_L2", "Ability/path/path_18.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_18_L3", "Ability/path/path_18.lua", LUA_MODIFIER_MOTION_NONE)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function path_18:constructor()
    path_18.__base__.constructor(self)
end
function path_18:GetIntrinsicModifierName()
    return "modifier_" .. self:GetAbilityName() .. "_L" .. self:GetLevel()
end

----默认buff
modifier_path_18_L1 = class({})

function modifier_path_18_L1:IsHidden()
    return false
end

function modifier_path_18_L1:IsDebuff()
    return false
end

function modifier_path_18_L1:IsPurgable()
    return false
end

function modifier_path_18_L1:GetTexture()
    return "path18"
end

function modifier_path_18_L1:OnDestroy()
    if self.oPlayer then
        for _, eBZ in pairs(self.oPlayer.m_tabBz) do
            if IsValid(eBZ) and TP_DOMAIN_7 == eBZ.m_path.m_typePath then
                eBZ:RemoveModifierByName(self:GetName())
                eBZ:RemoveModifierByNameAndCaster("modifier_medusa_stone_gaze_stone", self.oPlayer.m_eHero)
            end
        end
    end
    if self.unUpdataBZBuffByCreate then
        self:unUpdataBZBuffByCreate()
    end
    if self.tEventID then
        for _, nID in pairs(self.tEventID) do
            EventManager:unregisterByID(nID)
        end
    end
end

function modifier_path_18_L1:OnCreated(kv)
    if not IsValid(self) then
        return
    end
    if not IsValid(self:GetAbility()) then
        return
    end
    local oAblt = self:GetAbility()
    local typeDamage = DAMAGE_TYPE_PURE
    self.damage = oAblt:GetSpecialValueFor("damage")
    if IsClient() or not self:GetParent():IsRealHero() then
        return
    end
    self.oPlayer = PlayerManager:getPlayer(self:GetParent():GetPlayerID())
    if not self.oPlayer then
        return
    end
    self.tEventID = {}

    ----给玩家兵卒buff
    Timers:CreateTimer(0.1, function()
        if IsValid(self) and IsValid(self:GetAbility()) then
            for _, eBZ in pairs(self.oPlayer.m_tabBz) do
                if TP_DOMAIN_7 == eBZ.m_path.m_typePath then
                    eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self:GetName(), {})
                end
            end
            self.unUpdataBZBuffByCreate = AbilityManager:updataBZBuffByCreate(self.oPlayer, self:GetAbility(), function(eBZ)
                if TP_DOMAIN_7 == eBZ.m_path.m_typePath and IsValid(self) then
                    eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self:GetName(), {})
                    Timers:CreateTimer(0.5, function()
                        if IsValid(oAblt) then
                            eBZ:AddNewModifier(self.oPlayer.m_eHero, oAblt, "modifier_medusa_stone_gaze_stone", nil)
                        end
                    end)
                end
            end)
        end
    end)
    ----石化兵卒
    Timers:CreateTimer(0.5, function()
        if oAblt:IsNull() then
            return
        end
        for _, v in pairs(self.oPlayer.m_tabBz) do
            if TP_DOMAIN_7 == v.m_path.m_typePath and not v:HasModifier("modifier_medusa_stone_gaze_stone") then
                v:AddNewModifier(self.oPlayer.m_eHero, oAblt, "modifier_medusa_stone_gaze_stone", nil)
            end
        end
    end)

    ----监听单位触发路径
    table.insert(self.tEventID, EventManager:register("Event_OnPath", function(tabEvent)
        if TP_DOMAIN_7 ~= tabEvent.path.m_typePath or tabEvent.entity:GetPlayerOwnerID() == self.oPlayer.m_nPlayerID then
            return
        end
        if oAblt:IsNull() then
            return true
        end
        if 0 < bit.band(PS_InPrison, self.oPlayer.m_typeState) then
            return
        end

        ----圣光特效
        local nPtclID = AMHC:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf"
        , PATTACH_POINT, false, tabEvent.entity)
        EmitGlobalSound("Hero_Omniknight.Purification")

        ----造成伤害
        local nEventID = EventManager:register("Event_Atk", function(tEvent2)
            if
            -- IsValid(self.oPlayer.m_eHero) and IsValid(tabEvent.entity)
            -- and self.oPlayer.m_eHero:GetEntityIndex() == tEvent2.entindex_attacker_const
            -- and tabEvent.entity:GetEntityIndex() == tEvent2.entindex_victim_const
            -- and 
            typeDamage == tEvent2.damagetype_const then
                tEvent2.damage = self.damage
            end
        end, nil, 987654321)
        AMHC:Damage(self.oPlayer.m_eHero, tabEvent.entity, self.damage, typeDamage, oAblt)
        EventManager:unregisterByID(nEventID, "Event_Atk")
    end))
    ----监听触发攻城
    table.insert(self.tEventID, EventManager:register("Event_GCLDReady", function(tabEvent)
        if TP_DOMAIN_7 ~= tabEvent.path.m_typePath or tabEvent.entity:GetPlayerOwnerID() == self.oPlayer.m_nPlayerID then
            return
        end
        if oAblt:IsNull() then
            return true
        end
        tabEvent.bIgnore = true
    end))
    ----已经在攻城
    local tPaths = PathManager:getPathByType(TP_DOMAIN_7)
    for _, path in pairs(tPaths) do
        if nil ~= path.m_nPlayerIDGCLD then
            path:atkCityEnd(false)
        end
    end
end

function modifier_path_18_L1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }
    return funcs
end

function modifier_path_18_L1:GetBonusDayVision()
    return self.damage
end

function modifier_path_18_L1:GetBonusNightVision()
    return self.jiansu
end
modifier_path_18_L2 = class({}, nil, modifier_path_18_L1)
modifier_path_18_L3 = class({}, nil, modifier_path_18_L1)