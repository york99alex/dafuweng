require("Ability/LuaItem")
----物品技能：洞察烟斗
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
item_pipe_lua = class({}, nil, LuaItem)
LinkLuaModifier("modifier_item_pipe_buff", "Ability/items/item_pipe_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_pipe_lua", "Ability/items/item_pipe_lua.lua", LUA_MODIFIER_MOTION_NONE)
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function item_pipe_lua:constructor()
    if self.__init then
        return
    end
    self.__base__.constructor(self)
end

function item_pipe_lua:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_TOGGLE
end

function item_pipe_lua:GetCooldown()
    return 1
end

----开始技能效果
function item_pipe_lua:OnToggle()
    if not IsValid(self) or not IsValid(self:GetCaster()) then
        return
    end
    local player = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if NIL(player) then
        return
    end

    if self:isToggle() then
        ----关闭效果
        EventManager:fireEvent("Event_item_pipe_lua_OnToggle_off", {
            player = player
        })
        return
    end
    ----开启效果
    ----
    ----添加buff
    player.m_eHero:AddNewModifier(player.m_eHero, self, "modifier_item_pipe_buff", nil)
    for _, v in pairs(player.m_tabBz) do
        if IsValid(v) then
            v:AddNewModifier(player.m_eHero, self, "modifier_item_pipe_buff", nil)
        end
    end
    ----兵卒buff更新
    self.unUpdataBuff = AbilityManager:updataBZBuffByCreate(player, self, function(eBZ)
        eBZ:AddNewModifier(player.m_eHero, self, "modifier_item_pipe_buff", nil)
    end)

    ----监听装备移除
    self.m_tEvnetID = {}
    local nItemEntID = self:GetEntityIndex()
    table.insert(self.m_tEvnetID, EventManager:register("Event_ItemInvalid", function(tEvent)
        if nItemEntID == tEvent.nItemEntID then
            self:OnToggle()
        end
    end))

    ----监听
    EventManager:register("Event_item_pipe_lua_OnToggle_off", function(tEvent)
        if tEvent.player == player then
            ----移除buff
            for _, v in pairs(player.m_tabBz) do
                v:RemoveModifierByName("modifier_item_pipe_buff")
            end
            player.m_eHero:RemoveModifierByName("modifier_item_pipe_buff")
            if "function" == type(self.unUpdataBuff) then
                self.unUpdataBuff()
            end
            for _, v in pairs(self.m_tEvnetID) do
                EventManager:unregisterByID(v)
            end
            return true
        end
    end)
end

function item_pipe_lua:isToggle()
    if self:GetCaster():FindModifierByName("modifier_item_pipe_buff") then
        return true
    end
    return false
end

----技能buff
modifier_item_pipe_buff = class({})
function modifier_item_pipe_buff:IsHidden()
    return false
end
function modifier_item_pipe_buff:IsPurgable()
    return false
end
function modifier_item_pipe_buff:IsPassive()
    return false
end
function modifier_item_pipe_buff:GetTexture()
    return "item_pipe"
end
function modifier_item_pipe_buff:OnCreated(kv)
    self.bonus_spell_resist = self:GetAbility():GetSpecialValueFor("bonus_spell_resist")
    self.miss_mana_damege_percentage = self:GetAbility():GetSpecialValueFor("miss_mana_damege_percentage")
    self.miss_need_mana = self:GetAbility():GetSpecialValueFor("miss_need_mana")

    if IsClient() then
        return
    end

    local eCaster = self:GetParent()
    EventManager:register("Event_BeAtk", self.onMiss, self, -987654321)

    self.m_tPtclID = {}
    local nPtclID = AMHC:CreateParticle("particles/items2_fx/pipe_of_insight.vpcf"
    , PATTACH_OVERHEAD_FOLLOW, false, eCaster)
    ---- ParticleManager:SetParticleControl(nPtclID, 0, eCaster:GetAbsOrigin() + (eCaster:GetUpVector() * eCaster:GetModelRadius() * 0.7))
    ParticleManager:SetParticleControlEnt(nPtclID, 1, eCaster, PATTACH_POINT_FOLLOW, "attach_origin", eCaster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(nPtclID, 2, Vector(eCaster:GetModelRadius() * 1.5, 0, 0))
    table.insert(self.m_tPtclID, nPtclID)

end
function modifier_item_pipe_buff:OnDestroy()
    if IsClient() then
        return
    end

    EventManager:unregister("Event_BeAtk", self.onMiss, self)

    for _, v in pairs(self.m_tPtclID) do
        ParticleManager:DestroyParticle(v, false)
    end

end
function modifier_item_pipe_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
    return funcs
end
function modifier_item_pipe_buff:GetModifierMagicalResistanceBonus()
    return
end
function modifier_item_pipe_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
----触发闪避魔法
function modifier_item_pipe_buff:onMiss(tEvent)

    if 1 > tEvent.damage
    or not IsValid(self:GetParent())
    or tEvent.entindex_victim_const ~= self:GetParent():GetEntityIndex()
    or DAMAGE_TYPE_MAGICAL ~= tEvent.damagetype_const
    or self.miss_mana_damege_percentage < RandomInt(1, 100)
    then
        return
    end

    local player = PlayerManager:getPlayer(self:GetParent():GetPlayerOwnerID())
    if NIL(player) then
        return
    end

    local nNeedMana = self.miss_need_mana
    if nNeedMana > player.m_eHero:GetMana() then
        return
    end

    ----扣蓝
    player.m_eHero:SpendMana(nNeedMana, self:GetAbility())

    ----触发
    tEvent.damage = 0
    local nID = AMHC:CreateParticle("particles/custom/item_pipe_miss_2.vpcf"
    , PATTACH_POINT, false, self:GetParent(), 2)
    ParticleManager:SetParticleControl(nID, 0, self:GetParent():GetAbsOrigin() + Vector(0, 0, 200))
    EmitSoundOn("DOTA_Item.LinkensSphere.Activate", self:GetParent())
end

----被动buff
modifier_item_pipe_lua = class({})
function modifier_item_pipe_lua:IsHidden()
    return true
end
function modifier_item_pipe_lua:IsPurgable()
    return false
end
function modifier_item_pipe_lua:OnCreated(kv)
    self.magic_resistance = self:GetAbility():GetSpecialValueFor("magic_resistance")
    if IsClient() then
        return
    end

    onItem_huiXue({
        ability = self:GetAbility(),
        caster = self:GetParent(),
        State = "OnCreated",
    })
end
function modifier_item_pipe_lua:OnDestroy()
    if IsClient() then
        return
    end
    onItem_huiXue({
        ability = self:GetAbility(),
        caster = self:GetParent(),
        State = "OnDestroy",
    })
end
function modifier_item_pipe_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
    return funcs
end
function modifier_item_pipe_lua:GetModifierMagicalResistanceBonus()
    return self.magic_resistance
end
function modifier_item_pipe_lua:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end