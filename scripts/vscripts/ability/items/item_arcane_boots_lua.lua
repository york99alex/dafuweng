require("Ability/LuaItem")
----物品技能： 奥术鞋
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
item_arcane_boots_lua = class({
}, nil, LuaItem)
LinkLuaModifier("modifier_item_arcane_boots_lua", "Ability/items/item_arcane_boots_lua.lua", LUA_MODIFIER_MOTION_NONE)

----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function item_arcane_boots_lua:constructor()
    if self.__init then
        return
    end
    self.__base__.constructor(self)
end

----魔法消耗
function item_arcane_boots_lua:GetManaCost(nLevel)
    if self:GetCaster()
    and (self:GetCaster():IsHero()
    or self:GetCaster():GetMana() >= self:GetSpecialValueFor("mana_cost")) then
        return self:GetSpecialValueFor("mana_cost")
    end
    return 0
end

----选择无目标时
function item_arcane_boots_lua:CastFilterResult()
    if nil ~= GMManager then
        ----非自己阶段不能施法
        if self:GetCaster():GetPlayerOwnerID() ~= GMManager.m_nOrderID then
            self.m_strCastError = "LuaAbilityError_SelfRound"
            return UF_FAIL_CUSTOM
        end
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

            ----在目标攻击时不能施法
            if self:GetCaster():IsHero() then
                if 0 < bit.band(PS_AtkHero, oPlayer.m_typeState) then
                    self.m_strCastError = "LuaAbilityError_Battle"
                    return UF_FAIL_CUSTOM
                end
            elseif self:GetCaster().m_bBattle then
                self.m_strCastError = "LuaAbilityError_Battle"
                return UF_FAIL_CUSTOM
            end
        end
    end
    return UF_SUCCESS
end

----开始技能效果
function item_arcane_boots_lua:OnSpellStart()

    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if not oPlayer then
        return
    end

    ----特效
    nPrlt = AMHC:CreateParticle("particles/items_fx/arcane_boots.vpcf"
    , PATTACH_POINT, false, oPlayer.m_eHero, 2)

    ----恢复英雄魔法
    local nMana = self:GetSpecialValueFor("replenish_amount")
    oPlayer.m_eHero:GiveMana(nMana)
    ----回复全部兵卒魔法
    local nCount = 0
    for _, v in pairs(oPlayer.m_tabBz) do
        if v:GetMaxMana() > v:GetMana() then
            v:GiveMana(v:GetMaxMana())
            nCount = nCount + 1
            AMHC:CreateParticle("particles/items_fx/arcane_boots_recipient.vpcf"
            , PATTACH_POINT, false, v, 2)
        end
    end

    ----音效
    EmitGlobalSound("DOTA_Item.ArcaneBoots.Activate")

    ----设置冷却
    local nBonusCD = self:GetSpecialValueFor("bonus_cd")
    AbilityManager:setRoundCD(oPlayer, self, self:GetCooldownTime() + nBonusCD * nCount)

    if not self:GetCaster():IsHero() then
        ----兵卒施法扣除英雄魔法
        oPlayer.m_eHero:SpendMana(self:GetSpecialValueFor("mana_cost"), self)
        self:GetCaster():GiveMana(self:GetManaCost(0))
    end
end

----默认buff
modifier_item_arcane_boots_lua = class({})
function modifier_item_arcane_boots_lua:IsHidden()
    return true
end
function modifier_item_arcane_boots_lua:IsPurgable()
    return false
end
function modifier_item_arcane_boots_lua:OnCreated(kv)
    if IsClient() then
        return
    end
    ----增加英雄魔法上限
    local function onItem()
        for i = 0, 5 do
            local item = self:GetParent():GetItemInSlot(i)
            if item then
                if "modifier_" .. item:GetAbilityName() == self:GetName() then
                    onItem_MaxMana({
                        ability = item
                        , caster = self:GetParent()
                    })
                    self.m_item = item
                    return
                end
            end
        end
        return 0.1
    end
    Timers:CreateTimer(onItem)
end
function modifier_item_arcane_boots_lua:OnDestroy()
    if IsClient() then
        return
    end
    ----减少增加的英雄魔法上限
    if self.m_item then
        onItem_MaxMana({
            ability = self.m_item
            , caster = self:GetParent()
        })
    end
end
function modifier_item_arcane_boots_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
    }
    return funcs
end
function modifier_item_arcane_boots_lua:GetModifierMoveSpeedBonus_Percentage_Unique()
    return 15
end