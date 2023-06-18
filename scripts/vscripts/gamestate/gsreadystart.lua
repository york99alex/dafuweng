--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == GSReadyStart then
    -----@class GSReadyStart
    GSReadyStart = class({
    }, nil, GS)
end
GSManager.m_tStates[GS_ReadyStart] = GSReadyStart

----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function GSReadyStart:constructor(...)
    GSReadyStart.__base__.constructor(self, ...)
end

----进入当前状态
function GSReadyStart:start()
    print('GSReadyStart:start')
    GMManager.m_timeOprt = 50
end

----当前状态的持续
function GSReadyStart:update()
    GMManager:updataTimeOprt()
    if 0 >= GMManager.m_timeOprt then
        ----准备进入begin
        local isBegin = GMManager:addRound()
        ----游戏开始
        EventManager:fireEvent("Event_GameStart")

        if isBegin then
            ----准备进入begin
            GMManager:setStateBeginReady()
        end

        ----2人直接开启终局决战
        if 2 >= PlayerManager:getAlivePlayerCount() then
            GMManager.m_bFinalBattle = true
            EventManager:fireEvent("Event_FinalBattle")
        end
    end
end