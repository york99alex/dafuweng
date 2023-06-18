-----移形换位
if nil == Card_MAGIC_Swap then
    ---@class Card_MAGIC_Swap : Card
    Card_MAGIC_Swap = class({}, nil, Card)
    if PrecacheItems then
        table.insert(PrecacheItems, "particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf")
        table.insert(PrecacheItems, "soundevents/game_sounds_heroes/game_sounds_vengefulspirit.vsndevts")
    end
end

---@type Card_MAGIC_Swap
local this = Card_MAGIC_Swap

----构造函数
function this:constructor(tInfo, nPlayerID)
    this.__base__.constructor(self, tInfo, nPlayerID)
end

----能否对兵卒释放
function this:isCanCastBZ()
    return false
end
----能否对战斗中玩家释放
function this:isCanCastBattleTarget()
    return false
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
    ----交换位置
    local path = owner.m_pathCur
    owner:blinkToPath(playerTarget.m_pathCur)
    playerTarget:blinkToPath(path)

    ----特效
    EmitGlobalSound('Hero_VengefulSpirit.NetherSwap')
    local nPtclID = AMHC:CreateParticle('particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf'
    , PATTACH_POINT, false, owner.m_eHero, 5)
    ParticleManager:SetParticleControl(nPtclID, 0, owner.m_eHero:GetAbsOrigin())
    ParticleManager:SetParticleControl(nPtclID, 1, eTarget:GetAbsOrigin())
end