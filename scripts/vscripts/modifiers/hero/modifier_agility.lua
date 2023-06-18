if modifier_agility == nil then
    modifier_agility = class({})
end

local public = modifier_agility

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
function public:OnStackCountChanged(iOldStackCount)
    if IsServer() then
        local hParent = self:GetParent()
        local iNewStackCount = self:GetStackCount()
        local iChanged = iNewStackCount - iOldStackCount

        if hParent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
            local iValue = iChanged * ATTRIBUTE_PRIMARY_ATTACK_DAMAGE
            hParent:SetBaseDamageMax(hParent:GetBaseDamageMax() + iValue)
            hParent:SetBaseDamageMin(hParent:GetBaseDamageMin() + iValue)
        end
    end
end
function public:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end
function public:GetModifierAttackSpeedBonus_Constant(params)
    return ATTRIBUTE_AGILITY_ATTACK_SPEED * self:GetStackCount()
end
function public:GetModifierPhysicalArmorBonus(params)
    return Round(ATTRIBUTE_AGILITY_PHYSICAL_ARMOR * self:GetStackCount())
end
function public:GetModifierPercentageCooldownStacking(params)
    return (1 - math.pow(1 - ATTRIBUTE_AGILITY_COOLDOWN_REDUCTION_PERCENT * 0.01, self:GetStackCount())) * 100
end