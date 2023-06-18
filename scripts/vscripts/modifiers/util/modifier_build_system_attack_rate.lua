if modifier_build_system_attack_rate == nil then
    modifier_build_system_attack_rate = class({})
end

local public = modifier_build_system_attack_rate

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
    local info = CustomNetTables:GetTableValue("buildings", tostring(self:GetParent():entindex()))
    if info.tUpgrades[tostring(info.iLevel-1)] ~= nil and info.tUpgrades[tostring(info.iLevel-1)].AttackRate ~= nil then
        self.attack_rate = info.tUpgrades[tostring(info.iLevel-1)].AttackRate
    end
end
function public:OnRefresh(params)
    local info = CustomNetTables:GetTableValue("buildings", tostring(self:GetParent():entindex()))
    if info.tUpgrades[tostring(info.iLevel-1)] ~= nil and info.tUpgrades[tostring(info.iLevel-1)].AttackRate ~= nil then
        self.attack_rate = info.tUpgrades[tostring(info.iLevel-1)].AttackRate
    end
end
function public:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}
end
function public:GetModifierBaseAttackTimeConstant(params)
	return self.attack_rate
end