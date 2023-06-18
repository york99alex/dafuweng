local OrderStatus = {}
function AddOrder(nPlayerID, tOrder)
    OrderStatus[nPlayerID] = tOrder
end
function RemoveOrder(nPlayerID)
    OrderStatus[nPlayerID] = nil
end
function GetPayOrder(nPlayerID)
    return OrderStatus[nPlayerID]
end
GetPayID = (function()
    local i = 0
    return function() i = i + 1 return i end
end)()

TIME_CHECK_ORDER = 3        --验证

function CheckRechargeComplete(iPlayerID)
    local player = PlayerResource:GetPlayer(iPlayerID)
    GameRules:GetGameModeEntity():Timer(3, function()
        coroutine.wrap(function()
            local times = 0
            while true do
                times = times + 1

                local tOrder = GetPayOrder(iPlayerID)
                if not tOrder then
                    return
                end

                local iStatusCode, sBody = Service:HTTPRequestSync("POST", ACTION_QUERY_ORDER_STATUS, {
                    order_id = tOrder.order_id
                    , server_key = Service:GetSendKey()
                }, 10)

                print("iStatusCode : " .. iStatusCode)
                print("sBody : " .. sBody)

                if iStatusCode == 200 then
                    local hBody = json.decode(sBody)
                    if hBody ~= nil and hBody.order_state ~= nil and hBody.order_state ~= "0" then
                        RemoveOrder(iPlayerID)
                        if hBody.order_state == "1" then
                            local nGold = hBody.item_count ~= nil and tonumber(hBody.item_count) or 0
                            Service.tPlayerServiceData[iPlayerID].nGold = nGold + Service.tPlayerServiceData[iPlayerID].nGold
                            Service:UpdateNetTables()
                        end
                        CustomGameEventManager:Send_ServerToPlayer(player, "Svc_PayFinished", {
                            nPlayerID = iPlayerID,
                            result = hBody.order_state,
                        })
                        return
                    end
                end

                if times >= 20 then
                    break
                end
                Sleep(TIME_CHECK_ORDER)
            end

            --超时
            RemoveOrder(iPlayerID)
            CustomGameEventManager:Send_ServerToPlayer(player, "Svc_PayFinished", {
                nPlayerID = iPlayerID,
                result = 2,
            })
        end)()
    end)
end

-- Event("get_recharge_url", function(tData)
--     local iPlayerID = tData.PlayerID
--     local type = tData.type or 1
--     local amount = tostring(tData.amount)
--     local steamid = tostring(PlayerResource:GetSteamID(iPlayerID))
--     local iStatusCode, sBody = Service:HTTPRequestSync("POST", ACTION_REQUEST_QRCODE, { amount = amount, steamid = steamid, type = type }, 10)
--     print("iStatusCode : " .. iStatusCode)
--     print("sBody : " .. sBody)
--     local url = ""
--     local order_id = -1
--     if iStatusCode == 200 then
--         local hBody = json.decode(sBody)
--         if hBody ~= nil and hBody.link ~= nil then
--             url = hBody.link
--             order_id = hBody.order_id
--             AddOrder(order_id)
--             CheckRechargeComplete(iPlayerID, order_id)
--         end
--     end
--     return { url = url, order_id = order_id }
-- end)
----支付请求
function aaa(_, tData)
    local iPlayerID = tData.PlayerID
    if not iPlayerID then
        return
    end
    local player = PlayerResource:GetPlayer(iPlayerID)
    tData.typeItem = tData.typeItem or 1

    ----有支付订单，返回当前订单
    local tOrder = GetPayOrder(iPlayerID)
    if nil ~= tOrder then
        ----同样的订单返回之前的
        if tOrder.nPay == tData.nPay
        and tOrder.typePay == tData.typePay
        and tOrder.typeItem == tData.typeItem
        then
            if tOrder.url then
                tData.url = tOrder.url
                tData.result = 0
                CustomGameEventManager:Send_ServerToPlayer(player, "Svc_PayRequest", tData)
            end
            return
        end
        ----取消之前订单
        bbb(_, tData)
    end

    ----验证订单
    tData.result = checkPayData(tData)
    if 0 ~= tData.result then
        CustomGameEventManager:Send_ServerToPlayer(player, "Svc_PayRequest", tData)
        return
    end

    ----向后台请求支付订单
    tOrder = {}
    tOrder.typePay = tData.typePay
    tOrder.typeItem = tData.typeItem
    tOrder.nPay = tData.nPay
    AddOrder(iPlayerID, tOrder)

    local function req()
        local tSendData = {
            steamid64 = tostring(PlayerResource:GetSteamID(iPlayerID)),
            item_type = tOrder.typeItem,
            pay_type = tOrder.typePay,
            pay_count = tOrder.nPay,
            server_key = Service:GetSendKey()
        }
        local iStatusCode, sBody = Service:HTTPRequestSync("POST", ACTION_REQUEST_QRCODE, tSendData, 10)
        local tOrderNow = GetPayOrder(iPlayerID)
        if tOrderNow then
            if tOrderNow == tOrder then
                if iStatusCode == 200 then
                    local hBody = json.decode(sBody)
                    if hBody ~= nil and 0 == hBody.result and hBody.link ~= nil then
                        -- tOrder = {
                        --     url = hBody.link,
                        --     order_id = hBody.order_id
                        -- }
                        -- AddOrder(iPlayerID, tOrder)
                        tOrderNow.url = hBody.link
                        tOrderNow.order_id = hBody.order_id
                        CheckRechargeComplete(iPlayerID)
                        tData.url = hBody.link
                        CustomGameEventManager:Send_ServerToPlayer(player, "Svc_PayRequest", tData)
                    end
                end
            else
                RemoveOrder(iPlayerID)
            end
        end
    end
    (coroutine.wrap(req))()
end
CustomGameEventManager:RegisterListener("Svc_PayRequest", aaa)

----取消支付
function bbb(_, tData)
    local tOrder = GetPayOrder(tData.PlayerID)
    if tOrder then
        Service:HTTPRequest("POST", ACTION_REQUEST_ORDER_CLOSE, {
            order_id = tOrder.order_id,
            server_key = Service:GetSendKey()
        }, 10, function(iStatusCode, sBody, a)
        end)
        RemoveOrder(tData.PlayerID)
    end
end
CustomGameEventManager:RegisterListener("Svc_PayClose", bbb)

function checkPayData(tData)
    if 'number' ~= type(tData.nPay) then
        return 1
    end
    if 1 > tData.nPay then
        return 2
    end
    if 0 ~= tData.nPay % 1 then
        return 3
    end
    return 0
end