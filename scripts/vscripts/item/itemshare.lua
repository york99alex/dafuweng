----装备共享
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if not ItemShare then
    ItemShare = {
        m_tabShare = {}			----共享组
    }
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
function ItemShare:init(bReload)
    if not bReload then
        EventManager:register("Event_ItemMove", ItemShare.onEvent_ItemMove, ItemShare, 10000)
        EventManager:register("Event_ItemAdd", ItemShare.onEvent_ItemAdd, ItemShare, -10000)
        EventManager:register("Event_ItemDel", ItemShare.onEvent_ItemDel, ItemShare, -10000)
        EventManager:register("Event_ItemSell", ItemShare.onEvent_ItemSell, ItemShare, 10000)
        EventManager:register("Event_ItemGive", ItemShare.onEvent_ItemGive, ItemShare, 10000)
        EventManager:register("Event_ItemLock", ItemShare.onEvent_ItemLock, ItemShare)
        EventManager:register("Event_ItemSplit", ItemShare.onEvent_ItemSplit, ItemShare, -10000)

    end
end

----是否是共享单位
function ItemShare:isShare(nEntID)
    return ItemShare:getShareTab(nEntID) and true or false
end

----获取共享组
function ItemShare:getShareTab(nEntID, bDel)
    for k = #ItemShare.m_tabShare, 1, -1 do
        local v = ItemShare.m_tabShare[k]
        local b
        for j = #v, 1, -1 do
            if not v[j] or v[j]:IsNull() then
                table.remove(v, j)
                if 0 >= #v then
                    table.remove(ItemShare.m_tabShare, k)
                end
            elseif nEntID == v[j]:GetEntityIndex() then
                b = true
            end
        end
        if b then
            if bDel then
                table.remove(ItemShare.m_tabShare, k)
                return v
            end
            return copy(v)
        end
    end
end

----设置共享关系
function ItemShare:setShareAdd(e1, e2)
    if e1._eShareOwner and e2._eShareOwner and e1._eShareOwner ~= e2._eShareOwner then
        return  ----共享主单位不同
    end

    local tab1 = ItemShare:getShareTab(e1:GetEntityIndex(), true)
    local tab2 = ItemShare:getShareTab(e2:GetEntityIndex(), true)
    if tab1 and tab1 == tab2 then
        return
    end

    ----添加关系
    if not tab1 then
        tab1 = { e1 }
    end
    if not tab2 then
        tab2 = { e2 }
    end

    ----设置共享主单位
    if e1._eShareOwner then
        for _, v in pairs(tab2) do
            v._eShareOwner = e1._eShareOwner
        end
    elseif e2._eShareOwner then
        for _, v in pairs(tab1) do
            v._eShareOwner = e2._eShareOwner
        end
    end

    table.insert(ItemShare.m_tabShare, concat(tab1, tab2))
end
function ItemShare:setShareDel(e)
    local tab = ItemShare:getShareTab(e:GetEntityIndex(), true)
    if not tab then
        return
    end
    for k, v in pairs(tab) do
        if e == v then
            table.remove(tab, k)
            if 0 < #tab then
                table.insert(ItemShare.m_tabShare, tab)
            end
            return true
        end
    end
end
----设置共享单位为主单位,主单位装备作为本源物品不能被同步
function ItemShare:setShareOwner(e)
    e._eShareOwner = e
    local tab = ItemShare:getShareTab(e:GetEntityIndex())
    if not tab then
        return
    end
    for _, v in pairs(tab) do
        v._eShareOwner = e
    end
end

----物品移动
function ItemShare:onEvent_ItemMove(tabEvent)
    --[[d     
        entindex_ability: 347
        entindex_target: 1
        issuer_player_id_const: 0
        order_type: 19
        position_x: 0
        position_y: 0
        position_z: 0
        queue: 0
        sequence_number_const: 15
        units:
            0: 134
    ]]
    local tab = ItemShare:getShareTab(tabEvent.units["0"], true)
    if not tab then
        return
    end
    local e = EntIndexToHScript(tabEvent.units["0"])

    ----有主单位，只能主单位移动
    if e._eShareOwner and not e._eShareOwner:IsNull() and e ~= e._eShareOwner then
        tabEvent.bIgnore = true
        table.insert(ItemShare.m_tabShare, tab)
        local item = EntIndexToHScript(tabEvent.entindex_ability)
        local itemCur = e._eShareOwner:GetItemInSlot(item:GetItemSlot())
        if itemCur then
            ExecuteOrderFromTable({
                UnitIndex = e._eShareOwner:GetEntityIndex(),
                OrderType = tabEvent.order_type,
                TargetIndex = tabEvent.entindex_target, ----Optional.  Only used when targeting units
                AbilityIndex = itemCur:GetEntityIndex(), ----Optional.  Only used when casting abilities
                Position = nil, ----Optional.  Only used when targeting the ground
                Queue = 0 ----Optional.  Used for queueing up abilities
            })
        end
    else
        Timers:CreateTimer(function()
            for _, v in pairs(tab) do
                if v ~= e and not v:IsNull() then
                    e:syncItem(v)
                end
            end
            table.insert(ItemShare.m_tabShare, tab)
        end)
    end
