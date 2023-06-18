if modifier_bonus_mana == nil then
	modifier_bonus_mana = class({})
end

local public = modifier_bonus_mana

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
function public:GetTexture()
	return "modifier_bonus_mana"
end
function public:OnCreated(params)
	if IsServer() then
		if params.bonus_mana ~= nil then
			self:SetStackCount(self:GetStackCount()+params.bonus_mana)
		end
	end
end
function public:OnRefresh(params)
	if IsServer() then
		if params.bonus_mana ~= nil then
			self:SetStackCount(self:GetStackCount()+params.bonus_mana)
		end
	end
end
function public:OnRemoved()
	if IsServer() then
		local hParent = self:GetParent()
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(-self:GetStackCount())
		end
	end
end
function public:OnStackCountChanged(iOldStackCount)
	if IsServer() then
		local hParent = self:GetParent()
		local iNewStackCount = self:GetStackCount()
		if hParent.CalculateStatBonus then
			hParent:CalculateStatBonus()
		end
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(iNewStackCount-iOldStackCount)
		end
	end
end
function public:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end
function public:GetModifierManaBonus(params)
    return self:GetStackCount()
end