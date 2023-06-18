if not IsServer() then
	return
end
require("service/payment")
--[[	一些需要用到的特殊函数
]]
--
function Sleep(fTime, szUnique)
	local co = coroutine.running()
	GameRules:GetGameModeEntity():Timer(fTime, function()
		coroutine.resume(co)
	end)
	coroutine.yield()
end

if Service == nil then
	Service = class({
		m_tRandomSkinOrder = nil, ----抽奖订单
	})
end
local public = Service

Address = "http://bg.yzygames.cn:88/service.php"
if DEBUG then
	-- Address = "http://47.103.114.114/api/service"
	-- Address = "http://localhost/api/service"
end

ACTION_DEBUG_SERVER_KEY = "debug_server_key"
ACTION_ERRORUNLOAD = "error_unload"

ACTION_REQUEST_QRCODE = "request_qrcode"					-- 请求支付
ACTION_QUERY_ORDER_STATUS = "query_order_status"			-- 支付信息
ACTION_REQUEST_ORDER_CLOSE = "request_order_close"			-- 取消支付
ACTION_QUERY_PLAYER_DATA = "query_player_data"				-- 获取玩家数据
ACTION_QUERY_ALL_ITEMS = "query_all_items"					-- 获取玩家物品库存
ACTION_QUERY_USE_SKIN = "query_use_skin"					-- 获取玩家使用的皮肤
ACTION_QUERY_GOODS = "query_goods"							-- 获取商品
ACTION_QUERY_All = "query_all"								-- 获取全部数据
ACTION_REQUEST_GAME_END = "request_game_end"				-- 请求游戏结算

ACTION_CHANGE_HERO_SKIN = "change_skin"						-- 改变皮肤
ACTION_BUY = "buy"											-- 购买物品
ACTION_RANDOM_SKIN = "random_skin"							-- 请求抽奖

function public:init(bReload)
	self.tStoreGoods = {}
	if not bReload then
		self.tPlayerStoreAllItems = {}
		self.tPlayerServiceData = {}
		self.m_tRandomSkinOrder = {}
		self.bServerChecked = false
	end

	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(public, "OnGameRulesStateChange"), public)
	EventManager:register("Event_Service_AllData", public.onEvent_Service_PlayerData, public)
	EventManager:register("Event_Service_PlayerData", public.onEvent_Service_PlayerData, public)
	CustomGameEventManager:RegisterListener("Svc_RandomSkin", public.onMsg_Svc_RandomSkin)
	CustomGameEventManager:RegisterListener("Svc_UseSkin", public.onMsg_Svc_UseSkin)
end

function public:HTTPRequest(sMethod, sAction, hParams, fTimeout, hFunc)
	do return end
	local szURL = Address .. "?action=" .. sAction
	local handle = CreateHTTPRequestScriptVM(sMethod, szURL)

	-- handle:SetHTTPRequestHeaderValue("Dedicated-Server-Key", GetDedicatedServerKeyV2(KEY))
	handle:SetHTTPRequestHeaderValue("Content-Type", "application/json;charset=uft-8")

	if hParams ~= nil then
		handle:SetHTTPRequestRawPostBody("application/json", json.encode(hParams))
	end

	handle:SetHTTPRequestAbsoluteTimeoutMS((fTimeout or 5) * 1000)

	handle:Send(function(response)
		hFunc(response.StatusCode, response.Body, response)
	end)
end

function public:HTTPRequestSync(sMethod, sAction, hParams, fTimeout)
	local co = coroutine.running()
	self:HTTPRequest(sMethod, sAction, hParams, fTimeout, function(iStatusCode, sBody, hResponse)
		coroutine.resume(co, iStatusCode, sBody, hResponse)
	end)
	return coroutine.yield()
end

function public:GetSendKey()
	if not DEBUG then
		return GetDedicatedServerKey('bnsl') .. GetDedicatedServerKeyV2('bngf')
	end
	return GetDedicatedServerKey('bnsl')
end

