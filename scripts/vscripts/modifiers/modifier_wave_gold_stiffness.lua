if modifier_wave_gold_stiffness == nil then
	modifier_wave_gold_stiffness = class({})
end

local public = modifier_wave_gold_stiffness

function public:IsHidden()
	return false
end
function public:IsDebuff()
	return true
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
function public:GetTexture()
	return "alchemist_goblins_greed"
end
function public:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_lvl2.vpcf"
end
function public:StatusEffectPriority()
	return 100
end
function public:OnCreated(params)
	self.incoming_damage_pct = WAVE_GOLD_EXTRA_IMCOMING_DAMAGE_PCT
	if IsServer() then 
		local hCaster = self:GetParent()

		hCaster:StartGestureWithPlaybackRate(ACT_DOTA_IDLE_RARE, WAVE_GOLD_STUN_DURATION)

		local EffectName = "particles/econ/events/ti5/blink_dagger_end_lvl2_ti5.vpcf"
		-- local EffectName = "particles/units/heroes/hero_beastmaster/beastmaster_primal_roar.vpcf"
		local nIndexFX = ParticleManager:CreateParticle(EffectName, PATTACH_CUSTOMORIGIN_FOLLOW, hCaster)
		ParticleManager:SetParticleControlEnt(nIndexFX, 0, hCaster, PATTACH_CUSTOMORIGIN_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
		-- ParticleManager:SetParticleControlEnt(nIndexFX, 1, hCaster, PATTACH_CUSTOMORIGIN_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(nIndexFX) 
	end
end
function public:OnRefresh(params)
	self.incoming_damage_pct = WAVE_GOLD_EXTRA_IMCOMING_DAMAGE_PCT
	if IsServer() then 
		local hCaster = self:GetParent()

		hCaster:StartGestureWithPlaybackRate(ACT_DOTA_IDLE_RARE, WAVE_GOLD_STUN_DURATION)

		local EffectName = "particles/econ/events/ti5/blink_dagger_end_lvl2_ti5.vpcf"
		-- local EffectName = "particles/units/heroes/hero_beastmaster/beastmaster_primal_roar.vpcf"
		local nIndexFX = ParticleManager:CreateParticle(EffectName, PATTACH_CUSTOMORIGIN_FOLLOW, hCaster)
		ParticleManager:SetParticleControlEnt(nIndexFX, 0, hCaster, PATTACH_CUSTOMORIGIN_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
		-- ParticleManager:SetParticleControlEnt(nIndexFX, 1, hCaster, PATTACH_CUSTOMORIGIN_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(nIndexFX) 
	end
end
function public:OnDestroy()
	if IsServer() then
		local hCaster = self:GetParent()

		hCaster:FadeGesture(ACT_DOTA_IDLE_RARE)
	end
end
function public:OnIntervalThink()
end
function public:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end
function public:GetModifierIncomingDamage_Percentage(params)
	return self.incoming_damage_pct
end
function public:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end

