require('Card/CardFactory')
----卡牌管理模块
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if not CardManager then
    CardManager = {
        EvtID = {
            Event_CardUseRequest = "Event_CardUseRequest"   ----请求使用卡牌
        }
        , m_tabCards = {}
        , m_tGetCardCount = {}     ----记录给玩家发牌的数量{playerid,{type,count}}
    }
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----初始化
function CardManager:init(bReload)
    if not bReload then
        local funCreate = CardFactory.create
        CardFactory.create = function(self, ...)
            local card = funCreate(CardFactory, ...)
            table.insert(CardManager.m_tabCards, card)
            return card
        end

        CardManager:registerEvent()
    end
end

----获取卡牌自增ID
function CardManager:getIncludeID()
    local nIncludeID = 0
    CardManager.getIncludeID = function()
        nIncludeID = nIncludeID + 1
        return nIncludeID
    end
    return CardManager:getIncludeID()
end

----获取卡牌用ID
function CardManager:getCardByID(nID)
    for _, v in pairs(CardManager.m_tabCards) do
        if nID == v.m_nID then
            return v
        end
    end
end

----获取一个玩家获取某卡牌的次数
function CardManager:getPlayerGetCardCount(nPlayerID, typeCard)
    ---- DeepPrintTable(self.m_tGetCardCount)
    if self.m_tGetCardCount[nPlayerID] then
        if self.m_tGetCardCount[nPlayerID][typeCard] then
            return self.m_tGetCardCount[nPlayerID][typeCard]
        end
    end
    return 0
end

----事件回调-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----注册事件
function CardManager:registerEvent()
    EventManager:register(CardManager.EvtID.Event_CardUseRequest, CardManager.onEvent_CardUseRequest, CardManager)
    CustomGameEventManager:RegisterListener("GM_CardInfo", CardManager.onEvent_GetCardInfo)
end
function CardManager:onEvent_GetCardInfo(tabData)
    print("onEvent_GetCardInfo")
    DeepPrint(tabData)
    local tab = KeyValues.CardKv;
    print("tab:===")
    DeepPrint(tab)
    local data = {
        nPlayerID = tabData.PlayerID,
        data = tab,
    }
    PlayerManager:sendMsg("GM_CardInfo", data, tabData.PlayerID);
end
----玩家请求使用卡牌
function CardManager:onEvent_CardUseRequest(tabEvent)
    print("onEvent_CardUseRequest")
    -- DeepPrint(tabEvent)
    if not tabEvent.nCardID or not tabEvent.PlayerID then
        return
    end
    local player = PlayerManager:getPlayer(tabEvent.PlayerID)
    ---@type Card
    local card = CardManager:getCardByID(tabEvent.nCardID)
    local nUseType = 0
    local nResult = (function()
        if card then
            if tabEvent.PlayerID == card.m_nOwnerID then
                ----判断施法目标
                if 0 < bit.band(TCardCast_Target, card.m_typeCast) then
                    if "number" == type(tabEvent.nTargetEntID)
                    and UF_SUCCESS == card:CastFilterResultTarget(EntIndexToHScript(tabEvent.nTargetEntID)) then
                        nUseType = TCardCast_Target
                        return 0
                    end
                end
                if 0 < bit.band(TCardCast_Pos, card.m_typeCast) then
                    if "number" == type(tabEvent.nPosX)
                    and "number" == type(tabEvent.nPosY)
                    and "number" == type(tabEvent.nPosZ)
                    and UF_SUCCESS == card:CastFilterResultLocation(Vector(tabEvent.nPosX, tabEvent.nPosY, tabEvent.nPosZ)) then
                        nUseType = TCardCast_Pos
                        return 0
                    end
                end
                if 0 < bit.band(TCardCast_Nil, card.m_typeCast) then
                    if UF_SUCCESS == card:CastFilterResult() then
                        nUseType = TCardCast_Nil
                        return 0
                    end
                end
                card:onCastError()
            end
            print("[onEvent_CardUseRequest]: card type is ", card.m_typeCard, "  card cast type is ", card.m_typeCast)
        end
        return 1
    end)()

    local tabData = {
        nPlayerID = tabEvent.PlayerID,
        nCardID = tabEvent.nCardID,
        nRequest = nResult,
        typeOprt = TypeOprt.TO_UseCard,
    }

    print("use card nResult=" .. nResult)

    if 0 == nResult then
        tabData["CardType"] = card.m_typeCard
        tabData["CardKind"] = card.m_typeKind
        tabData["ManaCost"] = card:GetManaCost()
        tabData["nTargetEntID"] = tabEvent.nTargetEntID
        tabData["nPosX"] = tabEvent.nPosX
        tabData["nPosY"] = tabEvent.nPosY
        tabData["nPosZ"] = tabEvent.nPosZ

        ----使用卡牌
        card:GetOwner():spendMana(card:GetManaCost())
        card:OnSpellStart()
        ----删除卡牌
        card:destory()

        ----广播全部玩家
        PlayerManager:broadcastMsg("GM_OperatorFinished", tabData)

        ----游戏记录
        local typeRecord = TGameRecord_UseCard
        local tabKV = {}
        tabKV["strCard"] = GameRecord:encodeLocalize("Card_" .. card.m_typeCard)
        if nUseType == TCardCast_Target then
            local eTarget = EntIndexToHScript(tabEvent.nTargetEntID)
            if IsValid(eTarget) then
                -- local playerTarget = PlayerManager:getPlayer(eTarget:GetPlayerOwnerID())
                -- if playerTarget then
                typeRecord = TGameRecord_UseCardTarget
                tabKV["strTarget"] = GameRecord:encodeLocalize(eTarget:GetUnitName())
                -- tabKV["strTarget"] = GameRecord:encodeLocalize(playerTarget.m_eHero:GetUnitName())
                -- end
            end
        end
        GameRecord:setGameRecord(TGameRecord_String, tabEvent.PlayerID, {
            strText = GameRecord:encodeGameRecord(GameRecord:encodeLocalize('GameRecord_' .. typeRecord, tabKV))
        })
    else
        ----失败，通知请求玩家
        player:sendMsg("GM_OperatorFinished", tabData)
    end

    print("GM_OperatorFinished=========================")
    PrintTable(tabData)
    print("GM_OperatorFinished=========================")
end