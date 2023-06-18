-----@class Auction
if not Auction then
    Auction = {
        sendData = nil, ---- 发起拍卖数据
        sendPlayerID = -1, ---- 发起玩家id
        startGold = 0, ---- 起拍金
        addGold = AUCTION_ADD_GOLD, ---- 最低加价
        allJoinBidInfo = {}, ---- 所有参与拍卖数据 arr: {{nPlayerID,nGold},...}
        lastBidPlayers = {}, ---- 所有玩家的最后出价 tab: k playerID v nGold
        curGold = 0, ---- 当前出价
        auctionTimer = nil, ---- 计时Timer
        curBidTime = 0, ---- 当前竞拍剩余时间
        ---- 拍卖进行状态
        aucState = {
            runtime = 0,
            finish = 1
        },
        state = 1, ---- 默认已完成
        EvtID = {
            Event_TO_SendAuction = "Event_TO_SendAuction",
            Event_TO_BidAuction = "Event_TO_BidAuction"
        }
    }
end

local this = Auction

function Auction.init(bReload)
    if not bReload then
        this.PrintSendData("Init()", ">>")
        EventManager:register(this.EvtID.Event_TO_SendAuction, this.Process_TO_SendAuction)
        EventManager:register(this.EvtID.Event_TO_BidAuction, this.Process_TO_BidAuction)
        EventManager:register("Event_GCLD", this.onPathGCLD)
        EventManager:register("Event_PlayerDie", this.onPlayerDie)

    end
end

function Auction.onPathGCLD(tabEvent)
    if this.state == this.aucState.finish then
        return
    end
    local tabPath = json.decode(this.sendData.json)
    for k, pathID in pairs(tabPath) do
        if pathID == tabEvent.path.m_nID then
            this.Cancle(-1)
            return
        end
    end
end

function Auction.onPlayerDie(tabEvent)
    if this.state == this.aucState.finish then
        return
    end
    if tabEvent.player.m_nPlayerID == this.sendPlayerID then
        this.Cancle(-2)
    end
end

function Auction.ResetData()
    this.SetAuctionPathState(TypePathState.None)
    this.sendData = nil
    this.sendPlayerID = -1
    this.startGold = 0
    this.allJoinBidInfo = {}
    this.lastBidPlayers = {}
    this.curGold = 0
    this.curBidTime = 0
    this.state = this.aucState.finish
end

function Auction.Process_TO_SendAuction(data)
    this.PrintSendData("Process_TO_SendAuction", data)
    this.PrintSendData("json is ", json.decode(data.json))
    local sendData = {}
    if this.state == this.aucState.finish then
        local arrPath = json.decode(data.json)
        sendData.nRequest = this.CheckPath(data.nPlayerID, arrPath)

    else
        sendData.nRequest = 0
    end
    sendData.nPlayerID = data.nPlayerID
    sendData.typeOprt = TypeOprt.TO_SendAuction
    sendData.nGold = data.nGold
    sendData.json = data.json
    this.Send_GM_OperatorFinished(sendData)

    ---- 发起拍卖
    if 1 == sendData.nRequest then
        ---- 军情记录
        local arrPaths = json.decode(data.json)
        GameRecord:setGameRecord(
        TGameRecord_SendAuction,
        data.nPlayerID,
        {
            nGold = GameRecord:encodeGameRecord(data.nGold),
            strPathsName = GameRecord:encodeGameRecord(this.GetPathsLocalize(arrPaths))
        }
        )
        ---- test
        this.PrintSendData("arrpath is ", this.GetPathsLocalize(arrPaths))

        ---- 初始化拍卖数据
        this.sendData = data
        this.sendPlayerID = data.nPlayerID
        this.startGold = data.nGold
        this.allJoinBidInfo = {}
        this.curGold = data.nGold
        this.state = this.aucState.runtime

        this.SetAuctionPathState(TypePathState.Auction)
        ---- 通知
        local sendAllData = {}
        sendAllData.nPlayerID = data.nPlayerID
        sendAllData.nSendPlayerID = data.nPlayerID
        sendAllData.typeOprt = TypeOprt.TO_BidAuction
        sendAllData.nGold = data.nGold
        sendAllData.nAddGold = this.addGold
        sendAllData.nTotalTime = AUCTION_BID_TIME
        sendAllData.json = data.json
        this.SendAll_GM_Operator(sendAllData)
        this.StartTimers(sendAllData)
    end
