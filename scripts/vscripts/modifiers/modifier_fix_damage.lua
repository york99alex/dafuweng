if modifier_fix_damage == nil then
    modifier_fix_damage = class({})
end

local public = modifier_fix_damage

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
function public:RemoveOnDeath()
    return false
end
function public:DestroyOnExpire()
    return false
end
function public:IsPermanent()
    return true
end
function public:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end
function public:GetModifierIncomingDamage_Percentage(params)
    local percent = 100
    if params.damage_type == DAMAGE_TYPE_PHYSICAL then
        if params.attacker then
            percent = percent * GetOutgoingDamagePercent(params.attacker, DAMAGE_TYPE_PHYSICAL) * 0.01
        end
    end
    if params.damage_type == DAMAGE_TYPE_MAGICAL then
        if params.attacker then
            percent = percent * GetOutgoingDamagePercent(params.attacker, DAMAGE_TYPE_MAGICAL) * 0.01
        end
    end
    if params.damage_type == DAMAGE_TYPE_PURE then
        if params.attacker then
            percent = percent * GetOutgoingDamagePercent(params.attacker, DAMAGE_TYPE_PURE) * 0.01
        end
    end
    if params.attacker then
        percent = percent * GetOutgoingDamagePercent(params.attacker, DAMAGE_TYPE_NONE) * 0.01
    end
    return percent - 100
end
function public:GetModifierIncomingSpellDamageConstant(params)
    -- 无视魔法抗性效果
    if params.attacker and params.damage_type == DAMAGE_TYPE_MAGICAL then
        local magicalArmor = self:GetParent():GetMagicalArmorValue()
        local value = GetIgnoreMagicResistanceValue(params.attacker)
        local ignore = math.max(magicalArmor, 0) - math.max(magicalArmor - value, 0)
        local actualMagicalArmor = magicalArmor - ignore
        local factor = (1 - actualMagicalArmor) / (1 - magicalArmor)
        return params.original_damage * (factor - 1)
    end
end
-- function public:GetModifierTotalDamageOutgoing_Percentage(params)
--     local percent = 100
--     local bIsSpellCrit = false
--     -- 法术暴击
--     if params.attacker == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ~= DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
--         local spell_crit_damage = GetSpellCriticalStrike(params.attacker)
--         if spell_crit_damage > 0 then
--             spell_crit_damage = spell_crit_damage + GetSpellCriticalStrikeDamage(params.attacker)
--             percent = percent * spell_crit_damage * 0.01
--             bIsSpellCrit = true
--         end
--     end
--     -- 伤害转化
--     if params.attacker == self:GetParent()
--     and params.damage_type == DAMAGE_TYPE_PHYSICAL
--     and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ~= DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL
--     and params.attacker:HasModifier("modifier_t21_magical_link_buff") then
--         local modifier_t21_magical_link_buff = params.attacker:FindModifierByName("modifier_t21_magical_link_buff")
--         if IsValid(modifier_t21_magical_link_buff) then
--             local transform_damage_percent = modifier_t21_magical_link_buff.transform_damage_percent or 0
--             local tDamageTable = {
--                 ability = params.inflictor,
--                 victim = params.target,
--                 attacker = params.attacker,
--                 damage = params.original_damage * percent * 0.01 * transform_damage_percent * 0.01,
--                 damage_type = DAMAGE_TYPE_MAGICAL,
--                 damage_flags = params.damage_flags + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL,
--             }
--             ApplyDamage(tDamageTable)
--             percent = percent * (1 - transform_damage_percent * 0.01)
--         end
--     end
--     if bIsSpellCrit then
--         if percent > 0 then
--             SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, params.target, params.original_damage * percent * 0.01, params.attacker:GetPlayerOwner())
--         end
--     end
--     return percent - 100
-- end