require("Ability/LuaAbility")
----技能：龙破斩    英雄：莉娜
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_lina_dragon_slave then
    LuaAbility_lina_dragon_slave = class({}, nil, LuaAbility)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_lina_dragon_slave:constructor()
    self.__base__.constructor(self)
end

---- 定义技能的施法距离
function LuaAbility_lina_dragon_slave:GetCastRange(vLocation, hTarget)
    if IsClient() then
        local tabPlayerInfo = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self:GetCaster():GetPlayerOwnerID())
        if not tabPlayerInfo then
            return
        end
        require('Path/PathManager')
        require('Ability/AbilityManager')
        local nPathIDQ = PathManager:getVertexPathID(tabPlayerInfo.nPathCurID)
        local tabPathID = { nPathIDQ }
        local nPathID = PathManager:getNextPathID(tabPlayerInfo.nPathCurID, 1)
        while nPathID ~= nPathIDQ do
            table.insert(tabPathID, nPathID)
            nPathID = PathManager:getNextPathID(nPathID, 1)
        end
        AbilityManager:showAbltMark(self, self:GetCaster(), tabPathID)
    end
    return 0
end

----选择无目标时
function LuaAbility_lina_dragon_slave:CastFilterResult()
    if not self:isCanCast() then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end

----开始技能效果
function LuaAbility_lina_dragon_slave:OnSpellStart()
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    local nRange = self:GetSpecialValueFor("range")
    local nOffset = self:GetSpecialValueFor("offset")

    ----特效
    local nPtclID = AMHC:CreateParticle("particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf"
    , PATTACH_POINT, false, oPlayer.m_eHero, 3)
    local pathQ = PathManager:getVertexPath(oPlayer.m_pathCur)
    local v3 = (pathQ.m_entity:GetAbsOrigin() - oPlayer.m_pathCur.m_entity:GetAbsOrigin()):Normalized()
    local nSpeed = self:GetSpecialValueFor("dragon_slave_speed")
    ParticleManager:SetParticleControl(nPtclID, 0, oPlayer.m_pathCur.m_entity:GetAbsOrigin())
    ParticleManager:SetParticleControl(nPtclID, 1, v3 * nSpeed)
    EmitGlobalSound("Hero_Lina.DragonSlave")

    ----伤害作用格数内的玩家
    local pathTarget = oPlayer.m_pathCur
    Timers:CreateTimer(function()
        pathTarget = PathManager:getNextPath(pathTarget, 1)
        local tabPlayer = {}
        PlayerManager:findRangePlayer(tabPlayer, pathTarget, 1, 0, function(player)
            if player == oPlayer
            or not self:checkTarget(player.m_eHero)
            or 0 < bit.band(PS_AtkMonster
            , player.m_typeState) then
                return false    ----排除
            end
            return true
        end)
        ----对玩家造成伤害
        if 0 < #tabPlayer then
            self:atk(tabPlayer)
        end
        if pathTarget ~= pathQ then
            return 0.17
        end
    end)

    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = self })
    ----设置冷却
    AbilityManager:setRoundCD(oPlayer, self)
end
function LuaAbility_lina_dragon_slave:atk(tabPlayer)
    ----获取伤害数值
    local nDamage = self:GetSpecialValueFor("dragon_slave_damage")

    ----造成伤害
    for k, v in pairs(tabPlayer) do
        AMHC:Damage(self:GetCaster(), v.m_eHero, nDamage, self:GetAbilityDamageType(), self)
    end
end