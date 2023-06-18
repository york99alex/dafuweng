--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----卡牌基类
if nil == Card then
    ---@class Card
    Card = class({
        m_nID = nil					----卡牌ID
        , m_nOwnerID = nil          ----拥有者ID
        , m_nManaCost = nil          ----魔法消耗
        , m_nManaCostBase = nil          ----基础魔法消耗

        , m_strCastError = ""           ----释放错误信息
        , m_strCastErrorSound = ""      ----释放错误音效

        , m_typeCard = nil			----卡牌类型
        , m_typeCast = nil			----施法类型
        , m_typeKind = nil			----卡牌种类

        , m_eTarget = nil			----目标单位
        , m_vTargetPos = nil			----目标点

        , m_tabAbltInfo = nil       ---- 技能信息
    })
end

---@type Card
local this = Card

----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function this:constructor(tInfo, nPlayerID)
    self.m_typeCard = tonumber(tInfo.CardType)
    self.m_nID = CardManager:getIncludeID()
    if nPlayerID then
        self.m_nOwnerID = nPlayerID
        if not CardManager.m_tGetCardCount[nPlayerID] then CardManager.m_tGetCardCount[nPlayerID] = {} end
        CardManager.m_tGetCardCount[nPlayerID][self.m_typeCard] = 1 + (CardManager.m_tGetCardCount[nPlayerID][self.m_typeCard] or 0)
    end

    self.m_typeCast = tonumber(tInfo.CastType)
    self.m_typeKind = tonumber(tInfo.CardKind)
    self.m_nManaCost = tonumber(tInfo.ManaCost)
    self.m_nManaCostBase = self.m_nManaCost
end

----设置主人
function this:setOwner(player)
    self.m_nOwnerID = player.m_nPlayerID
end

function this:GetOwner()
    local player = PlayerManager:getPlayer(self.m_nOwnerID)
    if NIL(player) then
        return
    end
    return player
end
----选择目标单位时
----@param 目标单位
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function this:CastFilterResultTarget(hTarget)
    if not IsValid(hTarget) then
        return UF_FAIL_CUSTOM
    end
    if not self:CanUseCard(hTarget) then
        return UF_FAIL_CUSTOM
    end
    self.m_eTarget = hTarget
    return UF_SUCCESS
end
----
----选择目标地点时
----@param 目标地点vector
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function this:CastFilterResultLocation(vLocation)
    if not self:CanUseCard(nil, vLocation) then
        return UF_FAIL_CUSTOM
    end
    self.m_vTargetPos = vLocation
    return UF_SUCCESS
end
----
----选择无目标时
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function this:CastFilterResult()
    if not self:CanUseCard() then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end

----发送错误消息
function this:onCastError()
    if '' ~= self.m_strCastError then
        HudError:FireLocalizeError(self.m_nOwnerID, self.m_strCastError)
    end
    if '' ~= self.m_strCastErrorSound then
        EmitSoundOnClient(self.m_strCastErrorSound, PlayerResource:GetPlayer(self.m_nOwnerID))
        self.m_strCastErrorSound = ""
    end
end

----返回施法者
-----@return m_eHero
function this:GetCaster()
    local player = PlayerManager:getPlayer(self.m_nOwnerID)
    if NIL(player) then
        return
    end
    return player.m_eHero
end
----返回目标单位
function this:GetCursorTarget()
    return self.m_eTarget
end
----返回目标点
function this:GetCursorPosition()
    return self.m_vTargetPos
end
----返回伤害类型
function this:GetAbilityDamageType()
    return DAMAGE_TYPE_MAGICAL
end

----返回消耗魔法
function this:GetManaCost()
    if TESTHELP or TESTCARD then
        return 0
    end

    local nManaCost = self.m_nManaCost

    ----计算魔法减缩
    local player = PlayerManager:getPlayer(self.m_nOwnerID)
    if not NIL(player) then
        nManaCost = nManaCost - player.m_nManaSub
        if 0 > nManaCost then
            nManaCost = 0
        end
    end

    return nManaCost
