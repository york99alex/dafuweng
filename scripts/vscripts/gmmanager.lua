require("mode/Constant")
require("mode/EventManager")
require("lib/Help")
require("lib/util")
require("lib/timers")
list = require("lib/list")
require("lib/CoEvent")
require("lib/CoTimer")
require("lib/Coroutine")
require("lib/amhc_library/amhc")
require("lib/amhc_library/kv")
AMHCInit()
require("lib/ParaAdjuster")
require("lib/md5")
require("service/Service")

require("mechanics/attribute")
-- require("mechanics/eventtest")
require("utils")
require("kv")

require("Ability/AbilityManager")
require("Player/PlayerManager")
require("Path/PathManager")
require("Card/CardManager")
require("item/ItemManager")
require("mode/filters")
require("mode/Trade")
require("mode/Auction")
require("mode/DeathClearing")
require("mode/GameRecord")
require("mode/HudError")
require("mode/CameraManage")
require("mode/SkinManager")
require("mode/Selection")
require("mode/Supply")
require("mode/HeroSelection")
require("GameState/GSManager")

----游戏管理模块
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if not GMManager then
	GMManager = {
		m_typeState = GS_None, ----游戏状态
		m_nGameID = -1, ----比赛编号
		m_nOrderID = -1, ----当前操作玩家ID
		m_nOrderFirst = -1, ----首操作玩家ID
		m_nOrderIndex = -1,
		m_nOrderFirstIndex = 1, ----首操作index
		m_timeOprt = -1, ----回合剩余时限
		m_nRound = 0, ----当前回合数
		m_nBaoZi = 0, ----当前玩家豹子次数
		m_bFinalBattle = false, ----终局决战
		m_tabOprtCan = {}, ----当前全部可操作
		m_tabOprtSend = {}, ----当前全部可操作
		m_tabOprtBroadcast = {}, ----当前全部可操作
		m_tabEnd = {}, ----结算数据
		m_bNoSwap = false,
	}
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----游戏初始化
function GMManager:init(bReload)
	print("[GMManager.init()]")

	----初始成员变量
	----队伍
	if GetMapName() == 'map_2x3' then
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 0)
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1, 2)
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_2, 2)
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_3, 2)
	else
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 6)
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
		GameRules:LockCustomGameSetupTeamAssignment(true)   ----锁定
		GameRules:SetCustomGameSetupRemainingTime(0)
		GameRules:SetCustomGameSetupAutoLaunchDelay(5)
		GameRules:SetCustomGameSetupTimeout(500)
		---- GameRules:PlayerHasCustomGameHostPrivileges(false)
	end
	----选择英雄时间
	GameRules:SetHeroSelectionTime(TIME_SELECTHERO)
	GameRules:SetHeroSelectPenaltyTime(0)
	GameRules:GetGameModeEntity():SetSelectionGoldPenaltyEnabled(false)
	---- 设置决策时间
	GameRules:SetStrategyTime(0.5)
	---- 设置展示时间
	GameRules:SetShowcaseTime(0)
	----设置游戏准备时间
	GameRules:SetPreGameTime(3)
	----游戏结束断线时间
	GameRules:SetPostGameTime(180)
	----初始金币
	GameRules:SetStartingGold(0)
	----取消官方工资
	GameRules:SetGoldTickTime(60)
	GameRules:SetGoldPerTick(0)
	----无战争迷雾
	GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
	AddFOWViewer(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), 1500, -1, true)
	----无广播员
	GameRules:GetGameModeEntity():SetAnnouncerDisabled(true)
	----禁止买活
	GameRules:GetGameModeEntity():SetBuybackEnabled(false)
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:GetGameModeEntity():SetDeathOverlayDisabled(false)
	----禁用死亡时损失金钱
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath(true)
	----物品
	GameRules:GetGameModeEntity():SetStashPurchasingDisabled(false) ----开关储藏处购买功能
	GameRules:GetGameModeEntity():SetStickyItemDisabled(true) ----隐藏快速购买处的物品
	GameRules:GetGameModeEntity():SetRecommendedItemsDisabled(true) ----禁止推荐物品
	---- GameRules:GetGameModeEntity():SetGoldSoundDisabled(true)	----无金币音效
	----统一商店
	---- GameRules:SetUseUniversalShopMode(true)
	----自定义等级
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(25)
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(LEVEL_EXP)
	---- GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_zuus")
	self:registerEvent()
	self:registerMessage()
	self:registerThink()

	Service:init(bReload)
	Filters:init(bReload)
	Attributes:init(bReload)
	ParaAdjuster:Init()
	---- 设置智力不加蓝
	ParaAdjuster:SetIntToMana(0)

	PlayerManager:init(bReload)
	PathManager:init(bReload)
	AbilityManager:init(bReload)
	CardManager:init(bReload)
	Trade.init(bReload)
	Auction.init(bReload)
	DeathClearing.init(bReload)
	SkinManager:init(bReload)
	ItemManager:init(bReload)
	Selection:init(bReload)
	Supply:init(bReload)
	HeroSelection:init(bReload)
	GSManager:init(bReload)

	GMManager.m_bNoSwap = string.find(GetMapName(), 'no_swap') and 1 or 0
	CustomNetTables:SetTableValue("GameingTable", "game_mode", {
		typeGameMode = GAME_MODE,
		bNoSwap = GMManager.m_bNoSwap
	})

	-- coroutine.start(function()
	--	 coroutine.wait(30)
	--	 print('test12333333')
	--	 local co3 = GSManager:yieldState()
	--	 GSManager:setState(GS_WaitOperator)
	--	 local co1 = GSManager:yieldState()
	--	 GSManager:setState(GS_Wait)
	--	 local co2 = GSManager:yieldState()
	--	 GSManager:setState(GS_Move)
	--	 GSManager:resumeState(co2)
	--	 GSManager:resumeState(co1)
	--	 GSManager:resumeState(co3)
	-- end)
	-- GSManager:yieldState()
	-- HOOK(GSManager, GSManager.realSetState, function(self, state)
	--	 print('debug real set state is ', state)
	-- end)
	-- HOOK(GSManager, GSManager.setState, function(self, state)
	--	 print('debug set state is ', state)
	-- end)
	-- GSManager:resumeState()
