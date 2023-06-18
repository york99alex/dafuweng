require("Ability/LuaAbility")
--技能撕裂伤口，小狗
LinkLuaModifier("modifier_life_stealer_open_wounds_biggeneral", "Ability/life_stealer/LuaAbility_life_stealer_open_wounds.lua", LUA_MODIFIER_MOTION_NONE)
if LuaAbility_life_stealer_open_wounds==nil then
	LuaAbility_life_stealer_open_wounds=class({}, nil, LuaAbility)
end 
function LuaAbility_life_stealer_open_wounds:constructor()
    LuaAbility_life_stealer_open_wounds.__base__.constructor(self)
end
function LuaAbility_life_stealer_open_wounds:OnSpellStart()
	local hCaster=self:GetCaster()
	local oPlayer=PlayerManager:getPlayer(hCaster:GetPlayerOwnerID())
	local hTarget=self:GetCursorTarget()
	hTarget:EmitSound("Hero_LifeStealer.OpenWounds.Cast")
	hTarget:AddNewModifier(hCaster, self, "modifier_life_stealer_open_wounds_biggeneral", nil)
	----触发耗蓝
	EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = self })
	----设置冷却
	AbilityManager:setRoundCD(oPlayer, self)
end
function LuaAbility_life_stealer_open_wounds:CastFilterResultTarget(hTarget)
	if not self:isCanCast(hTarget) then
		return UF_FAIL_CUSTOM
	end 
	if hTarget:GetPlayerOwnerID()==self:GetCaster():GetPlayerOwnerID() then
		self.m_strCastError = "LuaAbilityError_SelfCant"
        return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end
---modifier 
if modifier_life_stealer_open_wounds_biggeneral==nil then
	modifier_life_stealer_open_wounds_biggeneral=class({})
end
function modifier_life_stealer_open_wounds_biggeneral:IsHidden()
	return false
end
function modifier_life_stealer_open_wounds_biggeneral:IsDebuff()
	return true
end
function modifier_life_stealer_open_wounds_biggeneral:IsPurgable()
	return true
end
function modifier_life_stealer_open_wounds_biggeneral:IsPurgeException()
	return true
end
function modifier_life_stealer_open_wounds_biggeneral:AllowIllusionDuplicate()
	return false
end
function modifier_life_stealer_open_wounds_biggeneral:GetTexture()
	return "life_stealer_open_wounds"
end
function modifier_life_stealer_open_wounds_biggeneral:GetEffectName()
	return "particles/units/heroes/hero_life_stealer/life_stealer_open_wounds.vpcf"
end
function modifier_life_stealer_open_wounds_biggeneral:GetStatusEffectName()
	return "particles/status_fx/status_effect_life_stealer_open_wounds.vpcf"
end
function modifier_life_stealer_open_wounds_biggeneral:StatusEffectPriority()
	return 10
end
function modifier_life_stealer_open_wounds_biggeneral:OnCreated(params)
	self.slow_move_speed_pet=self:GetAbility():GetSpecialValueFor("slow_move_speed_pet")
	self.move_damage=self:GetAbility():GetSpecialValueFor("move_damage")
	self.duration=self:GetAbility():GetSpecialValueFor("duration")
	self.attack_speed_addition=0
	if IsServer() then
		--设置buff持续时间
		self.m_nRound=self.duration
		AbilityManager:judgeBuffRound(self:GetCaster():GetPlayerOwnerID(),self)
		 ----监听移动
		 EventManager:register("Event_Move", self.onEvent_Move, self)
	end
end
function modifier_life_stealer_open_wounds_biggeneral:onEvent_Move(tEvent)
	if tEvent.entity ~= self:GetParent() then
        return
	end
	local player = PlayerManager:getPlayer(tEvent.entity:GetPlayerOwnerID())
    local tEventID = {}
	table.insert(tEventID, EventManager:register("Event_CurPathChange", function(tEvent2)
        if tEvent2.player == player then
            local nDamage = self.move_damage
            AMHC:Damage(self:GetCaster(), self:GetParent(), nDamage, DAMAGE_TYPE_MAGICAL, self:GetAbility())
            return
        end
    end))
    table.insert(tEventID, EventManager:register("Event_MoveEnd", function(tEvent2)
        if tEvent2.entity == tEvent.entity then
            EventManager:unregisterByIDs(tEventID)
            return
        end
    end))
end
function modifier_life_stealer_open_wounds_biggeneral:OnRefresh(params)
	self.slow_move_speed_pet=self:GetAbility():GetSpecialValueFor("slow_move_speed_pet")
	self.move_damage=self:GetAbility():GetSpecialValueFor("move_damage")
	self.duration=self:GetAbility():GetSpecialValueFor("duration")
end
function modifier_life_stealer_open_wounds_biggeneral:OnDestroy()
	if IsServer() then
		EventManager:unregister("Event_Move", self.onEvent_Move, self)
	end
end
function modifier_life_stealer_open_wounds_biggeneral:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_life_stealer_open_wounds_biggeneral:GetModifierMoveSpeedBonus_Percentage()
	return self.slow_move_speed_pet
end
function modifier_life_stealer_open_wounds_biggeneral:OnAttackLanded(params)
	if IsValid(params.target) and params.attacker==self:GetCaster() then
		if self:GetCaster():HasModifier("modifier_life_stealer_open_wounds_biggeneral_attack") then
			local hAttackModifier = self:GetCaster():FindModifierByName("modifier_life_stealer_open_wounds_biggeneral_attack")
			hAttackModifier:Destroy()
			return
		else
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_life_stealer_open_wounds_biggeneral_attack", {duration=1})
		end 
	end
end 
---------------------------------------------
if nil==modifier_life_stealer_open_wounds_biggeneral_attack then
	modifier_life_stealer_open_wounds_biggeneral_attack=class({})
end
function modifier_life_stealer_open_wounds_biggeneral_attack:IsHidden()
	return false
end
function modifier_life_stealer_open_wounds_biggeneral_attack:IsDebuff()
	return false
end
function modifier_life_stealer_open_wounds_biggeneral_attack:IsPurgable()
	return false
end
function modifier_life_stealer_open_wounds_biggeneral_attack:IsPurgeException()
	return false
end
function modifier_life_stealer_open_wounds_biggeneral_attack:IsStunDebuff()
	return false
end
function modifier_life_stealer_open_wounds_biggeneral_attack:AllowIllusionDuplicate()
	return false
end
function modifier_life_stealer_open_wounds_biggeneral_attack:OnCreated(params)
end
function modifier_life_stealer_open_wounds_biggeneral_attack:OnDestroy()
end
function modifier_life_stealer_open_wounds_biggeneral_attack:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_life_stealer_open_wounds_biggeneral_attack:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		return 1000
	end
end
