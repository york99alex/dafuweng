if Attributes == nil then
    Attributes = class({})
end

local public = Attributes

local tPrimaryAttributes = {
    DOTA_ATTRIBUTE_STRENGTH = DOTA_ATTRIBUTE_STRENGTH,
    DOTA_ATTRIBUTE_AGILITY = DOTA_ATTRIBUTE_AGILITY,
    DOTA_ATTRIBUTE_INTELLECT = DOTA_ATTRIBUTE_INTELLECT,
}

LinkLuaModifier("modifier_primary_attribute", "modifiers/hero/modifier_primary_attribute.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_strength", "modifiers/hero/modifier_strength.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_agility", "modifiers/hero/modifier_agility.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_intellect", "modifiers/hero/modifier_intellect.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_base_strength", "modifiers/hero/modifier_base_strength.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_base_agility", "modifiers/hero/modifier_base_agility.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_base_intellect", "modifiers/hero/modifier_base_intellect.lua", LUA_MODIFIER_MOTION_NONE)

function public:init(bReload)
    -- GameEvent("custom_npc_first_spawned", Dynamic_Wrap(public, "OnNPCFirstSpawned"), public)
    EventManager:register("Event_BZCreate", Attributes.OnNPCFirstSpawned, Attributes, 987654321)
end

