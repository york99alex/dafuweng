require("Ability/LuaAbility")
----技能：雷击    兵卒：宙斯
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_BZ_zuus_lightning_bolt then
    LuaAbility_BZ_zuus_lightning_bolt = class({}, nil, LuaAbility)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_BZ_zuus_lightning_bolt:constructor()
    self.__base__.constructor(self)
    self:ai()
end

function LuaAbility_BZ_zuus_lightning_bolt:GetCastRange(vLocation, hTarget)
    return 0
end

----选择目标时
function LuaAbility_BZ_zuus_lightning_bolt:CastFilterResult()
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
function LuaAbility_BZ_zuus_lightning_bolt:OnSpellStart()
    local eTarget = self.m_eTarget
    if not IsValid(eTarget) then
        return
    end
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if not oPlayer then
        return
    end

    local nDamage = self:GetSpecialValueFor("damage")
    local nCasterEntID = self:GetCaster():GetEntityIndex()
    local sAbltName = self:GetAbilityName()

    ----释放闪电
    local nPtclID = AMHC:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf"
    , PATTACH_POINT, false, eTarget, 2)
    ParticleManager:SetParticleControl(nPtclID, 0, eTarget:GetAbsOrigin() + Vector(0, 0, 2000))
    ParticleManager:SetParticleControl(nPtclID, 1, eTarget:GetAbsOrigin())
    nPtclID = AMHC:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_lb_cfx_il.vpcf"
    , PATTACH_POINT, false, eTarget, 2)
    EmitGlobalSound("Hero_Zuus.LightningBolt")

    ----消耗魔法
    -- self:GetCaster():SpendMana(self:GetManaCost(self:GetLevel() - 1), self)
    ----对玩家造成伤害
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
function LuaAbility_BZ_zuus_lightning_bolt:isCanCDSub()
    return false
end
----是否计算耗魔减缩
function LuaAbility_BZ_zuus_lightning_bolt:isCanManaSub()
    return false
end