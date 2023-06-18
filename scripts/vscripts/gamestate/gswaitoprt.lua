--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == GSWaitOprt then
    -----@class GSWaitOprt
    GSWaitOprt = class({
    }, nil, GS)
end
GSManager.m_tStates[GS_WaitOperator] = GSWaitOprt

----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function GSWaitOprt:constructor(...)
    GSWaitOprt.__base__.constructor(self, ...)
end

----当前状态的持续
function GSWaitOprt:update()
    GMManager:updataTimeOprt()

    if 0 > GMManager.m_timeOprt then
        ----时间结束，自动操作
        GMManager:autoOprt()
    elseif 0 == GMManager.m_timeOprt then
        EmitGlobalSound("Custom.Time.Finish")
    elseif 0 < GMManager.m_timeOprt and 50 >= GMManager.m_timeOprt then
        if 0 == GMManager.m_timeOprt % 10 then
            EmitGlobalSound("Custom.Time.Urgent")

            ----自动操作roll点，如果有的话
            GMManager:autoOprt(TypeOprt.TO_Roll)
        end
        ---- elseif 50 == GMManager.m_timeOprt then
        ----     GMManager:autoOprt(TO_Roll)  ----自动操作roll点，如果有的话
    end
end