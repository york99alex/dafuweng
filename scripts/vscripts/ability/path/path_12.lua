require("Ability/LuaAbility")
----路径技能：天辉
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == path_12 then
    path_12 = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_path_12", "Ability/path/path_12.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_12_L1", "Ability/path/path_12.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_12_L2", "Ability/path/path_12.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_12_L3", "Ability/path/path_12.lua", LUA_MODIFIER_MOTION_NONE)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function path_12:constructor()
    path_12.__base__.constructor(self)
end
function path_12:GetIntrinsicModifierName()
    return "modifier_" .. self:GetAbilityName() .. "_L" .. self:GetLevel()
end

----默认buff
modifier_path_12_L1 = class({})

function modifier_path_12_L1:IsHidden()
    return false
end

function modifier_path_12_L1:IsDebuff()
    return false
end

function modifier_path_12_L1:IsPurgable()
    return false
end

function modifier_path_12_L1:GetTexture()
    return "path12"
end
-- function modifier_path_12_L1:GetEffectName()
--     return "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf"
-- end
-- function modifier_path_12_L1:GetEffectAttachType()
--     return PATTACH_OVERHEAD_FOLLOW
-- end
function modifier_path_12_L1:OnDestroy()
    if self.oPlayer and self.sBuffName then
        for _, eBZ in pairs(self.oPlayer.m_tabBz) do
            if IsValid(eBZ) then
                eBZ:RemoveModifierByName(self.sBuffName)
            end
        end
    end
    if self.unUpdataBZBuffByCreate then
        self:unUpdataBZBuffByCreate()
    end
end

function modifier_path_12_L1:OnCreated(kv)
    if not IsValid(self) then
        return
    end
    if not IsValid(self:GetAbility()) then
        return
    end
    self.hujia = self:GetAbility():GetSpecialValueFor("hujia")
    self.mokang = self:GetAbility():GetSpecialValueFor("mokang")
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
            self.sBuffName = self:GetName()
            for _, eBZ in pairs(self.oPlayer.m_tabBz) do
                eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self.sBuffName, {})
            end
            self.unUpdataBZBuffByCreate = AbilityManager:updataBZBuffByCreate(self.oPlayer, self:GetAbility(), function(eBZ)
                if IsValid(self) then
                    eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self.sBuffName, {})
                end
            end)
        end
    end)
end

function modifier_path_12_L1:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_path_12_L1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
    return funcs
end

function modifier_path_12_L1:GetModifierPhysicalArmorBonus()
    return self.hujia
end

function modifier_path_12_L1:GetModifierMagicalResistanceBonus()
    return self.mokang
end
modifier_path_12_L2 = class({}, nil, modifier_path_12_L1)
modifier_path_12_L3 = class({}, nil, modifier_path_12_L1)