end

function Auction.Process_TO_BidAuction(data)
    this.PrintSendData("Process_TO_BidAuction", data)
    local sendData = {}
    if data and this.state == this.aucState.runtime then
        local function checkBid(data)
            ---- 最后一个出价玩家
            local lastBidPlayer = this.allJoinBidInfo[#this.allJoinBidInfo]
            -----@type Player
            local player = PlayerManager:getPlayer(data.nPlayerID)
            if data.nPlayerID ~= this.sendPlayerID and player and
            (nil == lastBidPlayer or data.nPlayerID ~= lastBidPlayer.nPlayerID)
            then
                local selfLastBit = this.lastBidPlayers[data.nPlayerID]
                local selfHasGold = data.nGold <= player:GetGold() + (selfLastBit and selfLastBit or 0)
                if data.nGold and selfHasGold and this.curGold + this.addGold <= data.nGold then
                    return 1
                else
                    this.PrintSendData("BidAuction gold error", { dataGold = data.nGold, selfHasGold = tostring(selfHasGold), thisCurGold = this.curGold, thisAddGold = this.addGold })
                    return 3 ---- 竞拍金币不符
                end
            else
                return 2 ---- 竞拍玩家不符
            end
        end
        sendData.nRequest = checkBid(data)
        if 1 == sendData.nRequest then
            ---- 给玩家暂扣拍卖的钱
            local player = PlayerManager:getPlayer(data.nPlayerID)
            this.PrintSendData("Auction.Process_TO_BidAuction: set gold is ", -data.nGold)
            this.lastBidPlayers[data.nPlayerID] = data.nGold
            player:setGold(-data.nGold)
            ----通知UI显示花费
            this.SendAll_GM_ShowGold({ nGold = -data.nGold, nPlayerID = data.nPlayerID })

            local lastBid = this.allJoinBidInfo[#this.allJoinBidInfo]
            if lastBid then
                local lastBidPlayer = PlayerManager:getPlayer(lastBid.nPlayerID)
                lastBidPlayer:setGold(lastBid.nGold)
                ----通知UI显示花费
                this.SendAll_GM_ShowGold({ nGold = lastBid.nGold, nPlayerID = lastBid.nPlayerID })
            end
            table.insert(this.allJoinBidInfo, { nPlayerID = data.nPlayerID, nGold = data.nGold })
        end
    else
        sendData.nRequest = 0 ---- 非竞拍状态
    end

    sendData.nPlayerID = data.nPlayerID
    sendData.typeOprt = TypeOprt.TO_BidAuction
    sendData.nGold = data.nGold
    this.Send_GM_OperatorFinished(sendData)
    if sendData.nRequest == 1 then
        ---- 军情记录
        local arrPaths = json.decode(data.json)
        GameRecord:setGameRecord(TGameRecord_BidAuction, data.nPlayerID, { nGold = GameRecord:encodeGameRecord(data.nGold) })

        local sendAllData = {}
        sendAllData.nPlayerID = data.nPlayerID
        sendAllData.nSendPlayerID = this.sendPlayerID
        sendAllData.typeOprt = TypeOprt.TO_BidAuction
        sendAllData.nGold = data.nGold
        sendAllData.nAddGold = this.addGold
        sendAllData.nTotalTime = AUCTION_BID_TIME
        sendAllData.json = this.sendData.json
        this.SendAll_GM_Operator(sendAllData)
        this.StartTimers(sendAllData)
    end
end

---- 1 OK
function Auction.CheckPath(playerid, arrPath)
    local player = PlayerManager:getPlayer(playerid)
    if not player then
        return 2 ---- 玩家id错误
    end
    if arrPath and #arrPath > 0 then
        local hasBZPaths = {}
        for k, pathID in pairs(arrPath) do
            if not player:isHasPath(pathID) then
                return 4 ---- 包含未拥有路径
            end
            local path = PathManager:getPathByID(pathID)
            if path.m_tabENPC and 0 < #path.m_tabENPC then
                -- if path.m_typeState ~= TypePathState.None then
                --     return 8 ---- 当前领地不可拍卖
                -- end
                if path.m_nPlayerIDGCLD then
                    return 7 ----包含攻城中的地
                end
                if nil == hasBZPaths[path.m_typePath] then
                    hasBZPaths[path.m_typePath] = {}
                end
                table.insert(hasBZPaths[path.m_typePath], path)
            end
        end
        if GAME_MODE == GAME_MODE_ALLPATH then
            for typePath, paths in pairs(hasBZPaths) do
                if #player.m_tabMyPath[typePath] ~= #paths then
                    return 5 ---- 有连地错误
                end
            end
        end
    else
        return 3 ---- 路径为空
    end
    return 1
end

function Auction.SetAuctionPathState(typeState)
    local arrPath = json.decode(this.sendData.json)
    for k, pathID in pairs(arrPath) do
        local path = PathManager:getPathByID(pathID)
        path:setState(typeState)
    end
end

function Auction.Send_GM_Operator(data)
    this.PrintSendData("Send_GM_Operator", data)
    PlayerManager:sendMsg("GM_Operator", data, data.nPlayerID)
end

function Auction.Send_GM_OperatorFinished(data)
    this.PrintSendData("Send_GM_OperatorFinished", data)
    PlayerManager:sendMsg("GM_OperatorFinished", data, data.nPlayerID)
end

function Auction.SendAll_GM_Operator(data)
    this.PrintSendData("SendAll_GM_Operator", data)
    PlayerManager:broadcastMsg("GM_Operator", data)
end

function Auction.SendAll_GM_OperatorFinished(data)
    this.PrintSendData("SendAll_GM_OperatorFinished", data)
    PlayerManager:broadcastMsg("GM_OperatorFinished", data)
end

function Auction.SendAll_GM_ShowGold(data)
    this.PrintSendData("SendAll_GM_ShowGold", data)
    CustomGameEventManager:Send_ServerToAllClients("GM_ShowGold", data)
end
----- 开始竞拍倒计时
function Auction.StartTimers(tabBidAuctionData)
    this.StopTimers()
    this.curBidTime = AUCTION_BID_TIME
    this.auctionTimer = Timers:CreateTimer(
    function()
        if this.curBidTime >= 0 then
            this.PrintSendData("GameingTable", this.curBidTime)
            CustomNetTables:SetTableValue(
            "GameingTable",
            "auction",
            { remaining = this.curBidTime, tabBidAuctionData = tabBidAuctionData }
            )
            this.curBidTime = this.curBidTime - 1
            return 1
        else
            CustomNetTables:SetTableValue("GameingTable", "auction", { remaining = 0, tabBidAuctionData = nil })
            this.BitOutTime()
            this.StopTimers()
            return nil
        end
    end
    )
end
---- 停止竞拍计时
function Auction.StopTimers()
    if this.auctionTimer then
        Timers:RemoveTimer(this.auctionTimer)
    end
end
---- 拍卖超时
function Auction.BitOutTime()
    this.state = this.aucState.finish
    ---- 无人竞拍
    if not this.allJoinBidInfo or #this.allJoinBidInfo == 0 then
        local sendAllData = {}
        sendAllData.nPlayerID = this.sendPlayerID
        sendAllData.nSendPlayerID = this.sendPlayerID
        sendAllData.typeOprt = TypeOprt.TO_FinishAuction
        sendAllData.nGold = this.startGold
        sendAllData.json = this.sendData.json
        this.SendAll_GM_OperatorFinished(sendAllData)

        local tabPath = json.decode(this.sendData.json)

        local tabKV = {}
        tabKV["[strPathsName]"] = "''"
        for _, v in pairs(tabPath) do
            tabKV["[strPathsName]"] = tabKV["[strPathsName]"] .. " + " .. GameRecord:encodeLocalize('PathName_' .. v) .. "+','"
        end
        GameRecord:setGameRecord(TGameRecord_String, sendAllData.nPlayerID, {
            strText = GameRecord:encodeGameRecord(GameRecord:encodeLocalize('GameRecord_' .. TGameRecord_NoAuction, tabKV))
        })
        -- GameRecord:setGameRecord(TGameRecord_String, nil, {
        --     nPlayerIDSendAuction = this.sendPlayerID,
        --     nPlayerIDSucceedAuction = this.sendPlayerID,
        --     tabPathAuction = tabPath
        -- })
        this.ResetData()
        return
    end

    ---- 最后一个出价玩家信息
    local bidInfo = this.allJoinBidInfo[#this.allJoinBidInfo]

    if not PlayerManager:isAlivePlayer(bidInfo.nPlayerID) then
        this.Cancle(-3)
        return
    end

    local sendAllData = {}
    sendAllData.nPlayerID = bidInfo.nPlayerID
    sendAllData.nSendPlayerID = this.sendPlayerID
    sendAllData.typeOprt = TypeOprt.TO_FinishAuction
    sendAllData.nGold = bidInfo.nGold
    sendAllData.json = this.sendData.json
    this.SendAll_GM_OperatorFinished(sendAllData)

    local sendPlayer = PlayerManager:getPlayer(this.sendPlayerID)
    local recvPlayer = PlayerManager:getPlayer(bidInfo.nPlayerID)

    ---- 已取消 ----  给参与竞拍未拍得的玩家退钱
    ---- for id, nGold in pairs(this.lastBidPlayers) do
    ----     if id ~= bidInfo.nPlayerID then
    ----         PlayerManager:getPlayer(id):setGold(nGold)
    ----     end
    ---- end
    ---- 给发起拍卖的玩家加钱
    sendPlayer:setGold(bidInfo.nGold)
    ----通知UI显示花费
    this.SendAll_GM_ShowGold({ nGold = bidInfo.nGold, nPlayerID = this.sendPlayerID })

    ---- 交换土地
    local tabPath = json.decode(this.sendData.json)
    local addPaths = {}
    for _, nPathID in pairs(tabPath) do
        local path = PathManager:getPathByID(nPathID)
        if not addPaths[path.m_typePath] then addPaths[path.m_typePath] = {} end
        -- sendPlayer:setMyPathDel(path)
        table.insert(addPaths[path.m_typePath], path)
    end
    for _, v in pairs(addPaths) do
        sendPlayer:setMyPathsGive(v, recvPlayer)
        -- recvPlayer:setMyPathAdd(path)
    end

    ----设置游戏记录
    ---- GMManager:showGold(sendPlayer, bidInfo.nGold)
    ---- GMManager:showGold(recvPlayer, -bidInfo.nGold)
    GameRecord:setGameRecord(
    TGameRecord_FinishAuction,
    bidInfo.nPlayerID,
    {
        nGold = GameRecord:encodeGameRecord(bidInfo.nGold),
        strPathsName = GameRecord:encodeGameRecord(this.GetPathsLocalize(tabPath))
    }
    )

    ---- 重置数据
    this.ResetData()
end

---- 取消拍卖
-----@param reason number 取消原因 -1: 有地被攻城 -2: 发起玩家死亡 -3: 竞拍玩家死亡
function Auction.Cancle(reason)
    CustomNetTables:SetTableValue("GameingTable", "auction", { remaining = 0, tabBidAuctionData = nil })
    local lastBid = this.allJoinBidInfo[#this.allJoinBidInfo]
    if lastBid and reason ~= -3 then
        local lastBidPlayer = PlayerManager:getPlayer(lastBid.nPlayerID)
        lastBidPlayer:setGold(lastBid.nGold)
        ----通知UI显示花费
        this.SendAll_GM_ShowGold({ nGold = lastBid.nGold, nPlayerID = lastBid.nPlayerID })
    end

    local sendAllData = {}
    sendAllData.nPlayerID = reason ---- 竞拍者-1 取消拍卖
    sendAllData.nSendPlayerID = this.sendPlayerID
    sendAllData.typeOprt = TypeOprt.TO_FinishAuction
    sendAllData.nGold = this.startGold
    sendAllData.json = this.sendData.json
    this.SendAll_GM_OperatorFinished(sendAllData)
    this.ResetData()
    this.StopTimers()
end

function Auction.GetPathsLocalize(arrPath)
    local str = "''"
    for i = 1, #arrPath do
        str = str .. " + " .. GameRecord:encodeLocalize("PathName_" .. arrPath[i])
        if i ~= #arrPath then
            str = str .. " + ', '"
        end
    end
    return str
end

function Auction.PrintSendData(title, data)
    if DEBUG then
        print("===============================================")
        print("4Auction->", title)
        print(data)
        print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
    end
end