if modifier_building == nil then
	modifier_building = class({})
end

local public = modifier_building

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
	return true
end
function public:GetEffectName()
	return "maps/reef_assets/particles/reef_effects_hero.vpcf"
end
function public:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function public:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
		self.casting = false
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ORDER, self, self:GetParent())
end
function public:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ORDER, self, self:GetParent())
end
function public:OnIntervalThink()
	if IsServer() then
		local unit = self:GetParent()
		if not unit:IsAttacking() and not unit:IsChanneling() and not self.casting and not self.moving_item then
			if unit:GetAttackCapability() ~= DOTA_UNIT_CAP_NO_ATTACK then
				ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
					Position = unit:GetAbsOrigin()
				})
			end
			self:StartIntervalThink(-1)
		end
	end
end
function public:CheckState()
	return {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
end
function public:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
	}
end
function public:OnOrder(params)
	if params.unit == self:GetParent() then
		if params.order_type ~= DOTA_UNIT_ORDER_ATTACK_MOVE then
			self:StartIntervalThink(AI_TIMER_TICK_TIME)
		end
		if params.ability ~= nil then
			self.casting = true

			params.unit:GameTimer(math.max(params.ability:GetCastPoint(), 0.1), function()
				self.casting = false
			end)
		end
	end
end
function public:GetModifierDisableTurning(params)
	return (self:GetParent():GetUnitLabel() == "turning_disable") and 1 or 0
end
function public:GetModifierIgnoreCastAngle(params)
	return (self:GetParent():GetUnitLabel() == "turning_disable") and 1 or 0
end