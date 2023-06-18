require("Ability/LuaAbility")
----技能：龙破斩    兵卒：莉娜
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_BZ_lina_dragon_slave then
    LuaAbility_BZ_lina_dragon_slave = class({}, nil, LuaAbility)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_BZ_lina_dragon_slave:constructor()
    self.__base__.constructor(self)
    self:ai()
end

----施法距离
function LuaAbility_BZ_lina_dragon_slave:GetCastRange(vLocation, hTarget)
    return 0
end

----选择无目标时
function LuaAbility_BZ_lina_dragon_slave:CastFilterResult()
    if IsServer() then
        if IsValid(self:GetCaster().m_eAtkTarget) then
            self.m_eTarget = self:GetCaster().m_eAtkTarget
            local playerTarget = PlayerManager:getPlayer(self.m_eTarget:GetPlayerOwnerID())
            if playerTarget and 0 < bit.band(playerTarget.m_typeState, PS_AbilityImmune) then
                return UF_FAIL_CUSTOM  ----技能免疫
            end
            local tEvent = {
                ablt = self,
                bIgnore = true,
            }
            EventManager:fireEvent("Event_BZCastAblt", tEvent)
            if not tEvent.bIgnore then
                return UF_SUCCESS
            end
        end
    end
    self.m_strCastError = "LuaAbilityError_BZ"
    return UF_FAIL_CUSTOM
end

----开始技能效果
function LuaAbility_BZ_lina_dragon_slave:OnSpellStart()
    local eTarget = self.m_eTarget
    if not IsValid(eTarget) then
        return
    end
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if not oPlayer then
        return
    end
    local nCasterEntID = self:GetCaster():GetEntityIndex()
    local sAbltName = self:GetAbilityName()

    ----特效
    local nPtclID = AMHC:CreateParticle("particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf"
    , PATTACH_POINT, false, self:GetCaster(), 0.4)
    local v3 = (eTarget:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
    local nSpeed = self:GetSpecialValueFor("dragon_slave_speed")
    ParticleManager:SetParticleControl(nPtclID, 1, v3 * nSpeed)
    EmitGlobalSound("Hero_Lina.DragonSlave")

    ----消耗魔法
    -- self:GetCaster():SpendMana(self:GetManaCost(self:GetLevel() - 1), self)
    ----获取伤害数值
    local nDamage = self:GetSpecialValueFor("dragon_slave_damage")
    ----造成伤害
    AMHC:Damage(self:GetCaster(), eTarget, nDamage, self:GetAbilityDamageType(), self, 1, { bIgnoreBZHuiMo = true })
    ----设置CD
    -- if IsValid(self) then
    --     self:StartCooldown(self:GetCooldown(self:GetLevel() - 1))
    -- end
    ----触发放技能事件
    EventManager:fireEvent('dota_player_used_ability', {
        caster_entindex = nCasterEntID,
        abilityname = sAbltName,
    })
end

----是否计算冷却减缩
function LuaAbility_BZ_lina_dragon_slave:isCanCDSub()
    return false
end
----是否计算耗魔减缩
function LuaAbility_BZ_lina_dragon_slave:isCanManaSub()
    return false
end