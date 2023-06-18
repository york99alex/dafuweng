if modifier_strength == nil then
    modifier_strength = class({})
end

local public = modifier_strength

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
        self.sKey = SetOutgoingDamagePercent(hParent, DAMAGE_TYPE_PHYSICAL, 0)
    end
end
function public:OnStackCountChanged(iOldStackCount)
    if IsServer() then
        local hParent = self:GetParent()
        local iNewStackCount = self:GetStackCount()
        local iChanged = iNewStackCount - iOldStackCount

        hParent:ModifyMaxHealth(iChanged * ATTRIBUTE_STRENGTH_HP)

        if hParent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
            local iValue = iChanged * ATTRIBUTE_PRIMARY_ATTACK_DAMAGE
            hParent:SetBaseDamageMax(hParent:GetBaseDamageMax() + iValue)
            hParent:SetBaseDamageMin(hParent:GetBaseDamageMin() + iValue)
        end

        SetOutgoingDamagePercent(hParent, DAMAGE_TYPE_PHYSICAL, iNewStackCount * ATTRIBUTE_STRENGTH_PHYSICAL_DAMAGE_PERCENT, self.sKey)
    end
end
function public:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end
function public:GetModifierConstantHealthRegen(params)
    return ATTRIBUTE_STRENGTH_HP_REGEN * self:GetStackCount()
end
function public:GetModifierMagicalResistanceBonus(params)
    return Round(ATTRIBUTE_STRENGTH_MAGICAL_RESISTANCE * self:GetStackCount())
end
function public:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end