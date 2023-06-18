--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----游戏状态基类
if nil == GS then
    -----@class GS
    GS = class({
        m_typeState = nil, ----状态类型
    })
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function GS:constructor()
end

----进入当前状态
function GS:start()
end
----当前状态的持续
function GS:update()
end
----结束当前状态
function GS:over()
end