end

----设置当前状态
function GMManager:setState(typeState)
	print("last state: ", self.m_typeState, " cur state: ", typeState)
	-- print(debug.traceback("Stack trace: replaceState " .. typeState))
	self.m_typeState = typeState
	----同步网表
	local tab = { typeState = self.m_typeState }
	CustomNetTables:SetTableValue("GameingTable", "state", tab)
end

----设置当前操作玩家ID
function GMManager:setOrder(nOrder)
	print("GMManager.setOrder:=====================")
	print("last order: ", self.m_nOrderID, " cur order: ", nOrder, " first order:", self.m_nOrderFirst)
	print("GMManager.setOrder over======================")
	self.m_nOrderID = nOrder
	----同步网表
	local tab = { nPlayerID = self.m_nOrderID }
	CustomNetTables:SetTableValue("GameingTable", "order", tab)
end
function GMManager:getNextValidOrder(nOrder)
	local nIndex = HeroSelection:GetPlayerIDIndex(nOrder)
	nIndex = GMManager:addOrder(nIndex + 1)
	if not PlayerManager:isAlivePlayer(HeroSelection.m_PlayersSort[nIndex]) then
		return self:getNextValidOrder(HeroSelection.m_PlayersSort[nIndex])
	end
	return HeroSelection.m_PlayersSort[nIndex]
end
----获取上一个有效的操作玩家ID
function GMManager:getLastValidOrder(nOrder)
	local nIndex = HeroSelection:GetPlayerIDIndex(nOrder)
	if nIndex == nil then
		return self:getLastValidOrder(HeroSelection.m_PlayersSort[nIndex])
	end
	nIndex = GMManager:addOrder(nIndex - 1)
	if not PlayerManager:isAlivePlayer(HeroSelection.m_PlayersSort[nIndex]) then
		return self:getLastValidOrder(HeroSelection.m_PlayersSort[nIndex])
	end
	return HeroSelection.m_PlayersSort[nIndex]
end

----获取顺序上的order
function GMManager:addOrder(nOrder)
	if 1 > nOrder then
		return GMManager:addOrder(nOrder + PlayerManager:getPlayerCount())
	end
	nOrder = nOrder - 1
	return (nOrder % PlayerManager:getPlayerCount()) + 1
end

----更新回合操作时限
function GMManager:updataTimeOprt()
	self.m_timeOprt = self.m_timeOprt - 1

	----每一秒到更新网表
	if 0 == self.m_timeOprt % 10 then
		local tab = { time = self.m_timeOprt / 10 }
		CustomNetTables:SetTableValue("GameingTable", "timeOprt", tab)
	end
end

----发送操作
function GMManager:sendOprt(tabOprt)
	----添加可操作记录
	table.insert(self.m_tabOprtCan, tabOprt)
	table.insert(self.m_tabOprtSend, tabOprt)

	----发送消息给操作者
	PlayerManager:sendMsg("GM_Operator", tabOprt, tabOprt.nPlayerID)

	print("1[LUA]:Send======================>>>>>>>>>>>>>>>")
	DeepPrint(tabOprt)
end
----广播操作
function GMManager:broadcastOprt(tabOprt)
	----添加可操作记录
	table.insert(self.m_tabOprtCan, tabOprt)
	table.insert(self.m_tabOprtBroadcast, tabOprt)
	----发送消息给操作者
	PlayerManager:broadcastMsg("GM_Operator", tabOprt)
end

----验证操作
function GMManager:checkOprt(tabData, bDel)
	if bDel then
		local function cdt(v)
			return tabData.PlayerID == v.nPlayerID and tabData.typeOprt == v.typeOprt
		end
		remove(self.m_tabOprtSend, cdt)
		remove(self.m_tabOprtBroadcast, cdt)
	end
	for i, v in pairs(self.m_tabOprtCan) do
		----PlayerID：发送网包的玩家ID
		if tabData.PlayerID == v.nPlayerID and tabData.typeOprt == v.typeOprt then
			if bDel then
				table.remove(self.m_tabOprtCan, i)
			end
			return v
		end
	end
	return false
end

