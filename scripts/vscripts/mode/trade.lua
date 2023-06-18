-------------------------------------------------------------------------------------------------
----- 交易模块
-------------------------------------------------------------------------------------------------
-----@class Trade
if not Trade then
    Trade = {
        -----@private
        -----@type table 等待交易数据
        tabWaitTrade = {},
        EvtID = {
            Event_TO_TRADE = "Event_TO_TRADE",
            Event_TO_TRADE_BE = "Event_TO_TRADE_BE",
        }
    }
end

local this = Trade

function Trade.init(bReload)
    if not bReload then
        this.tabWaitTrade = {}
        this.SetNetTableValue()
        EventManager:register(this.EvtID.Event_TO_TRADE, this.ProcessTrade)
        EventManager:register(this.EvtID.Event_TO_TRADE_BE, this.ProcessTradeBe)
    end
end

function Trade.ProcessTrade(data)
    if 1 == GMManager.m_bNoSwap then
        return
    end

    data["nPlayerID"] = data.PlayerID
    -----@type Player
    local oPlayerTrade = PlayerManager:getPlayer(tonumber(data.nPlayerID))
    -----@type Player
    local oPlayerTradeBe = PlayerManager:getPlayer(tonumber(data.nPlayerIDTradeBe))

    local nRequest = 1
    if not (PlayerManager:isAlivePlayer(data.nPlayerID) and PlayerManager:isAlivePlayer(data.nPlayerIDTradeBe)) then
        nRequest = 11 ---- 交易玩家死亡
    elseif oPlayerTradeBe:isPlayerMuteTrade(data.nPlayerID) then
        nRequest = 10   ---- 对方屏蔽你的交易
    elseif data.nPlayerID ~= data.nPlayerIDTrade or not PlayerManager:isAlivePlayer(data.nPlayerID) or not PlayerManager:isAlivePlayer(data.nPlayerIDTrade) then
        nRequest = 9    ----操作玩家不是发起交易玩家
    elseif 0 < bit.band(oPlayerTrade.m_typeState, PS_Trading) or 0 < bit.band(oPlayerTradeBe.m_typeState, PS_Trading) then
        nRequest = 8        ----玩家正在交易中
    else
        nRequest = this.CheckTradeData(data.nPlayerID, data.nPlayerIDTradeBe, json.decode(data.json), nRequest, TypePathState.None)
    end

    data["nRequest"] = nRequest
    if 1 == nRequest then
        this.SetAuctionPathState(json.decode(data.json), TypePathState.Trade)

        ----发送被交易操作给被交易玩家
        local tabOprt = {}
        tabOprt.nPlayerID = data.nPlayerIDTradeBe
        tabOprt.nPlayerIDTrade = data.nPlayerIDTrade
        tabOprt.nPlayerIDTradeBe = data.nPlayerIDTradeBe
        tabOprt.typeOprt = TypeOprt.TO_TRADE_BE
        tabOprt.json = data.json
        this.Send_GM_Operator(tabOprt)

        ---- 保持数据并同步网表
        local tradeData = {}
        tradeData["nPIDTrade"] = data.nPlayerIDTrade
        tradeData["nPIDTradeBe"] = data.nPlayerIDTradeBe
        tradeData["tabDataTrade"] = data
        tradeData["tabDataTradeBe"] = tabOprt
        table.insert(this.tabWaitTrade, tradeData)
        this.SetNetTableValue()

        ----设置双方为交易中
        oPlayerTrade:setState(PS_Trading)
        oPlayerTradeBe:setState(PS_Trading)
        oPlayerTrade:setNetTableInfo()
        oPlayerTradeBe:setNetTableInfo()
    end
    print("jy request ===================" .. data["nRequest"])

    ----回包
    this.Send_GM_OperatorFinished(data)
