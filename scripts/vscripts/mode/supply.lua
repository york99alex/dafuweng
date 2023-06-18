----补给环节
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if not Supply then
    Supply = {
        m_tItems = {}, ----按价格分段的物品
        m_nFirstID = nil, ----上次轮抽首位玩家ID
        m_nGMOrder = nil, ----记录轮抽后的首位操作玩家
    }
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
function Supply:init(bReload)
    EventManager:register("Event_UpdateRound", Supply.onEvent_UpdateRound, Supply)
    EventManager:register("Event_PlayerDie", Supply.onEvent_PlayerDie, Supply, 10000)

    ----获取补给品
    for k, v in pairs(KeyValues.ItemsKvCustom) do
        if 'table' == type(v)
        and v.IsSupply and '0' ~= v.IsSupply then
            v['ItemName'] = k
            local nLevel = tonumber(v.IsSupply)
            if not Supply.m_tItems[nLevel] then Supply.m_tItems[nLevel] = {} end
            table.insert(Supply.m_tItems[nLevel], v)
        end
    end
end

----获取轮抽顺序
function Supply:getOrders()
    ---- if not Supply.m_nFirstID then
    ----     Supply.m_nFirstID = GMManager:getLastValidOrder(GMManager.m_nOrderFirst)
    ---- else
    ----     Supply.m_nFirstID = GMManager:getNextValidOrder(Supply.m_nFirstID)
    ---- end
    ---- local tOrders = { Supply.m_nFirstID }
    ---- for i = PlayerManager:getAlivePlayerCount(), 2, -1 do
    ----     table.insert(tOrders, GMManager:getNextValidOrder(tOrders[#tOrders]))
    ---- end
    local tOrders = {}
    if 1 == GMManager.m_nRound then
        table.insert(tOrders, GMManager.m_nOrderFirst)
        for i = PlayerManager:getPlayerCount(), 1, -1 do
            -- local nOrder = GMManager:getNextValidOrder(tOrders[#tOrders])
            local nOrder = GMManager:getLastValidOrder(tOrders[#tOrders])
            if nOrder == GMManager.m_nOrderFirst then
                break
            end
            table.insert(tOrders, nOrder)
        end
        table.remove(tOrders, 1)
        table.insert(tOrders, GMManager.m_nOrderFirst)
    else
        for i, _ in pairs(PlayerManager.m_tabPlayers) do
            if PlayerManager:isAlivePlayer(i) then
                table.insert(tOrders, i)
            end
        end
        table.sort(tOrders, function(a, b)
            local p1 = PlayerManager:getPlayer(a)
            local p2 = PlayerManager:getPlayer(b)
            return p1.m_nSumGold < p2.m_nSumGold
        end)
    end
    return tOrders
end

----轮数更新
function Supply:onEvent_UpdateRound(tEvtData)
    print("onEvent_UpdateRound")
    if self:checkRound(GMManager.m_nRound + 1) then
        CustomGameEventManager:Send_ServerToAllClients("round_tip", { sTip = "supply" })
    end
    if not self:checkRound(GMManager.m_nRound) then
        return
    end
    CustomGameEventManager:Send_ServerToAllClients("round_tip", { sTip = "false" })
    -- ----劫持begin,进入补给状态
    -- EventManager:register("Event_PlayerRoundBefore", function(tabEvent)
    --     if GS_Begin ~= tabEvent.typeGameState then
    --         return
    --     end
    local tData = {
        tabSupplyInfo = {},
        tabPlayerID = nil,
        nPlayerIDOprt = -1,
    }
    ----获取轮抽顺序
    tData.tabPlayerID = Supply:getOrders()
    ----获取补给物品
    Supply:_setSupply(tData)
    if 0 < #tData.tabSupplyInfo then
        tEvtData.isBegin = false

        ----设置数据到网表
        print("supply data:====================")
        DeepPrintTable(tData)
        CustomNetTables:SetTableValue("GameingTable", "supply", tData)
        ----设置游戏状态和操作时间
        -- tabEvent.typeGameState = GS_Supply
        -- GSManager:yieldState()
        GSManager:setState(GS_Supply)
        GMManager.m_timeOprt = TIME_SUPPLY_READY
        Supply.m_nGMOrder = GMManager.m_nOrderID
        GMManager:setOrder(-1)
    end
    -- return true
    -- end, nil, 10000)
end

---- 是否补给回合
function Supply:checkRound(nRound)
    if SUPPLY_ALL_ROUND <= nRound then
        if nRound % 5 ~= 0 then
            return false
        end
    else
        if not exist(SUPPLY_ROUNT, nRound) then
            return false
        end
    end
    return true
end

----玩家死亡，自动处理操作
function Supply:onEvent_PlayerDie(tabEvent)
    if GS_Supply ~= GMManager.m_typeState then
        return
    end
    local tData = CustomNetTables:GetTableValue("GameingTable", "supply")
    if not tData then
        Supply:setEnd()
        return
    end

    ----轮抽后的起始回合玩家死亡，替换为
    if Supply.m_nGMOrder == tabEvent.player.m_nPlayerID then
        Supply.m_nGMOrder = GMManager:getNextValidOrder(Supply.m_nGMOrder)
    end

    ----玩家操作时死亡，自动处理
    if tData.nPlayerIDOprt == tabEvent.player.m_nPlayerID then
        GMManager:checkOprt({ PlayerID = tData.nPlayerIDOprt, typeOprt = TypeOprt.TO_Supply }, true)
        local tHasSupplyID = {}
        for k, v in pairs(tData.tabSupplyInfo) do
            if not v.nOwnerID then
                table.insert(tHasSupplyID, k)
            end
        end
        Supply:_getSupply(tData, tHasSupplyID[RandomInt(1, #tHasSupplyID)])
    end
end

----操作时间结束
function Supply:onTimeOver()
    local tData = CustomNetTables:GetTableValue("GameingTable", "supply")
    if not tData then
        Supply:setEnd()
        return
    end

    if - 1 == tData.nPlayerIDOprt then
        ----开始操作
        tData.nPlayerIDOprt = tData.tabPlayerID['1']
        if PlayerManager:isAlivePlayer(tData.nPlayerIDOprt) then
            GMManager.m_timeOprt = TIME_SUPPLY_OPRT
        else
            GMManager.m_timeOprt = 2
        end
        GMManager:setOrder(tData.nPlayerIDOprt)
        GMManager:sendOprt({
            typeOprt = TypeOprt.TO_Supply,
            nPlayerID = tData.nPlayerIDOprt
        })
        ----设置网表
        CustomNetTables:SetTableValue("GameingTable", "supply", tData)
    else
        ----玩家操作超时，随机选择
        GMManager:checkOprt({ PlayerID = tData.nPlayerIDOprt, typeOprt = TypeOprt.TO_Supply }, true)
        local tHasSupplyID = {}
        for k, v in pairs(tData.tabSupplyInfo) do
            if not v.nOwnerID then
                table.insert(tHasSupplyID, k)
            end
        end
        Supply:_getSupply(tData, tHasSupplyID[RandomInt(1, #tHasSupplyID)])
    end
end

----处理操作
function Supply:processOprt(tOprt)
    if not tOprt.nRequest then
        return
    end

    local tData = CustomNetTables:GetTableValue("GameingTable", "supply")

    ----验证操作
    local funCheck = function()
        if not tData then
            return -1
        end
        if not tData.tabSupplyInfo[tostring(tOprt.nRequest)] then
            return -2
        end
        if tData.tabSupplyInfo[tostring(tOprt.nRequest)].nOwnerID then
            return -3   ----被其他玩家选择
        end
        if tData.tabSupplyInfo[tostring(tOprt.nRequest)].type == 'item' then
            local player = PlayerManager:getPlayer(tData.nPlayerIDOprt)
            if 9 <= player.m_eHero:getItemCount() then
                HudError:FireLocalizeError(tData.nPlayerIDOprt, 'Error_ItemMax')
                return -4   ----物品栏已满
            end
        end
        return tOprt.nRequest
    end
    tOprt.nRequest = funCheck()

    ----回包
    PlayerManager:sendMsg("GM_OperatorFinished", tOprt, tOprt.PlayerID)

    if 0 < tOprt.nRequest then
        ----成功
        GMManager:checkOprt(tOprt, true)
        Supply:_getSupply(tData, tostring(tOprt.nRequest))
    end
end

----设置补给品
function Supply:_setSupply(tData)
    local nSupplyCount = SUPPLY_COUNT[PlayerManager:getAlivePlayerCount()]
    if 0 >= nSupplyCount then
        return
    end

    ----地
    local tCanOccupyPaths = PathManager:getCanOccupyPaths()
    if 0 < #tCanOccupyPaths then
        if SUPPLY_ALL_ROUND <= GMManager.m_nRound then
            -- local alivePlayerCount = PlayerManager:getAlivePlayerCount()
            local supplyPathCount = math.min(nSupplyCount, #tCanOccupyPaths)--RandomInt(1, math.min(nSupplyCount, #tCanOccupyPaths))
            for i = 1, supplyPathCount do
                table.insert(tData.tabSupplyInfo, {
                    type = 'path',
                    nID = table.remove(tCanOccupyPaths, RandomInt(1, #tCanOccupyPaths)).m_nID
                })
                nSupplyCount = nSupplyCount - 1
            end

        else
            local player = PlayerManager:getPlayer(tData.tabPlayerID[1])
            if player
            and 1 < GMManager.m_nRound
            and not player.m_bDisconnect    ----断线
            and (GAME_MODE ~= GAME_MODE_ALLPATH or 0 == #player.m_tabBz) then   ----没兵
                local nHasPath = player:getMyPathCount()
                if nHasPath < math.ceil(PathManager:getPathCountAge() / 2) then
                    ----其他玩家地不能少于此人
                    local bFlag = false
                    for i = #tData.tabPlayerID, 2, -1 do
                        local nPath = PlayerManager:getPlayer(tData.tabPlayerID[i]):getMyPathCount()
                        if nHasPath > nPath then
                            bFlag = true
                            break
                        end
                    end
                    if not bFlag then
                        table.insert(tData.tabSupplyInfo, {
                            type = 'path',
                            nID = tCanOccupyPaths[RandomInt(1, #tCanOccupyPaths)].m_nID
                        })
                        nSupplyCount = nSupplyCount - 1
                    end
                end
            end
        end
    elseif SUPPLY_ALL_ROUND <= GMManager.m_nRound then
        ----给地轮抽，没地就不给
        return
    end

    ----物品
    local nLevel = 1
    if SUPPLY_ALL_ROUND > GMManager.m_nRound then
        nLevel = KEY(SUPPLY_ROUNT, GMManager.m_nRound)
        if 1 == nLevel then
            nLevel = 1
        elseif 2 == nLevel then
            nLevel = 2
        elseif 3 == nLevel then
            nLevel = 2
        elseif 4 == nLevel then
            nLevel = 3
        elseif 5 == nLevel then
            nLevel = 3
        end
    else
        nLevel = 3
    end
    local tItems
    for i = nLevel, 1, -1 do
        tItems = Supply.m_tItems[i]
        if 0 < #tItems then
            break
        end
    end
    for i = nSupplyCount, 1, -1 do
        table.insert(tData.tabSupplyInfo, {
            type = 'item',
            sName = tItems[RandomInt(1, #tItems)]['ItemName'],
        })
    end
end
----获取补给
function Supply:_getSupply(tData, sSupplyID)
    print("sSupplyID=" .. sSupplyID)

    ----设置补给主人
    tData.tabSupplyInfo[sSupplyID].nOwnerID = tData.nPlayerIDOprt

    local player = PlayerManager:getPlayer(tData.nPlayerIDOprt)
    if player and not player.m_bDie then
        if 'item' == tData.tabSupplyInfo[sSupplyID].type then
            ----添加物品
            if 9 > player.m_eHero:getItemCount() then
                if not NIL(player) and not player.m_eHero:IsNull() then
                    print("tData.tabSupplyInfo[sSupplyID].sName=" .. tData.tabSupplyInfo[sSupplyID].sName)
                    local item = player.m_eHero:AddItemByName(tData.tabSupplyInfo[sSupplyID].sName)
                    if item then
                        item:SetPurchaseTime(0)
                    end
                    player:setSumGold()
                end
            else
                ----满了自动卖掉
                local nGold = math.floor(GetItemCost(tData.tabSupplyInfo[sSupplyID].sName) * 0.5)
                GMManager:showGold(player, nGold)
                player:setGold(nGold)
                EmitSoundOnClient("Custom.Gold.Sell", player.m_oCDataPlayer)
                AMHC:CreateNumberEffect(player.m_eHero, nGold, 3, AMHC.MSG_MISS, { 255, 215, 0 }, 0)
            end
        elseif 'path' == tData.tabSupplyInfo[sSupplyID].type then
            ----添加领地
            local path = PathManager:getPathByID(tonumber(tData.tabSupplyInfo[sSupplyID].nID))
            if not NIL(path) then
                player:setMyPathAdd(path)
            end
        end
    end

    ----设置下一个玩家操作，或者结束
    local nCount = getSize(tData.tabPlayerID)
    for k, v in pairs(tData.tabPlayerID) do
        if v == tData.nPlayerIDOprt then
            if tonumber(k) >= nCount then
                ----结束
                Supply:setEnd(tData)
            else
                tData.nPlayerIDOprt = tData.tabPlayerID[tostring(tonumber(k) + 1)]
                if PlayerManager:isAlivePlayer(tData.nPlayerIDOprt) then
                    GMManager.m_timeOprt = TIME_SUPPLY_OPRT
                else
                    GMManager.m_timeOprt = 2
                end
                GMManager:setOrder(tData.nPlayerIDOprt)
                GMManager:sendOprt({
                    typeOprt = TypeOprt.TO_Supply,
                    nPlayerID = tData.nPlayerIDOprt
                })
                CustomNetTables:SetTableValue("GameingTable", "supply", tData)
            end
            break
        end
    end
end

----结束补给阶段
function Supply:setEnd(tData)
    tData = tData or CustomNetTables:GetTableValue("GameingTable", "supply")
    if tData then
        ----结束，2秒后清空补给阶段数据
        tData.nPlayerIDOprt = -2
        CustomNetTables:SetTableValue("GameingTable", "supply", tData)
        Timers:CreateTimer(2, function()
            CustomNetTables:SetTableValue("GameingTable", "supply", nil)
        end)
    end
    ----重新进入begin
    GMManager:setOrder(Supply.m_nGMOrder)
    Supply.m_nGMOrder = nil
    GMManager:setStateBeginReady(true)
end