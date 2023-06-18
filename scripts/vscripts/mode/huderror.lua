-----@class HudError
if not HudError then
    HudError = {

    }
end

local this = HudError

-----@param nPlayerID number 发送到的玩家ID -1 所有人
-----@param strMessage string 消息文本
function HudError:FireDefaultError(nPlayerID, strMessage)
    local data = {}
    data.type = 0
    data.message = strMessage
    if nPlayerID == -1 then
        this:SendToAllPlayer(data)
    else
        data.nPlayerID = nPlayerID
        this:SendToPlayer(data)
    end
end
-----@param nPlayerID number 发送到的玩家ID -1 所有人
function HudError:FireLocalizeError(nPlayerID, val, tabKV)
    local data = {}
    data.type = 1
    data.message = this:EncodeLocalize(val, tabKV)
    if nPlayerID == -1 then
        this:SendToAllPlayer(data)
    else
        data.nPlayerID = nPlayerID
        this:SendToPlayer(data)
    end
end

function HudError:EncodeLocalize(val, tabKV)
    if tabKV then
        local strKV = ""
        for k, v in pairs(tabKV) do
            strKV = strKV .. string.format("str=str.replace(\"%s\",%s);", k, v)
        end
        return string.format([[(function () {
            var str = %s;
            %s
            return str
        })()]], "$.Localize('#" .. val .. "')", strKV)
    else
        return "$.Localize('#" .. val .. "')"
    end
end

function HudError:SendToPlayer(data)
    PlayerManager:sendMsg("GM_HUDErrorMessage", data, data.nPlayerID)
end

function HudError:SendToAllPlayer(data)
    PlayerManager:broadcastMsg("GM_HUDErrorMessage", data)
end