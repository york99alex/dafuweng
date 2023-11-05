require("Ability/LuaAbility")
----路径技能：鵰巢
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == path_17 then
    path_17 = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_path_17", "Ability/path/path_17.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_17_L1", "Ability/path/path_17.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_17_L2", "Ability/path/path_17.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_17_L3", "Ability/path/path_17.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_17_debuff", "Ability/path/path_17.lua", LUA_MODIFIER_MOTION_NONE)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function path_17:constructor()
    path_17.__base__.constructor(self)
end
function path_17:GetIntrinsicModifierName()
    return "modifier_" .. self:GetAbilityName() .. "_L" .. self:GetLevel()
end

----默认buff
modifier_path_17_L1 = class({})
function modifier_path_17_L1:IsHidden()
    return false
end
function modifier_path_17_L1:IsDebuff()
    return false
end
function modifier_path_17_L1:IsPurgable()
    return false
end
function modifier_path_17_L1:GetTexture()
    return "path17"
end
function modifier_path_17_L1:OnDestroy()
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
    if self.tEventID then
        for _, nID in pairs(self.tEventID) do
            EventManager:unregisterByID(nID)
        end
    end
end
function modifier_path_17_L1:OnCreated(kv)
    if not IsValid(self) then
        return
    end
    if not IsValid(self:GetAbility()) then
        return
    end
    local oAblt = self:GetAbility()
    self.jiansu = self:GetAbility():GetSpecialValueFor("jiansu")
    self.damage = oAblt:GetSpecialValueFor("damage")

    if IsClient() or not self:GetParent():IsRealHero() then
        return
    end
    self.oPlayer = PlayerManager:getPlayer(self:GetParent():GetPlayerID())
    if not self.oPlayer then
        return
    end

    local function checkBZ(eBZ)
        if not NULL(eBZ) then
            if 3 == oAblt:GetLevel() or TP_DOMAIN_6 == eBZ.m_path.m_typePath then
                return true
            end
        end
        return false
    end

    ----给玩家兵卒buff
    Timers:CreateTimer(0.1, function()
        if IsValid(self) and IsValid(self:GetAbility()) then
            for _, eBZ in pairs(self.oPlayer.m_tabBz) do
                if checkBZ(eBZ) then
                    eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self:GetName(), {})
                end
            end
            self.unUpdateBZBuffByCreate = AbilityManager:updataBZBuffByCreate(self.oPlayer, self:GetAbility(), function(eBZ)
                if checkBZ(eBZ) and IsValid(self) then
                    eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self:GetName(), {})
                end
            end)
        end
    end)

    self.tEventID = {}

    local tabPath = PathManager:getPathByType(TP_DOMAIN_6)
    local pathMid = tabPath[2]
    local eDiao = pathMid.m_eDiao
    if not eDiao then
        return
    end

    ----监听敌人移动
    local tabMover = {}
    ----伤害检测
    local strDeBuffName = "modifier_path_17_debuff"
    local sDamageCD = "_onAblt_path_17_DamageCD" .. oAblt:GetEntityIndex()
    local sHasBuff
    if 2 <= oAblt:GetLevel() then
        ----2级以上带减速
        sHasBuff = "_onAblt_path_17_HasBuff" .. oAblt:GetEntityIndex()
    end
    local funOnDamage = function(v3, nID)
        if not IsValid(oAblt) then
            return
        end
        for _, v in pairs(tabMover) do
            if IsValid(v) then
                local nDis = (v:GetAbsOrigin() - v3):Length2D()
                if nDis > 200 then
                    if sHasBuff and v[sHasBuff .. nID] then
                        ----脱离范围删除减速buff
                        v[sHasBuff .. nID] = false
                        v:RemoveModifierByNameAndCaster(strDeBuffName, self.oPlayer.m_eHero)
                    end
                    return
                end
                if not v[sDamageCD .. nID] then
                    v[sDamageCD .. nID] = true
                    AMHC:Damage(self.oPlayer.m_eHero, v, self.damage, oAblt:GetAbilityDamageType(), oAblt)
                    Timers:CreateTimer(0.5, function()
                        v[sDamageCD .. nID] = false
                    end)
                end
                if sHasBuff and not v[sHasBuff .. nID] then
                    v[sHasBuff .. nID] = true
                    local oBuff = v:AddNewModifier(self.oPlayer.m_eHero, oAblt, strDeBuffName, {})
                end
            end
        end
    end
    local funOnMove = function(tabEvent)
        if tabEvent.entity == self.oPlayer.m_eHero then
            return
        end
        if not IsValid(oAblt) then
            return true
        end
        if 0 < bit.band(PS_InPrison, self.oPlayer.m_typeState) then
            return
        end

        ----添加移动中的实体
        table.insert(tabMover, tabEvent.entity)

        ----获取要生成飓风的路径区
        local tPaths = { {} }
        for _, path in pairs(PathManager.m_tabPaths) do
            if instanceof(path, PathDomain)
            and path.m_nOwnerID == self.oPlayer.m_nPlayerID
            and path.m_tabENPC[1] and checkBZ(path.m_tabENPC[1]) then
                local tab = tPaths[#tPaths]
                if tab[#tab] and tab[#tab].m_nID + 1 ~= path.m_nID then
                    table.insert(tPaths, {})
                end
                table.insert(tPaths[#tPaths], path)
                if #PathManager.m_tabPaths == path.m_nID and tPaths[1][1] and 1 == tPaths[1][1].m_nID then
                    ----首位相连
                    tPaths[1] = concat(tPaths[1], tPaths[#tPaths])
                    table.remove(tPaths, #tPaths)
                end
            end
        end

        ----创建飓风
        for _, tab in pairs(tPaths) do
            local nPtclID = AMHC:CreateParticle("particles/neutral_fx/tornado_ambient.vpcf"
            , PATTACH_POINT, false, eDiao)
            ----刮风在路径上做往复移动
            local tabPathMove = { tab[1] }
            if 1 < #tab then
                table.insert(tabPathMove, tab[#tab])
            end
            local pathCur = tabPathMove[1]
            local function getNextPath()
                for i = #tabPathMove, 1, -1 do
                    if tabPathMove[i] == pathCur then
                        if tabPathMove[i + 1] then return tabPathMove[i + 1] end
                        if tabPathMove[1] then return tabPathMove[1] end
                    end
                end
                return pathCur
            end

            ----持续移动飓风
            local function funMoveFeng()
                ----下一个目标
                local pathNext = getNextPath()
                ----计算运动
                local nFps = 30
                local nFpsTime = 1 / nFps
                local v3Dis = pathNext.m_entity:GetAbsOrigin() - pathCur.m_entity:GetAbsOrigin()
                local nTimeSum = 2 * nFps
                local v3Speed = v3Dis / nTimeSum
                local v3Cur = pathCur.m_entity:GetAbsOrigin()
                local nTimeCur = math.floor(nTimeSum)

                Timers:CreateTimer(function()
                    if 0 < #tabMover and IsValid(oAblt) then
                        v3Cur = v3Cur + v3Speed
                        ParticleManager:SetParticleControl(nPtclID, 0, v3Cur)
                        funOnDamage(v3Cur, nPtclID)   ----触发伤害和减速
                        pathMid:setDiaoGesture(ACT_DOTA_CAST_ABILITY_1)
                        nTimeCur = nTimeCur - 1
                        if 0 < nTimeCur then
                            return nFpsTime
                        end
                        pathCur = pathNext
                        funMoveFeng()
                    else
                        if IsValid(tabEvent.entity) then
                            tabEvent.entity:RemoveModifierByNameAndCaster(strDeBuffName, self.oPlayer.m_eHero)
                        end
                        ParticleManager:DestroyParticle(nPtclID, false)
                        pathMid:setDiaoGesture(-ACT_DOTA_CAST_ABILITY_1)

                        ----初始化伤害检测变量
                        tabEvent.entity[sDamageCD .. nPtclID] = false
                        tabEvent.entity[sDamageCD .. nPtclID] = false
                    end
                end)
            end
            funMoveFeng()
        end
    end
    if GS_Move == GMManager.m_typeState then
        ----当前已经在移动阶段，手动调用
        for _, v in pairs(PlayerManager.m_tabPlayers) do
            if 0 < bit.band(PS_Moving, v.m_typeState) then
                funOnMove({ entity = v.m_eHero })
            end
        end
    end
    table.insert(self.tEventID, EventManager:register("Event_Move", funOnMove))
    table.insert(self.tEventID, EventManager:register("Event_MoveEnd", function(tabEvent)
        if nil == oAblt or oAblt:IsNull() then
            return true
        end
        for k, v in pairs(tabMover) do
            if v == tabEvent.entity then
                table.remove(tabMover, k)
                break
            end
        end
    end))
end

function modifier_path_17_L1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }
    return funcs
end

function modifier_path_17_L1:GetBonusDayVision()
    return self.damage
end

function modifier_path_17_L1:GetBonusNightVision()
    return self.jiansu
end
modifier_path_17_L2 = class({}, nil, modifier_path_17_L1)
modifier_path_17_L3 = class({}, nil, modifier_path_17_L1)
modifier_path_17_debuff = class({})

function modifier_path_17_debuff:IsHidden()
    return false
end

function modifier_path_17_debuff:IsDebuff()
    return true
end

function modifier_path_17_debuff:IsPurgable()
    return false
end

function modifier_path_17_debuff:GetTexture()
    return "path17"
end

function modifier_path_17_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_path_17_debuff:GetModifierMoveSpeedBonus_Percentage(params)
    return self.jiansu
end

function modifier_path_17_debuff:OnCreated(kv)
    self.jiansu = self:GetAbility():GetSpecialValueFor("jiansu")
end