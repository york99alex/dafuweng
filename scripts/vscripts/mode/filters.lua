-- Global name: Filters
if Filters == nil then
    Filters = {}
end
local public = Filters

function public:AbilityTuningValueFilter(params)
    return true
end

function public:BountyRunePickupFilter(params)
    return true
end

function public:DamageFilter(params)
    --[[d        damage: 37.613315582275
		damagetype_const: 1
		entindex_attacker_const: 371
		entindex_victim_const: 371
    ]]
    local tEvent = copy(params)
    ----触发攻击事件
    EventManager:fireEvent("Event_Atk", tEvent)
    ----触发被攻击事件
    EventManager:fireEvent("Event_BeAtk", tEvent)
    if tEvent.bIgnore then
        return false    ----忽略订单
    end
    ----触发受伤事件
    EventManager:fireEvent("Event_OnDamage", tEvent)
    params.damage = tEvent.damage
    return true
end

function public:ExecuteOrderFilter(params)
    PrintTable(params)
    --[[ 命令常量
		DOTA_UNIT_ORDER_NONE = 0
		DOTA_UNIT_ORDER_MOVE_TO_POSITION = 1
		DOTA_UNIT_ORDER_MOVE_TO_TARGET = 2
		DOTA_UNIT_ORDER_ATTACK_MOVE = 3
		DOTA_UNIT_ORDER_ATTACK_TARGET = 4
		DOTA_UNIT_ORDER_CAST_POSITION = 5
		DOTA_UNIT_ORDER_CAST_TARGET = 6
		DOTA_UNIT_ORDER_CAST_TARGET_TREE = 7
		DOTA_UNIT_ORDER_CAST_NO_TARGET = 8
		DOTA_UNIT_ORDER_CAST_TOGGLE = 9
		DOTA_UNIT_ORDER_HOLD_POSITION = 10
		DOTA_UNIT_ORDER_TRAIN_ABILITY = 11
		DOTA_UNIT_ORDER_DROP_ITEM = 12
		DOTA_UNIT_ORDER_GIVE_ITEM = 13
		DOTA_UNIT_ORDER_PICKUP_ITEM = 14
		DOTA_UNIT_ORDER_PICKUP_RUNE = 15
		DOTA_UNIT_ORDER_PURCHASE_ITEM = 16
		DOTA_UNIT_ORDER_SELL_ITEM = 17
		DOTA_UNIT_ORDER_DISASSEMBLE_ITEM = 18
		DOTA_UNIT_ORDER_MOVE_ITEM = 19
		DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO = 20
		DOTA_UNIT_ORDER_STOP = 21
		DOTA_UNIT_ORDER_TAUNT = 22
		DOTA_UNIT_ORDER_BUYBACK = 23
		DOTA_UNIT_ORDER_GLYPH = 24
		DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH = 25
		DOTA_UNIT_ORDER_CAST_RUNE = 26
		DOTA_UNIT_ORDER_PING_ABILITY = 27
		DOTA_UNIT_ORDER_MOVE_TO_DIRECTION = 28
		DOTA_UNIT_ORDER_PATROL = 29
		DOTA_UNIT_ORDER_RADAR = 31
		DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION = 30
		DOTA_UNIT_ORDER_SET_ITEM_COMBINE_LOCK = 32
		DOTA_UNIT_ORDER_CONTINUE = 33
		DOTA_UNIT_ORDER_VECTOR_TARGET_CANCELED = 34
		DOTA_UNIT_ORDER_CAST_RIVER_PAINT = 35
		DOTA_UNIT_ORDER_PREGAME_ADJUST_ITEM_ASSIGNMENT = 36
	]]
    ----
    ---- DeepPrintTable(params)
    local orderType = params.order_type
    local playerID = params.issuer_player_id_const

    if params.units == nil or params.units["0"] == nil then
        return
    end
    local caster = EntIndexToHScript(params.units["0"])

    if
    -- orderType == DOTA_UNIT_ORDER_MOVE_TO_POSITION or
    orderType == DOTA_UNIT_ORDER_MOVE_TO_TARGET
    or orderType == DOTA_UNIT_ORDER_DROP_ITEM
    or orderType == DOTA_UNIT_ORDER_PICKUP_ITEM
    or orderType == DOTA_UNIT_ORDER_PICKUP_RUNE
    or orderType == DOTA_UNIT_ORDER_HOLD_POSITION
    or orderType == DOTA_UNIT_ORDER_ATTACK_MOVE
    or orderType == DOTA_UNIT_ORDER_PATROL
    or orderType == DOTA_UNIT_ORDER_ATTACK_TARGET
    or orderType == DOTA_UNIT_ORDER_MOVE_TO_DIRECTION
    then
        ----过滤玩家攻击，移动，脱捡装备，吃符，停止订单
        return TESTFREE
    elseif orderType == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
        ----玩家移动
        EventManager:fireEvent("Event_OrderMoveToPos", params)
        return TESTFREE
    elseif orderType == DOTA_UNIT_ORDER_PURCHASE_ITEM then
        ----购买物品
        EventManager:fireEvent("Event_ItemBuy", params)
    elseif orderType == DOTA_UNIT_ORDER_SELL_ITEM then
        ----出售物品
        EventManager:fireEvent("Event_ItemSell", params)
    elseif orderType == DOTA_UNIT_ORDER_DISASSEMBLE_ITEM then
        EventManager:fireEvent("Event_ItemSplit", params)
    elseif orderType == DOTA_UNIT_ORDER_MOVE_ITEM then
        EventManager:fireEvent("Event_ItemMove", params)
    elseif orderType == 32 then
        EventManager:fireEvent("Event_ItemLock", params)
    elseif orderType == DOTA_UNIT_ORDER_GIVE_ITEM then
        EventManager:fireEvent("Event_ItemGive", params)
    end

    --Return true by default to keep all other orders the same
    if params.bIgnore then
        return false
    end
    return true
