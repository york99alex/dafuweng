if modifier_intellect == nil then
    modifier_intellect = class({})
end

local public = modifier_intellect

function public:IsHidden()
    return true
end
function public:IsDebuff()
    return false
end
function public:IsPurgable()
    return false
end
function public:IsPurgeException()
    return false
end
function public:AllowIllusionDuplicate()
    return false
end
function public:DestroyOnExpire()
    return false
end
function public:OnCreated(params)
    if IsServer() then
        local hParent = self:GetParent()
        self.sKey = SetOutgoingDamagePercent(hParent, DAMAGE_TYPE_MAGICAL, 0)
    end
end
function public:OnStackCountChanged(iOldStackCount)
    if IsServer() then
        local hParent = self:GetParent()
        local iNewStackCount = self:GetStackCount()
        local iChanged = iNewStackCount - iOldStackCount

        hParent:ModifyMaxMana(iChanged * ATTRIBUTE_INTELLIGENCE_MANA)

        if hParent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
            local iValue = iChanged * ATTRIBUTE_PRIMARY_ATTACK_DAMAGE
            hParent:SetBaseDamageMax(hParent:GetBaseDamageMax() + iValue)
            hParent:SetBaseDamageMin(hParent:GetBaseDamageMin() + iValue)
        end

        SetOutgoingDamagePercent(hParent, DAMAGE_TYPE_MAGICAL, iNewStackCount * ATTRIBUTE_INTELLIGENCE_MAGICAL_DAMAGE_PERCENT, self.sKey)
    end
end
function public:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end
function public:GetModifierConstantManaRegen(params)
    return ATTRIBUTE_INTELLIGENCE_MANA_REGEN * self:GetStackCount()
end
function public:GetModifierSpellAmplify_Percentage(params)
    if self:GetParent():IsHero() then
        return self:GetParent():GetIntellect() * ATTRIBUTE_INTELLIGENCE_SPELL_AMPLIFY_PERCENT
    else
        return ATTRIBUTE_INTELLIGENCE_SPELL_AMPLIFY_PERCENT * self:GetStackCount()
    end
end