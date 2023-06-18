if modifier_builder == nil then
	modifier_builder = class({})
end

local public = modifier_builder

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
	return true
end
function public:DestroyOnExpire()
	return false
end
function public:IsPermanent()
	return true
end
function public:OnCreated(params)
	local hParent = self:GetParent()
	if IsServer() then
		local vColor = DOTA_PlayerColorVector[hParent:GetPlayerOwnerID()+1]
		local iParticleID = ParticleManager:CreateParticle("particles/player_color.vpcf", PATTACH_ABSORIGIN_FOLLOW, hParent)
		ParticleManager:SetParticleControl(iParticleID, 1, vColor)
		self:AddParticle(iParticleID, false, false, -1, false, false)
	end
end
function public:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
end
function public:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
	}
end
function public:GetVisualZDelta(params)
	return 0
end