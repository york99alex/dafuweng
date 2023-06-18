if PrecacheItems then
    table.insert(PrecacheItems, "particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf")
    table.insert(PrecacheItems, "particles/units/heroes/hero_legion_commander/legion_duel_ring.vpcf")
    table.insert(PrecacheItems, "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf")
end

----斧王卡牌
if nil == Card_HERO_AXE_berserkers_call then
    -----@class Card_HERO_AXE_berserkers_call : Card
    Card_HERO_AXE_berserkers_call = class({ mTargetPlayer = nil, mTargetPath = nil }, nil, Card)
end

----构造函数
function Card_HERO_AXE_berserkers_call:constructor(tInfo, nPlayerID)
    Card_HERO_AXE_berserkers_call.__base__.constructor(self, tInfo, nPlayerID)
    self.m_typeCast = TCardCast_Target
    self.m_nManaCost = 10
    self.m_nManaCostBase = self.m_nManaCost
end

----选择目标单位时
----@param 目标单位
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function Card_HERO_AXE_berserkers_call:CastFilterResultTarget(hTarget)
    print("Card_HERO_AXE_berserkers_call")

    if not self:CanUseCard(hTarget) then
        return UF_FAIL_CUSTOM
    end

    -----@type Player
    local owner = self:GetOwner()
    if not owner:hasBz(hTarget) then
        self.m_strCastError = "LuaAbilityError_TargetSelfBZ"
        return UF_FAIL_CUSTOM
    end
    self.m_eTarget = hTarget

    ---- 获取路径保存
    self.mTargetPath = PathManager:getPathByBZEntity(hTarget)

    ----获取最近玩家保存
    local tabPlayer = {}
    PlayerManager:findRangePlayer(tabPlayer, self.mTargetPath, 3, 0, function(player)
        if player == owner
        or 0 < bit.band(PS_AbilityImmune + PS_Die + PS_InPrison + PS_AtkMonster, player.m_typeState) then
            return false    ----排除死亡,自身,技能免疫,打野,监狱
        end
        return true
    end)
    local dis = 999
    self.mTargetPlayer = nil
    local vO = hTarget:GetAbsOrigin()
    for i = 1, #tabPlayer do
        local vT = tabPlayer[i].m_eHero:GetAbsOrigin()
        local d = (vO - vT):Length2D()
        if d < dis then
            dis = d
            self.mTargetPlayer = tabPlayer[i]
        end
    end

    if self.mTargetPlayer then
        return UF_SUCCESS
    end
    self.m_strCastError = "LuaAbilityError_Nil"
    return UF_FAIL_CUSTOM
end
----能否在攻击时释放
function Card_HERO_AXE_berserkers_call:isCanCastHeroAtk()
    return true
end

----卡牌释放
function Card_HERO_AXE_berserkers_call:OnSpellStart()
    self.m_eTarget:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
    EmitGlobalSound("Hero_Axe.Berserkers_Call")
    local heroPtl = AMHC:CreateParticle("particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", PATTACH_POINT_FOLLOW, false, self.m_eTarget, 1)

    Timers:CreateTimer(0.4, function()
        self:play()
    end)
end

