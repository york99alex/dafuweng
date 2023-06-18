----装备管理
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
INDEX_ITEM = 6
INDEX_BACK = 8
if not ItemManager then
    ItemManager = {
        m_tCombinable = {}, ----记录合成物品，用于过滤重复合成
    }
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
function ItemManager:init(bReload)
    if not bReload then
        EventManager:register("Event_ItemMove", ItemManager.onEvent_ItemMove, ItemManager)
        EventManager:register("Event_ItemAdd", ItemManager.onEvent_ItemAdd, ItemManager)
        EventManager:register("Event_ItemDel", ItemManager.onEvent_ItemDel, ItemManager)
        EventManager:register("Event_ItemSell", ItemManager.onEvent_ItemSell, ItemManager)
        EventManager:register("Event_ItemGive", ItemManager.onEvent_ItemGive, ItemManager)
        EventManager:register("Event_ItemLock", ItemManager.onEvent_ItemLock, ItemManager)
        EventManager:register("Event_ItemBuy", ItemManager.onEvent_ItemBuy, ItemManager)
        EventManager:register("Event_ItemInvalid", ItemManager.onEvent_ItemInvalid, ItemManager)
        EventManager:register("Event_ItemValid", ItemManager.onEvent_ItemValid, ItemManager)
        EventManager:register("Event_ItemSplit", ItemManager.onEvent_ItemSplit, ItemManager, -987654321)
    end
    ItemShare:init(bReload)
    if ItemPool then
        ItemPool:init(bReload)
    end
end

