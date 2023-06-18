if modifier_ambient_monkey_king == nil then
    modifier_ambient_monkey_king = class({})
end

local public = modifier_ambient_monkey_king

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
function public:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT+MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function public:OnCreated(params)
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
end
function public:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
end
function public:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_START,
	}
end
function public:OnAttackStart(params)
	if params.target == nil then return end

	if params.attacker == self:GetParent() then
		params.attacker:RemoveModifierByName("modifier_ambient_monkey_king_attack_range")
		params.attacker:RemoveModifierByName("modifier_ambient_monkey_king_attack_speed")

		params.attacker:AddNewModifier(params.attacker, nil, "modifier_ambient_monkey_king_attack_range", {fDistance=CalcDistanceBetweenEntityOBB(params.attacker, params.target)})
		params.attacker:AddNewModifier(params.attacker, nil, "modifier_ambient_monkey_king_attack_speed", nil)
	end
end