end

----物品获得
function ItemShare:onEvent_ItemAdd(tabEvent)
    --[[d     
        item_entindex_const	= 874
        inventory_parent_entindex_const	= 921   ----拥有该物品的ent
        suggested_slot	= -1
        item_parent_entindex_const	= 921
    ]]
    if tabEvent.bIgnore or tabEvent.bIgnore_ItemShare then
        return
    end
    local tab = ItemShare:getShareTab(tabEvent.inventory_parent_entindex_const, true)
    if not tab then
        return
    end

    local e = EntIndexToHScript(tabEvent.inventory_parent_entindex_const)

    ----有主单位，物品给主单位再同步共享
    if e._eShareOwner and not e._eShareOwner:IsNull() and e ~= e._eShareOwner then
        local item = EntIndexToHScript(tabEvent.item_entindex_const)
        if item then
            EventManager:fireEvent("Event_ItemDel", {
                item = item,
                entity = e,
                nItemEntID = item:GetEntityIndex(),
                nItemSlot = item:GetItemSlot(),
                sItemName = item:GetAbilityName(),
                id = 6,
            })
            Timers:CreateTimer(function()
                e:DropItemAtPositionImmediate(item, Vector(-3000, -3000, -3000))
                table.insert(ItemShare.m_tabShare, tab)
                e._eShareOwner:AddItem(item)
            end)
            return
        end
        table.insert(ItemShare.m_tabShare, tab)
    else
        Timers:CreateTimer(0.1, function()
            for _, v in pairs(tab) do
                if v ~= e and not v:IsNull() then
                    e:syncItem(v)
                end
            end
            ---- Timers:CreateTimer(function()
            table.insert(ItemShare.m_tabShare, tab)
            ---- end)
        end)
    end
end

----物品失去
function ItemShare:onEvent_ItemDel(tabEvent)
    --[[d     
        item = itemCur,
        entity = v,
        nItemEntID = itemCur:GetEntityIndex(),
        nItemSlot = itemCur:GetItemSlot(),
        sItemName = itemCur:GetAbilityName(),
    ]]
    if tabEvent.bIgnore_ItemShare then
        return
    end

    local e = tabEvent.entity
    if not e or e:IsNull() then
        return
    end

    local tab = ItemShare:getShareTab(e:GetEntityIndex(), true)
    if not tab then
        return
    end

    local item = tabEvent.item

    Timers:CreateTimer(function()
        for _, v in pairs(tab) do
            if v ~= e and not v:IsNull() then
                e:syncItem(v)
            end
        end
        ---- Timers:CreateTimer(function()
        table.insert(ItemShare.m_tabShare, tab)
        ---- end)
    end)
end

----物品出售
function ItemShare:onEvent_ItemSell(tabEvent)
    --[[d             
        entindex_ability: 347
        entindex_target: 0
        issuer_player_id_const: 0
        order_type: 17
        position_x: 0
        position_y: 0
        position_z: 0
        queue: 0
        sequence_number_const: 16
        units:
            0: 134
    ]]
    if tabEvent.bIgnore or tabEvent.bIgnore_ItemShare then
        return
    end
    ----有主单位，主单位卖
    local e = EntIndexToHScript(tabEvent.units["0"])
    if e and e._eShareOwner and not e._eShareOwner:IsNull() and e ~= e._eShareOwner then
        tabEvent.bIgnore = true
        local item = EntIndexToHScript(tabEvent.entindex_ability)
        if IsValid(item) then
            local itemCur = e._eShareOwner:GetItemInSlot(item:GetItemSlot())
            if itemCur then
                ---- ExecuteOrderFromTable({
                ----     UnitIndex = e._eShareOwner:GetEntityIndex(),
                ----     OrderType = tabEvent.order_type,
                ----     TargetIndex = tabEvent.entindex_target, ----Optional.  Only used when targeting units
                ----     AbilityIndex = itemCur:GetEntityIndex(), ----Optional.  Only used when casting abilities
                ----     Position = nil, ----Optional.  Only used when targeting the ground
                ----     Queue = 0 ----Optional.  Used for queueing up abilities
                ---- })
                ---- GMManager:showGold(player, ItemManager:getItemSellGold(item))
                e._eShareOwner:SellItem(itemCur)
                ---- EmitSoundOnClient("Custom.Gold.Sell", e._eShareOwner:GetPlayerOwner())
            end
        end
    end
