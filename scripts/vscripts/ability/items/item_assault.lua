----强袭胸甲
function onItem_assault(keys)
    if "OnDestroy" == keys.State then
        ----移除
        EventManager:fireEvent("Event_onItem_assault", keys)
        return
    end

    local function setBuff(eEnemy, path)
        if not eEnemy or eEnemy:IsNull() or not path then
            return
        end

        ----有buff return
        if keys.caster:FindModifierByName("modifier_item_assault_buff") then
            return
        end

        local player = PlayerManager:getPlayer(eEnemy:GetPlayerOwnerID())
        if NIL(player) then
            return
        end

        ----敌军单位数量
        local nEnemy = 1 + #player.m_tabBz

        ----添加buff
        keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_assault_buff", {})
        local oBuff = keys.caster:FindModifierByName("modifier_item_assault_buff")
        if oBuff then
            oBuff:SetStackCount(nEnemy)
        end
        keys.ability:ApplyDataDrivenModifier(keys.caster, eEnemy, "modifier_item_assault_debuff", {})
        local oDebuff = eEnemy:FindModifierByName("modifier_item_assault_debuff")
        if oDebuff then
            oDebuff:SetStackCount(nEnemy)
        end

        local tEventID2 = {}

        ----移除buff
        local function removeBuff()
            for _, v in pairs(tEventID2) do
                EventManager:unregisterByID(v)
            end
            if not keys.caster:IsNull() then
                keys.caster:RemoveModifierByName("modifier_item_assault_buff")
            end
            if not eEnemy:IsNull() then
                eEnemy:RemoveModifierByName("modifier_item_assault_debuff")
            end
        end

        ----监听攻城结束
        table.insert(tEventID2, EventManager:register("Event_GCLDEnd", function(tEvent2)
            if path == tEvent2.path then
                removeBuff()
            end
        end))
        ----监听装备移除
        table.insert(tEventID2, EventManager:register("Event_onItem_assault", function(keys2)
            if keys2.ability == keys.ability then
                removeBuff()
            end
        end))
        ----监听单位数量变更
        local function onCountChange(tEvent2)
            if tEvent2.entity:GetPlayerOwnerID() == player.m_nPlayerID then
                nEnemy = 1 + #player.m_tabBz
                if IsValid(oBuff) and oBuff:GetStackCount() ~= nEnemy then
                    oBuff:SetStackCount(nEnemy)
                    if IsValid(oDebuff) then
                        oDebuff:SetStackCount(nEnemy)
                    end
                end
            end
        end
        table.insert(tEventID2, EventManager:register("Event_BZCreate", onCountChange))
        table.insert(tEventID2, EventManager:register("Event_BZDestroy", onCountChange))
    end

    local tEventID = {}

    ----监听攻城
    table.insert(tEventID, EventManager:register("Event_GCLD", function(tEvent)
        local eEnemy
        if keys.caster == tEvent.entity then
            eEnemy = tEvent.path.m_tabENPC[1]
        elseif keys.caster == tEvent.path.m_tabENPC[1] then
            eEnemy = tEvent.entity
        end
        if not eEnemy or eEnemy:IsNull() then
            return
        end
        setBuff(eEnemy, tEvent.path)
    end))

    ----监听装备移除
    table.insert(tEventID, EventManager:register("Event_onItem_assault", function(keys2)
        if keys2.ability == keys.ability then
            for _, v in pairs(tEventID) do
                EventManager:unregisterByID(v)
            end
        end
    end))

    ----当前单位正在攻城，直接添加buff
    if keys.caster.m_bGCLD then
        if keys.caster:IsHero() then
            ----英雄
            if keys.caster.m_path and keys.caster.m_path.m_tabENPC then
                setBuff(keys.caster.m_path.m_tabENPC[1], keys.caster.m_path)
            end
        else
            ----兵卒
            if keys.caster.m_tabAtker then
                setBuff(keys.caster.m_tabAtker[1], keys.caster.m_path)
            end
        end
    end
end