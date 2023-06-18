if modifier_wave_gold == nil then
	modifier_wave_gold = class({})
end

local public = modifier_wave_gold

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
function public:RemoveOnDeath()
	return false
end
function public:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
function public:GetTexture()
	return "alchemist_goblins_greed"
end
function public:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold.vpcf"
end
function public:StatusEffectPriority()
	return 99
end
function public:OnCreated(params)
	self.moveSpeed = self:GetParent():GetBaseMoveSpeed()
	if IsServer() then
		local hCaster = self:GetParent() 
		local iHealth = WAVE_GOLD_HEALTH_TABLE[math.max(math.ceil(Spawner:GetActualRound()/5),1)]
		hCaster:SetMaxHealth(iHealth) 
		hCaster:SetHealth(iHealth) 
		self:SetDuration(20, true)
		self:StartIntervalThink(20)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function public:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function public:OnIntervalThink()
	if IsServer() then
		self:GetParent():ForceKill(false)
		self:StartIntervalThink(-1)
		self:Destroy()
	end
end
function public:CheckState()
	return {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = false,
	}
end
function public:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
end
function public:GetModifierModelScale(params)
	local hCaster = self:GetCaster()
	local return_value
	if WAVE_GOLD_LIMIT_SCALE > 1 then 
		return_value = 1*(math.min(hCaster:GetMaxHealth()/hCaster:GetHealth(), WAVE_GOLD_LIMIT_SCALE))*100 - 100
	else
		return_value = 1*(math.max(hCaster:GetHealth()/hCaster:GetMaxHealth(), WAVE_GOLD_LIMIT_SCALE))*100 - 100
	end
	return return_value
end
function public:GetMinHealth(params)
	return 1
end
function public:GetModifierMoveSpeed_AbsoluteMin(params)
	return self.moveSpeed
end
function public:OnTakeDamage( params )
	local hCaster = params.unit
	if hCaster ~= self:GetParent() then return end
	if IsServer() then 
		-- hCaster:SetModelScale(2.3*(math.max(hCaster:GetHealth()/hCaster:GetMaxHealth(),WAVE_GOLD_LIMIT_SCALE))) 
		if hCaster:GetHealth() < params.damage then 
		-- if hCaster:GetHealth() < 2  then 
			local iMaxHealth = hCaster:GetMaxHealth() * (1+WAVE_GOLD_HEALTH_BONUS_FACTOR)
			hCaster:SetMaxHealth(iMaxHealth)
			hCaster:SetHealth(iMaxHealth)

			hCaster:AddNewModifier(hCaster, nil, "modifier_wave_gold_stiffness", {duration = WAVE_GOLD_STUN_DURATION})
			-- hCaster:AddNewModifier(hCaster, nil, "modifier_stunned", {duration = WAVE_GOLD_STUN_DURATION})
		end 
	end
end