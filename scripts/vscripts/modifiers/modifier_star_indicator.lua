if modifier_star_indicator == nil then
	modifier_star_indicator = class({})
end

local public = modifier_star_indicator

function public:IsHidden()
	return false
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
function public:GetTexture()
	return "modifier_star_indicator"
end
function public:OnCreated(params)
	if IsServer() then
		self:IncrementStackCount()
	end
end
function public:OnRefresh(params)
	if IsServer() then
		self:IncrementStackCount()
	end
end