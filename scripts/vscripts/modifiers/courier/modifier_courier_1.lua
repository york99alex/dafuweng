if modifier_courier_1 == nil then
	modifier_courier_1 = class({})
end

local public = modifier_courier_1

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
			local iParticleID = ParticleManager:CreateParticle("particles/econ/courier/courier_cluckles/courier_cluckles_ambient.vpcf", PATTACH_ROOTBONE_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControl(iParticleID, 1, Vector(1, 0, 0))
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
	return "models/items/courier/mighty_chicken/mighty_chicken.vmdl"
end
function public:GetModifierModelScale(params)
	return 0
end
function public:GetVisualZDelta(params)
	return 0
end