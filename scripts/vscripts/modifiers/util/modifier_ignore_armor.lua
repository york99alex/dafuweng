if modifier_ignore_armor_debuff == nil then
    modifier_ignore_armor_debuff = class({})
end
function modifier_ignore_armor_debuff:IsHidden()
    return true
end
function modifier_ignore_armor_debuff:IsDebuff()
    return true
end
function modifier_ignore_armor_debuff:IsPurgable()
    return false
end
function modifier_ignore_armor_debuff:IsPurgeException()
    return false
end
function modifier_ignore_armor_debuff:IsStunDebuff()
    return false
end
function modifier_ignore_armor_debuff:AllowIllusionDuplicate()
    return false
end
function modifier_ignore_armor_debuff:RemoveOnDeath()
    return false
end
function modifier_ignore_armor_debuff:OnCreated(params)
    self.ignore_armor = self:GetAbilitySpecialValueFor("ignore_armor") * 0.01
    self.ignore_armor_base = self:GetAbilitySpecialValueFor("ignore_armor_base") * 0.01
    self.ignore_armor_bonus = self:GetAbilitySpecialValueFor("ignore_armor_bonus") * 0.01
    if self.ignore_armor then
        self.armor_reduction = -math.max(self:GetParent():GetPhysicalArmorValue(false) * self.ignore_armor, 0)
    else
        self.armor_reduction = -math.max(self:GetParent():GetPhysicalArmorBaseValue() * self.ignore_armor_base
        + self:GetParent():GetPhysicalArmorValue(true) * self.ignore_armor_bonus
        , 0)
    end
    AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_ignore_armor_debuff:OnDestroy()
    RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_ignore_armor_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    -- MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end
function modifier_ignore_armor_debuff:GetModifierPhysicalArmorBonus(params)
    return self.armor_reduction
end
function modifier_ignore_armor_debuff:OnTakeDamage(params)
    if params.unit == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
        self:Destroy()
    end
end
--==============
if modifier_ignore_armor == nil then
    modifier_ignore_armor = class({})
end
function modifier_ignore_armor:IsHidden()
    return true
end
function modifier_ignore_armor:IsDebuff()
    return false
end
function modifier_ignore_armor:IsPurgable()
    return false
end
function modifier_ignore_armor:IsPurgeException()
    return false
end
function modifier_ignore_armor:IsStunDebuff()
    return false
end
function modifier_ignore_armor:AllowIllusionDuplicate()
    return false
end
function modifier_ignore_armor:OnCreated(params)
    AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_ignore_armor:OnRefresh(params)
    RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_ignore_armor:OnAttackLanded(params)
    if params.target == nil then return end
    if params.attacker == self:GetParent() then
        params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_ignore_armor_debuff", { duration = 1 / 30 })
    end
end