function public:Register(hUnit)
    local sHeroName = hUnit:GetUnitName()
    local tData = KeyValues.UnitsKv[sHeroName]

    if tData == nil or tData.AttributePrimary == nil then
        return
    end
    hUnit.iPrimaryAttribute = tPrimaryAttributes[tData.AttributePrimary] or DOTA_ATTRIBUTE_INVALID
    if hUnit.iPrimaryAttribute == DOTA_ATTRIBUTE_INVALID then
        return
    end

    hUnit.fBaseStrength = tData.AttributeBaseStrength or 0
    hUnit.fStrength = hUnit.fBaseStrength
    hUnit.fStrengthGain = tData.AttributeStrengthGain or 0

    hUnit.fBaseAgility = tData.AttributeBaseAgility or 0
    hUnit.fAgility = hUnit.fBaseAgility
    hUnit.fAgilityGain = tData.AttributeAgilityGain or 0

    hUnit.fBaseIntellect = tData.AttributeBaseIntelligence or 0
    hUnit.fIntellect = hUnit.fBaseIntellect
    hUnit.fIntellectGain = tData.AttributeIntelligenceGain or 0

    hUnit.hStrModifier = hUnit:AddNewModifier(hUnit, nil, "modifier_strength", { duration = hUnit.fStrengthGain })
    hUnit.hAgiModifier = hUnit:AddNewModifier(hUnit, nil, "modifier_agility", { duration = hUnit.fAgilityGain })
    hUnit.hIntModifier = hUnit:AddNewModifier(hUnit, nil, "modifier_intellect", { duration = hUnit.fIntellectGain })

    hUnit.hBaseStrModifier = hUnit:AddNewModifier(hUnit, nil, "modifier_base_strength", nil)
    hUnit.hBaseAgiModifier = hUnit:AddNewModifier(hUnit, nil, "modifier_base_agility", nil)
    hUnit.hBaseIntModifier = hUnit:AddNewModifier(hUnit, nil, "modifier_base_intellect", nil)

    hUnit.hPrimaryAttributeModifier = hUnit:AddNewModifier(hUnit, nil, "modifier_primary_attribute", nil):SetStackCount(hUnit.iPrimaryAttribute)

    hUnit.GetPrimaryAttribute = function(self)
        return self.iPrimaryAttribute
    end

    hUnit.GetBaseStrength = function(self)
        return self.fBaseStrength
    end
    hUnit.GetStrength = function(self)
        return self.fStrength
    end
    hUnit.GetStrengthGain = function(self)
        return self.fStrengthGain
    end
    hUnit.ModifyStrength = function(self, fChanged, bIsBase)
        self.fStrength = self.fStrength + fChanged
        if bIsBase ~= nil and bIsBase == true then
            self.fBaseStrength = self.fBaseStrength + fChanged
        end
        self:_updateStrength()
    end
    hUnit.SetBaseStrength = function(self, fStrength)
        local fChanged = fStrength - self.fBaseStrength
        self:ModifyStrength(fChanged, true)
    end
    hUnit._updateStrength = function(self)
        self.hStrModifier:SetStackCount(math.max(self.fStrength, 0))
        self.hBaseStrModifier:SetStackCount(math.max(self.fBaseStrength, 0))
    end

    hUnit.GetBaseAgility = function(self)
        return self.fBaseAgility
    end
    hUnit.GetAgility = function(self)
        return self.fAgility
    end
    hUnit.GetAgilityGain = function(self)
        return self.fAgilityGain
    end
    hUnit.ModifyAgility = function(self, fChanged, bIsBase)
        self.fAgility = self.fAgility + fChanged
        if bIsBase ~= nil and bIsBase == true then
            self.fBaseAgility = self.fBaseAgility + fChanged
        end
        self:_updateAgility()
    end
    hUnit.SetBaseAgility = function(self, fAgility)
        local fChanged = fAgility - self.fBaseAgility
        self:ModifyAgility(fChanged, true)
    end
    hUnit._updateAgility = function(self)
        self.hAgiModifier:SetStackCount(math.max(self.fAgility, 0))
        self.hBaseAgiModifier:SetStackCount(math.max(self.fBaseAgility, 0))
    end

    hUnit.GetBaseIntellect = function(self)
        return self.fBaseIntellect
    end
    hUnit.GetIntellect = function(self)
        return self.fIntellect
    end
    hUnit.GetIntellectGain = function(self)
        return self.fIntellectGain
    end
    hUnit.ModifyIntellect = function(self, fChanged, bIsBase)
        self.fIntellect = self.fIntellect + fChanged
        if bIsBase ~= nil and bIsBase == true then
            self.fBaseIntellect = self.fBaseIntellect + fChanged
        end
        self:_updateIntellect()
    end
    hUnit.SetBaseIntellect = function(self, fIntellect)
        local fChanged = fIntellect - self.fBaseIntellect
        self:ModifyIntellect(fChanged, true)
    end
    hUnit._updateIntellect = function(self)
        self.hIntModifier:SetStackCount(math.max(self.fIntellect, 0))
        self.hBaseIntModifier:SetStackCount(math.max(self.fBaseIntellect, 0))
    end

    hUnit.LevelUp = function(self, bPlayEffects, bDown)
        local nChange = bDown and -1 or 1

        self:ModifyStrength(self:GetStrengthGain() * nChange, true)
        self:ModifyAgility(self:GetAgilityGain() * nChange, true)
        self:ModifyIntellect(self:GetIntellectGain() * nChange, true)

        local hAbilities = {}
        for i = 0, self:GetAbilityCount() - 1, 1 do
            local hAbility = self:GetAbilityByIndex(i)
            if hAbility then
                hAbilities[i] = {
                    iLevel = hAbility:GetLevel(),
                    bAutoCastState = hAbility:GetAutoCastState(),
                    bToggleState = hAbility:GetToggleState(),
                }

                hAbility.bNoRefresh = true
            end
        end

        if self.fBaseManaRegen == nil then
            self.fBaseManaRegen = self:GetManaRegen() - self:GetBonusManaRegen()
        end

        local fManaPercent = self:GetMana() / self:GetMaxMana()
        local fHealthPercent = self:GetHealth() / self:GetMaxHealth()
        self:CreatureLevelUp(nChange)
        self:SetBaseManaRegen(self.fBaseManaRegen)
        self:SetHealth(fHealthPercent * self:GetMaxHealth())
        self:SetMana(fManaPercent * self:GetMaxMana())

        for i, tData in pairs(hAbilities) do
            local hAbility = self:GetAbilityByIndex(i)
            if hAbility then
                hAbility:SetLevel(tData.iLevel)
                if hAbility:GetAutoCastState() ~= tData.bAutoCastState then hAbility:ToggleAutoCast() end
                if hAbility:GetToggleState() ~= tData.bToggleState then hAbility:ToggleAbility() end

                if tData.iLevel == 0 then
                    self:RemoveModifierByName(hAbility:GetIntrinsicModifierName() or "")
                end

                hAbility.bNoRefresh = false
            end
        end

        if bPlayEffects then
            local particleID = ParticleManager:CreateParticle("particles/generic_hero_status/hero_levelup.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
            ParticleManager:ReleaseParticleIndex(particleID)
        end
    end

    hUnit:_updateIntellect()
    hUnit:_updateStrength()
    hUnit:_updateAgility()
end

function public:OnNPCFirstSpawned(events)
    -- local spawnedUnit = EntIndexToHScript(events.entindex)
    -- if spawnedUnit == nil then return end
    if events.entity then
        Attributes:Register(events.entity)
    end
end

return public