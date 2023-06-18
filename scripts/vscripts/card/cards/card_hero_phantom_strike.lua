require("Ability/phantom_assassin/LuaAbility_phantom_strike")
if PrecacheItems then
    table.insert(PrecacheItems, "particles/units/heroes/hero_phantom_assassin/phantom_assassin_loadout.vpcf")
    table.insert(PrecacheItems, "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_dagger.vpcf")
end

--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----PA卡牌
if nil == Card_HERO_PHANTOM_strike then
    -----@class Card_HERO_PHANTOM_strike : Card
    Card_HERO_PHANTOM_strike = class({
        m_tabAbltInfo = nil      ----卡牌技能信息
    }, nil, Card)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function Card_HERO_PHANTOM_strike:constructor(tInfo, nPlayerID)
    Card_HERO_PHANTOM_strike.__base__.constructor(self, tInfo, nPlayerID)
    self.m_typeCast = TCardCast_Target
    self.m_tabAbltInfo = KeyValues.AbilitiesKv["LuaAbility_phantom_strike"]
    self.m_nManaCost = tonumber(self.m_tabAbltInfo["AbilityManaCost"])
    self.m_nManaCostBase = self.m_nManaCost
end

----选择目标单位时
----@param 目标单位
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function Card_HERO_PHANTOM_strike:CastFilterResultTarget(hTarget)
    print("Card_HERO_LINA_laguna_blade:CastFilterResultTarget")

    if not self:CanUseCard(hTarget) then
        return UF_FAIL_CUSTOM
    end

    -----@type Player
    local owner = self:GetOwner()

    if hTarget == owner.m_eHero or owner:hasBz(hTarget) or hTarget:GetPlayerOwnerID() < 0 or hTarget:IsIllusion() then
        ---- if hTarget:GetPlayerOwnerID() < 0 then
        self.m_strCastError = "LuaAbilityError_TargetEnemyHeroBZ"
        return UF_FAIL_CUSTOM
    end

    self.m_eTarget = hTarget
    return UF_SUCCESS
end

----返回伤害类型
function Card_HERO_PHANTOM_strike:GetAbilityDamageType()
    return load("return " .. self.m_tabAbltInfo["AbilityUnitDamageType"])()
end

----卡牌释放
function Card_HERO_PHANTOM_strike:OnSpellStart()
    -----@type Player
    local owner = self:GetOwner()
    local target = self:GetCursorTarget()
    local playerTarget = PlayerManager:getPlayer(target:GetPlayerOwnerID())
    -----@type Path
    local path = target:IsRealHero() and playerTarget.m_pathCur or PathManager:getPathByBZEntity(target)
    ----音效
    EmitGlobalSound("Hero_PhantomAssassin.Strike.Start")

    ----创建闪烁特效
    local cPtclID1 = AMHC:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_loadout.vpcf"
    , PATTACH_POINT, false, owner.m_eHero, 3)
    ParticleManager:SetParticleControl(cPtclID1, 0, owner.m_eHero:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(cPtclID1)

    local cPtclID2 = AMHC:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_loadout.vpcf"
    , PATTACH_RENDERORIGIN_FOLLOW, false, owner.m_eHero, 3)
    ParticleManager:SetParticleControl(cPtclID2, 0, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(cPtclID2)

    if not target:IsRealHero() then
        owner:blinkToPath(path)
        local vForward = owner.m_eHero:GetForwardVector()
        owner.m_eHero:SetForwardVector(target:GetAbsOrigin() - owner.m_eHero:GetForwardVector())
    else
        ----设置自身pos至目标身后 GetForwardVector()
        owner.m_eHero:SetOrigin(target:GetAbsOrigin() - target:GetForwardVector() * 150)
        FindClearSpaceForUnit(owner.m_eHero, owner.m_eHero:GetAbsOrigin(), true)
        owner.m_eHero:SetAngles(0, target:GetAnglesAsVector().y, 0)
        owner:setPath(path)
    end
    CameraManage:LookAt(owner.m_nPlayerID, owner.m_eHero:GetAbsOrigin(), 0.1)

    local cApltBJ = owner.m_eHero:FindAbilityByName("phantom_assassin_coup_de_grace")
    AMHC:AddAbilityAndSetLevel(owner.m_eHero, 'phantom_assassin_coup_de_grace_100', cApltBJ:GetLevel())

    local typeTeam = target:GetTeamNumber()
    target:SetTeam(DOTA_TEAM_BADGUYS)
    owner:setState(PS_AtkHero)
    Timers:CreateTimer(0.5, function()
        owner.m_eHero:MoveToTargetToAttack(target)

        ----攻击结束移动到目标所在路径
        local tEventID = {}
        local function atkEnd()
            if tEventID then
                for _, v in pairs(tEventID) do
                    EventManager:unregisterByID(v)
                end
                tEventID = nil
                target:SetTeam(typeTeam)
                owner:setState(-PS_AtkHero)
                AMHC:RemoveAbilityAndModifier(owner.m_eHero, 'phantom_assassin_coup_de_grace_100')
                local cPtclID3 = AMHC:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_dagger.vpcf"
                , PATTACH_RENDERORIGIN_FOLLOW, false, owner.m_eHero, 3)
                ParticleManager:SetParticleControl(cPtclID3, 0, target:GetAbsOrigin())
                ParticleManager:SetParticleControl(cPtclID3, 1, target:GetAbsOrigin())
                ParticleManager:SetParticleControlOrientation(cPtclID3, 1, -owner.m_eHero:GetForwardVector(), owner.m_eHero:GetRightVector(), owner.m_eHero:GetUpVector())
                ParticleManager:ReleaseParticleIndex(cPtclID3)
                ----攻击结束移动到目标所在路径
                owner:moveToPath(target.m_pathCur)
            end
        end

        table.insert(tEventID, EventManager:register("Event_Atk", function(tEvent)
            if tEvent.entindex_attacker_const == owner.m_eHero:GetEntityIndex() then
                atkEnd()
                return true
            end
        end))
        Timers:CreateTimer(owner.m_eHero:GetAttackAnimationPoint() * 2, atkEnd)
    end)

    ----攻击 触发暴击
    ---- owner.m_eHero:StartGesture(ACT_DOTA_ATTACK_EVENT)   ----攻击动作
    ---- Timers:CreateTimer(owner.m_eHero:GetAttackAnimationPoint(), function()
    ----动作时间结束
    ---- EmitGlobalSound("Hero_PhantomAssassin.CoupDeGrace") ----暴击音效
    ----模拟攻击一次
    ---- local nMax = owner.m_eHero:GetBaseDamageMax()
    ---- local nMin = owner.m_eHero:GetBaseDamageMin()
    ---- print("nMax=" .. nMax)
    ---- print("nMin=" .. nMin)
    ---- local cApltBJ = owner.m_eHero:FindAbilityByName("phantom_assassin_coup_de_grace")
    ---- local nRate = 0.01 * cApltBJ:GetSpecialValueFor("crit_bonus")   ----暴击倍率
    ---- owner.m_eHero:SetBaseDamageMax(nMax * nRate)
    ---- owner.m_eHero:SetBaseDamageMin(nMin * nRate)
    ---- owner.m_eHero:PerformAttack(target, false, false, false, false, false, false, false)
    ---- owner.m_eHero:SetBaseDamageMax(nMax - owner.m_eHero:GetBonusDamageFromPrimaryStat())
    ---- owner.m_eHero:SetBaseDamageMin(nMin - owner.m_eHero:GetBonusDamageFromPrimaryStat())
    ---- end)
end