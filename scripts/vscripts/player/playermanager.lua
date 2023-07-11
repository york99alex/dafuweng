require("Player/Player")
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----玩家管理模块
if not PlayerManager then
	PlayerManager = {
		m_bAllPlayerInit = false, ----全部玩家初始化完成
		m_tabPlayers = {} ----全部玩家数据
	}
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
function PlayerManager:init(bReload)
	if not bReload then
		self:registerEvent()
	end
end

-----@param nPlayerID number 获取玩家对象
function PlayerManager:getPlayer(nPlayerID)
	return self.m_tabPlayers[nPlayerID]
end
-----@param sSteamID64 string 获取玩家对象
function PlayerManager:getPlayerBySteamID64(sSteamID64)
	for id, player in pairs(PlayerManager.m_tabPlayers) do
		if sSteamID64 == tostring(PlayerResource:GetSteamID(id)) then
			return player
		end
	end
end
-----@param nUserID int 获取玩家对象
function PlayerManager:getPlayerByUserID(nUserID)
	for id, player in pairs(PlayerManager.m_tabPlayers) do
		if nUserID == player.m_nUserID then
			return player
		end
	end
end
-----@param strHero string 获取玩家对象通过英雄名
function PlayerManager:getPlayerByHeroName(strHero)
	for k, v in pairs(self.m_tabPlayers) do
		if strHero == v.m_eHero:GetUnitName() then
			return v
		end
	end
end
-----@param entindex number 获取玩家对象通过实体index
function PlayerManager:getPlayerByEntindex(entindex)
	for k, v in pairs(self.m_tabPlayers) do
		if entindex == v.m_eHero:GetEntityIndex() then
			return v
		end
	end
end
-----玩家是否存活
function PlayerManager:isAlivePlayer(nPlayerID)
	-----@type Player
	local player = self:getPlayer(nPlayerID)
	return player and not player.m_bDie
end
----获取玩家数量
function PlayerManager:getPlayerCount()
	return getSize(self.m_tabPlayers)
end
----- 获取存活玩家数量
function PlayerManager:getAlivePlayerCount()
	local nCount = 0
	for k, player in pairs(self.m_tabPlayers) do
		if self:isAlivePlayer(player.m_nPlayerID) then
			nCount = nCount + 1
		end
	end
	return nCount
end
----广播事件消息
function PlayerManager:broadcastMsg(strMsgID, tabData)
	CustomGameEventManager:Send_ServerToAllClients(strMsgID, tabData)
end

----发送事件消息给某玩家
function PlayerManager:sendMsg(strMsgID, tabData, nPlayerID)
	local oPlayer = self:getPlayer(nPlayerID)
	if oPlayer then
		oPlayer:sendMsg(strMsgID, tabData)
	end
end

----找到距离我最近路径的玩家
function PlayerManager:findClosePlayer(oPlayer, funFilter, nOffset)
	if "function" ~= type(funFilter) then
		funFilter = function()
			return true
		end
	end

	local pathCur = oPlayer.m_pathCur
	if nOffset then
		pathCur = PathManager:getNextPath(pathCur, nOffset)
	end

	local oRetrun = nil
	local nMin = -1
	for _, v in pairs(self.m_tabPlayers) do
		local nDis = PathManager:getPathDistance(pathCur, v.m_pathCur)
		if nDis < nMin or -1 == nMin then
			if funFilter(v) then
				nMin = nDis
				oRetrun = v
			end
		end
	end
	return oRetrun
end
----找到目标领地范围格数内的玩家
function PlayerManager:findRangePlayer(tabPlayer, pathTarger, nRange, nOffset, funFilter)
	if "function" ~= type(funFilter) then
		funFilter = function()
			return true
		end
	end

	nOffset = nOffset or 0
	nRange = nRange or 1
	if nRange > #PathManager.m_tabPaths then
		nRange = #PathManager.m_tabPaths
	end

	local nBeginID = pathTarger.m_nID - math.floor((nRange - 1) * 0.5) + nOffset
	for i = nBeginID + nRange - 1, nBeginID, -1 do
		local nID = i
		if nID > #PathManager.m_tabPaths then
			nID = nID % #PathManager.m_tabPaths
		elseif nID <= 0 then
			nID = nID + #PathManager.m_tabPaths
		end

		for k, v in pairs(self.m_tabPlayers) do
			if nID == v.m_pathCur.m_nID and funFilter(v) then
				table.insert(tabPlayer, v)
			end
		end
	end