-- 是否和服务器通讯成功
function public:IsChecked()
	return self.bServerChecked
end

--请求全部数据
function public:RequestAllData()
	self._RequestAllDataCount = self._RequestAllDataCount or 1
	self._RequestAllDataCount = self._RequestAllDataCount + 1
	local tPostData = {
		all_player = {},
		server_key = self:GetSendKey(),
	}
	for i, _ in pairs(PlayerManager.m_tabPlayers) do
		tPostData['all_player'][tostring(i)] = {
			steamid32 = tostring(PlayerResource:GetSteamAccountID(i)),
			steamid64 = tostring(PlayerResource:GetSteamID(i)),
			nickname = PlayerResource:GetPlayerName(i),
		}
	end
	self:HTTPRequest("POST", ACTION_QUERY_All, tPostData, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			-- print("RequestAllData:")
			-- DeepPrintTable(hBody)
			if hBody ~= nil then
				self.bServerChecked = true
				EventManager:fireEvent("Event_Service_AllData", hBody)
				return
			end
		end

		if not DEBUG or self._RequestAllDataCount < 10 then
			self:RequestAllData()
		end
	end)
end

-- 请求商品
function public:RequestQueryGoods()
	local tPostData = {
		server_key = self:GetSendKey(),
	}
	self:HTTPRequest("POST", ACTION_QUERY_GOODS, tPostData, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			-- print("RequestQueryGoods:")
			-- DeepPrintTable(hBody)
			if hBody ~= nil then
				if 0 == hBody.result then
					self.tStoreGoods = hBody[ACTION_QUERY_GOODS]
					self:UpdateNetTables()
				end
				return
			end
		end
		if not DEBUG then
			self:RequestQueryGoods()
		end
	end)
end

-- 请求玩家数据
function public:RequestPlayerData(iPlayerID)
	local sSteamID32 = tostring(PlayerResource:GetSteamAccountID(iPlayerID))
	local sSteamID64 = tostring(PlayerResource:GetSteamID(iPlayerID))
	local sNickname = PlayerResource:GetPlayerName(iPlayerID)
	local tabPostData = {
		steamid32 = sSteamID32,
		steamid64 = sSteamID64,
		nickname = sNickname,
		server_key = self:GetSendKey(),
	}
	self:HTTPRequest("POST", ACTION_QUERY_PLAYER_DATA, tabPostData, 10, function(iStatusCode, sBody, a)
		print('RequestPlayerData type(a)=' .. type(a))
		DeepPrintTable(a)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			if hBody ~= nil then
				print("RequestPlayerData:")
				DeepPrintTable(hBody)
				self.bServerChecked = true
				EventManager:fireEvent("Event_Service_PlayerData", hBody)
				return
			end
		end
		-- self:RequestPlayerData(iPlayerID)
	end)
end

-- 请求结算
function public:RequestGameEnd(tRank, funCallBack)
	local tabPostData = {
		gameid = GMManager.m_nGameID,
		game_rank = tRank,
		server_key = self:GetSendKey(),
	}
	self:HTTPRequest("POST", ACTION_REQUEST_GAME_END, tabPostData, 10, function(iStatusCode, sBody, a)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			if hBody ~= nil then
				print("RequestGameEnd:")
				DeepPrintTable(hBody)
				funCallBack(hBody)
				return
			end
		end
		if not DEBUG then
			self:RequestGameEnd(tRank, funCallBack)
		end
	end)
end

-- 请求玩家所有道具
function public:RequestPlayerAllItems(iPlayerID, funCallBack)
	local sSteamid = tostring(PlayerResource:GetSteamID(iPlayerID))
	local tabPostData = {
		steamid64 = sSteamid,
		server_key = self:GetSendKey(),
	}
	self:HTTPRequest("POST", ACTION_QUERY_ALL_ITEMS, tabPostData, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			print("RequestPlayerAllItems:")
			if hBody ~= nil then
				self.bServerChecked = true
				EventManager:fireEvent("Event_Service_PlayerAllItems", hBody)
				if nil ~= funCallBack then
					funCallBack(hBody)
				end
				return
			end
		end

		self:RequestPlayerAllItems(iPlayerID, funCallBack)
	end)
