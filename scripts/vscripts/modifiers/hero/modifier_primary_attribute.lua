if modifier_primary_attribute == nil then
	modifier_primary_attribute = class({})
end

local public = modifier_primary_attribute

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