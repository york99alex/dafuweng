--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == GSFinished then
    -----@class GSFinished
    GSFinished = class({
    }, nil, GS)
end
GSManager.m_tStates[GS_Finished] = GSFinished
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function GSFinished:constructor(...)
    GSFinished.__base__.constructor(self, ...)
end

----当前状态的持续
function GSFinished:update()
    print("onState_finished")
    print("GMManager.m_nOrderID=" .. GMManager.m_nOrderID)
    local oPlayer = PlayerManager:getPlayer(GMManager.m_nOrderID)
    oPlayer:setRoundFinished(true)

    ----下个顺序玩家回合
    GMManager:setOrder(GMManager:getNextValidOrder(GMManager.m_nOrderID))
    GMManager.m_nBaoZi = 0

    ----准备进入begin
    GSManager:setState(GS_Begin, false)

    ----一个轮回
    oPlayer = PlayerManager:getPlayer(GMManager.m_nOrderID)
    local isBegin = true
    if GMManager.m_nOrderID == GMManager.m_nOrderFirst and oPlayer.m_bRoundFinished then
        isBegin = GMManager:addRound()
    end

    if isBegin then
        ----准备进入begin
        GMManager:setStateBeginReady()
    end
end