end

-- 请求购买商品
function public:RequestPurchaseCommodity(iPlayerID, sID)
	local sSteamid = tostring(PlayerResource:GetSteamID(iPlayerID))

	self:HTTPRequest("POST", ACTION_BUY, { steamid = sSteamid, commodity_id = sID, server_key = GetDedicatedServerKeyV2(KEY) }, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			print("RequestPurchaseCommodity:")
			DeepPrintTable(hBody)
			self:RequestPlayerData(iPlayerID)
			self:RequestPlayerAllItems(iPlayerID)
			if hBody ~= nil and hBody.status == 0 then
			end
		end
	end)
end

-- 请求购买商品
function public:RequestRandomSkin(iPlayerID)
	local sSteamid = tostring(PlayerResource:GetSteamID(iPlayerID))

	local tPostData = {
		steamid64 = sSteamid,
		server_key = self:GetSendKey(),
	}
	self:HTTPRequest("POST", ACTION_RANDOM_SKIN, tPostData, 10, function(iStatusCode, sBody)
		public.m_tRandomSkinOrder[iPlayerID] = nil
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			print("RequestRandomSkin:")
			DeepPrintTable(hBody)
			if hBody ~= nil then
				CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(iPlayerID), "Svc_RandomSkinResult", {
					skin_id = hBody.skin_id,
					result = hBody.result,
				})
				if hBody.result == 0 then
					EventManager:fireEvent("Event_Service_PlayerData", hBody)
					EventManager:fireEvent("Event_Service_PlayerAllItems", hBody)
				end
				return
			end
		end
		----请求失败
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(iPlayerID), "Svc_RandomSkinResult", {
			result = 100,
		})
	end)
end
-- 请求购买商品
function public:RequestUseSkin(tSkinUse)
	local tPostData = {
		use_skins = tSkinUse,
		server_key = self:GetSendKey(),
	}
	self:HTTPRequest("POST", ACTION_CHANGE_HERO_SKIN, tPostData, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			print("RequestUseSkin:")
			DeepPrintTable(hBody)
			if hBody ~= nil then
				if hBody.result == 0 then
					EventManager:fireEvent("Event_Service_UseSkin", hBody)
				end
			end
		end
	end)
end

function public:RequestDebugServerKey()
	self:HTTPRequest("POST", ACTION_DEBUG_SERVER_KEY, { server_key = self:GetSendKey() }, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			print("RequestDebugServerKey:")
			DeepPrintTable(hBody)
		end
	end)
end

function public:UpdateNetTables()
	for nID, tab in pairs(self.tPlayerServiceData) do
		local tabData = CustomNetTables:GetTableValue("Service", "player_info_" .. nID) or {}
		tabData['nGold'] = tab['nGold']
		tabData['sLevel'] = tab['sLevel']
		CustomNetTables:SetTableValue("Service", "player_info_" .. nID, tabData)
	end

	PrintTable(self.tStoreGoods)
	CustomNetTables:SetTableValue("Service", "Skins", self.tStoreGoods)
	CustomNetTables:SetTableValue("Service", "store_goods", self.tStoreGoods)
	-- CustomNetTables:SetTableValue("service", "player_all_items", self.tPlayerStoreAllItems)
	-- CustomNetTables:SetTableValue("common", "service", {
	--	 server_checked = self.bServerChecked,
	-- })
end

