if PrecacheItems then
    table.insert(PrecacheItems, "particles/generic_gameplay/rune_bounty_owner.vpcf")
    table.insert(PrecacheItems, "particles/generic_gameplay/rune_bounty_gold.vpcf")
    table.insert(PrecacheItems, "particles/econ/events/ti9/shovel_revealed_loot_variant_0_treasure.vpcf")
end

--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----宝藏路径
if nil == PathTreasure then
    PathTreasure = class({
    }, nil, Path)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function PathTreasure:constructor(e)
    self.__base__.constructor(self, e)
end

----触发路径
function PathTreasure:onPath(oPlayer, ...)
    self.__base__.onPath(self, oPlayer, ...)


    AMHC:AddAbilityAndSetLevel(oPlayer.m_eHero, "no_bar")

    ----特效
    local nPtclID = AMHC:CreateParticle("particles/econ/events/ti9/shovel_revealed_loot_variant_0_treasure.vpcf"
    , PATTACH_POINT, false, oPlayer.m_eHero, 3)
    ParticleManager:SetParticleControl(nPtclID, 0, oPlayer.m_eHero:GetOrigin() + Vector(0, 0, 150))
    ParticleManager:SetParticleControl(nPtclID, 1, oPlayer.m_eHero:GetOrigin() + Vector(0, 0, 150))
    ----ParticleManager:ReleaseParticleIndex(nPtclID)
    EmitGlobalSound("Custom.Treasure.Begin")
    EmitSoundOn("Custom.Treasure.Channel", oPlayer.m_eHero)
    Timers:CreateTimer(1, function()
        StopSoundOn("Custom.Treasure.Channel", oPlayer.m_eHero)
        EmitGlobalSound("Custom.Treasure.End")

        nPtclID = AMHC:CreateParticle("particles/generic_gameplay/rune_bounty_gold.vpcf"
        , PATTACH_POINT, false, oPlayer.m_eHero, 4)
        ParticleManager:SetParticleControl(nPtclID, 0, oPlayer.m_eHero:GetOrigin() + Vector(0, 0, 200))
        ParticleManager:SetParticleControl(nPtclID, 1, oPlayer.m_eHero:GetOrigin() + Vector(0, 0, 200))
        nPtclID = AMHC:CreateParticle("particles/generic_gameplay/rune_bounty_owner.vpcf"
        , PATTACH_POINT, false, oPlayer.m_eHero, 4, function()
            AMHC:RemoveAbilityAndModifier(oPlayer.m_eHero, "no_bar")
        end)
        ParticleManager:SetParticleControl(nPtclID, 0, oPlayer.m_eHero:GetOrigin() + Vector(0, 0, 200))
        ParticleManager:SetParticleControl(nPtclID, 1, oPlayer.m_eHero:GetOrigin() + Vector(0, 0, 200))
    end)

    ----广播密藏探索
    local tabOprt = {}
    tabOprt.nPlayerID = oPlayer.m_nPlayerID
    tabOprt.typeOprt = TypeOprt.TO_TREASURE
    tabOprt.typePath = self.m_typePath
    tabOprt.nPathID = self.m_nID

    local typeTreasure = RandomInt(1, TTreasure_END - 1)
    local data = PathTreasure:getTreasure(typeTreasure, oPlayer)

    tabOprt.json = json.encode(data)
    PlayerManager:broadcastMsg("GM_OperatorFinished", tabOprt)
end
---- 获得宝藏
---- @param typeTreasure number 宝藏类型
---- @param player Player 获得玩家
---- @return {type: number, treasure: string} json
function PathTreasure:getTreasure(typeTreasure, player)
    if typeTreasure < TTreasure_Gold
    or typeTreasure >= TTreasure_END
    or NIL(player) then
        return { type = -1, treasure = "" }
    end

    print('typeTreasure: ', typeTreasure)

    local json = {}
    json.type = typeTreasure
    if TTreasure_Gold == typeTreasure then
        local gold = PathTreasure:RandomGold()
        json.treasure = tostring(gold)

        player:setGold(gold)
        GMManager:showGold(player, gold)
        ----设置游戏记录
        GameRecord:setGameRecord(TGameRecord_Treasure, player.m_nPlayerID, {
            strTreasure = GameRecord:encodeGameRecord(gold)
        })
    elseif TTreasure_Item == typeTreasure then
        if 9 <= player.m_eHero:getItemCount() then
            return PathTreasure:getTreasure(TTreasure_Gold, player)
        end

        local itemName = PathTreasure:RandomAItem(1)
        json.treasure = itemName

        local item = player.m_eHero:AddItemByName(itemName)
        if item then
            item:SetPurchaseTime(0)
        end
        GameRecord:setGameRecord(TGameRecord_Treasure, player.m_nPlayerID, {
            strTreasure = GameRecord:encodeGameRecord(GameRecord:encodeLocalize("DOTA_Tooltip_ability_" .. itemName))
        })
    elseif TTreasure_Path == typeTreasure then
        local path = PathManager:RandomACanOccupyPath()
        if path == nil then
            return PathTreasure:getTreasure(TTreasure_Item, player)
        end

        json.treasure = tostring(path.m_nID)

        player:setMyPathAdd(path)

        GameRecord:setGameRecord(TGameRecord_Treasure, player.m_nPlayerID, {
            strTreasure = GameRecord:encodeGameRecord(GameRecord:encodeLocalize("Treasure_text_path") .. "+" .. GameRecord:encodeLocalize("PathName_" .. path.m_nID))
        })
    end

    player:setSumGold()

    return json
end
---- 随机金币 100-1000
function PathTreasure:RandomGold()
    return RandomInt(1, 10) * 100
end
---- 随机一件装备
---- @param nLevel number 物品等级 1 / 2 / 3
---- @return string 物品名
function PathTreasure:RandomAItem(nLevel)
    local supplyItems = Supply.m_tItems
    local items = supplyItems[nLevel]
    local item = items[math.random(#items)]
    return item.ItemName
end