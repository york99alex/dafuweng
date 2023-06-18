--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----台阶路径
if nil == PathSteps then
    PathSteps = class({
        tSupplyCards = {},
    }, nil, Path)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function PathSteps:constructor(e)
    self.__base__.constructor(self, e)

    self.tSupplyCards = {}
    for k, v in pairs(KeyValues.CardKv) do
        if 'table' == type(v) and v.IsSupply and 0 ~= tonumber(v.IsSupply) then
            -- local level = tonumber(v.IsSupply)
            -- if not self.tSupplyCards[level] then self.tSupplyCards[level] = {} end
            table.insert(self.tSupplyCards, v)
        end
    end
end

----初始化空位数据
function PathSteps:initNilPos()
    self.m_tabPos = {
        {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * 55 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * -55 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * 55 + self.m_entity:GetForwardVector() * 75 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * -55 + self.m_entity:GetForwardVector() * 75 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * 55 - self.m_entity:GetForwardVector() * 75 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * -55 - self.m_entity:GetForwardVector() * 75 + self.m_entity:GetAbsOrigin()
        }
    }
end

----触发路径
function PathSteps:onPath(oPlayer, ...)
    self.__base__.onPath(self, oPlayer, ...)

    local tOprt = {}
    tOprt.nPlayerID = oPlayer.m_nPlayerID
    tOprt.typeOprt = TypeOprt.TO_RandomCard
    tOprt.typePath = self.m_typePath
    tOprt.nPathID = self.m_nID

    local cardData = self:randomCard(2)
    tOprt.json = json.encode(cardData)
    GMManager:sendOprt(tOprt)
end

function PathSteps:randomCard(count)
    local supplyCards = self.tSupplyCards
    local cards = {}

    local function random(i)
        local card = supplyCards[RandomInt(1, #supplyCards)]
        if i <= #supplyCards and exist(cards, card) then
            return random(i)
        end
        return card
    end

    for i = 1, count do
        local card = random(i)
        table.insert(cards, card)
    end

    return cards
end

function Process_TO_RandomCard(tData)
    local cardType = tData.nRequest
    local playerid = tData.PlayerID
    local player = PlayerManager:getPlayer(playerid)
    local tOprt = GMManager:checkOprt(tData, true)
    local cards = json.decode(tOprt.json)
    --1 手动选择 0 自动选择
    if cardType > 0 then
        local check = exist(cards, function(card)
            return card.CardType == cardType
        end)
        if not check then
            tOprt.nRequest = 0
        else
            tOprt.nRequest = 1
        end
    else
        tOprt.nRequest = 1
        if #cards > 0 then
            cardType = (cards[RandomInt(1, #cards)]).CardType
        end
    end
    if 1 == tOprt.nRequest then
        local card = CardFactory:create(cardType, playerid)
        CardFactory:create(cardType, playerid)
        if card then
            player:setCardAdd(card)
        end
    end
    PlayerManager:sendMsg("GM_OperatorFinished", tOprt, playerid)
end