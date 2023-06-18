--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == GSMove then
    -----@class GSMove
    GSMove = class({
    }, nil, GS)
end
GSManager.m_tStates[GS_Move] = GSMove

----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function GSMove:constructor(...)
    GSMove.__base__.constructor(self, ...)
end

----当前状态的持续
function GSMove:update()
end

----结束当前状态
function GSMove:over()
    EventManager:fireEvent("Event_GSMove_Over")
end