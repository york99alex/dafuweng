-----卡牌窃取
if nil == Card_MAGIC_Card_Steal then
    ---@class Card_MAGIC_Card_Steal : Card
    Card_MAGIC_Card_Steal = class({}, nil, Card)
    if PrecacheItems then
        table.insert(PrecacheItems, "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf")
        table.insert(PrecacheItems, "soundevents/game_sounds_heroes/game_sounds_rubick.vsndevts")
    end
end

---@type Card_MAGIC_Card_Steal
local this = Card_MAGIC_Card_Steal

----构造函数
function this:constructor(tInfo, nPlayerID)
    this.__base__.constructor(self, tInfo, nPlayerID)
end

----选择目标单位时
function this:CastFilterResultTarget(hTarget)
    if not IsValid(hTarget) then
        return UF_FAIL_CUSTOM
    end
    if not self:CanUseCard(hTarget) then
        return UF_FAIL_CUSTOM
    end

    ---@type Player
    local playerTarget = PlayerManager:getPlayer(hTarget:GetPlayerOwnerID())
    if not playerTarget then
        return UF_FAIL_CUSTOM
    end
    ----目标上一使用的卡牌
    local cardLast = playerTarget.m_tabUseCard[#playerTarget.m_tabUseCard]
    if not cardLast then
        self.m_strCastError = "CardError_NoLastCard"
        return UF_FAIL_CUSTOM
    end

    self.m_eTarget = hTarget
    return UF_SUCCESS
end

----能否对监狱中玩家释放
function this:isCanCastInPrisonTarget()
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
    ---@type Player
    local playerTarget = PlayerManager:getPlayer(eTarget:GetPlayerOwnerID())
    ----给目标上一使用的卡牌
    ---@type Card
    local cardLast = playerTarget.m_tabUseCard[#playerTarget.m_tabUseCard]
    if not cardLast then
        return
    end
    local card = CardFactory:create(cardLast.m_typeCard, owner.m_nPlayerID)
    if card then
        owner:setCardAdd(card)
    end

    ----特效
    EmitGlobalSound('Hero_Rubick.SpellSteal.Cast')
    local nPtclID = AMHC:CreateParticle('particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf'
    , PATTACH_OVERHEAD_FOLLOW, false, playerTarget.m_eHero, 3)
    ParticleManager:SetParticleControl(nPtclID, 1, owner.m_eHero:GetAbsOrigin())
end