--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]] ----
if nil == GSBegin then
    -----@class GSBegin
    GSBegin = class({}, nil, GS)
end
GSManager.m_tStates[GS_Begin] = GSBegin
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function GSBegin:constructor(...)
    GSBegin.__base__.constructor(self, ...)
end

----进入当前状态
function GSBegin:start()
    ----通知当前玩家回合开始
    -----@type Player
    local oPlayer = PlayerManager:getPlayer(GMManager.m_nOrderID)
    if nil == oPlayer or oPlayer.m_bDie then
        -- GMManager:setState(GS_Finished)
        GSManager:setState(GS_Finished)
        return
    end

    ----触发玩家回合开始事件
    local tabEvent = {
        oPlayer = oPlayer,
        bRoll = true
    }
    EventManager:fireEvent("Event_PlayerRoundBegin", tabEvent)

    if tabEvent.bRoll then
        ----广播roll点操作
        -- GMManager.m_tabOprtCan = {}
        local tabOprt = {}
        tabOprt.nPlayerID = GMManager.m_nOrderID
        tabOprt.typeOprt = TypeOprt.TO_Roll
        GMManager:broadcastOprt(tabOprt)
        ----进入等待操作阶段
        -- GMManager:setState(GS_WaitOperator)
        GSManager:setState(GS_WaitOperator)
        if oPlayer.m_bDisconnect then
            GMManager.m_timeOprt = TIME_OPERATOR_DISCONNECT
        else
            GMManager.m_timeOprt = TIME_OPERATOR
        end
    end
end

----当前状态的持续
function GSBegin:update()
    print("onState_begin")
end
