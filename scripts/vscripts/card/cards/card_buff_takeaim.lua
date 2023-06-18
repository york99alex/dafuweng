-----瞄准
if nil == Card_BUFF_TakeAim then
    ---@class Card_BUFF_TakeAim : Card
    Card_BUFF_TakeAim = class({}, nil, Card)
    LinkLuaModifier("modifier_sniper_take_aim_bg", "Card/Cards/Card_BUFF_TakeAim.lua", LUA_MODIFIER_MOTION_NONE)
    if PrecacheItems then
        table.insert(PrecacheItems, "soundevents/game_sounds_heroes/game_sounds_sniper.vsndevts")
    end
end

---@type Card_BUFF_TakeAim
local this = Card_BUFF_TakeAim

----构造函数
function this:constructor(tInfo, nPlayerID)
    this.__base__.constructor(self, tInfo, nPlayerID)
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
----能否对自身释放
function this:isCanCastSelf()
    return true
end
----能否对监狱中玩家释放
function this:isCanCastInPrisonTarget()
    return true
end
----能否对战斗中玩家释放
function this:isCanCastBattleTarget()
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

    ----添加buff
    AbilityManager:setCopyBuff('modifier_sniper_take_aim_bg'
    , eTarget, owner.m_eHero, nil, nil, true)

    EmitGlobalSound('Ability.AssassinateLoad')
end

----瞄准buff
modifier_sniper_take_aim_bg = class({})
function modifier_sniper_take_aim_bg:IsHidden()
    return false
end
function modifier_sniper_take_aim_bg:IsPurgable()
    return true
end
function modifier_sniper_take_aim_bg:IsDebuff()
    return false
end
function modifier_sniper_take_aim_bg:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_sniper_take_aim_bg:GetTexture()
    return 'sniper_take_aim'
end
function modifier_sniper_take_aim_bg:OnCreated(kv)
    self.bonus_attack_range = 100
end
function modifier_sniper_take_aim_bg:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    }
end
----额外射程
function modifier_sniper_take_aim_bg:GetModifierAttackRangeBonus()
    local nStack = math.max(self:GetStackCount(), 1)
    return self.bonus_attack_range * nStack
end