----物品移动
function ItemManager:onEvent_ItemMove(tabEvent)
    --[[d
        entindex_ability: 347
        entindex_target: 1          ----移动目标格子索引
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
    if tabEvent.bIgnore then
        return
    end
    local item = EntIndexToHScript(tabEvent.entindex_ability)
    if not IsValid(item) then return end
    if INDEX_ITEM > tabEvent.entindex_target then
        ----放入物品栏
        if INDEX_ITEM <= item:GetItemSlot() then
            ----从背包放入
            local caster = EntIndexToHScript(tabEvent.units["0"])
            if not IsValid(caster) then return end

            ----触发物品生效
            EventManager:fireEvent("Event_ItemValid", {
                item = item,
            })
            ----被交换物品触发失效
            local item2 = caster:GetItemInSlot(tabEvent.entindex_target)
            if item2 then
                EventManager:fireEvent("Event_ItemInvalid", {
                    item = item2,
                    entity = caster,
                    nItemEntID = item2:GetEntityIndex(),
                    nItemSlot = item2:GetItemSlot(),
                    sItemName = item2:GetAbilityName(),
                })
            end
        end
    elseif INDEX_BACK < tabEvent.entindex_target then
        ----放入储存库，禁止
        tabEvent.bIgnore = true
    else
        ----放入背包
        if INDEX_ITEM > item:GetItemSlot() then
            ----从物品栏放入
            local caster = EntIndexToHScript(tabEvent.units["0"])
            if not IsValid(caster) then return end

            ----触发物品失效
            EventManager:fireEvent("Event_ItemInvalid", {
                item = item,
                entity = caster,
                nItemEntID = item:GetEntityIndex(),
                nItemSlot = item:GetItemSlot(),
                sItemName = item:GetAbilityName(),
            })

            ----触发物品生效
            local item2 = caster:GetItemInSlot(tabEvent.entindex_target)
            if item2 then
                EventManager:fireEvent("Event_ItemValid", {
                    item = item2,
                })
            end
        end
    end
end

----物品获得
function ItemManager:onEvent_ItemAdd(tabEvent)
    --[[d
        item_entindex_const	= 874
        inventory_parent_entindex_const	= 921   ----拥有该物品的ent
        suggested_slot	= -1
        item_parent_entindex_const	= 921
    ]]
    local item = EntIndexToHScript(tabEvent.item_entindex_const)
    local caster = EntIndexToHScript(tabEvent.inventory_parent_entindex_const)
    ---- local caster = item:GetCaster()
    if not IsValid(caster) or not IsValid(item) then
        return
    end
    local nItemSlot = item:GetItemSlot()
    local sName = item:GetAbilityName()
    local nEntID = tabEvent.item_entindex_const

    ----获取合成物品
    ItemManager:getItemCombinable(caster, function(tabUse, tabFinish)
        if 0 == #tabUse then
            ----无物品合成
            if item:IsNull() then
                EventManager:fireEvent("Event_ItemDel", {
                    item = item,
                    entity = caster,
                    nItemEntID = nEntID,
                    nItemSlot = nItemSlot,
                    sItemName = sName,
                    id = 1,
                })
            elseif INDEX_ITEM > nItemSlot then
                EventManager:fireEvent("Event_ItemValid", {
                    item = item,
                })
            end
        elseif 0 < #tabFinish then
            ----有物品合成
            ----过滤重复，n个物品合成1个物品时，会重复n-1次
            local nItemEntID = tabFinish[1]:GetEntityIndex()
            if exist(self.m_tCombinable, nItemEntID) then
                return
            end
            table.insert(self.m_tCombinable, nItemEntID)
            Timers:CreateTimer(function()
                table.remove(self.m_tCombinable, nItemEntID)
            end)

            for _, v in pairs(tabUse) do
                EventManager:fireEvent("Event_ItemDel", {
                    item = item,
                    entity = caster,
                    nItemEntID = v.nEntID,
                    nItemSlot = v.nSlot,
                    sItemName = v.sName,
                    id = 2,
                })
            end

            EventManager:fireEvent("Event_ItemAdd", {
                item_entindex_const    = nItemEntID,
                inventory_parent_entindex_const    = tabEvent.inventory_parent_entindex_const,
                suggested_slot    = tabEvent.suggested_slot,
                item_parent_entindex_const    = tabEvent.item_parent_entindex_const,
            })
        end
    end)
end

----物品失去
function ItemManager:onEvent_ItemDel(tabEvent)
    --[[d
        item = itemCur,
        entity = v,
        nItemEntID = v.nEntID,
        nItemSlot = v.nSlot,
        sItemName = v.sName,
    ]]
    EventManager:fireEvent("Event_ItemInvalid", tabEvent)
end

----物品出售
function ItemManager:onEvent_ItemSell(tabEvent)
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
    if tabEvent.bIgnore then
        return
    end
    tabEvent.bIgnore = true
    local caster = EntIndexToHScript(tabEvent.units["0"])
    local item = EntIndexToHScript(tabEvent.entindex_ability)
    if not IsValid(caster) or not IsValid(item) then
        return
    end
    EventManager:fireEvent("Event_ItemDel", {
        item = item,
        entity = caster,
        nItemEntID = item:GetEntityIndex(),
        nItemSlot = item:GetItemSlot(),
        sItemName = item:GetAbilityName(),
        id = 3,
    })
    local player = PlayerManager:getPlayer(caster:GetPlayerOwnerID())
    local nGold = ItemManager:getItemSellGold(item)
    GMManager:showGold(player, nGold)
    player:setGold(nGold)
    caster:RemoveItem(item)
    EmitSoundOnClient("Custom.Gold.Sell", player.m_oCDataPlayer)
    AMHC:CreateNumberEffect(caster, nGold, 3, AMHC.MSG_MISS, { 255, 215, 0 }, 0)
end

----物品给予
function ItemManager:onEvent_ItemGive(tabEvent)
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
    if tabEvent.bIgnore then
        return
    end
    tabEvent.bIgnore = true

    local target = EntIndexToHScript(tabEvent.entindex_target)
    if not target and target:IsNull() then
        return
    end
    local caster = EntIndexToHScript(tabEvent.units["0"])
    if not caster and caster:IsNull() then
        return
    end

    if target:GetPlayerOwnerID() ~= caster:GetPlayerOwnerID() then
        return  ----非己方不能给物品
    end

    if 9 <= target:getItemCount() then
        HudError:FireLocalizeError(caster:GetPlayerOwnerID(), "Error_ItemMax")
        return
    end

    local item = EntIndexToHScript(tabEvent.entindex_ability)
    if not IsValid(item) then
        return
    end
    EventManager:fireEvent("Event_ItemDel", {
        item = item,
        entity = caster,
        nItemEntID = item:GetEntityIndex(),
        nItemSlot = item:GetItemSlot(),
        sItemName = item:GetAbilityName(),
        id = 4,
    })
    caster:DropItemAtPositionImmediate(item, Vector(-3000, -3000, -3000))
    -- caster:TakeItem(item)
    target:AddItem(item)
end

----物品锁定
function ItemManager:onEvent_ItemLock(tabEvent)
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
    if 0 ~= tabEvent.entindex_target then
        return
    end

    ----解锁装备获取合成
    local item = EntIndexToHScript(tabEvent.entindex_ability)
    local caster = EntIndexToHScript(tabEvent.units["0"])
    ---- local caster = item:GetCaster()
    if not IsValid(item) or not IsValid(caster) then
        return
    end
    local nItemSlot = item:GetItemSlot()
    local sName = item:GetAbilityName()
    local nEntID = tabEvent.item_entindex_const

    ----获取合成物品
    ItemManager:getItemCombinable(caster, function(tabUse, tabFinish)
        if 0 == #tabUse then
        elseif 0 < #tabFinish then
            ----有物品合成
            ----过滤重复，n个物品合成1个物品时，会重复n-1次
            local nItemEntID = tabFinish[1]:GetEntityIndex()
            if exist(self.m_tCombinable, nItemEntID) then
                return
            end
            table.insert(self.m_tCombinable, nItemEntID)
            Timers:CreateTimer(function()
                table.remove(self.m_tCombinable, nItemEntID)
            end)
            for _, v in pairs(tabUse) do
                EventManager:fireEvent("Event_ItemDel", {
                    item = v,
                    entity = caster,
                    nItemEntID = v.nEntID,
                    nItemSlot = v.nSlot,
                    sItemName = v.sName,
                    id = 6,
                })
            end
            EventManager:fireEvent("Event_ItemAdd", {
                item_entindex_const    = nItemEntID,
                inventory_parent_entindex_const    = tabEvent.units["0"],
                suggested_slot    = -1,
                item_parent_entindex_const    = tabEvent.units["0"],
            })
        end
    end)
end

----物品拆分
function ItemManager:onEvent_ItemSplit(tabEvent)
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
    tabEvent.bIgnore = true
    if tabEvent.bIgnore then
        return
    end
    local caster = EntIndexToHScript(tabEvent.units["0"])
    local item = EntIndexToHScript(tabEvent.entindex_ability)
    if not IsValid(caster) or not IsValid(item) then
        return
    end
    EventManager:fireEvent("Event_ItemDel", {
        item = item,
        entity = caster,
        nItemEntID = item:GetEntityIndex(),
        nItemSlot = item:GetItemSlot(),
        sItemName = item:GetAbilityName(),
    })
end

----物品失效
function ItemManager:onEvent_ItemInvalid(tabEvent)
    --[[d
        item = itemCur,
        entity = v,
        nItemEntID = v.nEntID,
        nItemSlot = v.nSlot,
        sItemName = v.sName,
    ]]
    ItemManager:removeItemBuff(tabEvent.entity, 'ability_' .. tabEvent.sItemName)
end
----物品生效
function ItemManager:onEvent_ItemValid(tabEvent)
    --[[d
        item = itemCur,
    ]]
    ItemManager:addItemBuff(tabEvent.item:GetCaster(), 'ability_' .. tabEvent.item:GetAbilityName())
end

----物品购买
function ItemManager:onEvent_ItemBuy(tabEvent)
    if tabEvent.bIgnore then
        return
    end
    tabEvent.bIgnore = true
    local caster = EntIndexToHScript(tabEvent.units["0"])
    if NIL(caster) or caster:IsNull() then
        return
    end

    ----物品信息
    local tItemInfo = FIND(KeyValues.ItemsKv, function(v)
        return "table" == type(v) and v.ID == tabEvent.entindex_ability
    end)
    if not tItemInfo then
        return
    end
    local sItemName = tItemInfo.key
    tItemInfo = tItemInfo.value
    tItemInfo['SideShop'] = tItemInfo['SideShop'] or '0'
    tItemInfo['SecretShop'] = tItemInfo['SecretShop'] or '0'

    -----@type Player
    local player = PlayerManager:getPlayer(caster:GetPlayerOwnerID())
    if NIL(player) then
        return
    end

    ----验证物品
    local function checkItem()
        if 1 == tItemInfo['SideShop'] then
            if 1 == tItemInfo['SecretShop'] then
                ----边路,神秘物品
                if TBuyItem_Secret ~= player.m_typeBuyState
                and TBuyItem_Side ~= player.m_typeBuyState
                and TBuyItem_SideAndSecret ~= player.m_typeBuyState then
                    HudError:FireLocalizeError(caster:GetPlayerOwnerID(), 'Error_ItemSideAndSecret')
                    local tPath = concat(PathManager:getPathByType(TP_SHOP_SIDE), PathManager:getPathByType(TP_SHOP_SECRET))
                    for _, v in pairs(tPath) do
                        fireMouseAction_symbol(v.m_entity:GetAbsOrigin(), player.m_oCDataPlayer, true)
                    end
                    return false
                end
            else
                ----边路物品
                if TBuyItem_Side ~= player.m_typeBuyState
                and TBuyItem_SideAndSecret ~= player.m_typeBuyState then
                    HudError:FireLocalizeError(caster:GetPlayerOwnerID(), 'Error_ItemSide')
                    local tPath = PathManager:getPathByType(TP_SHOP_SIDE)
                    for _, v in pairs(tPath) do
                        fireMouseAction_symbol(v.m_entity:GetAbsOrigin(), player.m_oCDataPlayer, true)
                    end
                    return false
                end
            end
            if 0 == player.m_nBuyItem then
                HudError:FireLocalizeError(caster:GetPlayerOwnerID(), 'Error_ItemNoCount')
                return false
            end
        elseif 1 == tItemInfo['SecretShop'] then
            ----神秘物品
            if TBuyItem_Secret ~= player.m_typeBuyState
            and TBuyItem_SideAndSecret ~= player.m_typeBuyState then
                HudError:FireLocalizeError(caster:GetPlayerOwnerID(), 'Error_ItemSecret')
                local tPath = PathManager:getPathByType(TP_SHOP_SECRET)
                for _, v in pairs(tPath) do
                    fireMouseAction_symbol(v.m_entity:GetAbsOrigin(), player.m_oCDataPlayer, true)
                end
                return false
            end
            if 0 == player.m_nBuyItem then
                HudError:FireLocalizeError(caster:GetPlayerOwnerID(), 'Error_ItemNoCount')
                return false
            end
        end
        return true
    end
    if not TESTITEM and not checkItem() then
        return
    end

    ----背包已经满
    if INDEX_BACK + 1 <= caster:getItemCount() then
        HudError:FireLocalizeError(caster:GetPlayerOwnerID(), "Error_ItemMax")
        return
    end

    ----买装备
    player:getItemBuy(sItemName)
    ---- if 1 == tItemInfo.ItemStackable and player.m_eHero:HasItemInInventory(sItemName) then
    ----     HudError:FireLocalizeError(player.m_nPlayerID, "LuaItemError_BuySingle")
    ----     return
    ---- end
end

----获取合成后的物品和消耗掉的物品
function ItemManager:getItemCombinable(e, funCallBack)
    local tabLast = {}
    for i = 0, 15 do
        local item = e:GetItemInSlot(i)
        if item then
            tabLast[i] = {
                item = item,
                nEntID = item:GetEntityIndex(),
                sName = item:GetAbilityName(),
                nSlot = i,
            }
        end
    end
    local tabUse = {}
    local tabFinish = {}
    Timers:CreateTimer(function()
        if not e:IsNull() then
            for i = 0, 15 do
                local item = e:GetItemInSlot(i)
                if item then
                    if not tabLast[i] or item ~= tabLast[i].item then
                        if tabLast[i] then
                            ----失去物品
                            table.insert(tabUse, tabLast[i])
                        end
                        ----获得新物品
                        table.insert(tabFinish, item)
                    end
                elseif tabLast[i] then
                    ----失去物品
                    table.insert(tabUse, tabLast[i])
                end
            end
        end

        if 0 == #tabUse or 1 ~= #tabFinish then
            ---- if 0 == #tabUse or 1 ~= #tabFinish then
            tabUse = {}
            tabFinish = {}
        else
            for _, v in pairs(tabUse) do
                if v.sName == tabFinish[1]:GetAbilityName() then
                    tabUse = {}
                    tabFinish = {}
                    break
                end
            end
        end

        funCallBack(tabUse, tabFinish)
    end)
end
----获取拆分后的物品
function ItemManager:getItemSplit(e, item, funCallBack)
    local nSlot = item:GetItemSlot()
    ---- if not nSlot then
    ----     return
    ---- end
    local tabNilSlot = {}
    for i = 1, 15 do
        if not e:GetItemInSlot(i) then
            table.insert(tabNilSlot, i)
        end
    end
    Timers:CreateTimer(function()
        if e:GetItemInSlot(nSlot) == item then
            return 0.01
        end
        local tab = { e:GetItemInSlot(nSlot) }
        for _, i in ipairs(tabNilSlot) do
            local itemCur = e:GetItemInSlot(i)
            if itemCur then
                table.insert(tab, itemCur)
            end
        end
        funCallBack(tab)
    end)
end

----获取单位物品栏的物品用名字
function CDOTA_BaseNPC:get05ItemByName(sName, itemIgnore)
    for i = 0, INDEX_ITEM - 1 do
        local item = self:GetItemInSlot(i)
        if item and item ~= itemIgnore and not item:IsNull() and item:GetAbilityName() == sName then
            return item
        end
    end
end
----获取单位物品栏加背包的物品用名字
function CDOTA_BaseNPC:get08ItemByName(sName, itemIgnore)
    if IsValid(self) then
        for i = 0, INDEX_BACK do
            local item = self:GetItemInSlot(i)
            if item and item ~= itemIgnore and not item:IsNull() and item:GetAbilityName() == sName then
                return item
            end
        end
    end
end

----获取一个单位拥有物品数量
function CDOTA_BaseNPC:getItemCount()
    local n = 0
    for i = 0, INDEX_BACK do
        if self:GetItemInSlot(i) then
            n = n + 1
        end
    end
    return n
end

----添加物品buff
function ItemManager:addItemBuff(u, a)
    if not u or u:IsNull() then
        return
    end

    local oAblt = u:FindAbilityByName(a)
    if not oAblt then
        oAblt = u:AddAbility(a)
        if not oAblt then
            return
        end
        oAblt:SetLevel(1)
    end

    ----叠加buff
    local oBuff = u:FindModifierByName("modifier_" .. a)
    if not oBuff then
        Timers:CreateTimer(function()
            oAblt:ApplyDataDrivenModifier(u, u, "modifier_" .. oAblt:GetAbilityName(), nil)
        end)
    else

        oBuff:IncrementStackCount()
    end
end
----移除物品buff
function ItemManager:removeItemBuff(u, a)
    if NIL(u) then
        return
    end
    if u:IsNull() then
        return
    end
    local oBuff = u:FindModifierByName("modifier_" .. a)
    if oBuff then
        oBuff:DecrementStackCount()
        if 0 >= oBuff:GetStackCount() then
            u:RemoveAbility(a)
            u:RemoveModifierByName(oBuff:GetName())
        end
    end
end

----移除物品
function ItemManager:removeItem(u, item)
    if not u or u:IsNull() then
        return
    end
    if not item or item:IsNull() then
        return
    end
    EventManager:fireEvent("Event_ItemDel", {
        item = item,
        entity = u,
        nItemEntID = item:GetEntityIndex(),
        nItemSlot = item:GetItemSlot(),
        sItemName = item:GetAbilityName(),
        id = 5,
    })
    u:RemoveItem(item)
end

----单位给另一个单位物品
function CDOTA_BaseNPC:giveItem(e, item)
    if not item or item:IsNull() or item:GetCaster() ~= self then
        return
    end
    if not e or e:IsNull() then
        return
    end

    ExecuteOrderFromTable({
        UnitIndex = self:GetEntityIndex(),
        OrderType = DOTA_UNIT_ORDER_GIVE_ITEM,
        TargetIndex = e:GetEntityIndex(), ----Optional.  Only used when targeting units
        AbilityIndex = item:GetEntityIndex(), ----Optional.  Only used when casting abilities
        Position = nil, ----Optional.  Only used when targeting the ground
        Queue = 0 ----Optional.  Used for queueing up abilities
    })
end

----卖出物品
ItemManager._SellItem = CDOTA_BaseNPC.SellItem
function CDOTA_BaseNPC:SellItem(item, ...)
    if not IsValid(item) or item:GetCaster() ~= self then
        return
    end

    local tEvent = {
        entindex_ability = item:GetEntityIndex(),
        units = {}
    }
    tEvent.units['0'] = self:GetEntityIndex()
    ItemManager:onEvent_ItemSell(tEvent)
    if not ItemPool then
        ItemManager._SellItem(self, item, ...)
    end
end

----获取物品当前出售金币
function ItemManager:getItemSellGold(item)
    if not NULL(item) then
        if 10 > GameRules:GetGameTime() - item:GetPurchaseTime() then
            return GetItemCost(item:GetAbilityName())
        else
            return math.floor(GetItemCost(item:GetAbilityName()) / 2)
        end
    end
    return 0
end

require("item/ItemShare")
-- require("item/ItemPool")