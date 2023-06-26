----撒旦之邪力
function onItem_satanic(keys)
    ----监听受伤
    EventManager:register("Event_OnDamage", function(tEvent)
        if not IsValid(keys.ability) or not IsValid(keys.caster) then
            return true
        end
        if tEvent.entindex_victim_const ~= keys.caster:GetEntityIndex()
        or 1 > tEvent.damage
        or not keys.ability:IsCooldownReady()
        then
            return
        end
        ----少于阈值触发
        local nHeathMin = keys.caster:GetMaxHealth() * 30 * 0.01
        local nHeathCur = keys.caster:GetHealth() - tEvent.damage
        if nHeathCur <= nHeathMin then
            keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel() - 1))
            keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_xixue_satanic", { duration = 5 })
        end
    end)
end

LinkLuaModifier("modifier_xixue_satanic", "Ability/items/item_satanic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_xixue_satanic_debuff", "Ability/items/item_satanic.lua", LUA_MODIFIER_MOTION_NONE)


----不洁狂热
if modifier_xixue_satanic_debuff == nil then
    modifier_xixue_satanic_debuff = class({})
end
function modifier_xixue_satanic_debuff:IsHidden()
    return true
end
function modifier_xixue_satanic_debuff:IsDebuff()
    return true
end
function modifier_xixue_satanic_debuff:IsPurgable()
    return true
end
function modifier_xixue_satanic_debuff:IsPurgeException()
    return false
end
function modifier_xixue_satanic_debuff:IsStunDebuff()
    return false
end
function modifier_xixue_satanic_debuff:AllowIllusionDuplicate()
    return false
end
function modifier_xixue_satanic_debuff:RemoveOnDeath()
    return false
end
function modifier_xixue_satanic_debuff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_xixue_satanic_debuff:OnCreated(params)
    self.unholy_lifesteal_percent = self:GetAbilitySpecialValueFor("unholy_lifesteal_percent") * 0.01
    AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_xixue_satanic_debuff:OnDestroy()
    RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_xixue_satanic_debuff:OnTakeDamage(params)
    if params.attacker ~= self:GetCaster() then return end

    local nHeal
    if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
        ----攻击吸血
        nHeal = params.damage * self.unholy_lifesteal_percent
    elseif params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
        ----技能吸血
        nHeal = params.damage * self.unholy_lifesteal_percent
    end

    if nHeal and 0 < nHeal then
        params.attacker:Heal(nHeal, params.attacker)
        if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
            AMHC:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf"
            , PATTACH_OVERHEAD_FOLLOW, false, params.attacker, 2)
        else
            AMHC:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf"
            , PATTACH_OVERHEAD_FOLLOW, false, params.attacker, 2)
        end
    end
    self:Destroy()
end
--==============
if modifier_xixue_satanic == nil then
    modifier_xixue_satanic = class({})
end
function modifier_xixue_satanic:IsHidden()
    return false
end
function modifier_xixue_satanic:IsDebuff()
    return false
end
function modifier_xixue_satanic:IsPurgable()
    return false
end
function modifier_xixue_satanic:IsPurgeException()
    return false
end
function modifier_xixue_satanic:IsStunDebuff()
    return false
end
function modifier_xixue_satanic:AllowIllusionDuplicate()
    return false
end
function modifier_xixue_satanic:OnCreated(params)
    self.unholy_lifesteal_total_tooltip = self:GetAbilitySpecialValueFor("unholy_lifesteal_total_tooltip")
end
function modifier_xixue_satanic:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
    }
end
function modifier_xixue_satanic:GetModifierTotalDamageOutgoing_Percentage(params)
    if params.target == nil then return end
    if params.attacker == self:GetParent() then
        params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_xixue_satanic_debuff", { duration = 1 / 30 })
    end
end
function modifier_xixue_satanic:GetBonusDayVision()
    return self.unholy_lifesteal_total_tooltip
end