--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == GSSupply then
    -----@class GSSupply
    GSSupply = class({
    }, nil, GS)
end
GSManager.m_tStates[GS_Supply] = GSSupply
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function GSSupply:constructor(...)
    GSSupply.__base__.constructor(self, ...)
end

----当前状态的持续
function GSSupply:update()
    GMManager:updataTimeOprt()

    if 0 > GMManager.m_timeOprt then
        ----时间结束，自动操作
        Supply:onTimeOver()
    elseif 0 == GMManager.m_timeOprt then
        EmitGlobalSound("Custom.Time.Finish")
    elseif 0 < GMManager.m_timeOprt and 50 >= GMManager.m_timeOprt then
        if 0 == GMManager.m_timeOprt % 10 then
            EmitGlobalSound("Custom.Time.Urgent")
        end
    end
end
----结束当前状态
function GSSupply:over()
    EventManager:fireEvent("Event_GSSupply_Over")
end