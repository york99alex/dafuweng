-----魔瓶
if nil == Card_MAGIC_Bottle then
    ---@class Card_MAGIC_Bottle : Card
    Card_MAGIC_Bottle = class({}, nil, Card)
end

---@type Card_MAGIC_Bottle
local this = Card_MAGIC_Bottle

----构造函数
function this:constructor(tInfo, nPlayerID)
    this.__base__.constructor(self, tInfo, nPlayerID)
end

function this:CastFilterResultTarget(hTarget)
    if not IsValid(hTarget) then
        return UF_FAIL_CUSTOM
    end
    if not self:CanUseCard(hTarget) then
        return UF_FAIL_CUSTOM
    end
    if not hTarget.m_bRune then
        m_strCastError = "LuaAbilityError_TargetRune"
        return UF_FAIL_CUSTOM
    end
    self.m_eTarget = hTarget
    return UF_SUCCESS
end

----能否在移动时释放
function this:isCanCastMove()
    return true
end
----能否在监狱时释放
function this:isCanCastInPrison()
    return true
end
----能否在攻击时释放
function this:isCanCastHeroAtk()
    return true
end
----能否对兵卒释放
function this:isCanCastBZ()
    return false
end
----能否对英雄释放
function this:isCanCastHero()
    return false
end
----能否对神符释放
function this:isCanCastRune()
    return true
end

----卡牌释放
function this:OnSpellStart()
    local eTarget = self:GetCursorTarget()
    if not IsValid(eTarget) then
        return
    end
    ---@type Player
    local owner = self:GetOwner()
    ---@type PathRune
    local path = eTarget.m_path
    if not path or not instanceof(path, PathRune) then
        return
    end

    ----获得一张对应神符卡牌
    local typeCard
    if DOTA_RUNE_DOUBLEDAMAGE == path.m_typeRune then
        typeCard = TCard_MAGIC_BottleDouble
    elseif DOTA_RUNE_HASTE == path.m_typeRune then
        typeCard = TCard_MAGIC_BottleHaste
    elseif DOTA_RUNE_ILLUSION == path.m_typeRune then
        typeCard = TCard_MAGIC_BottleIllusion
    elseif DOTA_RUNE_INVISIBILITY == path.m_typeRune then
        typeCard = TCard_MAGIC_BottleInvisibility
    elseif DOTA_RUNE_REGENERATION == path.m_typeRune then
        typeCard = TCard_MAGIC_BottleRegeneration
    elseif DOTA_RUNE_BOUNTY == path.m_typeRune then
        typeCard = TCard_MAGIC_BottleBounty
    elseif DOTA_RUNE_ARCANE == path.m_typeRune then
        typeCard = TCard_MAGIC_BottleArcane
    else
        return
    end
    local card = CardFactory:create(typeCard, owner.m_nPlayerID)
    if card then
        owner:setCardAdd(card)
    end
    ----移除这个神符
    path:destoryRune()
    Timers:CreateTimer(2, function()
        path:spawnRune()
    end)

    ----特效
    EmitGlobalSound('Bottle.Cork')
end