if modifier_elite_5 == nil then
	modifier_elite_5 = class({})
end

local public = modifier_elite_5

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
function public:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf"
end
function public:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function public:OnCreated(params)
	self.model_scale = 50
	self.health_percentage = 5
	self.status_resistance = 99

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
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
	}
end
function public:GetModifierModelScale(params)
	return self.model_scale
end
function public:GetModifierStatusResistanceStacking(params)
	return self.status_resistance
end