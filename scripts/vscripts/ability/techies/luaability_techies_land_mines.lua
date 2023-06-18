require("Ability/LuaAbility")
----技能：地雷    英雄：炸弹人
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_techies_land_mines then
    LuaAbility_techies_land_mines = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_techies_land_mines", "Ability/techies/LuaAbility_techies_land_mines.lua", LUA_MODIFIER_MOTION_NONE)
    if PrecacheItems then
        table.insert(PrecacheItems, "particles/units/heroes/hero_techies/techies_remote_mine.vpcf")
        table.insert(PrecacheItems, "particles/units/heroes/hero_techies/techies_suicide.vpcf")
    end
end
local this = LuaAbility_techies_land_mines
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function this:constructor()
    this.__base__.constructor(self)
end

----选择目标时
function this:CastFilterResultTarget(hTarget)
    if IsValid(hTarget) then
        return self:CastFilterResultLocation(hTarget:GetAbsOrigin())
    end
    return UF_SUCCESS
end

----选择目标地点时
function this:CastFilterResultLocation(vLocation)
    if not self:isCanCast() then
        return UF_FAIL_CUSTOM
    end
    if IsServer() then
        local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
        if oPlayer then
            local path = PathManager:getClosePath(vLocation)
            ----范围
            local nRange = math.floor(self:GetSpecialValueFor("range") * 0.5)
            local nDis = math.min(PathManager:getPathDistance(path, oPlayer.m_pathCur, true), PathManager:getPathDistance(path, oPlayer.m_pathCur, false))
            if nDis > nRange then
                self.m_strCastError = "LuaAbilityError_Range"
                return UF_FAIL_CUSTOM
            end
            ----距离
            local dis = (vLocation - path.m_entity:GetAbsOrigin()):Length2D()
            if dis > 150 then
                self.m_strCastError = "LuaAbilityError_TargetPath"
                return UF_FAIL_CUSTOM
            end
            self.m_vPosTarget = vLocation
            self.m_pathTarget = path
        end
    end
    return UF_SUCCESS
end

----开始技能效果
function this:OnSpellStart()
    if not self.m_vPosTarget or not self.m_pathTarget then
        return
    end
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if not oPlayer then
        return
    end

    ----音效
    EmitGlobalSound("Hero_Techies.LandMine.Plant")

    ----创建地雷
    local eBomb = AMHC:CreateUnit("bomb", self.m_vPosTarget, 0, self:GetCaster(), DOTA_TEAM_GOODGUYS)
    eBomb.m_nDamage = self:GetSpecialValueFor("damage")
    eBomb.m_path = self.m_pathTarget
    eBomb._GetOwner = eBomb.GetOwner
    eBomb.GetOwner = function(self)
        local eOwner = eBomb:_GetOwner()
        if not IsValid(eOwner) then
            if IsValid(eBomb.m_path.m_tabENPC[1]) and eBomb.m_path.m_tabENPC[1]:GetPlayerOwnerID() == oPlayer.m_nPlayerID then
                eOwner = eBomb.m_path.m_tabENPC[1]
            else
                eOwner = oPlayer.m_eHero
            end
        end
        return eOwner
    end
    if not oPlayer._tBombs then oPlayer._tBombs = {} end
    if not oPlayer._tBombs[eBomb.m_path] then oPlayer._tBombs[eBomb.m_path] = {} end
    table.insert(oPlayer._tBombs[eBomb.m_path], eBomb)

    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = self })
    ----设置冷却
    AbilityManager:setRoundCD(oPlayer, self)

    ----该地区有人直接引爆
    Timers:CreateTimer(1, function()
        if IsValid(eBomb) then
            local tEnt = eBomb.m_path:getJoinEnt()
            for _, v in pairs(tEnt) do
                if self:checkTarget(v) then
                    EventManager:fireEvent("Event_BombDetonate", {
                        path = eBomb.m_path,
                        player = oPlayer,
                    })
                    return
                end
            end
        end
    end)
end

----验证目标
function this:checkTarget(eTarget)
    if not IsValid(eTarget) then
        return false
    end
    if eTarget:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID() then
        return false
    end
    ---@type Player
    local playerTarget = PlayerManager:getPlayer(eTarget:GetPlayerOwnerID())
    if not playerTarget then
        return false
    end
    if 0 < bit.band(playerTarget.m_typeState, PS_Die + PS_AbilityImmune + PS_InPrison) then
        return false
    end
    return true
end

function this:GetIntrinsicModifierName()
    return "modifier_techies_land_mines"
end

