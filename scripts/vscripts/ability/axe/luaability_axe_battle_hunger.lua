require("Ability/LuaAbility")
----技能：战斗畏惧    英雄：斧王
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_axe_battle_hunger then
    LuaAbility_axe_battle_hunger = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_luaAbility_axe_battle_hunger", "Ability/axe/LuaAbility_axe_battle_hunger.lua", LUA_MODIFIER_MOTION_NONE)
    if PrecacheItems then
        table.insert(PrecacheItems, "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf")
    end
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_axe_battle_hunger:constructor()
    self.__base__.constructor(self)
end

function LuaAbility_axe_battle_hunger:GetCastRange(vLocation, hTarget)
    return 0
end

----选择目标时
function LuaAbility_axe_battle_hunger:CastFilterResultTarget(hTarget)
    if not self:isCanCast(hTarget) then
        return UF_FAIL_CUSTOM
    end

    ----不能是自己
    if hTarget:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID() then
        self.m_strCastError = "LuaAbilityError_SelfCant"
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end

----开始技能效果
function LuaAbility_axe_battle_hunger:OnSpellStart()
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    local eTarget = self:GetCursorTarget()
    local nDamage = self:GetSpecialValueFor("damage")
    local nDuration = self:GetSpecialValueFor("duration")

    ----添加减攻击buff
    AbilityManager:setCopyBuff('modifier_luaAbility_axe_battle_hunger'
    , eTarget, self:GetCaster(), self)
    ----监听兵卒升级
    -- if self:GetParent().m_bBZ then
    --     self.funUnregister = AbilityManager:updataBZBuffByLevel(self:GetParent(), function(eBZ)
    --         local oBuff2 = eTarget:AddNewModifier(self:GetCaster(), self, "modifier_luaAbility_axe_battle_hunger", {})
    --         if oBuff2 then
    --             oBuff2.m_nDuration = oBuff.m_nDuration
    --             oBuff = oBuff2
    --         end
    --     end)
    -- end
    EmitGlobalSound("Hero_Axe.Battle_Hunger")

    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = self })

    ----设置冷却
    AbilityManager:setRoundCD(oPlayer, self)
end

----默认buff
modifier_luaAbility_axe_battle_hunger = class({})
function modifier_luaAbility_axe_battle_hunger:IsDebuff()
    return true
end
function modifier_luaAbility_axe_battle_hunger:IsPurgable()
    return true
end
function modifier_luaAbility_axe_battle_hunger:GetTexture()
    return "axe_battle_hunger"
end
function modifier_luaAbility_axe_battle_hunger:GetEffectName()
    return "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf"
end
function modifier_luaAbility_axe_battle_hunger:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_luaAbility_axe_battle_hunger:DeclareFunctions()
    local funcs = {
        -- MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        -- MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }
    return funcs
end
function modifier_luaAbility_axe_battle_hunger:OnDestroy()
    if IsClient() then
        return
    end
    EventManager:fireEvent("modifier_luaAbility_axe_battle_hunger", self)
    EventManager:unregisterByIDs(self.m_tEventID)
end
function modifier_luaAbility_axe_battle_hunger:OnCreated(kv)
    self.m_nBonusAtk = self:GetAbility():GetSpecialValueFor("bonus_atk")
    self.m_nDamage = self:GetAbility():GetSpecialValueFor("damage")
    self.m_nDuration = self:GetAbility():GetSpecialValueFor("duration")

    if IsClient() then
        return
    end
    self.m_nAbilityDamageType = self:GetAbility():GetAbilityDamageType()
    self.m_nRound = self.m_nDuration
    AbilityManager:judgeBuffRound(self:GetCaster():GetPlayerOwnerID(), self)

    self.m_tEventID = {}
    ----检测目标玩家每轮开始
    table.insert(self.m_tEventID, EventManager:register("Event_PlayerRoundBegin", function(tabEvent)
        if self:IsNull() then
            return true
        end
        if self:GetParent():GetPlayerOwnerID() ~= tabEvent.oPlayer.m_nPlayerID then
            return
        end
        ----造成伤害
        AMHC:Damage(self:GetCaster(), self:GetParent(), self.m_nDamage, self.m_nAbilityDamageType, self:GetAbility())
        -- if 1 == self.m_nDuration then
        --     self:GetParent():RemoveModifierByNameAndCaster("modifier_luaAbility_axe_battle_hunger", self:GetCaster())
        --     return true
        -- end
        -- self.m_nDuration = self.m_nDuration - 1
    end))
end
-- function modifier_luaAbility_axe_battle_hunger:GetModifierBaseDamageOutgoing_Percentage()
--     return self.m_nBonusAtk
-- end
function modifier_luaAbility_axe_battle_hunger:GetModifierDamageOutgoing_Percentage()
    return self.m_nBonusAtk
end
function modifier_luaAbility_axe_battle_hunger:GetBonusDayVision()
    if IsClient() then
        return self.m_nDamage
    end
end
function modifier_luaAbility_axe_battle_hunger:GetBonusNightVision()
    if IsClient() then
        return self.m_nDuration
    end
end