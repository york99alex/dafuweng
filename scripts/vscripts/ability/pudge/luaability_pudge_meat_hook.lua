require("Ability/LuaAbility")
----技能：肉钩    英雄：屠夫帕吉
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
LuaAbility_pudge_meat_hook = class({}, nil, LuaAbility)
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_pudge_meat_hook:constructor()
    self.__base__.constructor(self)

    ----绑定self
    self.filterTarget = bind(self.filterTarget, self)
end

----选择目标时
function LuaAbility_pudge_meat_hook:CastFilterResultTarget(hTarget)
    if not self:isCanCast() then
        return UF_FAIL_CUSTOM
    end
    if IsServer() then
        self.m_strCastError = 'ERROR'
        local playerTarget = PlayerManager:getPlayer(hTarget:GetPlayerOwnerID())
        if not self.filterTarget(playerTarget) then
            return UF_FAIL_CUSTOM
        end
    end
    return UF_SUCCESS
end

----选择无目标时
function LuaAbility_pudge_meat_hook:CastFilterResult()
    if not self:isCanCast() then
        return UF_FAIL_CUSTOM
    end

    if PlayerManager then
        ----获取随机玩家
        local tabPlayer = PlayerManager:findRandomPlayer(1, self.filterTarget)
        if nil == tabPlayer or 1 ~= #tabPlayer then
            ----没有有效攻击目标
            self.m_strCastError = "LuaAbilityError_Nil"
            return UF_FAIL_CUSTOM
        end
    end

    return UF_SUCCESS
end

----开始技能效果
function LuaAbility_pudge_meat_hook:OnSpellStart()
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    local hTarget = self:GetCursorTarget()
    local oPlayerTarget
    if IsValid(hTarget) then
        oPlayerTarget = PlayerManager:getPlayer(hTarget:GetPlayerOwnerID())
    end
    if not oPlayerTarget then
        ----获取随机玩家
        local tabPlayer = PlayerManager:findRandomPlayer(1, self.filterTarget)
        if nil == tabPlayer or 1 ~= #tabPlayer then
            return
        end
        oPlayerTarget = tabPlayer[1]
    end

    ---- local oPlayerTarget = PlayerManager:getPlayer(self:GetCursorTarget():GetPlayerOwnerID())
    local nDamage = self:GetSpecialValueFor("damage")

    ----计算运动
    local nFps = 30
    local nFpsTime = 1 / nFps
    local v3Dis = oPlayerTarget.m_eHero:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
    local nTime = math.floor(math.floor(v3Dis:Length() / 500) * 0.2 * nFps)    ----每500码耗时0.2秒
    if 2 * nFps < nTime then
        nTime = math.floor(2 * nFps)
    elseif 0.2 * nFps >= nTime then
        nTime = math.floor(0.2 * nFps)
    end
    local v3Speed = v3Dis / nTime
    local v3Cur = self:GetCaster():GetAbsOrigin()
    local nTimeCur = nTime

    ----创建肉钩特效
    local nPtclID = AMHC:CreateParticle("particles/econ/items/pudge/pudge_trapper_beam_chain/pudge_nx_meathook.vpcf"
    , PATTACH_CUSTOMORIGIN, false, self:GetCaster(), 2 * nTime * nFpsTime)
    ----ParticleManager:SetParticleAlwaysSimulate(nPtclID)
    ParticleManager:SetParticleControlEnt(nPtclID, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetAbsOrigin(), true)
    ----ParticleManager:SetParticleControl(nPtclID, 1, oPlayerTarget.m_eHero:GetAbsOrigin())  ----目标点
    ----ParticleManager:SetParticleControl(nPtclID, 2, Vector(0, 0, 0))   ----速度
    ParticleManager:SetParticleControl(nPtclID, 3, Vector(5, 0, 0))     ----持续时间
    ----ParticleManager:SetParticleControl(nPtclID, 4, Vector(1, 0, 0))     ----钩子旋转
    ----ParticleManager:SetParticleControl(nPtclID, 5, Vector(0, 0, 0))
    ----ParticleManager:SetParticleControlEnt(nPtclID, 7, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, self:GetCaster():GetAbsOrigin(), true)
    ----肉钩持续向目标运动
    self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)   ----出钩动作
    EmitSoundOn("Hero_Pudge.AttackHookExtend", oPlayer.m_eHero)
    Timers:CreateTimer(0, function()
        v3Cur = v3Cur + v3Speed
        ParticleManager:SetParticleControl(nPtclID, 6, v3Cur)
        ParticleManager:SetParticleControl(nPtclID, 1, v3Cur)
        nTimeCur = nTimeCur - 1
        if 0 < nTimeCur then
            return nFpsTime
        end

        ----钩到目标,伤害
        AMHC:Damage(self:GetCaster(), oPlayerTarget.m_eHero, nDamage, self:GetAbilityDamageType(), self)

        ----拉回来
        self:GetCaster():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
        self:GetCaster():StartGesture(ACT_DOTA_CHANNEL_ABILITY_1)   ----收钩动作
        StopSoundOn("Hero_Pudge.AttackHookExtend", oPlayer.m_eHero)
        EmitSoundOn("Hero_Pudge.AttackHookImpact", oPlayer.m_eHero)
        EmitSoundOn("Hero_Pudge.AttackHookRetract", oPlayer.m_eHero)
        Timers:CreateTimer(0, function()
            v3Cur = v3Cur - v3Speed
            ParticleManager:SetParticleControl(nPtclID, 6, v3Cur)
            ParticleManager:SetParticleControl(nPtclID, 1, v3Cur)
            oPlayerTarget.m_eHero:SetAbsOrigin(v3Cur)
            nTimeCur = nTimeCur + 1
            if nTime > nTimeCur then
                return nFpsTime
            end

            ----结束
            self:GetCaster():RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_1)
            StopSoundOn("Hero_Pudge.AttackHookRetract", oPlayer.m_eHero)
            oPlayerTarget:blinkToPath(oPlayer.m_pathCur)
            return nil
        end)
        return nil
    end)

    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = self })
    ----设置冷却
    AbilityManager:setRoundCD(oPlayer, self)
end

----过滤技能目标
function LuaAbility_pudge_meat_hook:filterTarget(player)
    if not player
    or player.m_eHero == self:GetCaster()    ----自身
    or not self:checkTarget(player.m_eHero)
    or 0 < bit.band(
    PS_InPrison       ----入狱
    ---- + PS_Invis          ----隐身
    + PS_AtkHero        ----战斗中
    , player.m_typeState) then
        return false    ----排除
    end
    return true
end