require("Ability/LuaAbility")
require("Ability/pudge/LuaAbility_pudge_rot")
----技能：腐烂    兵卒：屠夫帕吉
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
LuaAbility_BZ_pudge_rot = class({
    m_bDamageCheck = nil
    , m_nPctlID = nil
    , m_nRange = nil
    , m_nDamage = nil
    , m_nTime = nil
}, nil, LuaAbility)
-- LinkLuaModifier("modifier_LuaAbility_BZ_pudge_rot_aura", "Ability/pudge/LuaAbility_pudge_rot.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_LuaAbility_BZ_pudge_rot_debuff", "Ability/pudge/LuaAbility_BZ_pudge_rot.lua", LUA_MODIFIER_MOTION_NONE)
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_BZ_pudge_rot:constructor()
    self.__base__.constructor(self)
    self:ai()
    self.Caster = self:GetCaster()

    self.m_nRange = self:GetSpecialValueFor("range")
    self.m_nDamage = self:GetSpecialValueFor("damage")
    self.m_nTime = self:GetSpecialValueFor("time_damage")
end

----施法距离
function LuaAbility_BZ_pudge_rot:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("range")
end

----选择无目标时
function LuaAbility_BZ_pudge_rot:CastFilterResult()
    if IsServer() then
        if self.m_bDamageCheck then
            ----已经开启
            return UF_FAIL_CUSTOM
        end

        if IsValid(self:GetCaster().m_eAtkTarget) then
            self.m_eTarget = self:GetCaster().m_eAtkTarget
            local playerTarget = PlayerManager:getPlayer(self.m_eTarget:GetPlayerOwnerID())
            if playerTarget and 0 < bit.band(playerTarget.m_typeState, PS_AbilityImmune) then
                return UF_FAIL_CUSTOM ----技能免疫
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
function LuaAbility_BZ_pudge_rot:OnSpellStart()
    for _, v in pairs(self:GetCaster().m_tabAtker) do
        if self:checkTarget(v) then
            local nDis = (v:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length()
            if nDis <= self.m_nRange then
                ----开启腐烂
                self:swithPctl(true)
                ----开伤害检测
                self:swithDamageCheck(true)
                ----耗尽能量
                -- self:GetCaster():SetMana(0)
                break
            end
        end
    end

    ----触发放技能事件
    local nCasterEntID = self:GetCaster():GetEntityIndex()
    local sAbltName = self:GetAbilityName()
    EventManager:fireEvent('dota_player_used_ability', {
        caster_entindex = nCasterEntID,
        abilityname = sAbltName,
    })
end

----开关腐烂特效
function LuaAbility_BZ_pudge_rot:swithPctl(bOn)
    if bOn then
        ----开启
        if nil == self.m_nPctlID then
            ---- EmitSoundOn("Hero_Pudge.Rot", self.Caster)
            -- self.Caster:StartGesture(ACT_DOTA_CAST2_STATUE)
            self.m_nPctlID = AMHC:CreateParticle("particles/units/heroes/hero_pudge/pudge_rot.vpcf"
            , PATTACH_POINT_FOLLOW, false, self.Caster)
            ParticleManager:SetParticleControl(self.m_nPctlID, 1, Vector(self.m_nRange, 0, 0))
        end
    elseif nil ~= self.m_nPctlID then
        ----关闭
        ---- StopSoundEvent("Hero_Pudge.Rot", self.Caster)
        ParticleManager:DestroyParticle(self.m_nPctlID, false)
        self.m_nPctlID = nil
    end
end

----开关伤害检测
function LuaAbility_BZ_pudge_rot:swithDamageCheck(bOn)
    if bOn then
        ----开启
        self.m_bDamageCheck = true
        local tabDamageCD = {}
        Timers:CreateTimer(function()
            if not self.m_bDamageCheck then
                return
            end
            if not self:IsNull() and not self:GetCaster():IsNull() then
                for _, v in pairs(self:GetCaster().m_tabAtker) do
                    if not tabDamageCD[v:GetEntityIndex()] then
                        local nDis = (v:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length()
                        if nDis <= self.m_nRange then
                            ----造成伤害
                            AMHC:Damage(self:GetCaster(), v, self.m_nDamage, self:GetAbilityDamageType(), self, 1, { bIgnoreBZHuiMo = true })
                            v:AddNewModifier(self:GetCaster(), self, 'modifier_LuaAbility_BZ_pudge_rot_debuff', { duration = self.m_nTime })
                            tabDamageCD[v:GetEntityIndex()] = true
                            Timers:CreateTimer(self.m_nTime, function()
                                tabDamageCD[v:GetEntityIndex()] = nil
                            end)
                        end
                    end
                end
            else
                self:swithPctl(false)
                return
            end
            if 0 == getSize(tabDamageCD) then
                ----关闭
                self:swithPctl(false)
                self.m_bDamageCheck = nil
            else
                return 0.1
            end
        end)
    else
        self.m_bDamageCheck = nil
    end
end

----是否计算冷却减缩
function LuaAbility_BZ_pudge_rot:isCanCDSub()
    return false
end
----是否计算耗魔减缩
function LuaAbility_BZ_pudge_rot:isCanManaSub()
    return false
end

---------------------------------------------------------------------
--Modifiers
if modifier_LuaAbility_BZ_pudge_rot_debuff == nil then
    modifier_LuaAbility_BZ_pudge_rot_debuff = class({})
end
function modifier_LuaAbility_BZ_pudge_rot_debuff:IsDebuff()
    return true
end
function modifier_LuaAbility_BZ_pudge_rot_debuff:IsPurgable()
    return false
end
function modifier_LuaAbility_BZ_pudge_rot_debuff:OnCreated()
    self.rot_slow = self:GetAbility():GetSpecialValueFor("rot_slow")
end
function modifier_LuaAbility_BZ_pudge_rot_debuff:OnRefresh()
    self.rot_slow = self:GetAbility():GetSpecialValueFor("rot_slow")
end
function modifier_LuaAbility_BZ_pudge_rot_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end
function modifier_LuaAbility_BZ_pudge_rot_debuff:GetModifierMoveSpeedBonus_Percentage(params)
    return self.rot_slow
end