end

-----能否释放卡牌技能
function this:CanUseCard(hTarget, vTargetPos)
    ----非自己阶段不能施法
    if not self:isCanCastOtherRound() and self:GetCaster():GetPlayerOwnerID() ~= GMManager.m_nOrderID then
        self.m_strCastError = "LuaAbilityError_SelfRound"
        return false
    end
    ----被沉默
    if not self:isCanCastChenMo() and self:GetCaster():IsSilenced() then
        self.m_strCastError = "LuaAbilityError_ChenMo"
        self.m_strCastErrorSound = "Custom.Silence.Ablt"
        return false
    end
    ----移动阶段不能施法
    if not self:isCanCastMove() and GS_Move == GMManager.m_typeState then
        self.m_strCastError = "LuaAbilityError_Move"
        return false
    end
    ----补给阶段不能施法
    if GS_Supply == GMManager.m_typeState then
        self.m_strCastError = "LuaAbilityError_Supply"
        return false
    end
    ----亡国阶段不能施法
    if GS_DeathClearing == GMManager.m_typeState then
        self.m_strCastError = "LuaAbilityError_DeathClearing"
        return false
    end
    ----等待阶段不能施法
    if GS_Wait == GMManager.m_typeState then
        self.m_strCastError = "LuaAbilityError_Wait"
        return false
    end
    ----玩家英雄
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if nil ~= oPlayer then
        ----在监狱不能施法
        if not self:isCanCastInPrison() and 0 < bit.band(PS_InPrison, oPlayer.m_typeState) then
            self.m_strCastError = "LuaAbilityError_Prison"
            return false
        end
        ----在英雄攻击时不能施法
        if not self:isCanCastHeroAtk() and 0 < bit.band(PS_AtkHero, oPlayer.m_typeState) then
            self.m_strCastError = "LuaAbilityError_Battle"
            return false
        end
        ----亡国清算时不能施法
        if oPlayer.m_bDeathClearing then
            self.m_strCastError = "LuaAbilityError_Die"
            return false
        end
    end
    ----没蓝不能施法
    if self:GetManaCost() > self:GetCaster():GetMana() then
        self.m_strCastError = "LuaAbilityError_NeedMana_Hero"
        return false
    end

    if hTarget and not self:checkTarget(hTarget) then
        return false
    end

    return true
end

----验证目标
function this:checkTarget(hTarget)
    if not IsValid(hTarget) then
        return false
    end

    ----不能是自己
    if hTarget == self:GetCaster() and not self:isCanCastSelf() then
        self.m_strCastError = "LuaAbilityError_SelfCant"
        return false
    end

    ----玩家
    if hTarget.GetPlayerOwnerID then
        local oPlayer = PlayerManager:getPlayer(hTarget:GetPlayerOwnerID())
        if oPlayer then
            ----目标死亡
            if 0 < bit.band(PS_Die, oPlayer.m_typeState) then
                return false
            end
            ----目标技能免疫
            if not self:isCanCastAbilityImmune() then
                if 0 < bit.band(PS_AbilityImmune, oPlayer.m_typeState) then
                    self.m_strCastError = "LuaAbilityError_AbilityImmune"
                    return false
                end
            end
            ----目标在监狱
            if not self:isCanCastInPrisonTarget() then
                if 0 < bit.band(PS_InPrison, oPlayer.m_typeState) then
                    self.m_strCastError = "LuaAbilityError_Prison"
                    return false
                end
            end
            ----目标在战斗
            if not self:isCanCastBattleTarget() then
                if 0 < bit.band(PS_AtkHero, oPlayer.m_typeState) then
                    self.m_strCastError = "LuaAbilityError_Battle"
                    return false
                end
            end
        end
    end

    ----目标是英雄
    if hTarget.IsHero and hTarget:IsHero() then
        if hTarget:IsIllusion() and not self:isCanCastIllusion() then
            ----不能是幻象
            self.m_strCastError = "LuaAbilityError_IllusionsCant"
            return false
        elseif not self:isCanCastHero() then
            ----不能是英雄
            self.m_strCastError = "LuaAbilityError_HeroCant"
            return false
        end
    elseif hTarget.m_bBZ then
        ----兵卒
        if not self:isCanCastBZ() then
            ----不能是兵卒
            self.m_strCastError = "LuaAbilityError_BZCant"
            return false
        end
    elseif hTarget.m_bMonster then
        ----野怪
        if not self:isCanCastMonster() then
            ----需要玩家控制，不能是野怪
            self.m_strCastError = "LuaAbilityError_MonsterCant"
            return false
        end
    elseif hTarget.m_bRune then
        ----神符
        if not self:isCanCastRune() then
            ----不能是神符
            self.m_strCastError = "LuaAbilityError_RuneCant"
            return false
        end
    else
        return false
    end

    return true
