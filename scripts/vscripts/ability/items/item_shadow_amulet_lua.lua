require("Ability/LuaItem")
----物品技能：暗影护符
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
item_shadow_amulet_lua = class({
}, nil, LuaItem)
LinkLuaModifier("modifier_item_shadow_amulet_lua", "Ability/items/item_shadow_amulet_lua.lua", LUA_MODIFIER_MOTION_NONE)
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function item_shadow_amulet_lua:constructor()
    if self.__init then
        return
    end
    self.__base__.constructor(self)
end

----施法距离
function item_shadow_amulet_lua:GetCastRange(vLocation, hTarget)
    return 0
end
----魔法消耗
function item_shadow_amulet_lua:GetManaCost(nLevel)
    if self:GetCaster()
    and (self:GetCaster():IsHero()
    or self:GetCaster():GetMana() >= self:GetSpecialValueFor("mana_cost")) then
        return self:GetSpecialValueFor("mana_cost")
    end
    return 0
end

----选择目标时
function item_shadow_amulet_lua:CastFilterResultTarget(hTarget)
    if nil ~= GMManager then
        ----移动阶段不能施法
        if GS_Move == GMManager.m_typeState then
            self.m_strCastError = "LuaAbilityError_Move"
            return UF_FAIL_CUSTOM
        end
    end

    if nil ~= PlayerManager then
        local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
        if nil ~= oPlayer then
            ----英雄魔法不足
            if oPlayer.m_eHero:GetMana() < self:GetSpecialValueFor("mana_cost") then
                self.m_strCastError = "LuaAbilityError_NeedMana_Hero"
                return UF_FAIL_CUSTOM
            end

            ----在监狱不能施法
            if 0 < bit.band(PS_InPrison, oPlayer.m_typeState) then
                self.m_strCastError = "LuaAbilityError_Prison"
                return UF_FAIL_CUSTOM
            end

            ----不是己方英雄或者兵卒
            if hTarget:GetPlayerOwnerID() ~= oPlayer.m_nPlayerID then
                self.m_strCastError = "LuaAbilityError_TargetSelfHeroBZ"
                return UF_FAIL_CUSTOM
            end

            ----在目标攻击时不能施法
            if hTarget:IsHero() then
                if 0 < bit.band(PS_AtkHero, oPlayer.m_typeState) then
                    self.m_strCastError = "LuaAbilityError_Battle"
                    return UF_FAIL_CUSTOM
                end
            elseif hTarget.m_bBattle then
                self.m_strCastError = "LuaAbilityError_Battle"
                return UF_FAIL_CUSTOM
            end
        end
    end
    return UF_SUCCESS
end

----开始技能效果
function item_shadow_amulet_lua:OnSpellStart(a)
    ---- if nil == PlayerManager then
    ----     return
    ---- end
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if not oPlayer then
        return
    end

    local eTarget = self:GetCursorTarget()
    ----添加隐身
    eTarget:AddNewModifier(eTarget, self, "modifier_item_glimmer_cape_fade", {})
    ----兵卒升级后更新buff上去
    local function updataBuff(tabEvent)
        if tabEvent.eBZ == eTarget then
            eTarget = tabEvent.eBZNew
            eTarget:AddNewModifier(eTarget, self, "modifier_item_glimmer_cape_fade", {})
        end
    end
    EventManager:register("Event_BZLevel", updataBuff)

    ----监听打野移除隐身
    local function delBuff(tabEvent)
        if tabEvent.entity == eTarget then
            ----移除buff
            eTarget:RemoveModifierByName("modifier_item_glimmer_cape_fade")
            return true
        end
    end
    EventManager:register("Event_AtkMoster", delBuff)

    ----监听持续时间回合结束
    local nRound = self:GetSpecialValueFor("round")
    EventManager:register("Event_PlayerRoundBegin", function(tabEvent)
        if eTarget:IsNull() then
            EventManager:unregister("Event_BZLevel", updataBuff)
            EventManager:unregister("Event_AtkMoster", delBuff)
            return true
        end
        nRound = nRound - 1
        if 0 == nRound then
            ----移除buff
            EventManager:unregister("Event_BZLevel", updataBuff)
            EventManager:unregister("Event_AtkMoster", delBuff)
            eTarget:RemoveModifierByName("modifier_item_glimmer_cape_fade")
            return true
        end
    end)

    ----设置冷却
    AbilityManager:setRoundCD(oPlayer, self)

    if self:GetCaster():IsHero() then
        ----施法后转回原方向
        oPlayer.m_eHero:MoveToPosition(oPlayer.m_pathCur:getUsePos(oPlayer.m_eHero) + oPlayer.m_pathCur.m_entity:GetForwardVector():Normalized())
    else
        ----兵卒施法扣除英雄魔法
        oPlayer.m_eHero:SpendMana(self:GetSpecialValueFor("mana_cost"), self)
        self:GetCaster():GiveMana(self:GetManaCost(0))
    end
end

----默认buff
modifier_item_shadow_amulet_lua = class({})
function modifier_item_shadow_amulet_lua:IsHidden()
    return true
end
function modifier_item_shadow_amulet_lua:IsPurgable()
    return false
end
function modifier_item_shadow_amulet_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end
function modifier_item_shadow_amulet_lua:GetModifierAttackSpeedBonus_Constant()
    return 20
end
function modifier_item_shadow_amulet_lua:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end