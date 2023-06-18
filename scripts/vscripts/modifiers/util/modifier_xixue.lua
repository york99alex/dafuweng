if modifier_xixue_debuff == nil then
    modifier_xixue_debuff = class({})
end
function modifier_xixue_debuff:IsHidden()
    return true
end
function modifier_xixue_debuff:IsDebuff()
    return true
end
function modifier_xixue_debuff:IsPurgable()
    return false
end
function modifier_xixue_debuff:IsPurgeException()
    return false
end
function modifier_xixue_debuff:IsStunDebuff()
    return false
end
function modifier_xixue_debuff:AllowIllusionDuplicate()
    return false
end
function modifier_xixue_debuff:RemoveOnDeath()
    return false
end
function modifier_xixue_debuff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_xixue_debuff:OnCreated(params)
    self.lifesteal_percent = self:GetAbilitySpecialValueFor("lifesteal_percent") * 0.01
    self.lifesteal_ablt_percent = self:GetAbilitySpecialValueFor("lifesteal_ablt_percent") * 0.01
    AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_xixue_debuff:OnDestroy()
    RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_xixue_debuff:OnTakeDamage(params)
    if params.attacker ~= self:GetCaster() then return end

    local nHeal
    if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK
    and 0 < self.lifesteal_percent then
        ----攻击吸血
        nHeal = params.damage * self.lifesteal_percent
    elseif params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL
    and 0 < self.lifesteal_ablt_percent then
        ----技能吸血
        nHeal = params.damage * self.lifesteal_ablt_percent
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
if modifier_xixue == nil then
    modifier_xixue = class({})
end
function modifier_xixue:IsHidden()
    return true
end
function modifier_xixue:IsDebuff()
    return false
end
function modifier_xixue:IsPurgable()
    return false
end
function modifier_xixue:IsPurgeException()
    return false
end
function modifier_xixue:IsStunDebuff()
    return false
end
function modifier_xixue:AllowIllusionDuplicate()
    return false
end
function modifier_xixue:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_xixue:OnCreated(params)
    -- AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
-- function modifier_xixue:OnRefresh(params)
--     RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
-- end
-- function modifier_xixue:OnAttackLanded(params)
--     if params.target == nil then return end
--     if params.attacker == self:GetParent() then
--         params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_xixue_debuff", { duration = 1 / 30 })
--     end
-- end
function modifier_xixue:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end
function modifier_xixue:GetModifierTotalDamageOutgoing_Percentage(params)
    if params.target == nil then return end
    if params.attacker == self:GetParent() then
        params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_xixue_debuff", { duration = 1 / 30 })
    end
