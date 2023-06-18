if modifier_elite_2 == nil then
	modifier_elite_2 = class({})
end

local public = modifier_elite_2

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
function public:OnCreated(params)
	self.model_scale = WAVE_ELITE_MODIFIERS_SPECIALVALUES[self:GetName()].model_scale
	self.health_percentage = WAVE_ELITE_MODIFIERS_SPECIALVALUES[self:GetName()].health_percentage
	self.magical_resistance = WAVE_ELITE_MODIFIERS_SPECIALVALUES[self:GetName()].magical_resistance

	if IsServer() then
		self:GetParent():ModifyMaxHealth(self:GetParent():GetMaxHealth()*self.health_percentage*0.01)

		local unit = self:GetParent()
		local particleID = ParticleManager:CreateParticle("particles/items_fx/black_king_bar_avatar.vpcf", PATTACH_CUSTOMORIGIN, unit)
		ParticleManager:SetParticleControlEnt(particleID, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)
	end
end
function public:CheckState()
	return {
	}
end
function public:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end
function public:GetModifierModelScale(params)
	return self.model_scale
end
function public:GetModifierMagicalResistanceBonus(params)
	return self.magical_resistance
end