function modifier_path_12_L3:OnCreated(kv)
    modifier_path_12_L3.__base__.OnCreated(self, kv)
    if IsClient() then
        return
    end

    self.oPlayer = PlayerManager:getPlayer(self:GetParent():GetPlayerOwnerID())
    if not self.oPlayer then
        return
    end
    local tPaths = PathManager:getPathByType(TP_DOMAIN_1)
    if 3 ~= #tPaths
    or self:GetParent() ~= tPaths[2].m_tabENPC[1] then
        return
    end

    self.tEventID = {}

    ----合体兵卒
    local function setBZ321()
        if not IsValid(tPaths[2].m_tabENPC[1]) then
            return
        end
        ----移除边上2个兵卒
        if tPaths[1].m_tabENPC[1] then
            self.oPlayer:removeBz(tPaths[1].m_tabENPC[1])
        end
        if tPaths[3].m_tabENPC[1] then
            self.oPlayer:removeBz(tPaths[3].m_tabENPC[1])
        end

        ----成长中间的兵卒
        self.eBZ = tPaths[2].m_tabENPC[1]
        -- table.insert(self.m_tabBz, eBZ)
        table.insert(tPaths[1].m_tabENPC, self.eBZ)
        table.insert(tPaths[3].m_tabENPC, self.eBZ)
        ----变大
        self.eBZ:SetModelScale(2)
        ----等级翻倍
        for i = self.eBZ:GetLevel(), 1, -1 do
            self.eBZ:LevelUp(false)
        end

        ----增加攻击距离
        self.nAddAtkRange = self.eBZ:GetBaseAttackRange()
        local tData = {}
        tData[tostring(self.eBZ:GetEntityIndex())] = self.nAddAtkRange
        CustomNetTables:SetTableValue("GameingTable", self:GetName(), tData)

        ----特效
        if ACT_DOTA_SPAWN_STATUE then
            self.eBZ:StartGesture(ACT_DOTA_SPAWN_STATUE)
        end
        -- Timers:CreateTimer(1, function()
        --     self.eBZ:RemoveGesture(ACT_DOTA_VICTORY)
        --     -- self.eBZ:Stop()
        -- end)
        for _, path in pairs(tPaths) do
            local nPtclID = AMHC:CreateParticle("particles/units/unit_greevil/loot_greevil_death.vpcf"
            , PATTACH_ABSORIGIN, false, self.eBZ, 5)
            ParticleManager:SetParticleControl(nPtclID, 0, path.m_eCity:GetAbsOrigin())
            ParticleManager:SetParticleControl(nPtclID, 1, path.m_eCity:GetAbsOrigin())
            ParticleManager:SetParticleControl(nPtclID, 2, path.m_eCity:GetAbsOrigin())
        end
        EmitGlobalSound("Custom.AYZZ.All")

        ----重新计算兵卒升级
        table.insert(self.tEventID, EventManager:register("Event_BZLevelUp", function(tEvent)
            if not IsValid(self) or not IsValid(self.eBZ) then
                return true
            end
            if tEvent.eBZ == self.eBZ then
                tEvent.nLevel = self.oPlayer.m_eHero:GetLevel() * 2 - self.eBZ:GetLevel()
            end
        end))
    end

    ----判断天辉是否有在被攻城
    local bGCLD = false
    for _, path in pairs(tPaths) do
        if path.m_nPlayerIDGCLD then
            bGCLD = true
            break
        end
    end
    if bGCLD then
        ----等待攻城结束再合体
        table.insert(self.tEventID, EventManager:register("Event_GCLDEnd", function(tEvent)
            if TP_DOMAIN_1 == tEvent.path.m_typePath then
                setBZ321()
                return true
            end
        end))
    else
        setBZ321()
    end
end

function modifier_path_12_L3:OnDestroy()
    modifier_path_12_L3.__base__.OnDestroy(self)

    if self.tEventID then
        for _, v in pairs(self.tEventID) do
            EventManager:unregisterByID(v)
        end
    end

    if self.oPlayer and self.eBZ then
        ----解体巨人兵卒
        local tPaths = PathManager:getPathByType(TP_DOMAIN_1)
        if 3 ~= #tPaths then
            return
        end

        ----创建边上2个兵卒
        for i = 1, 3, 2 do
            for k, v in pairs(tPaths[i].m_tabENPC) do
                if not IsValid(v) or v == self.eBZ then
                    table.remove(tPaths[i].m_tabENPC, k)
                end
            end
        end
        self.oPlayer:createBzOnPath(tPaths[1], 3)
        self.oPlayer:createBzOnPath(tPaths[3], 3)

        ----还原中间的兵卒
        if IsValid(self.eBZ) and tPaths[2].m_tabENPC[1] == self.eBZ then
            -- table.insert(self.m_tabBz, eBZ)
            pcall(function()
                self.eBZ:StartGesture(ACT_DOTA_SPAWN_STATUE)
            end)
            self.eBZ:ModifyHealth(self.eBZ:GetMaxHealth(), nil, false, 0)
            self.eBZ:SetModelScale(KeyValues.UnitsKv[self.eBZ:GetUnitName()].ModelScale or 1)
            self.oPlayer:setBzLevelUp(self.eBZ)
        end
    end
end

function modifier_path_12_L3:GetModifierAttackRangeBonus()
    if not self.nAddAtkRange then
        local tData = CustomNetTables:GetTableValue("GameingTable", self:GetName())
        if tData then
            self.nAddAtkRange = tData[tostring(self:GetParent():GetEntityIndex())]
        end
    end
    return self.nAddAtkRange
    -- return 300
end

function modifier_path_12_L3:GetBonusDayVision()
    return self.nAddAtkRange
    -- return 300
end

function modifier_path_12_L3:GetBonusNightVision()
    return self.nAddAtkRange
    -- return 300
end

function modifier_path_12_L3:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }
    return funcs
end