----装备对象池
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if not ItemPool then
    ItemPool = {
        m_tabPool = {},
        m_entity = nil, ----转移装备的实体
    }
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
function ItemPool:init(bReload)
end

function ItemPool:getItem(sItemName)
    local tPool = ItemPool.m_tabPool[sItemName]
    if tPool then
        for i = #tPool, 1, -1 do
            local item = tPool[i]
            table.remove(tPool, i)
            if not item:_IsNull() then
                item.IsNull = item._IsNull
                item._IsNull = nil
                item:SetPurchaseTime(GameRules:GetGameTime())
                print("get in pool=" .. #tPool)
                return item
            end
        end
    end
    print("new item")
end
function ItemPool:setItem(item)
    local eOwner = item:GetCaster()
    if IsValid(eOwner) then
        eOwner:TakeItem(item)
        -- eOwner:DropItemAtPositionImmediate(item, Vector(0, 0, 0))
        -- eOwner:DropItemAtPositionImmediate(item, Vector(-3000, -3000, -3000))
    end

    item:SetPurchaser(nil)
    item:SetParent(nil, "")
    item:EndCooldown()
    item._IsNull = item.IsNull
    item.IsNull = ItemPool.IsNull

    local tPool = ItemPool.m_tabPool[item:GetAbilityName()]
    if not tPool then
        tPool = {}
        ItemPool.m_tabPool[item:GetAbilityName()] = tPool
    end
    table.insert(tPool, item)
    print("set in pool=" .. #tPool)
end
function ItemPool:IsNull(...)
    return true
end
function ItemPool:clearItem()
    for k, tPool in pairs(ItemPool.m_tabPool) do
        for i = #tPool, 1, -1 do
            local item = tPool[i]
            table.remove(tPool, i)
            if not item:_IsNull() then
                item:GetCaster():RemoveItem(item)
                print("clearItem")
            end
        end
    end
end
function ItemPool:getItemTo(item, e)
    if not IsValid(item) or not IsValid(e) then
        return
    end
    -- ItemManager.m_entity:SetAbsOrigin(item:GetAbsOrigin())
    e:AddItem(item)
    -- ItemManager.m_entity:SetAbsOrigin(Vector(0, 0, 0))
    -- ItemManager.m_entity:PickupDroppedItem(item)
    -- ItemManager.m_entity:SetAbsOrigin(e:GetAbsOrigin())
    -- ItemManager.m_entity:MoveToNPCToGiveItem(e, item)
end

----添加装备
ItemPool._AddItemByName = CDOTA_BaseNPC.AddItemByName
function CDOTA_BaseNPC:AddItemByName(sItemName, ...)
    local item = ItemPool:getItem(sItemName)
    if item then
        item:SetPurchaser(self)
        item:SetParent(self, "")
        -- self:AddItem(item)
        ItemPool:getItemTo(item, self)
        if item.m_nLockState and 0 ~= item.m_nLockState then
            ItemShare:lockItem(item)
        end
        return item
    end
    return ItemPool._AddItemByName(self, sItemName, ...)
end

----移除装备
ItemPool._RemoveItem = CDOTA_BaseNPC.RemoveItem
function CDOTA_BaseNPC:RemoveItem(item, ...)
    if not IsValid(item) or item:GetCaster() ~= self then
        return
    end
    ItemPool:setItem(item)
end

----卖出物品
-- ItemPool._SellItem = CDOTA_BaseNPC.SellItem
-- function CDOTA_BaseNPC:SellItem(item, ...)
--     if not IsValid(item) or item:GetCaster() ~= self then
--         return
--     end
--     ItemPool:setItem(item)
--     ItemPool._SellItem(self, item, ...)
-- end
ItemPool._CreateItem = CreateItem
function CreateItem(sItemName, owner, owner2, ...)
    local item = ItemPool:getItem(sItemName)
    if item then
        item:SetPurchaser(owner2)
        item:SetParent(owner2, "")
        owner2:AddItem(item)
        return item
    end
    return ItemPool._CreateItem(sItemName, owner, owner2, ...)
end