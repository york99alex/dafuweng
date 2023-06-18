function onItem_power_treads(keys)
    if "OnDestroy" == keys.State then
        ----移除
        EventManager:fireEvent("Event_onItem_power_treads", keys)
        return
    end

    if not keys.caster:IsRealHero() then
        return
    end
    if keys.caster._onItem_power_treads then
        ----多件装备不叠加
        return
    end

    ----装备
    keys.caster._onItem_power_treads = true
    local nManaToSpeed = keys.ability:GetSpecialValueFor('mana_to_speed')
    local nAdd = keys.caster:GetMana() * nManaToSpeed
    keys.caster:SetBaseMoveSpeed(keys.caster:GetBaseMoveSpeed() + nAdd)

    local tEventID = {}
    table.insert(tEventID, EventManager:register("Event_HeroManaChange", function(tEvent)
        if keys.caster == tEvent.player.m_eHero then
            keys.caster:SetBaseMoveSpeed(keys.caster:GetBaseMoveSpeed() - nAdd)
            nAdd = keys.caster:GetMana() * nManaToSpeed
            keys.caster:SetBaseMoveSpeed(keys.caster:GetBaseMoveSpeed() + nAdd)
        end
    end))
    table.insert(tEventID, EventManager:register("Event_onItem_power_treads", function(keys2)
        if keys2.caster ~= keys.caster then
            return
        end
        local item = keys.caster:get05ItemByName(keys2.ability:GetAbilityName(), keys2.ability)
        if item then
            keys.ability = item
        else
            keys.caster._onItem_power_treads = false
            keys.caster:SetBaseMoveSpeed(keys.caster:GetBaseMoveSpeed() - nAdd)
            for _, v in pairs(tEventID) do
                EventManager:unregisterByID(v)
            end
        end
    end))
end