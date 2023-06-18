require("Ability/LuaAbility")
----技能：忽悠    英雄：米波
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_meepo_poof then
    LuaAbility_meepo_poof = class({}, nil, LuaAbility)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_meepo_poof:constructor()
    self.__base__.constructor(self)
end

----选择目标单位时
function LuaAbility_meepo_poof:CastFilterResultTarget(hTarget)
    if not self:isCanCast() then
        return UF_FAIL_CUSTOM
    end
    if nil ~= GMManager then
        ----判断目标是否是米波
        if "models/heroes/meepo/meepo.vmdl" ~= hTarget:GetModelName() then
            self.m_strCastError = "LuaAbilityError_meepo_poof_1"
            return UF_FAIL_CUSTOM
        end
    end
    return UF_SUCCESS
end

----开始施法
function LuaAbility_meepo_poof:OnAbilityPhaseStart()
    if IsServer() then
        self._GS = GMManager.m_typeState
        -- GMManager:setState(GS_Wait)
        self._YieldStateCO = GSManager:yieldState()
        GSManager:setState(GS_Wait)

        -- GMManager.m_typeState = GS_Wait
    end
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())

    ----声音
    EmitGlobalSound("Hero_Meepo.Poof.Channel")

    ----离开持续施法特效
    local nPtclID = AMHC:CreateParticle("particles/units/heroes/hero_meepo/meepo_poof_start.vpcf"
    , PATTACH_POINT, false, oPlayer.m_eHero, 3)
    ParticleManager:SetParticleControl(nPtclID, 0, oPlayer.m_eHero:GetOrigin())
    ParticleManager:ReleaseParticleIndex(nPtclID)

    return true
end

----开始技能效果
function LuaAbility_meepo_poof:OnSpellStart()
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    local eTarget = self:GetCursorTarget()

    ----离开的遁地特效
    local nPtclID = AMHC:CreateParticle("particles/units/heroes/hero_meepo/meepo_loadout.vpcf"
    , PATTACH_POINT, false, oPlayer.m_eHero, 3)

    ----获取施法位置作用格数内的玩家
    local nRange = self:GetSpecialValueFor("range")
    local tabPlayer = {}
    PlayerManager:findRangePlayer(tabPlayer, oPlayer.m_pathCur, nRange, nil, function(player)
        if player == oPlayer
        or 0 < bit.band(PS_AbilityImmune + PS_Die + PS_InPrison + PS_AtkMonster, player.m_typeState) then
            return false    ----排除死亡,自身,技能免疫
        end
        return true
    end)

    ----对玩家造成伤害
    self:atk(tabPlayer)

    oPlayer.m_eHero:SetOrigin(oPlayer.m_eHero:GetOrigin() - Vector(0, 9999, 9999))
    Timers:CreateTimer(0.5, function()
        ----再现的遁地特效
        if eTarget:IsRealHero() then
            oPlayer:blinkToPath(PlayerManager:getPlayer(eTarget:GetPlayerOwnerID()).m_pathCur)
        else
            oPlayer:blinkToPath(eTarget.m_path)
        end
        local nPtclID2 = AMHC:CreateParticle("particles/units/heroes/hero_meepo/meepo_loadout.vpcf"
        , PATTACH_POINT, false, oPlayer.m_eHero, 3)

        ----再现声音
        EmitGlobalSound("Hero_Meepo.Poof.End")

        ----获取目标位置作用格数内的玩家
        tabPlayer = {}
        if eTarget.m_path then
            PlayerManager:findRangePlayer(tabPlayer, eTarget.m_path, nRange, nil, function(player)
                if player == oPlayer
                or not self:checkTarget(player.m_eHero) then
                    return false    ----排除死亡,自身,技能免疫
                end
                return true
            end)
        end

        ----对玩家造成伤害
        self:atk(tabPlayer)

        ----重置状态
        if self._GS then
            -- if GS_Wait == GMManager.m_typeState
            -- or GS_DeathClearing == GMManager.m_typeState then
            --     GMManager:setState(self._GS)
            -- end
            self._GS = nil
        end
        GSManager:resumeState(self._YieldStateCO)
    end)

    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = self })

    ----设置冷却
    AbilityManager:setRoundCD(oPlayer, self)
end
function LuaAbility_meepo_poof:atk(tabPlayer)
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())

    ----获取伤害数值
    local nDamage = self:GetSpecialValueFor("poof_damage")
    local cBuff = oPlayer:getBuffByName("modifier_meepo_ransack")
    if nil ~= cBuff then
        nDamage = nDamage + cBuff:GetStackCount()   ----叠加洗劫提升的伤害
    end
    ----造成伤害
    for k, v in pairs(tabPlayer) do
        if v ~= oPlayer then
            AMHC:Damage(self:GetCaster(), v.m_eHero, nDamage, self:GetAbilityDamageType(), self)
        end
    end
end

function LuaAbility_meepo_poof:getDamage()
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    local nDamage = self:GetSpecialValueFor("poof_damage")
    local cBuff = oPlayer:getBuffByName("modifier_meepo_ransack")
    if nil ~= cBuff then
        nDamage = nDamage + cBuff:GetStackCount()   ----叠加洗劫提升的伤害
    end
    return nDamage
end