----地雷检测buff
modifier_techies_land_mines = class({})
function modifier_techies_land_mines:IsHidden()
    return true
end
function modifier_techies_land_mines:IsPurgable()
    return false
end
function modifier_techies_land_mines:OnDestroy()
    if IsServer() then
        EventManager:unregister("Event_JoinPath", self.onEvent_JoinPath, self)
        EventManager:unregister("Event_BombDetonate", self.onEvent_BombDetonate, self)
        EventManager:unregister("Event_OnDamage", self.onEvent_OnDamage, self)
    end
end
function modifier_techies_land_mines:OnCreated(kv)
    if IsClient() or not self:GetParent():IsRealHero() then
        return
    end
    self.oPlayer = PlayerManager:getPlayer(self:GetParent():GetPlayerID())
    if not self.oPlayer then
        return
    end
    if not self.oPlayer._tBombs then self.oPlayer._tBombs = {} end
    self.m_typeDamage = self:GetAbility():GetAbilityDamageType()

    ----监听玩家踩入
    EventManager:register("Event_JoinPath", self.onEvent_JoinPath, self)
    ----监听引爆
    EventManager:register("Event_BombDetonate", self.onEvent_BombDetonate, self)
    ----监听死亡
    EventManager:register("Event_PlayerDie", self.onEvent_PlayerDie, self)
    ----监听伤害
    EventManager:register("Event_OnDamage", self.onEvent_OnDamage, self)
end
function modifier_techies_land_mines:onEvent_JoinPath(tEvent)
    -- if tEvent.player ~= oPlayer then
    if
    tEvent.player ~= self.oPlayer
    then
        Timers:CreateTimer(function()
            EventManager:fireEvent("Event_BombDetonate", {
                path = tEvent.player.m_pathCur,
                player = self.oPlayer,
            })
        end)
    end
end
function modifier_techies_land_mines:onEvent_BombDetonate(tEvent)
    if tEvent.player ~= self.oPlayer then
        return
    end
    local path = tEvent.path
    -- "particles/units/heroes/hero_techies/techies_remote_mine.vpcf"
    -- "particles/units/heroes/hero_techies/techies_suicide.vpcf"   ----大雷
    local tBombs = self.oPlayer._tBombs[path]
    if not tBombs or 0 >= #tBombs then
        return
    end

    ----获取被炸单位
    tEvent.tETarget = tEvent.tETarget or {}
    local tETarget = concat(path:getJoinEnt(), tEvent.tETarget)
    if path.m_tabENPC then
        tETarget = concat(tETarget, path.m_tabENPC)
    end

    removeRepeat(tETarget)
    removeAll(tETarget, function(v)
        return not self:GetAbility():checkTarget(v)
    end)

    ----伤害
    for _, eBomb in pairs(tBombs) do
        if IsValid(eBomb) then

            ----炸弹指定的目标
            if eBomb.m_tETarget then
                removeAll(eBomb.m_tETarget, function(v)
                    return not self:GetAbility():checkTarget(v)
                end)
            end

            ----伤害全部目标
            local tETargetCur = eBomb.m_tETarget or tETarget
            for _, v in pairs(tETargetCur) do
                ----造成伤害
                AMHC:Damage(eBomb:GetOwner(), v, eBomb.m_nDamage, self.m_typeDamage, self:GetAbility(), 1, { bIgnoreBZHuiMo = true })
            end

            ----爆炸特效
            local nPtclID = AMHC:CreateParticle("particles/units/heroes/hero_techies/techies_suicide.vpcf"
            , PATTACH_ABSORIGIN, false, eBomb, 5)

            ----销毁炸弹
            eBomb:Destroy()
        end
    end
    self.oPlayer._tBombs[path] = nil
    EmitGlobalSound("Hero_Techies.LandMine.Detonate")
end
function modifier_techies_land_mines:onEvent_PlayerDie(tEvent)
    if tEvent.player == self.oPlayer then
        for _, tPathBombs in pairs(self.oPlayer._tBombs) do
            for _, eBomb in pairs(tPathBombs) do
                if IsValid(eBomb) then
                    eBomb:Destroy()
                end
            end
        end
        self.oPlayer._tBombs = {}
    end
end
function modifier_techies_land_mines:onEvent_OnDamage(tEvent)
    if tEvent.bBladeMail then
        if IsValid(tEvent.ability) and tEvent.ability.GetAbilityName then
            if tEvent.ability:GetAbilityName() == 'LuaAbility_techies_land_mines' then
                ----刃甲反炸弹的伤害，不回蓝
                tEvent.bIgnoreBZHuiMo = true
            end
        end
    end
end