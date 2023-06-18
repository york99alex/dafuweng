if modifier_cooldown_reduction == nil then
	modifier_cooldown_reduction = class({})
end

local public = modifier_cooldown_reduction

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
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}
end
function public:GetModifierPercentageCooldown(params)
	return self:GetDuration()
end