end

function public:HealingFilter(params)
    return true
end

function public:ItemAddedToInventoryFilter(params)
    --[[d        item_entindex_const	= 874
        inventory_parent_entindex_const	= 921   ----最后拥有该物品的ent
        suggested_slot	= -1
        item_parent_entindex_const	= 921
    ]]
    ----触发获取物品
    EventManager:fireEvent("Event_ItemAdd", params)
    if params.bIgnore then
        return false    ----忽略订单
    end
    return true
end

function public:ModifierGainedFilter(params)
    return true
end

function public:ModifyExperienceFilter(params)
    return true
end

function public:ModifyGoldFilter(params)
    local iPlayerID = params.player_id_const
    local iReason = params.reason_const
    local bIsReliable = params.reliable == 1
    local iGold = params.gold

    -- 总经济统计
    -- if PlayerResource:IsValidPlayerID(iPlayerID) then
    --     PlayerData.playerDatas[iPlayerID].statistics.gold = PlayerData.playerDatas[iPlayerID].statistics.gold + iGold
    -- end
    return true
end

function public:RuneSpawnFilter(params)
    return false
end

function public:TrackingProjectileFilter(params)
    return true
end

function public:init(bReload)
    local GameMode = GameRules:GetGameModeEntity()

    GameMode:SetAbilityTuningValueFilter(Dynamic_Wrap(public, "AbilityTuningValueFilter"), public)
    GameMode:SetBountyRunePickupFilter(Dynamic_Wrap(public, "BountyRunePickupFilter"), public)
    GameMode:SetDamageFilter(Dynamic_Wrap(public, "DamageFilter"), public)
    GameMode:SetExecuteOrderFilter(Dynamic_Wrap(public, "ExecuteOrderFilter"), public)
    GameMode:SetHealingFilter(Dynamic_Wrap(public, "HealingFilter"), public)
    GameMode:SetItemAddedToInventoryFilter(Dynamic_Wrap(public, "ItemAddedToInventoryFilter"), public)
    GameMode:SetModifierGainedFilter(Dynamic_Wrap(public, "ModifierGainedFilter"), public)
    GameMode:SetModifyExperienceFilter(Dynamic_Wrap(public, "ModifyExperienceFilter"), public)
    GameMode:SetModifyGoldFilter(Dynamic_Wrap(public, "ModifyGoldFilter"), public)
    GameMode:SetRuneSpawnFilter(Dynamic_Wrap(public, "RuneSpawnFilter"), public)
    GameMode:SetTrackingProjectileFilter(Dynamic_Wrap(public, "TrackingProjectileFilter"), public)
end

return public