end
----找到随机N个玩家
function PlayerManager:findRandomPlayer(nCount, funFilter)
	nCount = nCount or 1
	if "function" ~= type(funFilter) then
		funFilter = function()
			return true
		end
	end

	local tabPlayers = {}
	for _, v in pairs(self.m_tabPlayers) do
		table.insert(tabPlayers, v)
	end

	for i = #tabPlayers, 1, -1 do
		if not funFilter(tabPlayers[i]) then
			table.remove(tabPlayers, i)
		end
	end
	while #tabPlayers > nCount do
		table.remove(tabPlayers, RandomInt(1, #tabPlayers))
	end

	return tabPlayers
end

----设置全部玩家兵卒可否攻击
function PlayerManager:setAllBzAttack()
	for k, v in pairs(self.m_tabPlayers) do
		v:setAllBzAttack()
	end
end

----给全部玩家加经验
function PlayerManager:setExpByAllHero(nVal)
	for _, oPlayer in pairs(self.m_tabPlayers) do
		oPlayer.m_eHero:AddExperience(nVal, 0, false, false)
	end
end

----给全部玩家加魔法
function PlayerManager:setManaByAllHero(nVal)
	for _, oPlayer in pairs(self.m_tabPlayers) do
		oPlayer.m_eHero:GiveMana(nVal)
	end
end

----自动选择英雄
function PlayerManager:autoSelectHero(nVal)
	for _, oPlayer in pairs(self.m_tabPlayers) do
		if - 1 == PlayerResource:GetSelectedHeroID(oPlayer.m_nPlayerID) then
			if oPlayer.m_oCDataPlayer then
				oPlayer.m_oCDataPlayer:MakeRadnomHeroSelection()
			else
				print("nil oPlayer.m_oCDataPlayer")
			end
		end
	end
end

----事件回调-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----注册事件
function PlayerManager:registerEvent()
	if IsServer() then
		----玩家断线
		ListenToGameEvent("player_disconnect", Dynamic_Wrap(PlayerManager, "onEvent_playerDisconnect"), self)
	end

	----玩家连接
	ListenToGameEvent("player_connect_full", Dynamic_Wrap(PlayerManager, "onEvent_playerConnectFull"), self)
	----选择英雄
	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(PlayerManager, "onEvent_playerPickHero"), self)
	----玩家英雄的生成
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(PlayerManager, "onEvent_NPCSpawned"), self)
	----单位受伤
	ListenToGameEvent("entity_hurt", Dynamic_Wrap(PlayerManager, "onEvent_entityHurt"), self)
	----玩家使用技能
	ListenToGameEvent("dota_player_used_ability", Dynamic_Wrap(PlayerManager, "onEvent_dota_player_used_ability"), self)
	----玩家聊天
	ListenToGameEvent("player_chat", Dynamic_Wrap(PlayerManager, "onEvent_player_chat"), self)

	----玩家英雄升级
	----ListenToGameEvent("dota_player_gained_level", Dynamic_Wrap(PlayerManager, "onEvent_levelUp"), self)
end
----连接
function PlayerManager:onEvent_playerConnectFull(keys)
	keys.PlayerID = keys.userid
	if 0 > keys.PlayerID then
		return
	end
	-----@type Player
	local oPlayer = PlayerManager:getPlayer(keys.PlayerID)
	if nil == oPlayer then
		oPlayer = Player(keys.PlayerID)
		self.m_tabPlayers[keys.PlayerID] = oPlayer
		oPlayer.m_oCDataPlayer = PlayerResource:GetPlayer(oPlayer.m_nPlayerID)
	else
		oPlayer.m_oCDataPlayer = PlayerResource:GetPlayer(oPlayer.m_nPlayerID)
		----断线重连
		oPlayer:setDisconnect(false)
		----重新发送手牌
		oPlayer:sendHandCardData()
		----重新发操作
		for i = 1, #GMManager.m_tabOprtCan do
			local tabOprt = GMManager.m_tabOprtCan[i]
			if tabOprt.nPlayerID == keys.PlayerID then
				print("9[LUA]:ReconnectSend===========>>>>>>>>>>>>>>>")
				DeepPrint(tabOprt)
				self:sendMsg("GM_Operator", tabOprt, keys.PlayerID)
			end
		end
	end

	oPlayer.m_nUserID = keys.userid