end

----物品给予
function ItemShare:onEvent_ItemGive(tabEvent)
    --[[d             
        entindex_ability: 347
        entindex_target: 0
        issuer_player_id_const: 0
        order_type: 17
        position_x: 0
        position_y: 0
        position_z: 0
        queue: 0
        sequence_number_const: 16
        units:
            0: 134
    ]]
    if tabEvent.bIgnore or tabEvent.bIgnore_ItemShare then
        return
    end
    local tab = ItemShare:getShareTab(tabEvent.units["0"])
    if not tab then
        return
    end

    local target = EntIndexToHScript(tabEvent.entindex_target)
    local item = EntIndexToHScript(tabEvent.entindex_ability)
    local e = EntIndexToHScript(tabEvent.units["0"])

    ----物品不能给共享单位
    for _, v in pairs(tab) do
        if v == target then
            tabEvent.bIgnore = true
            return
        end
    end
end

----物品锁定
function ItemShare:onEvent_ItemLock(tabEvent)
    --[[d             
        entindex_ability: 969
        entindex_target: 1
        issuer_player_id_const: 0
        order_type: 32
        position_x: 0
        position_y: 0
        position_z: 0
        queue: 0
        sequence_number_const: 14
        units:
            0: 522
    ]]
    if tabEvent.bIgnore then
        return
    end

    ----标识物品锁定状态
    local item = EntIndexToHScript(tabEvent.entindex_ability)
    if not IsValid(item) then
        return
    end

    item.m_nLockState = tabEvent.entindex_target

    if tabEvent.bIgnore_ItemShare then
        return
    end

    local tab = ItemShare:getShareTab(tabEvent.units["0"])
    if not tab then
        return
    end

    local e = EntIndexToHScript(tabEvent.units["0"])
    local i = item:GetItemSlot()

    for _, v in pairs(tab) do
        if v ~= e then
            local itemCur = v:GetItemInSlot(i)
            if itemCur then
                if not itemCur.m_nLockState then
                    itemCur.m_nLockState = 0
                end
                if itemCur.m_nLockState ~= tabEvent.entindex_target then
                    EventManager:register("Event_ItemLock", function(tabEvent2)
                        if itemCur:GetEntityIndex() == tabEvent2.entindex_ability then
                            tabEvent2.bIgnore_ItemShare = true
                            return true
                        end
                    end, nil, 10000)
                    ExecuteOrderFromTable({
                        UnitIndex = v:GetEntityIndex(),
                        OrderType = tabEvent.order_type,
                        TargetIndex = tabEvent.entindex_target, ----Optional.  Only used when targeting units
                        AbilityIndex = itemCur:GetEntityIndex(), ----Optional.  Only used when casting abilities
                        Position = nil, ----Optional.  Only used when targeting the ground
                        Queue = 0 ----Optional.  Used for queueing up abilities
                    })
                end
            end
        end
    end
end

----物品拆分
function ItemShare:onEvent_ItemSplit(tabEvent)
    --[[d             
        entindex_ability: 628
        entindex_target: 0
        issuer_player_id_const: 0
        order_type: 18
        position_x: 0
        position_y: 0
        position_z: 0
        queue: 0
        sequence_number_const: 11
        units:
          0: 512
    ]]
    if tabEvent.bIgnore or tabEvent.bIgnore_ItemShare then
        return
    end
    local tab = ItemShare:getShareTab(tabEvent.units["0"])
    if not tab then
        return
    end

    local e = EntIndexToHScript(tabEvent.units["0"])
    local item = EntIndexToHScript(tabEvent.entindex_ability)
    local i = item:GetItemSlot()

    ----拆解的物品标识锁定
    ItemManager:getItemSplit(e, item, function(tabItem)
        for _, itemN in pairs(tabItem) do
            itemN.m_nLockState = 1
        end
    end)

    ----拆解共享单位物品
    for _, v in pairs(tab) do
        if v ~= e then
            local itemCur = v:GetItemInSlot(i)
            if itemCur then
                EventManager:register("Event_ItemSplit", function(tabEvent2)
                    if itemCur:GetEntityIndex() == tabEvent2.entindex_ability then
                        tabEvent2.bIgnore_ItemShare = true
                        return true
                    end
                end, nil, 10000)
                ----拆解的物品标识锁定
                ItemManager:getItemSplit(v, itemCur, function(tabItem)
                    for _, itemN in pairs(tabItem) do
                        itemN.m_nLockState = 1
                    end
                end)
                ExecuteOrderFromTable({
                    UnitIndex = v:GetEntityIndex(),
                    OrderType = tabEvent.order_type,
                    TargetIndex = 0, ----Optional.  Only used when targeting units
                    AbilityIndex = itemCur:GetEntityIndex(), ----Optional.  Only used when casting abilities
                    Position = nil, ----Optional.  Only used when targeting the ground
                    Queue = 0 ----Optional.  Used for queueing up abilities
                })
            end
        end
    end
