if modifier_elite_4 == nil then
	modifier_elite_4 = class({})
end

local public = modifier_elite_4

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

	if IsServer() then
		self:GetParent():ModifyMaxHealth(self:GetParent():GetMaxHealth()*self.health_percentage*0.01)
	end
end
function public:CheckState()
	return {
	}
end
function public:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
end
function public:GetModifierModelScale(params)
	return self.model_scale
end