end
----断线
function PlayerManager:onEvent_playerDisconnect(keys)
	print("onEvent_playerDisconnect")
	PrintTable(keys)
	-- PlayerID: 0
	-- name: wonder
	-- networkid: [U:1:137911060]
	-- reason: 2
	-- splitscreenplayer: -1
	-- userid: 2
	-- xuid: 76561198098176788
	if 0 > keys.PlayerID then
		return
	end
	-----@type Player
	local player = PlayerManager:getPlayer(keys.PlayerID)
	if nil == player then
		player = Player(keys.PlayerID)
		self.m_tabPlayers[keys.PlayerID] = player
		player.m_oCDataPlayer = PlayerResource:GetPlayer(keys.PlayerID)
	end

	----掉线随机英雄
	if
	-1 == PlayerResource:GetSelectedHeroID(keys.PlayerID) and not NULL(player.m_oCDataPlayer) and
	GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION
	then
		print("MakeRandomHeroSelection")
		---- player.m_oCDataPlayer:MakeRandomHeroSelection()
		HeroSelection:Disconnect(keys.PlayerID);
	end

	----设置断线
	player:setDisconnect(true)

	----轮询是否放弃比赛 和 掉线超时检测
	local function killPlayer()
		player.m_bAbandon = true
		if not player.m_bDie then
			if GS_DeathClearing == GMManager.m_typeState
			and player.m_bDeathClearing then
				----死亡清算时，放弃比赛，自动处理死亡清算
				GMManager:autoOprt(nil, player)
			else
				EventManager:fireEvent("Event_PlayerDie", { player = player })
			end
		end
	end
	local nTime = TIME_OUT_DISCONNECT or 300
	Timers:CreateTimer(5, function()
		nTime = nTime - 5
		local typeConnectState = PlayerResource:GetConnectionState(keys.PlayerID)

		----放弃比赛
		if DOTA_CONNECTION_STATE_ABANDONED == typeConnectState then
			killPlayer()
			EventManager:fireEvent('Event_Abandoned', { nPlayerID = keys.PlayerID })
			local tab = { tPlayerID = {} }
			tab.tPlayerID[keys.PlayerID] = keys.PlayerID
			-- EventManager:fireEvent('Event_EndGame', tab)
			return
		end
		----掉线中
		if DOTA_CONNECTION_STATE_DISCONNECTED == typeConnectState then
			----掉线超时
			if 0 >= nTime then
				if player.m_eHero then
					local tabKV = {}
					tabKV["[strHeroName]"] = GameRecord:encodeLocalize(player.m_eHero:GetUnitName())
					GameRecord:setGameRecord(TGameRecord_String, keys.PlayerID, {
						strText = GameRecord:encodeGameRecord(GameRecord:encodeLocalize("GameRecord_" .. TGameRecord_DisconnetOutTime, tabKV))
					})
				end
				killPlayer()
				return
			end
			return 5
		end
	end)
end
----英雄选择载入地图
function PlayerManager:onEvent_playerPickHero(keys)
	if PS_None == GMManager.m_typeState then
		print("onEvent_playerPickHero")
		local eHero = EntIndexToHScript(keys.heroindex)
		local oPlayer = self.m_tabPlayers[eHero:GetPlayerOwnerID()]
		if nil ~= oPlayer and not oPlayer.__init then
			oPlayer.m_eHero = eHero
			oPlayer:initPlayer()
			if nil == self.nInit then
				self.nInit = 0
			end
			self.nInit = self.nInit + 1
			if self.nInit == self:getPlayerCount() then
				self.nInit = nil
				Timers:CreateTimer(1, function()
					self.m_bAllPlayerInit = true
				end)
			end
		end
	end
end
----单位生成
function PlayerManager:onEvent_NPCSpawned(keys)
	---- print("onEvent_NPCSpawned")
	---- local eHero =  EntIndexToHScript(keys.entindex) ----单位
	---- if not eHero:IsHero() then
	---- 	return
	---- end
end
----单位受伤
function PlayerManager:onEvent_entityHurt(keys)
	---- print("onEvent_entityHurt")
end
----玩家英雄升级
function PlayerManager:onEvent_levelUp(tEvent)
	print("onEvent_levelUp")
end
----玩家使用技能
function PlayerManager:onEvent_dota_player_used_ability(tEvent)
	----	 {
	----	caster_entindex				 	= 454 (number)
	----	abilityname					 	= "LuaAbility_pudge_rot" (string)
	----	PlayerID							= 0 (number)
	----	splitscreenplayer			   	= -1 (number)
	---- }
	EventManager:fireEvent('dota_player_used_ability', tEvent)
