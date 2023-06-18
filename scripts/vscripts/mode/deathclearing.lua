-----@class DeathClearing 死亡清算 TO_DeathClearing
if not DeathClearing then
    DeathClearing = {
        -----@type table
        beforeGameState = {
            m_typeState = GS_None,
            m_nOrderID = -1,
            m_timeOprt = -1
        },
        mHooks = nil,
        ----- 正在清算的玩家
        mDCPlayers = {},

        resumeGameTimer = nil,
        EvtID = {
            ----- 触发死亡清算
            Event_TO_SendDeathClearing = "Event_TO_SendDeathClearing",
            ----- 死亡清算操作结束
            Event_TO_DeathClearing = "Event_TO_DeathClearing",
        }
    }
end

-----@type DeathClearing
local this = DeathClearing

function DeathClearing.init(bReload)
    this.Print("init")

    if not bReload then
        this.beforeGameState = nil
        EventManager:register(this.EvtID.Event_TO_SendDeathClearing, this.ProcessSendDC, nil, 100)
        EventManager:register(this.EvtID.Event_TO_DeathClearing, this.ProcessDC, nil, 101)
    end
end

----- 玩家发起亡国清算
function DeathClearing.ProcessSendDC(data)
    -----@type Player
    local player = PlayerManager:getPlayer(data.nPlayerID)
    this.Print("ProcessSendDC: plaeyr id " .. player.m_nPlayerID .. ' gold is ' .. player:GetGold())

    -- if data.nPlayerID == GMManager.m_nOrderID and player:GetGold() < 0 and GMManager.m_typeState == GS_Move then
    --     EventManager:register("Event_MoveEnd", function(data)
    --         if data.entity == player.m_eHero and player:GetGold() < 0 and not player.m_bDie then
    --             if not exist(this.mDCPlayers, player.m_nPlayerID) then
    --                 this.StartDC(player.m_nPlayerID)
    --             end
    --         end
    --         return true
    --     end)
    --     return
    -- end
    if player:GetGold() < 0 and
    (GMManager.m_typeState == GS_Move
    or GMManager.m_typeState == GS_wait
    or GMManager.m_typeState == GS_Supply) then
        local function waitDC()
            if player:GetGold() < 0 and not player.m_bDie then
                if not exist(this.mDCPlayers, player.m_nPlayerID) then
                    this.StartDC(player.m_nPlayerID)
                end
            end
            return true
        end

        local EvtID = ""
        if GMManager.m_typeState == GS_Move then
            EvtID = "Event_GSMove_Over"
        elseif GMManager.m_typeState == GS_wait then
            EvtID = "Event_GSWait_Over"
        elseif GMManager.m_typeState == GS_Supply then
            EvtID = "Event_GSSupply_Over"
        end
        EventManager:register(EvtID, waitDC)
        return
    end
    if not exist(this.mDCPlayers, player.m_nPlayerID) and player:GetGold() < 0 then
        this.StartDC(player.m_nPlayerID)
    else
        this.ProcessDC({ PlayerID = data.nPlayerID, nPlayerID = data.nPlayerID, typeOprt = TypeOprt.TO_DeathClearing, nRequest = 0 })
    end
end

function DeathClearing.WaitMoveEndDC()

    EventManager:fireEvent(DeathClearing.EvtID.Event_TO_SendDeathClearing, { nPlayerID = self.m_nPlayerID })
end

function DeathClearing.StartDC(nPlayerID)

    if this.resumeGameTimer then
        Timers:RemoveTimer(this.resumeGameTimer)
    end
    if this.beforeGameState == nil then
        this.beforeGameState = {
            m_typeState = GMManager.m_typeState,
            m_nOrderID = GMManager.m_nOrderID,
            m_timeOprt = GMManager.m_timeOprt,
            m_tabOprtSend = copy(GMManager.m_tabOprtSend),
            m_tabOprtBroadcast = copy(GMManager.m_tabOprtBroadcast)
        }
    end

    table.insert(this.mDCPlayers, nPlayerID)

    GSManager:setState(GS_DeathClearing)
    GMManager:setOrder(nPlayerID)
    this.HookGMMgr()
    ---- 设置亡国清算状态，暂停其他操作
    -- this.mHooks["setState"](GMManager, GS_DeathClearing)
    -- GMManager:setOrder(nPlayerID)
    GMManager.m_timeOprt = TIME_OPERATOR * 2
    -- for i, v in pairs(GMManager.m_tabOprtCan) do
    --     if  then
    --         table.remove(GMManager.m_tabOprtCan, i)
    --     end
    -- end
    print('debug dc remove oprt1')
    PrintTable(GMManager.m_tabOprtCan)
    removeAll(GMManager.m_tabOprtCan, function(v)
        return TypeOprt.TO_DeathClearing ~= v.typeOprt
    end)
    print('debug dc remove oprt2')
    PrintTable(GMManager.m_tabOprtCan)
    removeAll(GMManager.m_tabOprtSend, function(v)
        return TypeOprt.TO_DeathClearing ~= v.typeOprt
    end)
    removeAll(GMManager.m_tabOprtBroadcast, function(v)
        return TypeOprt.TO_DeathClearing ~= v.typeOprt
    end)


    local sendAllData = {
        nPlayerID = nPlayerID,
        typeOprt = TypeOprt.TO_DeathClearing
    }
    this.mHooks["broadcastOprt"](GMManager, sendAllData)
    this.Print("sendAllData: TO_DeathClearing", sendAllData)

    local player = PlayerManager:getPlayer(nPlayerID)
    this.PlayerDC(player, true)
end