end

----能否在其他玩家回合时释放
function this:isCanCastOtherRound()
    return false
end
----能否在沉默时释放
function this:isCanCastChenMo()
    return false
end
----能否在移动时释放
function this:isCanCastMove()
    return false
end
----能否在监狱时释放
function this:isCanCastInPrison()
    return false
end
----能否在英雄攻击时释放
function this:isCanCastHeroAtk()
    return false
end

----能否对自身释放
function this:isCanCastSelf()
    return false
end
----能否对技能免疫释放
function this:isCanCastAbilityImmune()
    return false
end
----能否对幻象释放
function this:isCanCastIllusion()
    return false
end
----能否对兵卒释放
function this:isCanCastBZ()
    return true
end
----能否对英雄释放
function this:isCanCastHero()
    return true
end
----能否对野怪释放
function this:isCanCastMonster()
    return false
end
----能否对神符释放
function this:isCanCastRune()
    return false
end
----能否对监狱中玩家释放
function this:isCanCastInPrisonTarget()
    return false
end
----能否对战斗中玩家释放
function this:isCanCastBattleTarget()
    return true
end

-----return special value for param form m_tabAbltInfo
function this:GetSpecialValueFor(param, index)
    if self.m_tabAbltInfo then
        local tabSpecial = self.m_tabAbltInfo["AbilitySpecial"]
        if tabSpecial then
            for _k, _v in pairs(tabSpecial) do
                for p, v in pairs(_v) do
                    if p == param then
                        local res = {}
                        for num in string.gmatch(v, "%d+") do
                            table.insert(res, tonumber(num))
                        end
                        if index and 0 > index and #res >= index then
                            return res[index]
                        end
                        return res[1]
                    end
                end
            end
        end
    end
end

----卡牌释放
function this:OnSpellStart()
end

----卡牌删除
function this:destory()
    local player = PlayerManager:getPlayer(self.m_nOwnerID)
    player:setCardDel(self)

    for k, v in pairs(CardManager.m_tabCards) do
        if v == self then
            table.remove(CardManager.m_tabCards, k)
            break
        end
    end
end

----卡牌更新
function this:updata()
    local player = PlayerManager:getPlayer(self.m_nOwnerID)
    if NIL(player) then
        return
    end

    ----通知客户端更新卡牌数据
    local jsonData = {
        self:encodeJsonData()
    }

    jsonData = json.encode(jsonData)

    player:sendMsg("GM_CardUpdata", {
        nPlayerID = self.m_nOwnerID,
        json = jsonData
    })
end
function this:encodeJsonData()
    return {
        nCardID = self.m_nID,
        CardType = self.m_typeCard,
        CardKind = self.m_typeKind,
        CastType = self.m_typeCast,
        ManaCost = self:GetManaCost(),
    }
end