function Card_HERO_AXE_berserkers_call:play()
    -----@type npc
    local caster = self.m_eTarget
    -----@type PathDomain
    local path = self.mTargetPath
    -----@type Player
    local owner, targetPlayer = self:GetOwner(), self.mTargetPlayer

    ---- 增加兵卒属性
    ---- print("..........................................................................................................................")
    ---- print(caster:GetPhysicalArmorValue())
    ---- print(caster:GetMagicalArmorValue())
    ---- print("..........................................................................................................................")
    ---- caster:SetPhysicalArmorBaseValue()
    ---- caster:SetBaseMagicalResistanceValue()
    local function moveCallback()
        caster.m_bBattle = true
        caster.m_bGCLD = true
        targetPlayer.m_eHero.m_bGCLD = true
        path.m_nPlayerIDGCLD = targetPlayer.m_nPlayerID

        targetPlayer:setState(PS_AtkHero)
        targetPlayer:setState(PS_Rooted)
        targetPlayer:setState(PS_Pass)
        ----设置双方攻击
        owner:setBzAttack(caster, true)
        owner:setBzAtker(caster, targetPlayer.m_eHero)
        owner:setBzBeAttack(caster, true)
        targetPlayer.m_eHero:MoveToTargetToAttack(caster)

        EventManager:register("Event_GCLDEnd", function(tabEvent)
            if tabEvent.entity == targetPlayer.m_eHero and tabEvent.path == path then
                targetPlayer:setState(-PS_AtkHero)
                targetPlayer:setState(-PS_Rooted)
                targetPlayer:setState(-PS_Pass)
                return true
            end
        end)
        ---- 决斗特效
        path.m_nPtclIDGCLD = AMHC:CreateParticle("particles/units/heroes/hero_legion_commander/legion_duel_ring.vpcf", PATTACH_ABSORIGIN, false, targetPlayer.m_eHero)
        ---- 音效
        EmitSoundOn("Hero_LegionCommander.Duel", caster)
    end

    ----移动到兵卒前
    targetPlayer:moveToPos(path.m_eCity:GetAbsOrigin() + path.m_eCity:GetForwardVector() * 50, moveCallback)
    ----监听双方被攻击事件
    EventManager:register("Event_BeAtk", function(tabEvent)
        local e
        if caster:GetEntityIndex() == tabEvent.entindex_victim_const then
            e = caster
        elseif targetPlayer.m_eHero:GetEntityIndex() == tabEvent.entindex_victim_const then
            e = targetPlayer.m_eHero
        else
            return
        end

        tabEvent.bIgnoreGold = true     ----攻城时不扣钱
        if tabEvent.damage >= e:GetHealth() then
            ----一方死亡，战斗结束
            tabEvent.bIgnore = true
            ----TODO:
            self:stop(e == caster)
            ----英雄死亡回满血
            if e == targetPlayer.m_eHero then
                targetPlayer.m_eHero:ModifyHealth(targetPlayer.m_eHero:GetMaxHealth(), nil, false, 0)
            end
            return true
        end
    end)
end

function Card_HERO_AXE_berserkers_call:stop(myselfWon)
    print(myselfWon)
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    -----@type Player
    local owner, targetPlayer = self:GetOwner(), self.mTargetPlayer
    -----@type PathDomain
    local path = self.mTargetPath
    -----@type npc
    local caster = self.m_eTarget

    ---- 还原增加的属性
    ---- caster:SetPhysicalArmorBaseValue((caster:GetPhysicalArmorValue() - 100))
    ---- caster:SetBaseMagicalResistanceValue((caster:GetMagicalArmorValue() - 100))
    ----销毁特效
    ParticleManager:DestroyParticle(path.m_nPtclIDGCLD, false)
    StopSoundOn("Hero_LegionCommander.Duel", caster)
    if myselfWon then
        owner:setMyPathDel(path)
        targetPlayer:setMyPathAdd(path)
        targetPlayer.m_eHero.m_bGCLD = nil

        AMHC:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf"
        , PATTACH_ABSORIGIN, false, targetPlayer.m_eHero, 2)
        EmitGlobalSound("Hero_LegionCommander.Victory")
    else
        ----攻城失败，扣钱
        local nGold = caster:GetHealth()
        targetPlayer:giveGold(nGold, owner)
        GMManager:showGold(targetPlayer, -nGold)
        GMManager:showGold(owner, nGold)

        ----回复兵卒血量
        ---- caster:ModifyHealth(caster:GetMaxHealth(), nil, false, 0)
        caster.m_bBattle = nil
        caster.m_bGCLD = nil
        owner:setBzAttack(caster)
        owner:setBzAtker(caster, targetPlayer.m_eHero, true)
        owner:setBzBeAttack(caster, false)

        EmitGlobalSound("Hero_LegionCommander.Duel.Cast")
    end

    ----攻城结束事件
    EventManager:fireEvent("Event_GCLDEnd", {
        entity = targetPlayer.m_eHero
        , path = path
        , bWin = myselfWon
    })

    ----英雄回到原位
    targetPlayer:setState(-(PS_AtkHero))
    path.m_nPlayerIDGCLD = nil
    targetPlayer:moveToPos(path:getUsePos(), function()
        targetPlayer:resetToPath()
    end)
end