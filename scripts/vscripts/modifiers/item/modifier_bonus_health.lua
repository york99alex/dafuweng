if modifier_bonus_health == nil then
	modifier_bonus_health = class({})
end

local public = modifier_bonus_health

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
	return "modifier_bonus_health"
end
function public:OnCreated(params)
	if IsServer() then
		if params.bonus_health ~= nil then
			self:SetStackCount(self:GetStackCount()+params.bonus_health)
		end
	end
end
function public:OnRefresh(params)
	if IsServer() then
		if params.bonus_health ~= nil then
			self:SetStackCount(self:GetStackCount()+params.bonus_health)
		end
	end
end
function public:OnRemoved()
	if IsServer() then
		local hParent = self:GetParent()
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(-self:GetStackCount())
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
			hParent:ModifyMaxHealth(iNewStackCount-iOldStackCount)
		end
	end
end
function public:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
end
function public:GetModifierHealthBonus(params)
	return self:GetStackCount()
end