----自动处理操作
function GMManager:autoOprt(typeOprt, oPlayer)
	--print("autoOprt 111 typeOprt=" .. (typeOprt or 'nil'))
	--PrintTable(self.m_tabOprtCan)
	for k, v in pairs(self.m_tabOprtCan) do
		if
		(nil == typeOprt or typeOprt == v.typeOprt) and ----指定操作
		(nil == oPlayer or v.nPlayerID == oPlayer.m_nPlayerID)
		then ----指定玩家
			v.PlayerID = v.nPlayerID
			if TypeOprt.TO_Finish == v.typeOprt then
				----结束回合
				v.nRequest = 1
			elseif TypeOprt.TO_Roll == v.typeOprt then
				----roll点
				v.nRequest = 1
			elseif TypeOprt.TO_AYZZ == v.typeOprt then
				----安营扎寨，默认不
				v.nRequest = 0
			elseif TypeOprt.TO_GCLD == v.typeOprt then
				----攻城略地，默认不
				v.nRequest = 0
			elseif TypeOprt.TO_TP == v.typeOprt then
				----TP传送，默认不
				v.nRequest = 0
			elseif TypeOprt.TO_PRISON_OUT == v.typeOprt then
				----出狱，默认不买活
				v.nRequest = 0
			elseif TypeOprt.TO_DeathClearing == v.typeOprt then
				v.nRequest = 0
			elseif TypeOprt.TO_AtkMonster == v.typeOprt then
				v.nRequest = 0
			elseif TypeOprt.TO_RandomCard == v.typeOprt then
				v.nRequest = 0
			end

			if nil ~= v.nRequest then
				print("autoOprt", v.typeOprt, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
				self:onMsg_oprt(v)
				return self:autoOprt(typeOprt, oPlayer)
			end
		end
	end
end

----自动处理可选操作
function GMManager:autoOptionalOprt(oPlayer)
	GMManager:autoOprt(TypeOprt.TO_TP, oPlayer)
	GMManager:autoOprt(TypeOprt.TO_GCLD, oPlayer)
	GMManager:autoOprt(TypeOprt.TO_AtkMonster, oPlayer)
	GMManager:autoOprt(TypeOprt.TO_RandomCard, oPlayer)
end

----飘金
function GMManager:showGold(oPlayer, nGold)
	----通知UI显示花费
	CustomGameEventManager:Send_ServerToAllClients(
	"GM_ShowGold",
	{
		nGold = nGold,
		nPlayerID = oPlayer.m_nPlayerID
	}
	)

	----设置游戏记录
	---- GameRecord:setGameRecord(0 < nGold and TGameRecord_GoldAdd or TGameRecord_GoldDel
	---- , oPlayer.m_nPlayerID, {
	----	 nGold = GameRecord:encodeGameRecord(nGold)
	---- })
	----花费特效
	---- if 0 < nGold then
	----	 AMHC:CreateNumberEffect(oPlayer.m_eHero, nGold, 3, AMHC.MSG_XP, { 255, 255, 128 })
	---- else
	----	 AMHC:CreateNumberEffect(oPlayer.m_eHero, -nGold, 3, AMHC.MSG_MANA_LOSS, { 205, 0, 0 })
	---- end
end

----增加轮数
function GMManager:addRound()
	GMManager.m_nRound = GMManager.m_nRound + 1
	----同步网表
	CustomNetTables:SetTableValue("GameingTable", "round", {
		nRound = GMManager.m_nRound
	})


	local tEvtData = { isBegin = true, nRound = GMManager.m_nRound }

	if RoundTip[GMManager.m_nRound] then
		CustomGameEventManager:Send_ServerToAllClients("round_tip", { sTip = "false" })
	end

	----触发轮数更新
	EventManager:fireEvent("Event_UpdateRound", tEvtData)

	if RoundTip[GMManager.m_nRound + 1] then
		CustomGameEventManager:Send_ServerToAllClients("round_tip", { sTip = RoundTip[GMManager.m_nRound + 1] })
	end

	----全图商店
	if GLOBAL_SHOP_ROUND == GMManager.m_nRound then
		for _, player in pairs(PlayerManager.m_tabPlayers) do
			player:setBuyState(TBuyItem_SideAndSecret, -1)
		end
	end

	return tEvtData.isBegin
end

----设置结算数据
function GMManager:setGameEndData()
	for _, v in pairs(GMManager.m_tabEnd) do
		local player = PlayerManager:getPlayerBySteamID64(v.steamid64)
		if not NIL(player) then
			player.m_nRank = v.rank_num
			local info = {}
			info["nRank"] = player.m_nRank
			info["nKill"] = player.m_nKill
			info["nGCLD"] = player.m_nGCLD
			info["nDamageHero"] = player.m_nDamageHero
			info["nDamageBZ"] = player.m_nDamageBZ
			info["nGoldMax"] = player.m_nGoldMax
			info["nReward"] = 0

			local tServiceInfo = CustomNetTables:GetTableValue("Service", "player_info_" .. player.m_nPlayerID)
			if tServiceInfo then
				info["sLevel"] = tServiceInfo["sLevel"]
			end

			CustomNetTables:SetTableValue("EndTable", "player_info_" .. player.m_nPlayerID, info)
		end
	end

	----请求结算
	Service:RequestGameEnd(GMManager.m_tabEnd, function(tData)
		----添加结算信息
		for steamid, v in pairs(tData) do
			local player = PlayerManager:getPlayerBySteamID64(tostring(steamid))
			if player then
				local info = CustomNetTables:GetTableValue("EndTable", "player_info_" .. player.m_nPlayerID)
				if info then
					info["nReward"] = v["gold"]
					info["sLevel"] = v["level"]
					print("GameEnd Data ======================================")
					DeepPrintTable(info)
					CustomNetTables:SetTableValue("EndTable", "player_info_" .. player.m_nPlayerID, info)
				end
			end
		end
	end)

	GMManager.m_tabEnd = {}
end

-----跳过投骰子
function GMManager:skipRoll(nPlayerID)
	print(nPlayerID, "  skipRoll~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	local tabOprt = {
		typeOprt = TypeOprt.TO_Roll,
		PlayerID = nPlayerID,
		nPlayerID = nPlayerID
	}
	----有roll点操作取消
	PrintTable(self.m_tabOprtCan)
	if GMManager:checkOprt(tabOprt, true) then
		tabOprt.nNum1 = 0
		tabOprt.nNum2 = 0
		PlayerManager:broadcastMsg("GM_OperatorFinished", tabOprt)
		----发送操作：完成回合
		GMManager:broadcastOprt({ typeOprt = TypeOprt.TO_Finish, nPlayerID = nPlayerID })
		PrintTable(self.m_tabOprtCan)
	end
end
----准备进入begin状态
function GMManager:setStateBeginReady()
	GSManager:setState(GS_Begin, false)
	EventManager:fireEvent("Event_PlayerRoundBefore", { typeGameState = GS_Begin })
	GSManager:startState()
end

----事件回调-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----注册事件
function GMManager:registerEvent()
	----游戏状态变更
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(GMManager, "onEvent_game_rules_state_change"), self)
	----购买物品
	---- ListenToGameEvent("dota_item_purchased", Dynamic_Wrap(GMManager, "onEvent_itemPurchased"), self)
	EventManager:register("Event_Roll", self.onEvent_Roll, self, -1000)
	EventManager:register("Event_ChangeGold_Atk", self.onEvent_ChangeGold, self)
	EventManager:register("Event_ItemBuy", self.onEvent_ItemBuy, self)
	EventManager:register("Event_PlayerDie", self.onEvent_PlayerDie, self, -1000)
	EventManager:register("Event_Service_AllData", GMManager.onEvent_Service_AllData, GMManager)
