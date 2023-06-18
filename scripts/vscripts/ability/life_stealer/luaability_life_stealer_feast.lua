require("Ability/LuaAbility")
----技能：盛宴    英雄：小狗
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_life_stealer_feast then
    LuaAbility_life_stealer_feast = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_life_stealer_feast_biggeneral", "Ability/life_stealer/LuaAbility_life_stealer_feast.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_life_stealer_feast_biggeneral_attack_buff", "Ability/life_stealer/LuaAbility_life_stealer_feast.lua", LUA_MODIFIER_MOTION_NONE)
end 
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_life_stealer_feast:constructor()
    LuaAbility_life_stealer_feast.__base__.constructor(self)
end
function LuaAbility_life_stealer_feast:GetIntrinsicModifierName()
    return "modifier_life_stealer_feast_biggeneral"
end
--modifier
----------------------------
if modifier_life_stealer_feast_biggeneral==nil then
	modifier_life_stealer_feast_biggeneral=class({})
end
function modifier_life_stealer_feast_biggeneral:IsHidden()
	return true
end
function modifier_life_stealer_feast_biggeneral:IsDebuff()
	return false
end
function modifier_life_stealer_feast_biggeneral:IsPurgable()
	return false
end
function modifier_life_stealer_feast_biggeneral:IsPurgeException()
	return false
end
function modifier_life_stealer_feast_biggeneral:AllowIllusionDuplicate()
	return false
end
function modifier_life_stealer_feast_biggeneral:OnCreated(params)
	self.hp_leech_percent=self:GetAbility():GetSpecialValueFor("hp_leech_percent") 
end
function modifier_life_stealer_feast_biggeneral:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACK_LANDED, 
    }
end
function modifier_life_stealer_feast_biggeneral:OnAttackLanded(params)
	if IsValid(params.target) and params.attacker==self:GetParent() then
		self.iTargetMaxHp=params.target:GetMaxHealth()
		self.iBonusDamage=self.iTargetMaxHp*self.hp_leech_percent*0.01
		self:GetParent():Heal(self.iBonusDamage, self:GetAbility()) 
		print("self.iBonusDamage:",self.iBonusDamage)
		SendOverheadEventMessage(self:GetParent(), OVERHEAD_ALERT_HEAL, self:GetParent(), self.iBonusDamage, self:GetParent())
		if self:GetParent():HasModifier("modifier_life_stealer_feast_biggeneral_attack_buff") then
			local hAttackModifier = self:GetParent():FindModifierByName("modifier_life_stealer_feast_biggeneral_attack_buff")
			hAttackModifier:Destroy()
			return
		else
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_life_stealer_feast_biggeneral_attack_buff", {duration=1})
		end
	end
end
----------------------------------------- 
if modifier_life_stealer_feast_biggeneral_attack_buff==nil then
	modifier_life_stealer_feast_biggeneral_attack_buff=class({})
end
function modifier_life_stealer_feast_biggeneral_attack_buff:IsHidden()
	return false
end
function modifier_life_stealer_feast_biggeneral_attack_buff:IsDebuff()
	return false
end
function modifier_life_stealer_feast_biggeneral_attack_buff:IsPurgable()
	return false
end
function modifier_life_stealer_feast_biggeneral_attack_buff:IsPurgeException()
	return false
end
function modifier_life_stealer_feast_biggeneral_attack_buff:AllowIllusionDuplicate()
	return false
end
function modifier_life_stealer_feast_biggeneral_attack_buff:OnCreated(params) 
end
function modifier_life_stealer_feast_biggeneral_attack_buff:OnRefresh(params) 
end
function modifier_life_stealer_feast_biggeneral_attack_buff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, 
    }
end
function modifier_life_stealer_feast_biggeneral_attack_buff:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		return 1000
	end
end