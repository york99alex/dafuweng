require("Ability/LuaAbility")
LinkLuaModifier("modifier_life_stealer_rage_biggeneral", "Ability/life_stealer/LuaAbility_life_stealer_rage.lua", LUA_MODIFIER_MOTION_NONE)
----技能：狂暴    英雄：小狗
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_life_stealer_rage then
    LuaAbility_life_stealer_rage = class({}, nil, LuaAbility)
end 
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_life_stealer_rage:constructor()
    LuaAbility_life_stealer_rage.__base__.constructor(self)
end 
function LuaAbility_life_stealer_rage:OnSpellStart()
	local hCaster=self:GetCaster()
	hCaster:EmitSound("Hero_LifeStealer.Rage")
	-- hCaster:Purge(false, true, false, true, false)  
	hCaster:AddNewModifier(hCaster, self, "modifier_life_stealer_rage_biggeneral", nil)  
end 
---modifier 
if modifier_life_stealer_rage_biggeneral==nil then
	modifier_life_stealer_rage_biggeneral=class({})
end
function modifier_life_stealer_rage_biggeneral:IsHidden()
	return false
end
function modifier_life_stealer_rage_biggeneral:IsDebuff()
	return false
end
function modifier_life_stealer_rage_biggeneral:IsPurgable()
	return false
end
function modifier_life_stealer_rage_biggeneral:IsPurgeException()
	return false
end
function modifier_life_stealer_rage_biggeneral:AllowIllusionDuplicate()
	return false
end
function modifier_life_stealer_rage_biggeneral:OnCreated(params) 
	self.move_speed_pet=self:GetAbility():GetSpecialValueFor("move_speed_pet")
	self.ignore_ability_damage_pet=self:GetAbility():GetSpecialValueFor("ignore_ability_damage_pet")
	self.duration=self:GetAbility():GetSpecialValueFor("duration")
	self.state_resistance=self:GetAbility():GetSpecialValueFor("state_resistance")
	--设置buff持续时间
	if IsServer() then 
		self.m_nRound=self.duration 
		AbilityManager:judgeBuffRound(self:GetCaster():GetPlayerOwnerID(),self)
		local iParticleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/units/heroes/hero_life_stealer/life_stealer_rage.vpcf", self:GetParent()), PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(iParticleID, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(iParticleID, 1, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(iParticleID, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(iParticleID, false, false, -1, false, false)
	end
end
function modifier_life_stealer_rage_biggeneral:OnRefresh(params)  
	self:OnCreated(params)
end
function modifier_life_stealer_rage_biggeneral:OnDestroy()
	if IsServer() then 
	end
end
function modifier_life_stealer_rage_biggeneral:GetTexture()
	return "life_stealer_rage"
end
function modifier_life_stealer_rage_biggeneral:GetStatusEffectName()
	return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end
function modifier_life_stealer_rage_biggeneral:StatusEffectPriority()
	return 10
end
function modifier_life_stealer_rage_biggeneral:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
	}
end
function modifier_life_stealer_rage_biggeneral:GetModifierMoveSpeedBonus_Percentage()
	return self.move_speed_pet
end
function modifier_life_stealer_rage_biggeneral:GetModifierIncomingSpellDamageConstant()
	return -self.ignore_ability_damage_pet
end
function modifier_life_stealer_rage_biggeneral:GetModifierStatusResistanceStacking()
	return self.state_resistance
end