end

----游戏状态变更
function GMManager:onEvent_game_rules_state_change()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		----等待玩家加载界面
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		----选择队伍界面
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
		----选择hero
		HeroSelection:UpdateTime()
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		----进入地图,准备阶段
		HeroSelection:ClearNetTab()
		if GameRules:IsCheatMode() and not IsInToolsMode() then
			----作弊
			GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		end
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		----游戏开始
		-- Timers:CreateTimer(1, function()
		--	 return GMManager:onThink_wageGold()
		-- end)
	end
end

----购买物品
function GMManager:onEvent_ItemBuy(tabEvent)
	local player = PlayerManager:getPlayer(tabEvent.issuer_player_id_const)
	-- if TESTCARD and TESTHELP then
	--	 -----@type Player
	--	 local unitName = player.m_eHero:GetUnitName()
	--	 local cardID = nil
	--	 local function checkUnitName(str)
	--		 return string.find(string.lower(unitName), string.lower("_" .. str)) ~= nil
	--	 end
	--	 if checkUnitName("LINA") then
	--		 cardID = TCard_HERO_LINA_laguna_blade
	--	 elseif checkUnitName("AXE") then
	--		 cardID = TCard_HERO_AXE_berserkers_call
	--	 elseif checkUnitName("ZUUS") then
	--		 cardID = TCard_HERO_ZUUS_thundergods_wrath
	--	 elseif checkUnitName("PHANTOM") then
	--		 cardID = TCard_HERO_PHANTOM_strike
	--	 elseif checkUnitName("MEEPO") then
	--		 cardID = TCard_HERO_MEEPO_summon_image
	--	 end
	--	 -- cardID = RandomInt(10005, 10007)
	--	 -- cardID = TCard_MONSTER_brush_field
	--	 if cardID then
	--		 local card = CardFactory:create(cardID)
	--		 player:setCardAdd(card)
	--	 end
	-- end
end

----玩家roll点后移动
function GMManager:onEvent_Roll(tabEvent)
	if tabEvent.bIgnore then
		return
	end
	----触发移动事件
	EventManager:fireEvent("Event_Move", { entity = tabEvent.player.m_eHero })

	local pathDes = PathManager:getNextPath(tabEvent.player.m_pathCur, tabEvent.nNum1 + tabEvent.nNum2)
	if TESTHELP and nil ~= GMManager._TestHelp_Roll_nRoll then
		pathDes = PathManager:getNextPath(tabEvent.player.m_pathCur, GMManager._TestHelp_Roll_nRoll)
		GMManager._TestHelp_Roll_nRoll = nil
	end

	-- self:setState(GS_Move)
	-- self._YieldStateCO_Move = GSManager:yieldState()
	GSManager:setState(GS_Move)
	tabEvent.player:moveToPath(pathDes, function(bSuccess)
		----触发移动结束事件
		if GS_Move == GMManager.m_typeState
		or GS_DeathClearing == GMManager.m_typeState then
			----移动结束
			GSManager:setState(GS_WaitOperator)
		end
		EventManager:fireEvent("Event_MoveEnd", { entity = tabEvent.player.m_eHero })

		tabEvent.player.m_nRollMove = tabEvent.player.m_nRollMove + 1
		----玩家死亡不操作
		if tabEvent.player.m_bDie then
			return
		end
		----判断路径触发功能
		pathDes:onPath(tabEvent.player)

		----触发豹子判断
		local tEventJudge = { player = tabEvent.player }
		EventManager:fireEvent("Event_RollBaoZiJudge", tEventJudge)
		if not tEventJudge.bIgnore and tabEvent.nNum1 == tabEvent.nNum2 and
		0 == bit.band(PS_InPrison + PS_AtkMonster, tabEvent.player.m_typeState)
		then
			----豹子,发送roll点操作
			self:broadcastOprt({
				typeOprt = TypeOprt.TO_Roll,
				bPrison = tonumber(PRISON_BAOZI_COUNT - 1 == GMManager.m_nBaoZi),
				nPlayerID = tabEvent.player.m_nPlayerID
			})
			----追加时间
			if TIME_BAOZI_YZ >= self.m_timeOprt then
				self.m_timeOprt = self.m_timeOprt + TIME_BAOZI_ADD
			end
			return
		end

		----发送操作：完成回合
		self:broadcastOprt({
			typeOprt = TypeOprt.TO_Finish,
			nPlayerID = tabEvent.player.m_nPlayerID
		})
	end)
end

