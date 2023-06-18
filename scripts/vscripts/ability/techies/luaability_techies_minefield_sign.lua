require("Ability/LuaAbility")
----技能：地雷标识    英雄：炸弹人
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_techies_minefield_sign then
    LuaAbility_techies_minefield_sign = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_techies_minefield_sign", "Ability/techies/LuaAbility_techies_minefield_sign.lua", LUA_MODIFIER_MOTION_NONE)
    if PrecacheItems then
        table.insert(PrecacheItems, "models/heroes/techies/techies_sign.vmdl")
    end
end
local this = LuaAbility_techies_minefield_sign
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
            ----距离
            local dis = (vLocation - path.m_entity:GetAbsOrigin()):Length2D()
            if dis > 150 then
                self.m_strCastError = "LuaAbilityError_TargetPath"
                return UF_FAIL_CUSTOM
            end
            ----验证是否有雷
            if not oPlayer._tBombs
            or not oPlayer._tBombs[path]
            or (0 >= #oPlayer._tBombs[path]) then
                self.m_strCastError = "LuaAbilityError_NoBomb"
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
    EmitGlobalSound("Hero_Techies.Sign")

    ----创建标识
    local eSign = AMHC:CreateUnit("bomb", self.m_vPosTarget, RandomInt(270 - 45, 270 + 45), self:GetCaster(), DOTA_TEAM_GOODGUYS)
    eSign:SetModel("models/heroes/techies/techies_sign.vmdl")
    eSign.m_nChance = self:GetSpecialValueFor("chance")
    eSign.m_path = self.m_pathTarget
    if not oPlayer._tBombSigns then oPlayer._tBombSigns = {} end
    if not oPlayer._tBombSigns[eSign.m_path] then oPlayer._tBombSigns[eSign.m_path] = {} end
    table.insert(oPlayer._tBombSigns[eSign.m_path], eSign)

    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = self })
    ----设置冷却
    AbilityManager:setRoundCD(oPlayer, self)
end


function this:GetIntrinsicModifierName()
    return "modifier_techies_minefield_sign"
end

----标识检测buff
modifier_techies_minefield_sign = class({})
function modifier_techies_minefield_sign:IsHidden()
    return true
end
function modifier_techies_minefield_sign:IsPurgable()
    return false
end
function modifier_techies_minefield_sign:OnDestroy()
    if IsServer() then
        EventManager:unregister("Event_CurPathChange", self.onEvent_CurPathChange, self)
        EventManager:unregister("Event_BombDetonate", self.onEvent_BombDetonate, self)
    end
end
function modifier_techies_minefield_sign:OnCreated(kv)
    if IsClient() or not self:GetParent():IsRealHero() then
        return
    end
    self.oPlayer = PlayerManager:getPlayer(self:GetParent():GetPlayerID())
    if not self.oPlayer then
        return
    end
    if not self.oPlayer._tBombSigns then self.oPlayer._tBombSigns = {} end

    ----监听玩家当前路径
    EventManager:register("Event_CurPathChange", self.onEvent_CurPathChange, self)

    ----监听引爆
    EventManager:register("Event_BombDetonate", self.onEvent_BombDetonate, self)
end
function modifier_techies_minefield_sign:onEvent_CurPathChange(tEvent)
    if
    tEvent.player ~= self.oPlayer
    and 0 == bit.band(PS_AbilityImmune, tEvent.player.m_typeState)
    then
        ----计算触发引爆概率
        local path = tEvent.player.m_pathCur
        local tBombSigns = self.oPlayer._tBombSigns[path]
        if not tBombSigns then
            return
        end
        for _, eSign in pairs(tBombSigns) do
            local nChance = eSign.m_nChance or 0
            if RandomInt(1, 100) <= nChance then
                EventManager:fireEvent("Event_BombDetonate", {
                    path = tEvent.player.m_pathCur,
                    player = self.oPlayer,
                    tETarget = { tEvent.player.m_eHero },
                })
                return
            end
        end
    end
end
function modifier_techies_minefield_sign:onEvent_BombDetonate(tEvent)
    if tEvent.player ~= self.oPlayer then
        return
    end
    local path = tEvent.path
    local tBombSigns = self.oPlayer._tBombSigns[path]
    if not tBombSigns then
        return
    end
    for _, eSign in pairs(tBombSigns) do
        if IsValid(eSign) then
            eSign:Destroy()
        end
    end
    self.oPlayer._tBombSigns[path] = nil
end