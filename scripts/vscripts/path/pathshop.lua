--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----商店
if nil == PathShop then
    -----@class PathShop
    PathShop = class({
    }, nil, Path)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function PathShop:constructor(e, ...)
    self.__base__.constructor(self, e, ...)
    EventManager:register("Event_JoinPath", self.onEvent_JoinPath, self, 0)
    EventManager:register("Event_LeavePath", self.onEvent_LeavePath, self, 0)
end

----触发路径
function PathShop:onPath(oPlayer, ...)
    self.__base__.onPath(self, oPlayer, ...)

    -- if GLOBAL_SHOP_ROUND <= GMManager.m_nRound then
    --     return
    -- end
    -- ----设置玩家购物状态
    -- if TP_SHOP_SIDE == self.m_typePath then
    --     oPlayer:setBuyState(TBuyItem_Side, 1)
    -- else
    --     oPlayer:setBuyState(TBuyItem_Secret, 1)
    -- end
    -- ----监听玩家离开购物区
    -- EventManager:register("Event_LeavePath", function(tEvent)
    --     if tEvent.player == oPlayer then
    --         if GLOBAL_SHOP_ROUND > GMManager.m_nRound then
    --             oPlayer:setBuyState(TBuyItem_None, 0)
    --         end
    --         return true
    --     end
    -- end)
end

----设置可购物
function PathShop:setCanBuy(oPlayer)
    ----设置玩家购物状态
    if TP_SHOP_SIDE == self.m_typePath then
        oPlayer:setBuyState(TBuyItem_Side, 1)
    else
        oPlayer:setBuyState(TBuyItem_Secret, 1)
    end
end
----玩家当前路径改变
function PathShop:onEvent_JoinPath(tEvent)
    if self ~= tEvent.player.m_pathCur then
        return
    end
    if self == tEvent.player.m_pathLast then
        return
    end
    if GLOBAL_SHOP_ROUND <= GMManager.m_nRound then
        return
    end
    self:setCanBuy(tEvent.player)
end
----玩家离开路径
function PathShop:onEvent_LeavePath(tEvent)
    if self ~= tEvent.path then
        return
    end
    if GLOBAL_SHOP_ROUND <= GMManager.m_nRound then
        return
    end
    tEvent.player:setBuyState(TBuyItem_None, 0)
end