function DeathClearing.ProcessDC(data)
    this.Print("Process_DeathClearing", data)

    if this.beforeGameState == nil then
        return
    end

    local checkOP = GMManager:checkOprt(data, true)
    if checkOP ~= false then
        local player = PlayerManager:getPlayer(data.nPlayerID)
        remove(this.mDCPlayers, data.nPlayerID)

        local playerDie = false
        ---- 判断玩家破产
        if player:GetGold() < 0 then
            this.PlayerDeath(player)
            playerDie = true
        end

        if #this.mDCPlayers == 0 then
            this.UnhookGMMgr()
            ---- 还原之前游戏状态
            GMManager:setOrder(this.beforeGameState.m_nOrderID)
            GMManager.m_timeOprt = (this.beforeGameState.m_timeOprt / 10) * 10 + 1
            if playerDie and this.beforeGameState.m_nOrderID == data.nPlayerID then
                GSManager:setState(GS_Finished)
            else
                print('debug DC: typeState is ', this.beforeGameState.m_typeState)
                GSManager:setState(this.beforeGameState.m_typeState)
            end

            ---- 恢复之前操作
            this.resumeGameTimer = Timers:CreateTimer({
                endTime = 0,
                callback = function()
                    this.Print("resume m_tabOprtBroadcast:", this.beforeGameState.m_tabOprtBroadcast)
                    this.Print("resume m_tabOprtSend:", this.beforeGameState.m_tabOprtSend)
                    for i = 1, #this.beforeGameState.m_tabOprtBroadcast do
                        local tabOprt = this.beforeGameState.m_tabOprtBroadcast[i]
                        if tabOprt.nPlayerID == data.nPlayerID and playerDie == false
                        or tabOprt.nPlayerID ~= data.nPlayerID then
                            this.Print("GMManager.broadcastOprt")
                            GMManager:broadcastOprt(tabOprt)
                        end
                    end
                    for i = 1, #this.beforeGameState.m_tabOprtSend do
                        local tabOprt = this.beforeGameState.m_tabOprtSend[i]
                        if tabOprt.nPlayerID == data.nPlayerID and playerDie == false
                        or tabOprt.nPlayerID ~= data.nPlayerID then
                            this.Print("GMManager.sendOprt")
                            GMManager:sendOprt(tabOprt)
                        end
                    end
                    this.Print("resume end")
                    this.beforeGameState = nil
                end
            })
        else
            GMManager:setOrder(this.mDCPlayers[1])
        end
        PlayerManager:broadcastMsg("GM_OperatorFinished", { nPlayerID = data.nPlayerID, typeOprt = TypeOprt.TO_DeathClearing })
        this.PlayerDC(player, false)
    end
end

function DeathClearing.HookGMMgr()
    if this.mHooks == nil then
        this.mHooks = {}
        this.mHooks["setState"] = HOOK(GSManager, GSManager.setState, this.GSSetState)
        this.mHooks["realSetState"] = HOOK(GSManager, GSManager.realSetState, this.GSSetState)
        this.mHooks["replaceState"] = HOOK(GSManager, GSManager.replaceState, this.GSSetState)
        this.mHooks["sendOprt"] = HOOK(GMManager, GMManager.sendOprt, this.GMMgrSendOprt)
        this.mHooks["broadcastOprt"] = HOOK(GMManager, GMManager.broadcastOprt, this.GMMgrBroadcastOprt)
    end
end

function DeathClearing.UnhookGMMgr()
    UNHOOK(GSManager, GSManager.setState)
    UNHOOK(GSManager, GSManager.realSetState)
    UNHOOK(GSManager, GSManager.replaceState)
    UNHOOK(GMManager, GMManager.sendOprt)
    UNHOOK(GMManager, GMManager.broadcastOprt)
    this.mHooks = nil
end

-----发送操作在死亡时
function DeathClearing.SendOprtOnDC(tabOprt, bIsBroadcast)
    this.Print('DeathClearing.SendOprtOnDC: bIsBroadcast is ' .. tostring(bIsBroadcast), tabOprt)
    if bIsBroadcast then
        table.insert(this.beforeGameState.m_tabOprtBroadcast, tabOprt)
    else
        table.insert(this.beforeGameState.m_tabOprtSend, tabOprt)
    end
end
-----设置游戏状态在死亡时
function DeathClearing.GSSetState(_GS, state)
    -- if state == GS_Begin then
    --     print(debug.traceback("Stack trace: DeathClearing  GSSetState GS_Begin!"))
    -- end
    this.Print("DeathClearing:GMMgrSetState: ", state)
    if GS_Wait == state or GS_DeathClearing == state then
        return
    end
    this.beforeGameState.m_typeState = state
end
function DeathClearing:GMMgrSendOprt(tabOprt)
    this.SendOprtOnDC(tabOprt, false)
end
function DeathClearing:GMMgrBroadcastOprt(tabOprt)
    this.SendOprtOnDC(tabOprt, true)
end

----- 检查剩余财产 RemainingProperty
function DeathClearing.CheckRP()
end

----设置玩家死亡清算状态
----@param player Player
function DeathClearing.PlayerDC(player, state)
    if player.m_bDeathClearing ~= state then
        player.m_bDeathClearing = state
        player:setNetTableInfo()
    end
end

----- 玩家死亡
-----@param player Player
function DeathClearing.PlayerDeath(player)
    this.Print("PlayerDeath", player.m_nPlayerID)
    if GMManager.m_nOrderFirst == player.m_nPlayerID then
        GMManager.m_nOrderFirst = GMManager:getNextValidOrder(player.m_nPlayerID)
    end

    EventManager:fireEvent("Event_PlayerDie", { player = player })
end

function DeathClearing.Print(title, data)
    if DEBUG then
        print("DeathClearing ==============================")
        print("5[[DeathClearing->", title, "]]:")
        PrintTable(data)
        print("DeathClearing over==========================")
    end
end