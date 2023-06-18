if modifier_base_agility == nil then
	modifier_base_agility = class({})
end

local public = modifier_base_agility

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