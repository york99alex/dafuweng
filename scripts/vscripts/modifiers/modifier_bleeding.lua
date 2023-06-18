if modifier_bleeding == nil then
    modifier_bleeding = class({})
end

local public = modifier_bleeding

function public:IsHidden()
	return false
end
function public:IsDebuff()
	return true
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
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function public:OnCreated(params)
	local hParent = self:GetParent()
	if IsServer() then
		self.iDamageType = params.iDamageType

		self.fTriggerDistance = params.fTriggerDistance or 100
		self.vLastPosition = params.vLastPosition ~= nil and StringToVector(params.vLastPosition) or hParent:GetAbsOrigin()
		self.fDistance = params.fDistance or 0

		local iParticleID = ParticleManager:CreateParticle("particles/bleeding_debuff.vpcf", PATTACH_CUSTOMORIGIN, hParent)
		ParticleManager:SetParticleControlEnt(iParticleID, 0, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", hParent:GetAbsOrigin(), true)
		self:AddParticle(iParticleID, false, false, -1, false, false)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_UNIT_MOVED, self)
end
function public:OnRefresh(params)
	local hParent = self:GetParent()
	if IsServer() then
		self.iDamageType = params.iDamageType
	end
end
function public:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_UNIT_MOVED, self)
end
function public:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_UNIT_MOVED,
	}
end
function public:OnUnitMoved(params)
	local hParent = self:GetParent()
	local hCaster = self:GetCaster()
	local hAbility = self:GetAbility()
	if hParent == params.unit then
		if not IsValid(hCaster) then
			self:Destroy()
			return
		end

		if self.funcDamgeCallback == nil then return end

		local vPosition = params.new_pos
		self.fDistance = self.fDistance + (vPosition-self.vLastPosition):Length2D()

		local fDamageFactor = math.floor(self.fDistance/self.fTriggerDistance)
		for i = 1, fDamageFactor, 1 do
			self.fDistance = self.fDistance - self.fTriggerDistance

			local fDamage = self.funcDamgeCallback(hParent) or 0

			local vColor = Vector(255, 32, 32)
			local fDuration = 1
			local iNumber = math.ceil(fDamage)
			local iParticleID = ParticleManager:CreateParticle("particles/msg_fx/msg_damage.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControlEnt(iParticleID, 0, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", hParent:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(iParticleID, 1, Vector(0, iNumber, 3))
			ParticleManager:SetParticleControl(iParticleID, 2, Vector(fDuration, #tostring(iNumber)+1, 0))
			ParticleManager:SetParticleControl(iParticleID, 3, vColor)
			ParticleManager:ReleaseParticleIndex(iParticleID)

			local tDamageTable = {
				ability = hAbility,
				victim = hParent,
				attacker = hCaster,
				damage = fDamage,
				damage_type = self.iDamageType,
			}
			ApplyDamage(tDamageTable)
		end

		self.vLastPosition = vPosition
	end
end