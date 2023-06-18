if modifier_ambient_monkey_king_attack_speed == nil then
    modifier_ambient_monkey_king_attack_speed = class({})
end

local public = modifier_ambient_monkey_king_attack_speed

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
function public:OnCreated(params)
    local fValue = self:GetParent():GetAttackSpeed()*100
	if fValue >= 170 and fValue < 275 then
		self.sActivity = "fast"
	elseif fValue >= 275 and fValue < 350 then
		self.sActivity = "faster"
	elseif fValue >= 350 then
		self.sActivity = "fastest"
	end
end
function public:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}
end
function public:GetActivityTranslationModifiers(params)
	return self.sActivity
end