end
--通过聊天输入执行命令
function PlayerManager:onEvent_player_chat(keys)
	-- DeepPrintTable(keys)
	local player = PlayerManager:getPlayer(keys.playerid)
	local tokens = string.split(string.lower(keys.text), " ")
	if DEBUG then
		if "-roll" == tokens[1] then
			GMManager._TestHelp_Roll_nRoll = tonumber(tokens[2])
		elseif "-item" == tokens[1] then
			player.m_eHero:AddItemByName(tokens[2])
		elseif "-gold" == tokens[1] then
			player:setGold(tonumber(tokens[2]))
		elseif "-levelup" == tokens[1] then
			for i = tonumber(tokens[2]), 1, -1 do
				local nLevelUpExp = LEVEL_EXP[player.m_eHero:GetLevel() + 1]
				if nLevelUpExp then
					player:setExpAdd(nLevelUpExp - player.m_eHero:GetCurrentXP())
				end
			end
		elseif "-roundup" == tokens[1] then
			GMManager.m_nRound = tonumber(tokens[2])
		elseif "-card" == tokens[1] then
			local card = CardFactory:create(tonumber(tokens[2]), player.m_nPlayerID)
			if card then
				player:setCardAdd(card)
			end
		elseif "-skin" == tokens[1] then
			local SkinID
			if tokens[3] then
				SkinID = tokens[2] .. '_' .. tokens[3]
			else
				local tSkin = SkinManager:getUseSink(player.m_nPlayerID, tonumber(tokens[2]))
				if not tSkin then
					return
				end
				SkinID = tSkin.SkinID
			end
			SkinManager:setUseSink(player.m_nPlayerID, SkinID, not tokens[3])
		elseif "-test" == tokens[1] then
		end
	end
end

----外用接口方法-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- 获取领地最少的玩家的领地数量
function PlayerManager:getLeastPathCount()
	local min = 0
	----@param player Player
	for pid, player in pairs(self.m_tabPlayers) do
		if PlayerManager:isAlivePlayer(player.m_nPlayerID) then
			local sum = player:getPathCount()
			if sum < min then
				min = sum
			end
		end
	end
	return min
end
---- 获取领地最少的玩家
function PlayerManager:getLeastPathPlayer()
	local min = PlayerManager:getLeastPathCount()
	local resPlayers = {}
	for pid, player in pairs(self.m_tabPlayers) do
		if PlayerManager:isAlivePlayer(player.m_nPlayerID) then
			local sum = player:getPathCount()
			if sum == min then
				table.insert(resPlayers, player)
			end
		end
	end
	return resPlayers
end
---- 是否领地最少的玩家
function PlayerManager:isLeastPathPlayer(playerid)
	local leastPlayers = PlayerManager:getLeastPathPlayer()
	return exist(leastPlayers, function(player)
		return player.m_nPlayerID == playerid
	end)
end
---- 获取领地最多的玩家的领地数量
function PlayerManager:getMostPathCount()
	local max = 0
	----@param player Player
	for pid, player in pairs(self.m_tabPlayers) do
		local sum = player:getPathCount()
		if sum > max then
			max = sum
		end
	end
	return max
end
---- 获取领地最多的玩家
function PlayerManager:getMostPathPlayer()
	local max = PlayerManager:getMostPathCount()
	local resPlayers = {}
	for pid, player in pairs(self.m_tabPlayers) do
		local sum = player:getPathCount()
		if sum == max then
			table.insert(resPlayers, player)
		end
	end
	return resPlayers
end
---- 是否领地最多的玩家
function PlayerManager:isMostPathPlayer(playerid)
	local mostPlayers = PlayerManager:getMostPathPlayer()
	return exist(mostPlayers, function(player)
		return player.m_nPlayerID == playerid
	end)
end
---- 处理屏蔽交易
function Process_TO_MultTrade(tData)
	if DEBUG then
		print("Process_TO_MultTrade: data is ")
		PrintTable(tData)
	end
	local mutePlayer = PlayerManager:getPlayer(tData.nPlayerMute)
	if tData.nPlayerMute ~= tData.PlayerID and mutePlayer then
		----@type Player
		local oPlayer = PlayerManager:getPlayer(tData.PlayerID)
		if oPlayer then
			oPlayer:setPlayerMuteTrade(tData.nPlayerMute, tData.bMute)
		end
	end
end