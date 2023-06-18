require("Ability/LuaAbility")
----路径技能：蛇沼
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == path_14 then
    path_14 = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_path_14", "Ability/path/path_14.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_14_L1", "Ability/path/path_14.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_14_L2", "Ability/path/path_14.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_14_L3", "Ability/path/path_14.lua", LUA_MODIFIER_MOTION_NONE)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function path_14:constructor()
    path_14.__base__.constructor(self)
end
function path_14:GetIntrinsicModifierName()
    return "modifier_" .. self:GetAbilityName() .. "_L" .. self:GetLevel()
end

----默认buff
modifier_path_14_L1 = class({})

function modifier_path_14_L1:IsHidden()
    return false
end

function modifier_path_14_L1:IsDebuff()
    return false
end

function modifier_path_14_L1:IsPurgable()
    return false
end

function modifier_path_14_L1:GetTexture()
    return "path14"
end

function modifier_path_14_L1:OnDestroy()
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
    if self.tEventID then
        for _, nID in pairs(self.tEventID) do
            EventManager:unregisterByID(nID)
        end
    end
end

function modifier_path_14_L1:OnCreated(kv)
    if not IsValid(self) then
        return
    end
    if not IsValid(self:GetAbility()) then
        return
    end
    self.time = self:GetAbility():GetSpecialValueFor("time")
    self.chance = self:GetAbility():GetSpecialValueFor("chance")
    if IsClient() or not self:GetParent():IsRealHero() then
        return
    end
    self.oPlayer = PlayerManager:getPlayer(self:GetParent():GetPlayerID())
    if not self.oPlayer then
        return
    end

    ----给玩家兵卒buff
    local function checkBZ(eBZ)
        if not NULL(eBZ) then
            if 3 == self:GetAbility():GetLevel() or TP_DOMAIN_3 == eBZ.m_path.m_typePath then
                return true
            end
        end
        return false
    end
    Timers:CreateTimer(0.1, function()
        if IsValid(self) and IsValid(self:GetAbility()) then
            self.sBuffName = self:GetName()
            for _, eBZ in pairs(self.oPlayer.m_tabBz) do
                if checkBZ(eBZ) then
                    eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self.sBuffName, {})
                end
            end
            self.unUpdataBZBuffByCreate = AbilityManager:updataBZBuffByCreate(self.oPlayer, self:GetAbility(), function(eBZ)
                if checkBZ(eBZ) and IsValid(self) then
                    eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self.sBuffName, {})
                end
            end)
        end
    end)

    ----监听玩家路过某路径事件
    self.tEventID = {
        EventManager:register("Event_PassingPath", self.onEvent_PassingPath, self)
    }
end

function modifier_path_14_L1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }
    return funcs
end

function modifier_path_14_L1:GetBonusDayVision()
    return self.time
end

function modifier_path_14_L1:GetBonusNightVision()
    return self.chance
end

function modifier_path_14_L1:onEvent_PassingPath(tabEvent)
    local oPlayer = self.oPlayer
    if not oPlayer or not IsValid(self) then
        return true
    end
    if tabEvent.entity.bTriggered
    or tabEvent.path.m_nOwnerID ~= oPlayer.m_nPlayerID
    or tabEvent.entity == oPlayer.m_eHero
    or 0 ~= bit.band(PS_InPrison, oPlayer.m_typeState)
    then
        return
    end
    if not tabEvent.path.m_tabENPC
    or not IsValid(tabEvent.path.m_tabENPC[1])
    or not tabEvent.path.m_tabENPC[1]:FindModifierByName(self:GetName())
    then
        return
    end

    ----判断触发
    local oPlayerTarget = PlayerManager:getPlayer(tabEvent.entity:GetPlayerOwnerID())
    if nil == oPlayerTarget or 0 < bit.band(oPlayerTarget.m_typeState, PS_AbilityImmune) then
        return  ----技能免疫
    end
    ---- 计算缠绕概率
    if RandomInt(1, 100) > self.chance then
        return
    end
    ----触发
    tabEvent.entity.bTriggered = true
    EventManager:register("Event_MoveEnd", function(tabEvent2)
        if tabEvent2.entity == tabEvent.entity then
            tabEvent.entity.bTriggered = nil  ----一次移动阶段只触发一次
            return true
        end
    end)

    ----设置缠绕玩家禁止移动
    oPlayerTarget:setState(PS_Rooted)

    ----计算缠绕运动
    local nFps = 30
    local nFpsTime = 1 / nFps
    local v3Dis = Vector(0, 0, oPlayerTarget.m_eHero:GetModelRadius() * 2.5)
    local nTimeSum = self.time * 0.5 * nFps
    local v3Speed = v3Dis / nTimeSum
    local v3Cur = oPlayerTarget.m_eHero:GetAbsOrigin()
    local nTimeCur = math.floor(nTimeSum * 0.5)

    local nPtclID2 = AMHC:CreateParticle("particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_ti6_arc_b.vpcf"
    , PATTACH_POINT_FOLLOW, false, oPlayerTarget.m_eHero, self.time)
    ParticleManager:SetParticleControlOrientationFLU(nPtclID2, 3, Vector(0, 0, 1), Vector(0, 1, 0), Vector(1, 0, 0))

    ----向上缠绕
    EmitSoundOn("Hero_ShadowShaman.Shackles.Cast", oPlayerTarget.m_eHero)
    Timers:CreateTimer(0, function()
        v3Cur = v3Cur + v3Speed
        ParticleManager:SetParticleControl(nPtclID2, 3, v3Cur)
        nTimeCur = nTimeCur - 1
        if 0 < nTimeCur then
            return nFpsTime
        end

        ----向下缠绕
        Timers:CreateTimer(nFpsTime, function()
            v3Cur = v3Cur - v3Speed
            ParticleManager:SetParticleControl(nPtclID2, 3, v3Cur)
            nTimeCur = nTimeCur + 1
            if nTimeSum > nTimeCur then
                return nFpsTime
            end

            ----结束
            ---- self:GetCaster():RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_1)
            local nPtclID = AMHC:CreateParticle("particles/econ/items/shadow_shaman/shadow_shaman_ti8/shadow_shaman_ti8_ether_shock_target_snakes.vpcf"
            , PATTACH_CENTER_FOLLOW, false, oPlayerTarget.m_eHero, 2)
            ParticleManager:SetParticleControl(nPtclID, 0, oPlayerTarget.m_eHero:GetOrigin())
            ParticleManager:SetParticleControl(nPtclID, 1, oPlayerTarget.m_eHero:GetOrigin() + Vector(0, 0, 10))
            EmitSoundOn("Hero_Medusa.MysticSnake.Cast", oPlayerTarget.m_eHero)

            ----设置缠绕玩家禁止移动取消
            oPlayerTarget:setState(-PS_Rooted)
            return nil
        end)
    end)
end

modifier_path_14_L2 = class({}, nil, modifier_path_14_L1)
modifier_path_14_L3 = class({}, nil, modifier_path_14_L1)