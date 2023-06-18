require("Ability/LuaAbility")
----技能：幻影突袭    英雄：幻影刺客 PA
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
LuaAbility_phantom_strike = class({}, nil, LuaAbility)
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_phantom_strike:constructor()
    self.__base__.constructor(self)

    ----绑定self
    self.filterTarget = bind(self.filterTarget, self)
end

----选择无目标时
function LuaAbility_phantom_strike:CastFilterResult()
    if not self:isCanCast() then
        return UF_FAIL_CUSTOM
    end
    if nil ~= PlayerManager then
        ----如果是玩家英雄
        local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
        if nil ~= oPlayer then
            ----获取前进区域最近玩家
            if nil == PlayerManager:findClosePlayer(oPlayer, self.filterTarget, 1) then
                ----没有有效攻击目标
                self.m_strCastError = "LuaAbilityError_Nil"
                return UF_FAIL_CUSTOM
            end
        end
    end
    return UF_SUCCESS
end

----开始技能效果
function LuaAbility_phantom_strike:OnSpellStart()
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())

    ----获取前进区域最近玩家
    local oPlayerTarget = PlayerManager:findClosePlayer(oPlayer, self.filterTarget, 1)
    if nil == oPlayerTarget then
        return
    end

    ----音效
    EmitGlobalSound("Hero_PhantomAssassin.Strike.Start")

    ----创建闪烁特效
    local cPtclID1 = AMHC:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_loadout.vpcf"
    , PATTACH_POINT, false, oPlayer.m_eHero, 3)
    ParticleManager:SetParticleControl(cPtclID1, 0, oPlayer.m_eHero:GetOrigin())
    ParticleManager:ReleaseParticleIndex(cPtclID1)
    local cPtclID2 = AMHC:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_loadout.vpcf"
    , PATTACH_RENDERORIGIN_FOLLOW, false, oPlayer.m_eHero, 3)
    ParticleManager:SetParticleControl(cPtclID2, 0, oPlayerTarget.m_eHero:GetOrigin())
    ParticleManager:ReleaseParticleIndex(cPtclID2)

    ----设置自身pos至目标身后
    oPlayer.m_eHero:SetOrigin(oPlayerTarget.m_eHero:GetOrigin() - oPlayerTarget.m_eHero:GetForwardVector() * 100)
    FindClearSpaceForUnit(oPlayer.m_eHero, oPlayer.m_eHero:GetOrigin(), true)
    oPlayer.m_eHero:SetAngles(0, oPlayerTarget.m_eHero:GetAnglesAsVector().y, 0)
    oPlayer:setPath(oPlayerTarget.m_pathCur)
    CameraManage:LookAt(oPlayer.m_nPlayerID, oPlayer.m_eHero:GetAbsOrigin(), 0.1)

    ----必定暴击
    local cApltBJ = oPlayer.m_eHero:FindAbilityByName("phantom_assassin_coup_de_grace")
    if cApltBJ then
        AMHC:AddAbilityAndSetLevel(oPlayer.m_eHero, 'phantom_assassin_coup_de_grace_100', cApltBJ:GetLevel())
    end

    ----攻击
    local typeTeam = oPlayerTarget.m_eHero:GetTeamNumber()
    oPlayerTarget.m_eHero:SetTeam(DOTA_TEAM_BADGUYS)
    oPlayer:setState(PS_AtkHero)
    oPlayer.m_eHero:AddAbility('')
    Timers:CreateTimer(0.5, function()
        oPlayer.m_eHero:MoveToTargetToAttack(oPlayerTarget.m_eHero)

        ----攻击结束移动到目标所在路径
        local tEventID = {}
        local function atkEnd()
            if tEventID then
                for _, v in pairs(tEventID) do
                    EventManager:unregisterByID(v)
                end
                tEventID = nil
                oPlayerTarget.m_eHero:SetTeam(typeTeam)
                oPlayer:setState(-PS_AtkHero)
                oPlayer.m_eHero:RemoveAbility('phantom_assassin_coup_de_grace_100')
                ----攻击结束移动到目标所在路径
                oPlayer:moveToPath(oPlayerTarget.m_pathCur)
            end
        end

        table.insert(tEventID, EventManager:register("Event_Atk", function(tEvent)
            if tEvent.entindex_attacker_const == oPlayer.m_eHero:GetEntityIndex() then
                atkEnd()
                return true
            end
        end))
        Timers:CreateTimer(oPlayer.m_eHero:GetAttackAnimationPoint() * 1.9, atkEnd)
    end)

    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = self })

    ----设置冷却
    AbilityManager:setRoundCD(oPlayer, self)
end

----过滤技能目标
function LuaAbility_phantom_strike:filterTarget(player)
    if player.m_eHero == self:GetCaster()    ----自身
    or not self:checkTarget(player.m_eHero)
    or 0 < bit.band(
    PS_InPrison       ----入狱
    + PS_Invis          ----隐身
    + PS_AtkHero
    + PS_AtkMonster
    , player.m_typeState) then
        return false    ----排除
    end
    return true
end