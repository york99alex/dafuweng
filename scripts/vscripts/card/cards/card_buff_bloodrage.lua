-----血怒
if nil == Card_BUFF_Bloodrage then
    ---@class Card_BUFF_Bloodrage : Card
    Card_BUFF_Bloodrage = class({}, nil, Card)
    LinkLuaModifier("modifier_bloodseeker_bloodrage_bg", "Card/Cards/Card_BUFF_Bloodrage.lua", LUA_MODIFIER_MOTION_NONE)
    if PrecacheItems then
        table.insert(PrecacheItems, "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf")
        table.insert(PrecacheItems, "soundevents/game_sounds_heroes/game_sounds_bloodseeker.vsndevts")
    end
end

---@type Card_BUFF_Bloodrage
local this = Card_BUFF_Bloodrage

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
----能否对野怪释放
function this:isCanCastMonster()
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
    AbilityManager:setCopyBuff('modifier_bloodseeker_bloodrage_bg'
    , eTarget, owner.m_eHero, nil, nil, true)

    EmitGlobalSound('hero_bloodseeker.bloodRage')
end

----血怒buff
modifier_bloodseeker_bloodrage_bg = class({})
function modifier_bloodseeker_bloodrage_bg:IsHidden()
    return false
end
function modifier_bloodseeker_bloodrage_bg:IsPurgable()
    return true
end
function modifier_bloodseeker_bloodrage_bg:IsDebuff()
    return self:GetParent():GetPlayerOwnerID() ~= self:GetCaster():GetPlayerOwnerID()
end
function modifier_bloodseeker_bloodrage_bg:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_bloodseeker_bloodrage_bg:GetTexture()
    return 'bloodseeker_bloodrage'
end
function modifier_bloodseeker_bloodrage_bg:GetEffectName()
    return "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf"
end
function modifier_bloodseeker_bloodrage_bg:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end
function modifier_bloodseeker_bloodrage_bg:OnCreated(kv)
    self.damage_out_amplify = 20
    self.damage_in_amplify = 20
end
function modifier_bloodseeker_bloodrage_bg:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end
----受到的伤害加深
function modifier_bloodseeker_bloodrage_bg:GetModifierIncomingDamage_Percentage(params)
    local nStack = math.max(self:GetStackCount(), 1)
    return self.damage_in_amplify * nStack
end
----造成的伤害加深
function modifier_bloodseeker_bloodrage_bg:GetModifierTotalDamageOutgoing_Percentage(params)
    local nStack = math.max(self:GetStackCount(), 1)
    return self.damage_out_amplify * nStack
end
function modifier_bloodseeker_bloodrage_bg:GetBonusDayVision()
    local nStack = math.max(self:GetStackCount(), 1)
    return self.damage_out_amplify * nStack
end
function modifier_bloodseeker_bloodrage_bg:GetBonusNightVision()
    local nStack = math.max(self:GetStackCount(), 1)
    return self.damage_in_amplify * nStack
end
function modifier_bloodseeker_bloodrage_bg:GetPriority()
    return MODIFIER_PRIORITY_LOW
end