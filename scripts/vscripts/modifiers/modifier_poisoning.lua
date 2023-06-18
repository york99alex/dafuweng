if modifier_poisoning == nil then
    modifier_poisoning = class({})
end

local public = modifier_poisoning

function public:IsHidden()
	return false
end
function public:IsDebuff()
	return true
end
function public:IsPurgable()
	return true
end
function public:IsPurgeException()
	return true
end
function public:AllowIllusionDuplicate()
	return false
end
function public:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function public:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf"
end
function public:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function public:OnCreated(params)
	local hParent = self:GetParent()
	self.fTickInterval = 1.0
	if IsServer() then
		self.iDamageType = DAMAGE_TYPE_MAGICAL

		self.fDPS = params.fDPS or 0

		local fInterval = params.fInterval or self.fTickInterval
		self.fTime = GameRules:GetGameTime() + fInterval
		self:StartIntervalThink(fInterval)

		self:SetStackCount(self.fDPS)
	end
end
function public:OnRefresh(params)
	local hParent = self:GetParent()
	if IsServer() then
		self.fDPS = self.fDPS + (params.fDPS or 0)

		self:SetStackCount(self.fDPS)
	end
end
function public:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster()

		if not IsValid(hCaster) then
			self:Destroy()
			return
		end

		self.fTime = GameRules:GetGameTime() + self.fTickInterval
		self:StartIntervalThink(self.fTickInterval)

		local hParent = self:GetParent()
		local hAbility = self:GetAbility()
		local fDamage = self.fDPS * self.fTickInterval

		local tDamageTable = {
			ability = hAbility,
			victim = hParent,
			attacker = hCaster,
			damage = fDamage,
			damage_type = self.iDamageType,
		}
		ApplyDamage(tDamageTable)

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, hParent, fDamage, hCaster)
	end
end