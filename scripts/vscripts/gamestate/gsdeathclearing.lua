--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]] ----
if nil == GSDeathClearing then
    -----@class GSDeathClearing
    GSDeathClearing = class({}, nil, GS)
end
GSManager.m_tStates[GS_DeathClearing] = GSDeathClearing
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function GSDeathClearing:constructor(...)
    GSDeathClearing.__base__.constructor(self, ...)
end

----当前状态的持续
function GSDeathClearing:update()
    -- print("table.maxn(self.m_tabOprtCan)",table.maxn(self.m_tabOprtCan))
    -- if (table.maxn(self.m_tabOprtCan) == 0) then
    --     GSManager:setState(GS_End)
    -- end
    print("onState_DeathClearing")
    GMManager:updataTimeOprt()

    if 0 > GMManager.m_timeOprt then
        ----时间结束，自动操作
        GMManager:autoOprt()
    elseif 0 == GMManager.m_timeOprt then
        EmitGlobalSound("Custom.Time.Finish")
    elseif 0 < GMManager.m_timeOprt and 50 >= GMManager.m_timeOprt then
        if 0 == GMManager.m_timeOprt % 10 then
            EmitGlobalSound("Custom.Time.Urgent")
        end
    end
end
