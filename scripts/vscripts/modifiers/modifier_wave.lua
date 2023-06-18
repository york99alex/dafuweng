if modifier_wave == nil then
    modifier_wave = class({})
end

local public = modifier_wave

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
function public:GetEffectName()
	return "maps/reef_assets/particles/reef_effects_creep.vpcf"
end
function public:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function public:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
end