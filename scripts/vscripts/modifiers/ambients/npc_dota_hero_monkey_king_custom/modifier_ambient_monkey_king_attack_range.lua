if modifier_ambient_monkey_king_attack_range == nil then
    modifier_ambient_monkey_king_attack_range = class({})
end

local public = modifier_ambient_monkey_king_attack_range

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
	if IsServer() then
		self:SetStackCount(params.fDistance or 0)
	end
end
function public:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}
end
function public:GetActivityTranslationModifiers(params)
	local fValue = self:GetStackCount()
	if fValue >= 0 and fValue < 300 then
		return "attack_normal_range"
	elseif fValue >= 300 then
		return "attack_long_range"
	end
end