require('GameState/GS')
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----游戏状态管理
if nil == GSManager then
    -----@class GSManager
    GSManager = {
        m_tStates = {}, ----全部状态对象
        m_typeStateCur = GS_None, ----当前状态
        m_typeStateLast = nil, ----上个状态
    }
end

require('GameState/GSNone')
require('GameState/GSBegin')
require('GameState/GSWait')
require('GameState/GSWaitOprt')
require('GameState/GSMove')
require('GameState/GSFinished')
require('GameState/GSDeathClearing')
require('GameState/GSSupply')
require('GameState/GSReadyStart')
require('GameState/GSEnd')

----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function GSManager:init(bReload)
end

-- 真实の设置状态(源方法用于HOOK)
function GSManager:realSetState(typeState)
    if typeState == GSManager.m_typeStateCur then
        return
    end

    local oState = GSManager:getStateObj()
    if oState then
        oState:over()
    end

    self:replaceState(typeState)
end

---- 切换状态
function GSManager:replaceState(typeState)

    -- print(debug.traceback("Stack trace: replaceState " .. typeState))
    GSManager.m_typeStateLast = GSManager.m_typeStateCur
    GSManager.m_typeStateCur = typeState

    GMManager:setState(typeState)

    local oState = GSManager:getStateObj()
    if oState then
        oState:start()
    end
end

-- 真实の设置状态
local function _realSetState(typeState)
    GSManager:realSetState(typeState)
end

-- 暂停设置状态
function GSManager:suspendSetState()
    if self.setThread then
        coroutine.resume(self.setThread, true)
    end
end

-- 让出当前状态
function GSManager:yieldState()
    local co
    if self.setThread then
        co = self.setThread
        self.setThread = nil
    else
        local state = self.m_typeStateCur
        co = co_create(function()
            _realSetState(state)
        end)
    end
    return co
end

---- 恢复挂起的状态
function GSManager:resumeState(co)
    if co and type(co) == "thread" then
        coroutine.resume(co)
    end
    -- if self.yieldThread then
    --     coroutine.resume(self.yieldThread)
    --     -- print(debug.traceback("Stack trace: replaceState " .. typeState))
    --     self.yieldThread = nil
    -- end
end

---- 开启待设置的状态
function GSManager:startState(isSuspend)
    if self.setThread then
        coroutine.resume(self.setThread)
        self.setThread = nil
    end
end

-- 设置当前状态
----@param immediately bool 是否立即开启
function GSManager:setState(typeState, immediately)
    self.setThread = co_create(function(suspend)
        suspend = suspend or false
        if suspend then
            coroutine.yield()
            coroutine.yield()
        end
        _realSetState(typeState)
    end)
    if immediately or nil == immediately then
        self:startState()
        self.setThread = nil
    end
end

----获取当前状态对象
function GSManager:getStateObj()
    return GSManager.m_tStates[GSManager.m_typeStateCur]
end

----持续触发当前状态
function GSManager:update()
    local oState = GSManager:getStateObj()
    if oState then
        oState:update()
    end
end