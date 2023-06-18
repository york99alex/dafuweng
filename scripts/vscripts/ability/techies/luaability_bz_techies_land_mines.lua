require("Ability/LuaAbility")
----技能：地雷    兵卒：炸弹人
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_BZ_techies_land_mines then
    LuaAbility_BZ_techies_land_mines = class({}, nil, LuaAbility)
end
local this = LuaAbility_BZ_techies_land_mines
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function this:constructor()
    this.__base__.constructor(self)
    self:ai()
end

----选择无目标时
function this:CastFilterResult()
    return UF_SUCCESS
end

----开始技能效果
function this:OnSpellStart()
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if not oPlayer then
        return
    end
    ---@type Path
    self.m_pathTarget = self:GetCaster().m_path
    if not self.m_pathTarget then
        return
    end
    self.m_vPosTarget = self.m_pathTarget.m_entity:GetAbsOrigin()
    self.m_vPosTarget = self.m_vPosTarget + Vector(RandomInt(-50, 50), RandomInt(-50, 50), 0)

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

    ----触发放技能事件
    local nCasterEntID = self:GetCaster():GetEntityIndex()
    local sAbltName = self:GetAbilityName()
    EventManager:fireEvent('dota_player_used_ability', {
        caster_entindex = nCasterEntID,
        abilityname = sAbltName,
    })

    ----该地区有人直接引爆
    Timers:CreateTimer(1, function()
        if IsValid(eBomb) then
            local tEnt = eBomb.m_path:getJoinEnt()
            for _, v in pairs(tEnt) do
                if self:checkTarget(v, oPlayer.m_nPlayerID) then
                    ----标记攻城炸弹
                    if eBomb.m_path.m_nPlayerIDGCLD then
                        local playerGC = PlayerManager:getPlayer(eBomb.m_path.m_nPlayerIDGCLD)
                        if playerGC then
                            ----指定炸攻城英雄
                            eBomb.m_tETarget = { playerGC.m_eHero }
                        end
                    end
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
function this:checkTarget(eTarget, nPlayerID)
    if not IsValid(eTarget) then
        return false
    end
    if eTarget:GetPlayerOwnerID() == nPlayerID then
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

----是否计算冷却减缩
function this:isCanCDSub()
    return false
end
----是否计算耗魔减缩
function this:isCanManaSub()
    return false
end

function this:ai()
    if IsClient() then
        return
    end
    ----持续进行施法判断
    Timers:CreateTimer(function()
        if not IsValid(self) then
            return
        end

        if self:IsCooldownReady()
        and AbilityManager:isCanOnAblt(self:GetCaster())
        and self:GetCaster():GetMana() >= self:GetManaCost(self:GetLevel() - 1) then
            ----蓝满了施法技能
            ExecuteOrderFromTable({
                UnitIndex = self:GetCaster():entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                TargetIndex = nil, --Optional.  Only used when targeting units
                AbilityIndex = self:GetEntityIndex(), --Optional.  Only used when casting abilities
                Position = nil, --Optional.  Only used when targeting the ground
                Queue = 0 --Optional.  Used for queueing up abilities
            })
        end
        return 1
    end)

end