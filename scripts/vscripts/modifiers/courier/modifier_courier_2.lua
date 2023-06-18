if modifier_courier_2 == nil then
	modifier_courier_2 = class({})
end

local public = modifier_courier_2

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
function public:OnCreated(params)
	if IsServer() then
		self:GetParent():GameTimer(0, function()
			local iParticleID = ParticleManager:CreateParticle("particles/econ/courier/courier_cluckles/courier_cluckles_ambient_flying.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(iParticleID, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_rocket_l", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(iParticleID, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_rocket_r", self:GetParent():GetAbsOrigin(), true)
			self:AddParticle(iParticleID, true, false, -1, false, false)
		end)
	end
end
function public:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
	}
end
function public:GetModifierModelChange(params)
	return "models/items/courier/mighty_chicken/mighty_chicken_flying.vmdl"
end
function public:GetModifierModelScale(params)
	return 0
end
function public:GetVisualZDelta(params)
	return 250
end