end
-----@param data table
function Trade.ProcessTradeBe(data)
    local tempTab = FIND(this.tabWaitTrade, function(v)
        local oprt = v.tabDataTradeBe
        return data.typeOprt == oprt.typeOprt
        and (data.PlayerID == oprt.nPlayerID or (data.PlayerID == oprt.nPlayerIDTrade and 0 == data.nRequest))
    end).value
    if tempTab == nil then
        this.PrintSendData("ProcessTradeBe data oprt is nil!!!!!!!!!!!!!!!!!!!!!!")
        return
    end

    local tabOprt = tempTab.tabDataTradeBe
    tabOprt.nRequest = data.nRequest

    -----@type Player
    local oPlayer = PlayerManager:getPlayer(tabOprt.nPlayerID)
    -----@type Player
    local oPlayerTrade = PlayerManager:getPlayer(tabOprt.nPlayerIDTrade)
    local tabJsonData = json.decode(tabOprt.json)

    if not PlayerManager:isAlivePlayer(tabOprt.nPlayerID) or not PlayerManager:isAlivePlayer(tabOprt.nPlayerIDTrade) then
        tabOprt.nRequest = 9    ----操作玩家不是发起交易玩家
    end

    tabOprt.nRequest = this.CheckTradeData(tabOprt.nPlayerIDTrade, tabOprt.nPlayerID, tabJsonData, data.nRequest, TypePathState.Trade)
    print("tabOprt.nRequest=" .. tabOprt.nRequest)
    ----交换交易品
    if 1 == tabOprt.nRequest then
        local tabPath = {}
        for strID, v in pairs(tabJsonData) do
            local oOut, oIn;
            if strID == tostring(tabOprt.nPlayerID) then
                oOut = oPlayer
                oIn = oPlayerTrade
            else
                oOut = oPlayerTrade
                oIn = oPlayer
            end

            local nGold = v["nGold"]
            if nGold then
                oOut:setGold(-nGold)
                GMManager:showGold(oOut, -nGold)
                oIn:setGold(nGold)
                GMManager:showGold(oIn, nGold)
            end


            local tab1 = v["arrPath"]
            local tab2 = {}
            for _, nPathID in pairs(tab1) do
                local path = PathManager:getPathByID(nPathID)
                if not tab2[path.m_typePath] then
                    tab2[path.m_typePath] = {}
                end
                ---- oOut:setMyPathDel(path)
                table.insert(tab2[path.m_typePath], path)
            end
            tabPath[oIn] = tab2
        end

        ----交换领地
        for oIn, tab in pairs(tabPath) do
            local oOut = oPlayerTrade
            if oIn == oOut then
                oOut = oPlayer
            end
            for typePath, tab2 in pairs(tab) do
                oOut:setMyPathsGive(tab2, oIn)
                ---- oIn:setMyPathAdd(path)
                ---- oOut:setMyPathDel(path)
            end
        end

        ----广播全部玩家
        this.SendAll_GM_OperatorFinished(tabOprt)

        ----设置游戏记录
        -- GameRecord:setGameRecord(TGameRecord_Trede, tabOprt.nPlayerIDTrade, {
        --     nPlayerIDTradeBe = GameRecord:encodeGameRecord(tabOprt.nPlayerIDTradeBe)
        -- })
    elseif 0 == tabOprt.nRequest then
        ----拒绝交易,通知交易双方
        oPlayer:sendMsg("GM_OperatorFinished", tabOprt)
        oPlayerTrade:sendMsg("GM_OperatorFinished", tabOprt)
    elseif 7 == tabOprt.nRequest then
        ----操作错误
        oPlayer:sendMsg("GM_OperatorFinished", tabOprt)
        return
    else
        oPlayer:sendMsg("GM_OperatorFinished", tabOprt)
        oPlayerTrade:sendMsg("GM_OperatorFinished", tabOprt)
    end

    ----玩家交易状态解除
    oPlayer:setState(-PS_Trading)
    oPlayerTrade:setState(-PS_Trading)

    this.SetAuctionPathState(tabJsonData, TypePathState.None)
    ----移除操作
    remove(this.tabWaitTrade, function(v)
        return tempTab == v
    end)
    this.SetNetTableValue()
end
----  0,1: 数据无误
function Trade.CheckTradeData(PIDTrade, PIDTradeBe, tabJsonData, nRequest, pathState)
    if 1 == nRequest then
        ----交易，验证
        if tabJsonData == nil or "table" ~= type(tabJsonData) then
            return -1
        end
        for nPlayerID, tab in pairs(tabJsonData) do
            -----@type Player
            local player = PlayerManager:getPlayer(tonumber(nPlayerID))
            if nil == player then
                return 2
            end

            if tab["nGold"] > 0 and player:GetGold() < tab["nGold"] or tab["nGold"] < 0 then
                return 3
            end

            local arrPath = tab["arrPath"]
            if nil ~= arrPath and 0 < #arrPath then
                local hasBZPaths = {}
                for k, pathID in pairs(arrPath) do
                    if not player:isHasPath(pathID) then
                        return 5 ---- 包含未拥有路径
                    end
                    local path = PathManager:getPathByID(pathID)
                    if path.m_typeState ~= pathState then
                        return 101 ---- 领地暂不可交易
                    end
                    if path.m_tabENPC and 0 < #path.m_tabENPC then
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
                            return 6 ---- 有连地错误
                        end
                    end
                end
            end
        end
    end
    return nRequest
end

function Trade.SetAuctionPathState(tabJsonData, typeState)
    for nPlayerID, tab in pairs(tabJsonData) do
        local arrPath = tab["arrPath"]
        for k, pathID in pairs(arrPath) do
            local path = PathManager:getPathByID(pathID)
            path:setState(typeState)
        end
    end
end

function Trade.SetNetTableValue()
    this.PrintSendData("SetNetTableValue", this.tabWaitTrade)
    CustomNetTables:SetTableValue("GameingTable", "trade", { tabWaitTrade = this.tabWaitTrade })
end

function Trade.Send_GM_Operator(data)
    this.PrintSendData("Send_GM_Operator", data)
    PlayerManager:sendMsg("GM_Operator", data, data.nPlayerID)
end

function Trade.Send_GM_OperatorFinished(data)
    this.PrintSendData("GM_OperatorFinished", data)
    PlayerManager:sendMsg("GM_OperatorFinished", data, data.nPlayerID)
end

function Trade.SendAll_GM_OperatorFinished(data)
    this.PrintSendData("SendAll_GM_OperatorFinished", data)
    PlayerManager:broadcastMsg("GM_OperatorFinished", data)
end

function Trade.PrintSendData(title, data)
    if DEBUG then
        print("===============================================")
        print("8Trade->", title)
        print(data)
        print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
    end
end