----玩家金币变化
function GMManager:onEvent_ChangeGold(tabEvent)
	if not self.m_tabChangeGold then
		self.m_tabChangeGold = {}
	end
	if not self.m_tabChangeGold[tabEvent.player.m_nPlayerID] then
		self.m_tabChangeGold[tabEvent.player.m_nPlayerID] = 0
	end
	self.m_tabChangeGold[tabEvent.player.m_nPlayerID] =	self.m_tabChangeGold[tabEvent.player.m_nPlayerID] + tabEvent.nGold
	CustomNetTables:SetTableValue("GameingTable", "change_gold", self.m_tabChangeGold)
	print("[network-changeGold]==============================")
	PrintTable(self.m_tabChangeGold)

	----设置3秒后清除
	if not self.m_nTimeChangeGold then
		Timers:CreateTimer(
		0.1,
		function()
			self.m_nTimeChangeGold = self.m_nTimeChangeGold - 1
			if 0 < self.m_nTimeChangeGold then
				return 0.1
			end
			self.m_nTimeChangeGold = nil
			self.m_tabChangeGold = nil
			CustomNetTables:SetTableValue("GameingTable", "change_gold", {})
		end
		)
	end
	self.m_nTimeChangeGold = 30
end

----玩家死亡
function GMManager:onEvent_PlayerDie(tabEvent)
	local nAlive = PlayerManager:getAlivePlayerCount()

	table.insert(GMManager.m_tabEnd, {
		steamid64 = tostring(PlayerResource:GetSteamID(tabEvent.player.m_nPlayerID)),
		rank_num = nAlive + 1,
		hero_name = tabEvent.player.m_eHero and tabEvent.player.m_eHero:GetUnitName() or "",
		time_game = math.floor(GameRules:GetGameTime()),
		is_abandon = tabEvent.player.m_bAbandon
	})

	if 2 == nAlive then
		----开启决战
		self.m_bFinalBattle = true
		EventManager:fireEvent("Event_FinalBattle")
	elseif 2 > nAlive then
		----游戏结束
		-- GMManager:setState(GS_End)
		GSManager:setState(GS_End)
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		----添加第一名
		for _, player in pairs(PlayerManager.m_tabPlayers) do
			if PlayerManager:isAlivePlayer(player.m_nPlayerID) then
				table.insert(GMManager.m_tabEnd, {
					steamid64 = tostring(PlayerResource:GetSteamID(player.m_nPlayerID)),
					rank_num = 1,
					hero_name = player.m_eHero and player.m_eHero:GetUnitName() or "",
					time_game = math.floor(GameRules:GetGameTime()),
					is_abandon = player.m_bAbandon
				})
				break
			end
		end

		local tEndGame = { tPlayerID = {} }
		for nID, _ in pairs(PlayerManager.m_tabPlayers) do
			tEndGame.tPlayerID[nID] = nID
		end
		EventManager:fireEvent('Event_EndGame', tEndGame)
	end

	----剩余操作出来
	if tabEvent.player.m_nPlayerID == GMManager.m_nOrderID
	and GS_DeathClearing ~= GMManager.m_typeState then
		----移除操作
		for i = #self.m_tabOprtCan, 1, -1 do
			if self.m_tabOprtCan[i].nPlayerID == tabEvent.player.m_nPlayerID then
				table.remove(self.m_tabOprtCan, i)
			end
		end
		if 1 < nAlive then
			-- GMManager:setState(GS_Finished)
			if GS_ReadyStart ~= GSManager.m_typeStateCur then
				GSManager:setState(GS_Finished)
			end
		end
	end

	----改变首位玩家
	if self.m_nOrderFirst == tabEvent.player.m_nPlayerID then
		self.m_nOrderFirst = GMManager:getNextValidOrder(tabEvent.player.m_nPlayerID)
	end

	----设置结算
	GMManager:setGameEndData()
end

----全部数据
function GMManager:onEvent_Service_AllData(tEvent)
	if - 1 == tonumber(tEvent["gameid"]) then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
	else
		GMManager.m_nGameID = tEvent["gameid"]
	end
end

----计时回调----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----注册计时协程
function GMManager:registerThink()
	----全局主流程
	GMManager._DotaState = {}
	Timers:CreateTimer(
	2,
	function()
		return GMManager:onThink_update()
	end
	)
end

----游戏进行时
function GMManager:onThink_update()
	CoUpdate()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		----这里游戏持续进行
		GSManager:update()
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		----等待玩家连接
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
		----英雄选择
		if not GMManager._DotaState[GameRules:State_Get()] then
			GMManager._DotaState[GameRules:State_Get()] = true
			----时间结束自动选择
			---- Timers:CreateTimer(
			---- math.abs(GameRules:GetDOTATime(false, true)),
			---- function()
			----	 PlayerManager:autoSelectHero()
			---- end
			---- )
		end
	end
	---- print("GameState=" .. GameRules:State_Get())
	return 0.1
end

----持续发工资
function GMManager:onThink_wageGold()
	if GameRules:IsGamePaused() then
		return 0.2
	end
	for _, oPlayer in pairs(PlayerManager.m_tabPlayers) do
		oPlayer:setGold(oPlayer:getWageGold(), true)
	end
	return 1
end

----消息回调----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----注册消息
function GMManager:registerMessage()
	CustomGameEventManager:RegisterListener("GM_Operator", self.onMsg_oprt)
	CustomGameEventManager:RegisterListener("GM_TestHelp_Roll", self.onMsg_TestHelp_Roll)
end

