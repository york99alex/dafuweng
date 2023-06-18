--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == GSNone then
    -----@class GSNone
    GSNone = class({
    }, nil, GS)
end
GSManager.m_tStates[GS_None] = GSNone
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function GSNone:constructor(...)
    GSNone.__base__.constructor(self, ...)
end

----当前状态的持续
function GSNone:update()
    print("onState_none")
    if PlayerManager.m_bAllPlayerInit then
        GMManager.m_nOrderFirst = HeroSelection.m_PlayersSort[GMManager.m_nOrderFirstIndex]--设置首操作者的ID
        GMManager:setOrder(GMManager.m_nOrderFirst)
        GMManager.m_nRound = 0
        GSManager:setState(GS_ReadyStart)
    end
end