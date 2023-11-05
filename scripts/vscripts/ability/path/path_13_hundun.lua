require("Ability/LuaAbility")
----路径技能：河道混沌
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == path_13_hundun then
    path_13_hundun = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_path_13_hundun", "Ability/path/path_13_hundun.lua", LUA_MODIFIER_MOTION_NONE)
    -- if PrecacheItems then
    --     table.insert(PrecacheItems, "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf")
    -- end
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function path_13_hundun:constructor()
    path_13_hundun.__base__.constructor(self)
end
function path_13_hundun:GetIntrinsicModifierName()
    return "modifier_path_13_hundun"
end

----默认buff
modifier_path_13_hundun = class({})

function modifier_path_13_hundun:IsHidden()
    return false
end

function modifier_path_13_hundun:IsDebuff()
    return false
end

function modifier_path_13_hundun:IsPurgable()
    return false
end

function modifier_path_13_hundun:GetTexture()
    return "path13"
end
-- function modifier_path_13_hundun:GetEffectName()
--     return "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf"
-- end
-- function modifier_path_13_hundun:GetEffectAttachType()
--     return PATTACH_OVERHEAD_FOLLOW
-- end
function modifier_path_13_hundun:OnDestroy()
    if IsClient() then
        return
    end
    if self.oPlayer then
        for _, eBZ in pairs(self.oPlayer.m_tabBz) do
            if IsValid(eBZ) then
                eBZ:RemoveModifierByName(self:GetName())
            end
        end
    end
    if self.unUpdateBZBuffByCreate then
        self:unUpdateBZBuffByCreate()
    end
end

function modifier_path_13_hundun:OnCreated(kv)
    if IsClient() or not self:GetParent():IsRealHero() then
        return
    end
    self.oPlayer = PlayerManager:getPlayer(self:GetParent():GetPlayerID())
    if not self.oPlayer then
        return
    end
    self.tEventID = {}

    ----给玩家全部兵卒buff
    Timers:CreateTimer(0.1, function()
        if IsValid(self) and IsValid(self:GetAbility()) then
            for _, eBZ in pairs(self.oPlayer.m_tabBz) do
                eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self:GetName(), {})
            end
            self.unUpdateBZBuffByCreate = AbilityManager:updataBZBuffByCreate(self.oPlayer, self:GetAbility(), function(eBZ)
                if IsValid(self) then
                    eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self:GetName(), {})
                end
            end)
        end
    end)
end
function modifier_path_13_hundun:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end
function modifier_path_13_hundun:GetModifierTotalDamageOutgoing_Percentage(params)
    EventManager:fireEvent("modifier_path_13_hundun_GetModifierTotalDamageOutgoing_Percentage", params)
    if not params.bIgnore then
        local typeDamage
        if DAMAGE_TYPE_MAGICAL == params.damage_type then
            typeDamage = DAMAGE_TYPE_PHYSICAL
        elseif DAMAGE_TYPE_PHYSICAL == params.damage_type then
            typeDamage = DAMAGE_TYPE_MAGICAL
        end

        ----造成反类型伤害
        if typeDamage then
            EventManager:register("modifier_path_13_hundun_GetModifierTotalDamageOutgoing_Percentage", function(tEvent)
                if tEvent.attacker == params.attacker
                and tEvent.target == params.target then
                    tEvent.bIgnore = true
                    return true
                end
            end)
            AMHC:Damage(params.attacker, params.target, params.original_damage, typeDamage)
            return -100
        end
    end
    return 0
end


-- =====================================
-- activity: -1
-- attacker:
-- basher_tested: false
-- cost: 0
-- damage: 0
-- damage_category: 1
-- damage_flags: 0
-- damage_type: 1
-- diffusal_applied: false
-- distance: 0
-- do_not_consume: false
-- fail_type: 0
-- gain: 0
-- heart_regen_applied: false
-- ignore_invis: false
-- issuer_player_index: 0
-- mkb_tested: false
-- new_pos: Vector 0000000000B0C040 [0.000000 0.000000 0.000000]
-- no_attack_cooldown: false
-- order_type: 0
-- original_damage: 54
-- process_procs: true
-- ranged_attack: false
-- record: 43
-- reincarnate: false
-- stout_tested: false
-- target: table: 0x005ea848
-- =====================================