----操作请求
function GMManager:onMsg_oprt(tabData)
	print("3[LUA]:Receive=================>>>>>>>>>>>>>>>")
	-- DeepPrint(tabData)
	PrintTable(tabData)
	if nil == tabData.typeOprt then
		return
	end

	if TypeOprt.TO_Free < tabData.typeOprt then
		if TypeOprt.TO_ZBMM == tabData.typeOprt then
		elseif TypeOprt.TO_XJGT == tabData.typeOprt then
		elseif TypeOprt.TO_TRADE == tabData.typeOprt then
			EventManager:fireEvent(Trade.EvtID.Event_TO_TRADE, tabData)
		elseif TypeOprt.TO_TRADE_BE == tabData.typeOprt then
			EventManager:fireEvent(Trade.EvtID.Event_TO_TRADE_BE, tabData)
		elseif TypeOprt.TO_SendAuction == tabData.typeOprt then
			EventManager:fireEvent(Auction.EvtID.Event_TO_SendAuction, tabData)
		elseif TypeOprt.TO_BidAuction == tabData.typeOprt then
			EventManager:fireEvent(Auction.EvtID.Event_TO_BidAuction, tabData)
		elseif TypeOprt.TO_UseCard == tabData.typeOprt then
			EventManager:fireEvent(CardManager.EvtID.Event_CardUseRequest, tabData)
		else
			local fun = _G["Process_" .. KEY(TypeOprt, tabData.typeOprt)]
			if fun and 'function' == type(fun) then
				fun(tabData)
			end
		end
	elseif false ~= GMManager:checkOprt(tabData) then ----这里的操作需要验证
		if TypeOprt.TO_Finish == tabData.typeOprt then
			----请求结束回合
			GMManager:processFinish(tabData)
		elseif TypeOprt.TO_Roll == tabData.typeOprt then
			GMManager:processRoll(tabData)
		elseif TypeOprt.TO_AYZZ == tabData.typeOprt then
			GMManager:processAYZZ(tabData)
		elseif TypeOprt.TO_GCLD == tabData.typeOprt then
			GMManager:processGCLD(tabData)
		elseif TypeOprt.TO_TP == tabData.typeOprt then
			GMManager:processTP(tabData)
		elseif TypeOprt.TO_PRISON_OUT == tabData.typeOprt then
			GMManager:processPrisonOut(tabData)
		elseif TypeOprt.TO_DeathClearing == tabData.typeOprt then
			EventManager:fireEvent(DeathClearing.EvtID.Event_TO_DeathClearing, tabData)
		elseif TypeOprt.TO_Supply == tabData.typeOprt then
			Supply:processOprt(tabData)
		elseif TypeOprt.TO_AtkMonster == tabData.typeOprt then
			GMManager:processAtkMonster(tabData)
		else
			local fun = _G["Process_" .. KEY(TypeOprt, tabData.typeOprt)]
			if fun and 'function' == type(fun) then
				fun(tabData)
			end
		end
	end
end

----处理完成
function GMManager:processFinish(tabData)
	if GS_Move == GMManager.m_typeState then
		HudError:FireLocalizeError(tabData.PlayerID, "LuaAbilityError_Move")
		return
	end
	if GS_Wait == GMManager.m_typeState then
		HudError:FireLocalizeError(tabData.PlayerID, "LuaAbilityError_Wait")
		return
	end

	-- GMManager:setState(GS_Finished)
	GSManager:setState(GS_Finished)

	----删除操作
	local tabOprt = self:checkOprt(tabData, true)
	tabOprt.nRequest = 1

	----回包
	PlayerManager:sendMsg("GM_OperatorFinished", tabOprt, tabOprt.nPlayerID)

	self:autoOprt(nil, PlayerManager:getPlayer(tabOprt.nPlayerID))
end

----处理roll点
function GMManager:processRoll(tabData)
	if GS_Move == GMManager.m_typeState then
		HudError:FireLocalizeError(tabData.PlayerID, "LuaAbilityError_Move")
		return
	end
	if GS_Wait == GMManager.m_typeState then
		HudError:FireLocalizeError(tabData.PlayerID, "LuaAbilityError_Wait")
		return
	end
	local oPlayer = PlayerManager:getPlayer(tabData.PlayerID)
	if NIL(oPlayer) then
		return
	end
	local bInPrison = 0 < bit.band(PS_InPrison, oPlayer.m_typeState)

	----有tp和攻城跳过
	self:autoOprt(TypeOprt.TO_TP)
	self:autoOprt(TypeOprt.TO_GCLD)
	self:autoOprt(TypeOprt.TO_AtkMonster)

	local nNum1, nNum2 = RandomInt(1, 6), RandomInt(1, 6)
	---- 是否占领路径点
	local function checkPath()
		if bInPrison then
			return false
		end
		local path = PathManager:getNextPath(oPlayer.m_pathCur, nNum1 + nNum2)
		return (instanceof(path, PathDomain) or instanceof(path, PathTP)) and not path.m_nOwnerID
	end

	print("roll default: ", nNum1, nNum2)

	---- 领地差值
	local difference = PlayerManager:getMostPathCount() - PlayerManager:getLeastPathCount()
	if 2 < difference then
		local randomNum = RandomInt(1, 2)
		print("roll randomNum: ", randomNum)
		if 1 == randomNum then
			local i = 1
			if PlayerManager:isLeastPathPlayer(tabData.PlayerID) then
				while i < 100 do
					if checkPath() then
						break
					end
					nNum1, nNum2 = RandomInt(1, 6), RandomInt(1, 6)
					i = i + 1
				end
			elseif PlayerManager:isMostPathPlayer(tabData.PlayerID) then
				while i < 100 do
					if not checkPath() then
						break
					end
					nNum1, nNum2 = RandomInt(1, 6), RandomInt(1, 6)
					i = i + 1
				end
			end
		end
	end
	print("roll final: ", nNum1, nNum2)
	---- ----随机点数
	---- local n = oPlayer:getMyPathCount() - PathManager:getPathCountAge() + 2
	---- if 0 >= n then
	----	 n = 1
	---- end
	---- for i = 1, n do
	----	 nNum1, nNum2 = RandomInt(1, 6), RandomInt(1, 6)
	----	 if 1 == RandomInt(1, 2) or not checkPath() then
	----		 break
	----	 end
	---- end
	if TESTHELP and nil ~= GMManager._TestHelp_Roll_nRoll and 12 >= GMManager._TestHelp_Roll_nRoll and
	2 <= GMManager._TestHelp_Roll_nRoll then
		if 6 < GMManager._TestHelp_Roll_nRoll then
			nNum1 = 6
		else
			nNum1 = GMManager._TestHelp_Roll_nRoll - 1
		end
		nNum2 = GMManager._TestHelp_Roll_nRoll - nNum1
	end

	----删除操作
	local tabOprt = self:checkOprt(tabData, true)

	----测试
	nNum1 = 2
	nNum2 = 4

	----广播玩家roll点操作
	tabOprt.nNum1 = nNum1
	tabOprt.nNum2 = nNum2
	PlayerManager:broadcastMsg("GM_OperatorFinished", tabOprt)
	----音效
	EmitGlobalSound("Custom.Roll.Ing")

	----玩家英雄根据点数移动
	-- self:setState(GS_Wait)
	-- self._YieldStateCO_Wait = GSManager:yieldState()
	GSManager:setState(GS_Wait)

	----设置计时器等待客户端roll点动画结束
	Timers:CreateTimer(1.5, function()
		----设置roll点记录
		GameRecord:setGameRecord(TGameRecord_Roll, tabData.PlayerID, {
			nRoll = GameRecord:encodeGameRecord(nNum1 + nNum2)
		})

		-- if GS_Wait == GMManager.m_typeState
		-- or GS_DeathClearing == GMManager.m_typeState then
		-- self:setState(GS_WaitOperator)
		GSManager:setState(GS_WaitOperator)
		----触发roll事件
		EventManager:fireEvent("Event_Roll", {
			player = oPlayer,
			nNum1 = nNum1,
			nNum2 = nNum2
		})
		-- end
	end)
