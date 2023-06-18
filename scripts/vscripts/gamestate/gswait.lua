--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == GSWait then
    -----@class GSWait
    GSWait = class({
        m_timeWait = 0,
    }, nil, GS)
end
GSManager.m_tStates[GS_Wait] = GSWait

----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function GSWait:constructor(...)
    GSWait.__base__.constructor(self, ...)
end

----进入当前状态
function GSWait:start()
    GSWait.m_timeWait = 100
end
----当前状态的持续
function GSWait:update()
    GSWait.m_timeWait = GSWait.m_timeWait - 1
    if 0 >= GSWait.m_timeWait then
        ----wait超时，回到上个操作
        -- GMManager:setState(GSManager.m_typeStateLast)
        GSManager:setState(GSManager.m_typeStateLast)
    end
end
----结束当前状态
function GSWait:over()
    EventManager:fireEvent("Event_GSWait_Over")
end