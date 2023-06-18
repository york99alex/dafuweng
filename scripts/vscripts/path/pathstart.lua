--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----起点路径
if nil == PathStart then
    PathStart = class({
        m_tPlayerGetCount = nil
    }, nil, Path)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function PathStart:constructor(e)
    self.__base__.constructor(self, e)
    self.m_tPlayerGetCount = {}
    ----监听玩家到起点发工资
    EventManager:register("Event_CurPathChange", PathStart.onEvent_CurPathChange, self, 0)
end

----玩家到起点
function PathStart:onEvent_CurPathChange(tabEvent)
    if self ~= tabEvent.player.m_pathCur or 0 >= GMManager.m_nRound then
        return
    end
    -----@type Player
    local player = tabEvent.player

    local nGet = self.m_tPlayerGetCount[player.m_nPlayerID]
    if not nGet then
        self.m_tPlayerGetCount[player.m_nPlayerID] = 0
        nGet = 0
    end

    local tEvent = {
        player = player,
        bIgnore = false,
    }
    EventManager:fireEvent("Event_WageGold", tEvent)
    if tEvent.bIgnore then
        return
    end

    local nGold = WAGE_GOLD - nGet * WAGE_GOLD_REDUCE
    player:setGold(nGold)
    GMManager:showGold(player, nGold)

    self.m_tPlayerGetCount[player.m_nPlayerID] = 1 + nGet
end