require('Card/Card')
for k, _ in pairs(KeyValues.CardKv) do
    require('Card/Cards/' .. k)
end
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----卡牌工厂
CardFactory = {
}

----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
function CardFactory:create(type, nPlayerID)
    ----获取卡牌信息
    local oClass
    local tCardInfo
    if KeyValues.CardKv then
        for k, v in pairs(KeyValues.CardKv) do
            if type == tonumber(v.CardType) then
                oClass = _G[k]
                tCardInfo = v
                break
            end
        end
    end
    if not oClass or not tCardInfo then
        return
    end

    ----对应类型的子类
    if oClass then
        return oClass(tCardInfo, nPlayerID)
    end
    return Card(tCardInfo, nPlayerID)
end