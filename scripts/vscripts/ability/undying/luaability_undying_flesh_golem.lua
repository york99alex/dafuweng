
require("Ability/LuaAbility")
LinkLuaModifier("modifier_luaability_undying_flesh_golem", "Ability/undying/LuaAbility_undying_flesh_golem.lua", LUA_MODIFIER_MOTION_NONE)

if LuaAbility_undying_flesh_golem == nil then
    LuaAbility_undying_flesh_golem = class({}, nil, LuaAbility)
end
function LuaAbility_undying_flesh_golem:CastFilterResult()
    if not self:isCanCast() then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
function LuaAbility_undying_flesh_golem:isCanCastMove()
    return true
end
function LuaAbility_undying_flesh_golem:OnSpellStart()
    if not IsServer() then
        return
    end
    local hCaster = self:GetCaster()

    local hPlayer = PlayerManager:getPlayerByEntindex(hCaster:GetEntityIndex())
    if not hPlayer then
        return
    end

    for _, hBZ in pairs(hPlayer.m_tabBz) do

        -- local hModifier = hBZ:FindModifierByName("modifier_LuaAbility_undying_tombstone")
        -- if hModifier then
        --     hModifier.bIsTomstone = false
        -- end

        if hBZ:HasModifier("modifier_LuaAbility_undying_tombstone_buff") then
            hBZ:RemoveModifierByName("modifier_LuaAbility_undying_tombstone_buff")
        end
        if hBZ:HasModifier("modifier_LuaAbility_undying_tombstone_thinker") then
            hBZ:RemoveModifierByName("modifier_LuaAbility_undying_tombstone_thinker")
        end

        hBZ.m_path.bIsStomstone = false

        AbilityManager:setCopyBuff('modifier_luaability_undying_flesh_golem'
        , hBZ, self:GetCaster(), self)
    end

    local buff = hPlayer.m_eHero:AddNewModifier(self:GetCaster(), self, 'modifier_luaability_undying_flesh_golem', nil)

    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = hPlayer, oAblt = self })
    ----设置冷却
    AbilityManager:setRoundCD(hPlayer, self)
end

if modifier_luaability_undying_flesh_golem == nil then
    modifier_luaability_undying_flesh_golem = class({})
end
function modifier_luaability_undying_flesh_golem:IsHidden()
    return false
end
function modifier_luaability_undying_flesh_golem:IsDebuff()
    return false
end
function modifier_luaability_undying_flesh_golem:IsPurgable()
    return false
end
function modifier_luaability_undying_flesh_golem:GetEffectName()
    return "particles/units/heroes/hero_undying/undying_fg_aura.vpcf"
end
if IsServer() then
    function modifier_luaability_undying_flesh_golem:OnCreated(params)
        if not self:GetParent():HasAbility("LuaAbility_undying_tombstone_zombie_deathstrike") then
            local hAbility = self:GetParent():AddAbility("LuaAbility_undying_tombstone_zombie_deathstrike")
            hAbility:SetLevel(self:GetAbility():GetLevel())
        end
        self.m_nDuration = self:GetAbility():GetSpecialValueFor("duration")
        self.m_nRound = self.m_nDuration
        AbilityManager:judgeBuffRound(self:GetCaster():GetPlayerOwnerID(), self)
    end
    function modifier_luaability_undying_flesh_golem:OnDestroy()
        if self:GetParent():HasAbility("LuaAbility_undying_tombstone_zombie_deathstrike") then
            self:GetParent():RemoveAbility("LuaAbility_undying_tombstone_zombie_deathstrike")
        end
    end
end
function modifier_luaability_undying_flesh_golem:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_HEALTH_BONUS
	}
end
function modifier_luaability_undying_flesh_golem:GetModifierModelChange()
    if IsServer() then
        local tModels = {
            "models/heroes/undying/undying_flesh_golem.vmdl",
            "models/items/undying/flesh_golem/davy_jones_set_davy_jones_set_kraken/davy_jones_set_davy_jones_set_kraken.vmdl",
            "models/items/undying/flesh_golem/ti9_cache_undying_carnivorous_parasitism_golem/ti9_cache_undying_carnivorous_parasitism_golem.vmdl"
        }
        local index = 1
        if self:GetParent():IsHero() then
            index = self:GetAbility():GetLevel()
        else
            ---@class Player
            local player = PlayerManager:getPlayer(self:GetParent():GetPlayerOwnerID())
            if player then
                index = tonumber(player:getBzStarLevel(self:GetParent()))
            end
        end
        return tModels[index]
    end
end
function modifier_luaability_undying_flesh_golem:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("health_bonus")
end