end

----处理安营扎寨
function GMManager:processAYZZ(tabData)
	----删除可操作
	local tabOprt = self:checkOprt(tabData)
	tabOprt.nRequest = tabData.nRequest

	local oPlayer, oPath

	----验证操作
	local funCheck = function()
		if 1 == tabData.nRequest then
			oPlayer = PlayerManager:getPlayer(tabOprt.nPlayerID)
			oPath = PathManager:getPathByID(tabOprt.nPathID)
			if not oPlayer or not oPath then
				return 100
			end

			if oPath.m_nPrice > oPlayer:GetGold() then
				----错误提示
				HudError:FireLocalizeError(tabData.PlayerID, "Error_NeedGold")
				return 2 ----金币不足
			end
		end
		return tabData.nRequest
	end
	tabOprt.nRequest = funCheck()

	if 1 == tabOprt.nRequest then
		----广播玩家安营扎寨
		PlayerManager:broadcastMsg("GM_OperatorFinished", tabOprt)

		if TESTHELP_ALLPATH then
			---@type Player
			local oPlayer = PlayerManager:getPlayer(tabOprt.nPlayerID)
			---@type Path
			local path = PathManager:getPathByID(tabOprt.nPathID)
			local paths = PathManager:getPathByType(path.m_typePath)
			if instanceof(path, PathDomain) then
				-- for i = 1, #paths do
				--	 if instanceof(paths[i], PathDomain) then
				--		 oPlayer:setMyPathAdd(paths[i])
				--	 end
				-- end
				for i = 1, #PathManager.m_tabPaths do
					if instanceof(PathManager.m_tabPaths[i], PathDomain) then
						oPlayer:setMyPathAdd(PathManager.m_tabPaths[i])
					end
				end
			end
		end
		----设置玩家领地
		oPlayer:setMyPathAdd(oPath)
		----消费金币
		oPlayer:setGold(-oPath.m_nPrice)
		self:showGold(oPlayer, -oPath.m_nPrice)

		----设置游戏记录
		GameRecord:setGameRecord(
		TGameRecord_AYZZ,
		tabOprt.nPlayerID,
		{
			strPathName = GameRecord:encodeGameRecord(GameRecord:encodeLocalize("PathName_" .. tabOprt.nPathID)),
			nGold = GameRecord:encodeGameRecord(oPath.m_nPrice)
		}
		)
	else
		----回包
		PlayerManager:sendMsg("GM_OperatorFinished", tabOprt, tabOprt.nPlayerID)
	end

	if 0 == tabOprt.nRequest or 1 == tabOprt.nRequest then
		self:checkOprt(tabData, true)
	end
end