end

----锁定物品
function ItemShare:lockItem(item)
    if NULL(item) then
        return
    end
    item.m_nLockState = item.m_nLockState or 0
    if 0 == item.m_nLockState then
        item.m_nLockState = 1
    else
        item.m_nLockState = 0
    end
    local tData = {
        UnitIndex = item:GetCaster():GetEntityIndex(),
        OrderType = 32,
        TargetIndex = item.m_nLockState, ----Optional.  Only used when targeting units
        AbilityIndex = item:GetEntityIndex(), ----Optional.  Only used when casting abilities
        Position = nil, ----Optional.  Only used when targeting the ground
        Queue = 0 ----Optional.  Used for queueing up abilities
    }
    local nEventID = EventManager:register("Event_ItemLock", function(tabEvent)
        if tData.AbilityIndex == tabEvent.entindex_ability then
            tabEvent.bIgnore_ItemShare = true
            return true
        end
    end, nil, 10000)
    ExecuteOrderFromTable(tData)
    EventManager:unregisterByID(nEventID)
end

----同步物品
function CDOTA_BaseNPC:syncItem(e)
    local tItemsUnLock = {}
    local tSyncSlot = {}
    local tItems = { {}, {} }
    for slot = 0, INDEX_BACK do
        tItems[1][slot] = self:GetItemInSlot(slot) or false
        tItems[2][slot] = e:GetItemInSlot(slot) or false
    end
    for slot = 0, INDEX_BACK do
        if not tItems[1][slot] then
            ----当前格子没装备
            if not tItems[2][slot] then
                ----同步单位也没装备，不用同步
            else
                ----移除物品
                ItemManager:removeItem(e, tItems[2][slot])
                tItems[2][slot] = false
            end
        else
            ----当前格子有装备
            if not tItems[2][slot] then
                ----同步单位没装备，同步
                table.insert(tSyncSlot, slot)
            elseif tItems[1][slot]:GetAbilityName() ~= tItems[2][slot]:GetAbilityName() then
                ----物品不同，移除物品，同步
                table.insert(tSyncSlot, slot)
                ItemManager:removeItem(e, tItems[2][slot])
                tItems[2][slot] = false
            end
        end
    end
    ----预先锁定
    for slot = 0, INDEX_BACK do
        if tItems[2][slot] then
            if not tItems[2][slot].m_nLockState or 0 == tItems[2][slot].m_nLockState then
                ItemShare:lockItem(tItems[2][slot])
            end
        end
    end
    ----同步
    for _, slot in ipairs(tSyncSlot) do
        local item2 = e:AddItemByName(tItems[1][slot]:GetAbilityName())
        ---- item2:StartCooldown(item:GetCooldownTimeRemaining())
        item2:SetPurchaseTime(tItems[1][slot]:GetPurchaseTime())
        ItemShare:lockItem(item2)
        e:SwapItems(item2:GetItemSlot(), slot)
        tItems[2][slot] = item2
    end
    ----解锁定
    for slot = 0, INDEX_BACK do
        if tItems[1][slot]
        and (not tItems[1][slot].m_nLockState or 0 == tItems[1][slot].m_nLockState) then
            ItemShare:lockItem(tItems[2][slot])
        end
    end
end
-- function CDOTA_BaseNPC:syncItem(e)
--     local tItemsUnLock = {}
--     for slot = 0, 8 do
--         local item2 = e:GetItemInSlot(slot)
--         if item2 then
--             ItemManager:removeItem(e, item2)
--         end
--     end
--     for slot = 0, 8 do
--         ---- local item2 = e:GetItemInSlot(slot)
--         ---- if item2 then
--         ----     ItemManager:removeItem(e, item2)
--         ---- end
--         local item = self:GetItemInSlot(slot)
--         if item then
--             local item2 = e:AddItemByName(item:GetAbilityName())
--             ---- item2:StartCooldown(item:GetCooldownTimeRemaining())
--             item2:SetPurchaseTime(item:GetPurchaseTime())
--             ItemShare:lockItem(item2)
--             e:SwapItems(item2:GetItemSlot(), item:GetItemSlot())
--             if not item.m_nLockState or 0 == item.m_nLockState then
--                 table.insert(tItemsUnLock, item2)
--             end
--         end
--     end
--     ----解锁定
--     ---- Timers:CreateTimer(function()
--     for _, v in ipairs(tItemsUnLock) do
--         if not v:IsNull() then
--             ItemShare:lockItem(v)
--         end
--     end
--     ---- end)
-- end