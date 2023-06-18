----游戏记录模块
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if not GameRecord then
    GameRecord = {}
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----设置游戏记录
function GameRecord:setGameRecord(typeRecord, nPlayerID, tabData)
    local nIndex = 0
    GameRecord.setGameRecord = function(self, typeRecord, nPlayerID, tabData)
        print("setGameRecord>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        local tab = {
            typeGameRecord = typeRecord,
            nPlayerID = nPlayerID,
            tabData = tabData,
            nTime = GameRules:GetDOTATime(false, true)
        }
        print("[GameRecord]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        print("nIndex:" .. nIndex);
        PrintTable(tab)
        print("[tab.tabData]>>>>>>>>>>>>>>>>>>>>")
        DeepPrint(tab.tabData)
        CustomNetTables:SetTableValue("GameingTable", "game_record_" .. nIndex, tab)
        nIndex = nIndex + 1
    end
    GameRecord:setGameRecord(typeRecord, nPlayerID, tabData)
end
function GameRecord:encodeGameRecord(val)
    return "GameRecord.__decode = " .. val
end
function GameRecord:encodeLocalize(val, tabKV)
    if tabKV then
        local strKV = ""
        for k, v in pairs(tabKV) do
            strKV = strKV .. string.format('str=str.replace("%s",%s);', k, v)
        end
        return string.format(
        [[(function () {
            var str = %s;
            %s
            return str
        })()]],
        "$.Localize('#" .. val .. "')",
        strKV
        )
    else
        return "$.Localize('#" .. val .. "')"
    end
end