end
-- ======================
-- activity: -1
-- attacker:
-- 		__self: userdata: 0x005ef0a0
-- 		m_bMonster: true
-- 		outgoingDamagePercents:
-- 				0:
-- 				1:
-- basher_tested: false
-- cost: 0
-- damage: 3.1526877880096
-- damage_category: 1
-- damage_flags: 0
-- damage_type: 1
-- diffusal_applied: false
-- distance: 0
-- do_not_consume: false
-- fail_type: 2
-- gain: 0
-- heart_regen_applied: false
-- ignore_invis: false
-- issuer_player_index: 32762
-- mkb_tested: false
-- new_pos: Vector 0000000000A61F28 [0.000000 0.000000 0.000000]
-- no_attack_cooldown: false
-- order_type: 0
-- original_damage: 11
-- process_procs: false
-- ranged_attack: false
-- record: 41
-- reincarnate: false
-- stout_tested: false
-- unit:
-- 		GiveMana: function: 0x005da210
-- 		SetMana: function: 0x005da258
-- 		SpendMana: function: 0x005da1e8
-- 		__recorder__:
-- 				mana: 32.800003051758
-- 		__recorder__modified_data__:
-- 				mana: 4
-- 		__self: userdata: 0x005cd8a8
-- 		_eShareOwner: table: 0x005cd868
-- 		_onItem_power_treads: true
-- 		hIntModifier:
-- 				BaseClass:
-- 						bool AllowIllusionDuplicate()
-- True/false if this modifier is active on illusions.
-- 						bool CanParentBeAutoAttacked()
-- 						bool DestroyOnExpire()
-- True/false if this buff is removed when the duration expires.
-- 						int GetAttributes()
-- Return the types of attributes applied to this modifier (enum value from DOTAModifierAttribute_t
-- 						float GetAuraDuration()
-- Returns aura stickiness
-- 						bool GetAuraEntityReject(handle hEntity)
-- Return true/false if this entity should receive the aura under specific conditions
-- 						int GetAuraRadius()
-- Return the range around the parent this aura tries to apply its buff.
-- 						int GetAuraSearchFlags()
-- Return the unit flags this aura respects when placing buffs.
-- 						int GetAuraSearchTeam()
-- Return the teams this aura applies its buff to.
-- 						int GetAuraSearchType()
-- Return the unit classifications this aura applies its buff to.
-- 						int GetEffectAttachType()
-- Return the attach type of the particle system from GetEffectName.
-- 						string GetEffectName()
-- Return the name of the particle system that is created while this modifier is active.
-- 						string GetHeroEffectName()
-- Return the name of the hero effect particle system that is created while this modifier is active.
-- 						string GetModifierAura()
-- The name of the secondary modifier that will be applied by this modifier (if it is an aura).
-- 						int GetPriority()
-- Return the priority order this modifier will be applied over others.
-- 						string GetStatusEffectName()
-- Return the name of the status effect particle system that is created while this modifier is active.
-- 						string GetTexture()
-- Return the name of the buff icon to be shown for this modifier.
-- 						int HeroEffectPriority()
-- Relationship of this hero effect with those from other buffs (higher is more likely to be shown).
-- 						bool IsAura()
-- True/false if this modifier is an aura.
-- 						bool IsAuraActiveOnDeath()
-- True/false if this aura provides buffs when the parent is dead.
-- 						bool IsDebuff()
-- True/false if this modifier should be displayed as a debuff.
-- 						bool IsHidden()
-- True/false if this modifier should be displayed on the buff bar.
-- 						IsNull: function: 0x00135ae0
-- 						bool IsPermanent()
-- 						bool IsPurgable()
-- True/false if this modifier can be purged.
-- 						bool IsPurgeException()
-- True/false if this modifier can be purged by strong dispels.
-- 						bool IsStunDebuff()
-- True/false if this modifier is considered a stun for purge reasons.
-- 						void OnCreated(handle table)
-- Runs when the modifier is created.
-- 						void OnDestroy()
-- Runs when the modifier is destroyed (after unit loses modifier).
-- 						void OnIntervalThink()
-- Runs when the think interval occurs.
-- 						void OnRefresh(handle table)
-- Runs when the modifier is refreshed.
-- 						void OnRemoved()
-- Runs when the modifier is destroyed (before unit loses modifier).
-- 						void OnStackCountChanged(int iStackCount)
-- Runs when stack count changes (param is old count).
-- 						bool RemoveOnDeath()
-- True/false if this modifier is removed when the parent dies.
-- 						bool ShouldUseOverheadOffset()
-- Apply the overhead offset to the attached effect.
-- 						int StatusEffectPriority()
-- Relationship of this status effect with those from other buffs (higher is more likely to be shown).
-- 				__self: userdata: 0x005d6c70
-- 				sKey: _68a6_OutgoingDamagePercent
-- 		m_path:
-- 				m_eCity:
-- 						__self: userdata: 0x00560298
-- 				m_entity:
-- 						__self: userdata: 0x0055cdd0
-- 				m_nID: 7
-- 				m_tabAtker:
-- 						1: table: 0x005cd868
-- 				m_tabEHero:
-- 						1: table: 0x005cd868
-- 				m_tabEJoin:
-- 						1: table: 0x005cd868
-- 				m_tabEMonster:
-- 						1: table: 0x005ef060
-- 				m_tabMonsterInfo:
-- 						1:
-- 								tabMonster:
-- 										npc_dota_neutral_fel_beast:
-- 												nCount: 2
-- 												tabPos:
-- 														1:
-- 																1: -100
-- 																2: 50
-- 																3: 0
-- 														2:
-- 																1: -100
-- 																2: -50
-- 																3: 0
-- 										npc_dota_neutral_ghost:
-- 												nCount: 1
-- 												nExp: 1
-- 												tabPos:
-- 														1:
-- 																1: 0
-- 																2: 0
-- 																3: 0
-- 								typeMonster: 1
-- 						2:
-- 								tabMonster:
-- 										npc_dota_neutral_kobold:
-- 												nCount: 3
-- 												tabPos:
-- 														1:
-- 																1: 0
-- 																2: 0
-- 																3: 0
-- 														2:
-- 																1: 0
-- 																2: -50
-- 																3: 0
-- 														3:
-- 																1: 0
-- 																2: 50
-- 																3: 0
-- 										npc_dota_neutral_kobold_taskmaster:
-- 												nCount: 1
-- 												nExp: 1
-- 												tabPos:
-- 														1:
-- 																1: -100
-- 																2: 0
-- 																3: 0
-- 										npc_dota_neutral_kobold_tunneler:
-- 												nCount: 1
-- 												tabPos:
-- 														1:
-- 																1: -100
-- 																2: 50
-- 																3: 0
-- 								typeMonster: 2
-- 						3:
-- 								tabMonster:
-- 										npc_dota_neutral_alpha_wolf:
-- 												nCount: 1
-- 												nExp: 1
-- 												tabPos:
-- 														1:
-- 																1: 0
-- 																2: 0
-- 																3: 0
-- 										npc_dota_neutral_giant_wolf:
-- 												nCount: 2
-- 												tabPos:
-- 														1:
-- 																1: -100
-- 																2: -50
-- 																3: 0
-- 														2:
-- 																1: -100
-- 																2: -50
-- 																3: 0
-- 								typeMonster: 1001
-- 						4:
-- 								tabMonster:
-- 										npc_dota_neutral_ogre_magi:
-- 												nCount: 1
-- 												nExp: 1
-- 												tabPos:
-- 														1:
-- 																1: 0
-- 																2: 0
-- 																3: 0
-- 										npc_dota_neutral_ogre_mauler:
-- 												nCount: 2
-- 												tabPos:
-- 														1:
-- 																1: -100
-- 																2: -50
-- 																3: 0
-- 														2:
-- 																1: -100
-- 																2: 50
-- 																3: 0
-- 								typeMonster: 1002
-- 						5:
-- 								tabMonster:
-- 										npc_dota_neutral_satyr_soulstealer:
-- 												nCount: 2
-- 												nExp: 1
-- 												tabPos:
-- 														1:
-- 																1: 0
-- 																2: -50
-- 																3: 0
-- 														2:
-- 																1: 0
-- 																2: 50
-- 																3: 0
-- 										npc_dota_neutral_satyr_trickster:
-- 												nCount: 2
-- 												tabPos:
-- 														1:
-- 																1: -100
-- 																2: -50
-- 																3: 0
-- 														2:
-- 																1: -100
-- 																2: 50
-- 																3: 0
-- 								typeMonster: 1003
-- 				m_tabPos:
-- 						1:
-- 								entity: table: 0x005cd868
-- 								vPos: Vector 000000000056B270 [-1065.385986 209.289917 416.000000]
-- 						2:
-- 								entity: table: 0x005cd868
-- 								vPos: Vector 000000000056B420 [-1065.385986 259.289917 416.000000]
-- 						3:
-- 								vPos: Vector 000000000056B5D0 [-1065.385986 159.289917 416.000000]
-- 						4:
-- 								vPos: Vector 000000000056B6F0 [-1215.385986 209.289917 416.000000]
-- 						5:
-- 								vPos: Vector 000000000056B8A0 [-1215.385986 259.289917 416.000000]
-- 						6:
-- 								vPos: Vector 000000000056BA50 [-1215.385986 159.289917 416.000000]
-- 				m_tabTrophy:
-- 						table: 0x005cd868:
-- 								nExp: 1
-- 								nGold: 157
-- 				m_typeMonsterCur: 2
-- 				m_typePath: 9
-- 				m_typeState: 0
-- 		outgoingDamagePercents:
-- 				0:
-- 				1:
-- 				2:
-- 						_68a6_OutgoingDamagePercent: 0
-- 		tModifierEvents:
-- 				157:
-- 						1:
-- 								BaseClass: table: 0x00135ab8
-- 								__self: userdata: 0x00a1b4d8