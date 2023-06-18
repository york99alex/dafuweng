require("Ability/LuaAbility")
----技能：弧形闪电    英雄：宙斯
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_zuus_arc_lightning then
    LuaAbility_zuus_arc_lightning = class({}, nil, LuaAbility)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_zuus_arc_lightning:constructor()
    self.__base__.constructor(self)
end

function LuaAbility_zuus_arc_lightning:GetCastRange(vLocation, hTarget)
    return 0
end

----选择目标时
function LuaAbility_zuus_arc_lightning:CastFilterResultTarget(hTarget)
    if not self:isCanCast(hTarget) then
        return UF_FAIL_CUSTOM
    end

    ----不能是自己
    if hTarget:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID() then
        self.m_strCastError = "LuaAbilityError_SelfCant"
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end

----开始技能效果
function LuaAbility_zuus_arc_lightning:OnSpellStart()
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    local eTarget = self:GetCursorTarget()
    local nRange = self:GetSpecialValueFor("range")
    local nCount = self:GetSpecialValueFor("jump_count")
    local fDelay = self:GetSpecialValueFor("jump_delay")
    local nDamage = self:GetSpecialValueFor("arc_damage")

    ----获取玩家
    local tabTarget = { self:GetCaster(), eTarget }
    local tabTargetV3 = { self:GetCaster():GetAbsOrigin(), eTarget:GetAbsOrigin() }
    for i = 1, nCount do
        local eCur = tabTarget[#tabTarget]
        local tab = {}
        PlayerManager:findRangePlayer(tab, eCur.m_path, nRange, 0, function(player)
            if player == oPlayer
            or not self:checkTarget(player.m_eHero)
            or exist(tabTarget, player.m_eHero) then
                return false    ----排除
            end
            return true
        end)
        ----获取最近的玩家
        local playerMin
        local nMin
        for _, v in pairs(tab) do
            local nDis = (v.m_eHero:GetAbsOrigin() - eTarget:GetAbsOrigin()):Length()
            if not nMin or nDis < nMin then
                nMin = nDis
                playerMin = v
            end
        end
        if playerMin then
            table.insert(tabTarget, playerMin.m_eHero)
            table.insert(tabTargetV3, playerMin.m_eHero:GetAbsOrigin())
        else
            break
        end
    end

    local function onDamege(nICur)
        ----特效
        local nPtclID = AMHC:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf"
        , PATTACH_POINT_FOLLOW, false, tabTarget[nICur], 1)
        ParticleManager:SetParticleControl(nPtclID, 1, tabTargetV3[nICur - 1])
        ParticleManager:SetParticleControl(nPtclID, 0, tabTargetV3[nICur])
        if 2 == nICur then
            EmitGlobalSound("Hero_Zuus.ArcLightning.Cast")
        else
            EmitGlobalSound("Hero_Zuus.ArcLightning.Target")
        end
        ----对玩家造成伤害
        AMHC:Damage(self:GetCaster(), tabTarget[nICur], nDamage, self:GetAbilityDamageType(), self)
    end

    ----释放闪电
    for i = 2, #tabTarget do
        local nICur = i
        local nTime = fDelay * (nICur - 2)
        if 0 < nTime then
            Timers:CreateTimer(nTime, function()
                onDamege(nICur)
            end)
        else
            onDamege(nICur)
        end
    end

    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = self })
    ----设置冷却
    AbilityManager:setRoundCD(oPlayer, self)
end