----处理攻城略地
function GMManager:processGCLD(tabData)
	----删除可操作
	local tabOprt = self:checkOprt(tabData)
	tabOprt.nRequest = tabData.nRequest

	local path

	----验证操作
	local funCheck = function()
		if 1 == tabData.nRequest then
			path = PathManager:getPathByID(tabOprt.nPathID)
			if not path then
				return 100
			end

			if path.m_nOwnerID == tabOprt.nPlayerID then
				HudError:FireLocalizeError(tabData.PlayerID, "Error_CantGCLD_Slef")
				return 2 ----自己领地
			elseif path.m_nPlayerIDGCLD then
				HudError:FireLocalizeError(tabData.PlayerID, "Error_CantGCLD_Battling")
				return 3 ----已在攻城中
			elseif path.m_tabENPC and IsValid(path.m_tabENPC[1]) and path.m_tabENPC[1]:IsStunned() then
				HudError:FireLocalizeError(tabData.PlayerID, "Error_CantGCLD_Stunned")
				return 4 ----目标眩晕
			elseif GS_Wait == GMManager.m_typeState then
				HudError:FireLocalizeError(tabData.PlayerID, "LuaAbilityError_Wait")
				return 5 ----等待
			end
			local playerBe = PlayerManager:getPlayer(path.m_nOwnerID)
			if playerBe and 0 < bit.band(playerBe.m_typeState, PS_InPrison) then
				HudError:FireLocalizeError(tabData.PlayerID, "Error_CantGCLD_InPrison")
				return 6 ----目标被地狱封印
			end
		end
		return tabData.nRequest
	end
	tabOprt.nRequest = funCheck()

	if 1 == tabOprt.nRequest then
		----广播玩家攻城略地
		PlayerManager:broadcastMsg("GM_OperatorFinished", tabOprt)

		-----@type PathDomain 玩家攻城
		path:atkCity(PlayerManager:getPlayer(tabOprt.nPlayerID))

		self:skipRoll(tabOprt.nPlayerID)
	else
		----回包
		PlayerManager:sendMsg("GM_OperatorFinished", tabOprt, tabOprt.nPlayerID)
	end

	if 0 == tabOprt.nRequest or 1 == tabOprt.nRequest then
		self:checkOprt(tabData, true)
	end
end

----处理打野
function GMManager:processAtkMonster(tabData)
	----删除可操作
	local tabOprt = self:checkOprt(tabData)
	tabOprt.nRequest = tabData.nRequest
	local path = PathManager:getPathByID(tabOprt.nPathID)

	----验证操作
	local funCheck = function()
		if 1 == tabData.nRequest then
			if GS_Wait == GMManager.m_typeState then
				HudError:FireLocalizeError(tabData.PlayerID, "LuaAbilityError_Wait")
				return 5 ----等待
			end
		end
		return tabData.nRequest
	end
	tabOprt.nRequest = funCheck()

	if 1 == tabOprt.nRequest then
		----广播玩家打野
		PlayerManager:broadcastMsg("GM_OperatorFinished", tabOprt)

		-----@type PathMonster 玩家打野
		path:setAtkerAdd(PlayerManager:getPlayer(tabOprt.nPlayerID))

		self:skipRoll(tabOprt.nPlayerID)
	else
		----回包
		PlayerManager:sendMsg("GM_OperatorFinished", tabOprt, tabOprt.nPlayerID)
	end

	if 0 == tabOprt.nRequest or 1 == tabOprt.nRequest then
		self:checkOprt(tabData, true)
	end
end

----处理TP传送
function GMManager:processTP(tabData)
	local oPlayer = PlayerManager:getPlayer(tabData.PlayerID)
	local tabOprt = self:checkOprt(tabData)

	----验证是否有效TP点
	tabData.nRequest = tabData.nRequest or 0
	if 0 < tabData.nRequest then
		local path = PathManager:getPathByID(tabData.nRequest)
		if nil == path or nil == path.m_nOwnerID or tabData.PlayerID ~= path.m_nOwnerID or path == oPlayer.m_pathCur then
			return
		end

		----设置游戏记录
		GameRecord:setGameRecord(TGameRecord_TP, oPlayer.m_nPlayerID, {
			strPathBegin = GameRecord:encodeGameRecord(
			GameRecord:encodeLocalize("PathName_" .. oPlayer.m_pathCur.m_nID)
			),
			strPathEnd = GameRecord:encodeGameRecord(GameRecord:encodeLocalize("PathName_" .. path.m_nID))
		})

		----传送
		path:TP(oPlayer)
	end

	----删除可操作
	self:checkOprt(tabData, true)
	tabOprt.nRequest = tabData.nRequest

	----回包
	PlayerManager:sendMsg("GM_OperatorFinished", tabOprt, tabOprt.nPlayerID)
end

----处理出狱
function GMManager:processPrisonOut(tabData)
	local tabOprt = self:checkOprt(tabData)
	local oPlayer = PlayerManager:getPlayer(tabData.PlayerID)

	----验证操作
	local funCheck = function()
		if 1 == tabData.nRequest then
			----玩家买活，验证金币
			if tabOprt.nGold > oPlayer:GetGold() then
				----错误提示
				HudError:FireLocalizeError(tabData.PlayerID, "Error_NeedGold")
				return 2 ----金币不足
			end
		end
		return tabData.nRequest
	end
	tabOprt.nRequest = funCheck()

	----回包
	PlayerManager:sendMsg("GM_OperatorFinished", tabOprt, tabData.PlayerID)
	if 1 < tabOprt.nRequest then
		return
	end

	----成功删除操作
	self:checkOprt(tabData, true)

	----买活出狱
	if 1 == tabOprt.nRequest then
		PathManager:getPathByType(TP_PRISON)[1]:setOutPrison(oPlayer)
		----扣钱
		oPlayer:setGold(-tabOprt.nGold)
		oPlayer.m_eHero:ModifyHealth(oPlayer.m_eHero:GetMaxHealth(), nil, false, 0)
		GMManager:showGold(oPlayer, -tabOprt.nGold)

		----设置游戏记录
		GameRecord:setGameRecord(
		TGameRecord_OutPrisonByGold,
		tabOprt.nPlayerID,
		{
			nGold = GameRecord:encodeGameRecord(tabOprt.nGold)
		}
		)
	end

	----发送Roll点操作
	tabOprt = {}
	tabOprt.nPlayerID = oPlayer.m_nPlayerID
	tabOprt.typeOprt = TypeOprt.TO_Roll
	self:broadcastOprt(tabOprt)
end

function GMManager:onMsg_TestHelp_Roll(tabData)
	GMManager._TestHelp_Roll_nRoll = tabData.nRoll
end

------ function print(str)--	 if nil ~= prt then--		 prt(str)--	 end-- end