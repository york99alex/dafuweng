if modifier_no_health_bar == nil then
    modifier_no_health_bar = class({})
end

local public = modifier_no_health_bar

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
function public:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT+MODIFIER_ATTRIBUTE_MULTIPLE+MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end