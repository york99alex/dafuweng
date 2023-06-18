if modifier_bounty_hunter_track_bounty == nil then
    modifier_bounty_hunter_track_bounty = class({})
end

local public = modifier_bounty_hunter_track_bounty

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
function public:GetTexture()
	return "alchemist_goblins_greed"
end
function public:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function public:OnTooltip(params)
	return self:GetStackCount()
end