--[[	监听事件
]]
--
function public:OnGameRulesStateChange()
	local state = GameRules:State_Get()
	if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		-- self:RequestDebugServerKey()
		self:RequestAllData()
		self:RequestQueryGoods()
		-- for iPlayerID = 0, PlayerResource:GetPlayerCount() - 1, 1 do
		--	 if PlayerResource:IsValidPlayerID(iPlayerID) then
		--		 self:RequestPlayerData(iPlayerID)
		--	 end
		-- end
		-- GameRules:GetGameModeEntity():Timer(2, function()
		--	 for iPlayerID = 0, PlayerResource:GetPlayerCount() - 1, 1 do
		--		 if PlayerResource:IsValidPlayerID(iPlayerID) then
		--			 self:RequestPlayerAllItems(iPlayerID)
		--		 end
		--	 end
		-- end)
		-- GameRules:GetGameModeEntity():Timer(10, function()
		--	 self.bServerChecked = true
		--	 self:UpdateNetTables()
		-- end)
		-- self:UpdateNetTables()
	end
end


function public:OnPurchaseGoods(eventSourceIndex, events)
	local iPlayerID = events.PlayerID
	local sCommodityID = events.commodity_id
	if sCommodityID ~= nil then
		self:RequestPurchaseCommodity(iPlayerID, sCommodityID)
	end
end

function public:onEvent_Service_PlayerData(tEvent)
	local tPlayerData = tEvent[ACTION_QUERY_PLAYER_DATA]
	if tPlayerData then
		for i, _ in pairs(PlayerManager.m_tabPlayers) do
			local tab = tPlayerData[tostring(PlayerResource:GetSteamID(i))]
			if tab then
				self.tPlayerServiceData[i] = {
					nGold = tonumber(tab.gold),
					sLevel = tab.rank_level,
				}
			end
		end
		self:UpdateNetTables()
	end
end

function public.onMsg_Svc_RandomSkin(_, tData)
	if not PlayerManager:getPlayer(tData.PlayerID) then
		return
	end
	local function check()
		local tPlayerData = public.tPlayerServiceData[tData.PlayerID]
		if not tPlayerData or not tPlayerData.nGold
		then
			return 1
		end
		----验证重复
		-- if not public.m_tRandomSkinOrder[tData.PlayerID] then public.m_tRandomSkinOrder[tData.PlayerID] = {} end
		if public.m_tRandomSkinOrder[tData.PlayerID] then
			return 2
		else
			public.m_tRandomSkinOrder[tData.PlayerID] = true
		end
		----验证鸡儿
		if tPlayerData.nGold < SKIN_RANDOM_GOLD then
			HudError:FireLocalizeError(tData.PlayerID, "Error_NoChichen")
			return 3
		end
		return 0
	end
	local tResult = { result = check() }
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tData.PlayerID), "Svc_RandomSkin", tResult)
	if 0 == tResult.result then
		public:RequestRandomSkin(tData.PlayerID)
	end
end

function public.onMsg_Svc_UseSkin(_, tData)
	if not PlayerManager:getPlayer(tData.PlayerID) then
		return
	end
	local tPlayerData = SkinManager.m_tPlayerSkin[tData.PlayerID]
	if not tPlayerData then
		return
	end
	local tab = string.split(tData.skin_id, '_')
	-- local typeSkin = tonumber(tab[1])
	if not exist(tPlayerData, tData.skin_id) then
		return
	end
	SkinManager:setUseSink(tData.PlayerID, tData.skin_id, 1 == tData.request)
end

----错误提交
if ERRORUPLOAD and IsServer() then
	public.m_tErrMsg = {}
	debug._traceback = debug.traceback
	debug.traceback = function(err, ...)
		local stack = debug._traceback(err, ...)
		local msg = tostring(err)
		if not public.m_tErrMsg[msg] then
			public.m_tErrMsg[msg] = pcall(function()
				local tPostData = {
					gmsvr_msg = stack,
					server_key = public:GetSendKey(),
				}
				tPostData.gmsvr_msg = tPostData.gmsvr_msg .. "\n" .. "gameid =" .. GMManager.m_nGameID
				public:HTTPRequest("POST", ACTION_ERRORUNLOAD, tPostData, 10, function(iStatusCode)
					if iStatusCode ~= 200 then
						public.m_tErrMsg[msg] = nil
					end
				end)
			end)
		end
		return stack
	end
end

return public