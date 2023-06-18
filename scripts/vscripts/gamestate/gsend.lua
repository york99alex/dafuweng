--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == GSEnd then
    -----@class GSEnd
    GSEnd = class({
    }, nil, GS)
end
GSManager.m_tStates[GS_End] = GSEnd
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function GSEnd:constructor(...)
    GSEnd.__base__.constructor(self, ...)
end

----当前状态的持续
function GSEnd:update()
    print("onState_end")
    GameRules:SetGameWinner(0)
end