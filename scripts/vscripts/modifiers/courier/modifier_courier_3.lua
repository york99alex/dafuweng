if modifier_courier_3 == nil then
	modifier_courier_3 = class({})
end

local public = modifier_courier_3

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
			self:GetParent():SetSkin(1)
			local iParticleID = ParticleManager:CreateParticle("particles/imagine_assets/courier_fx/courier_3.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(iParticleID, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_back", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(iParticleID, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eye_l", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(iParticleID, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eye_r", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(iParticleID, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
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
	return "models/courier/beetlejaws/mesh/beetlejaws.vmdl"
end
function public:GetModifierModelScale(params)
	return -20
end
function public:GetVisualZDelta(params)
	return 0
end