----皮肤管理模块
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if not SkinManager then
	SkinManager = {
		m_tPlayerSkin = {}, ----玩家拥有全部皮肤
		m_tPlayerSkinUseBase = {}, ----玩家使用的皮肤（后台）
		m_tPlayerSkinUse = {}, ----玩家使用的皮肤（当前）
		m_tCourierPoint = {}, ----信使出生点
		m_tCourier = {}, ----信使
	}
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
function SkinManager:init(bReload)
	if not bReload then
		self:registerEvent()
	end

	for i = 1, 100 do
		local ePoint = Entities:FindByName(nil, "courier_" .. i)
		if not ePoint then
			break
		end
		table.insert(self.m_tCourierPoint, ePoint)
	end

	if not DEBUG then
		return
	end
	----添加商品
	-- local tSkins = {}
	-- for SkinType, v in pairs(KeyValues.SkinsKv) do
	--	 ----获取皮肤类型
	--	 local typeSink
	--	 local tab = string.split(SkinType, '_')
	--	 if 2 <= #tab then
	--		 typeSink = tonumber(tab[2])
	--	 end
	--	 ----获取该类型的全部皮肤
	--	 if typeSink then
	--		 for SkinID, _ in pairs(v) do
	--			 local pos = string.find(SkinID, 'SkinID_')
	--			 if pos then
	--				 local tab = string.split(SkinID, '_')
	--				 if 3 <= #tab then
	--					 local sSkinID = tab[2] .. "_" .. tab[3]
	--					 tSkins[sSkinID] = {
	--						 sSkinID = sSkinID,
	--						 typeSkin = typeSink,
	--						 typeSkinLevel = SkinManager:getSkinLevel(sSkinID),
	--					 }
	--				 end
	--			 end
	--		 end
	--	 end
	-- end
	-- CustomNetTables:SetTableValue("Service", "Skins", tSkins)
end

function SkinManager:updateNetTables()
	for i, _ in pairs(PlayerManager.m_tabPlayers) do
		local tabData = CustomNetTables:GetTableValue("Service", "player_info_" .. i) or {}
		tabData['tSkinHas'] = self.m_tPlayerSkin[i]
		-- tabData['tSkinUse'] = self.m_tPlayerSkinUse[i]
		tabData['tSkinUse'] = {}
		for _, sSkinID in pairs(self.m_tPlayerSkinUse[i]) do
			table.insert(tabData['tSkinUse'], sSkinID)
		end
		CustomNetTables:SetTableValue("Service", "player_info_" .. i, tabData)
		print('Service player_info_' .. i .. '============')
		PrintTable(tabData)
	end
end

function SkinManager:getSkinLevel(sSkinID)
	local tab = string.split(sSkinID, '_')
	if 2 <= #tab then
		local nID = tonumber(tab[2])
		if 10000 > nID then
			return TSkinLevel_1
		elseif 20000 > nID then
			return TSkinLevel_2
		elseif 30000 > nID then
			return TSkinLevel_3
		elseif 40000 > nID then
			return TSkinLevel_4
		end
	end
	return TSkinLevel_1
end

----获取当前使用的皮肤
function SkinManager:getUseSink(nPlayerID, typeSkin)
	local tSkins = KeyValues.SkinsKv['SkinType_' .. typeSkin]
	if not tSkins then
		return
	end
	local tSkinInfo
	local SkinID = SkinManager.m_tPlayerSkinUse[nPlayerID][tonumber(typeSkin)]
	----没有就用默认的
	if not SkinID or '' == SkinID then
		SkinID = typeSkin .. "_0"
	end

	----皮肤信息
	tSkinInfo = tSkins['SkinID_' .. SkinID]
	if tSkinInfo then
		----有随机不同类型
		if tSkinInfo.Random then
			local nRoll = RandomInt(1, 100)
			for k, v in pairs(tSkinInfo.Random) do
				if nRoll < tonumber(v) then
					SkinID = k
					break
				end
			end
		end
		local tmp = tSkins[SkinID]
		if tmp then
			tSkinInfo = tmp
		end
		tSkinInfo['SkinID'] = SkinID
	end
	return tSkinInfo, tSkins['kind']
end
----设置使用的皮肤
function SkinManager:setUseSink(nPlayerID, sSkinID, bUnload)
	local tab = string.split(sSkinID, '_')
	if 0 == #tab then
		return
	end
	local typeSkin = tonumber(tab[1])
	if not SkinManager.m_tPlayerSkinUse[nPlayerID] then
		SkinManager.m_tPlayerSkinUse[nPlayerID] = {}
	end
	if bUnload then
		----一样才卸下
		if SkinManager.m_tPlayerSkinUse[nPlayerID][typeSkin] == sSkinID then
			SkinManager.m_tPlayerSkinUse[nPlayerID][typeSkin] = ''
			SkinManager:updateNetTables()
			EventManager:fireEvent("Event_UseSkinChange", { player = PlayerManager:getPlayer(nPlayerID) })
		end
	else
		----不一样就更换
		if SkinManager.m_tPlayerSkinUse[nPlayerID][typeSkin] ~= sSkinID then
			SkinManager.m_tPlayerSkinUse[nPlayerID][typeSkin] = sSkinID
			SkinManager:updateNetTables()
			EventManager:fireEvent("Event_UseSkinChange", { player = PlayerManager:getPlayer(nPlayerID) })
		end
	end
end

----设置皮肤
function SkinManager:setSink(typeSkin, eCaster, ...)
	if not IsValid(eCaster) then
		return
	end

	local tSkin, kindSkin = SkinManager:getUseSink(eCaster:GetPlayerOwnerID(), typeSkin)
	local tEvent = {
		eCaster = eCaster,
		tSkin = tSkin,
		bIgnore = false,
	}
	EventManager:fireEvent("Event_UpdataSkin" .. typeSkin, tEvent)
	if not tSkin or tEvent.bIgnore then
		return
	end

	if 'particle' == kindSkin then
		SkinManager:_setParticle(typeSkin, eCaster, tSkin, ...)
	elseif 'courier' == kindSkin then
		SkinManager:_setCourier(typeSkin, eCaster, tSkin, ...)
	end
end
----特效类型皮肤
function SkinManager:_setParticle(typeSkin, eCaster, tSkin, ...)
	local tTarget = { ... }
	local tEventID = {}

	for i, tInfo in pairs(tSkin) do
		if tostring(tonumber(i)) == i then
			----创建粒子
			local nPtclID = AMHC:CreateParticle(tInfo.EffectName, _G[tInfo.EffectAttachType], false, eCaster, tonumber(tInfo.Duration))
			----设置控制点
			if tInfo.ControlPointEntities then
				local function getTarget(str)
					if 'CASTER' == str then
						return eCaster
					elseif 'TARGET' == string.sub(str, 1, 6) then
						return tTarget[tonumber(string.sub(str, 8, 8))]
					end
				end
				for nCtrl, v in pairs(tInfo.ControlPointEntities) do
					for sTarget, sAttach in pairs(v) do
						local e = getTarget(sTarget)
						if e then
							ParticleManager:SetParticleControlEnt(nPtclID, tonumber(nCtrl), e, _G[tInfo.EffectAttachType], sAttach, e:GetAbsOrigin(), true)
						end
						break
					end
				end
			elseif tInfo.ControlPoints then
				for nCtrl, v in pairs(tInfo.ControlPoints) do
					local v3 = load(
					'local TARGET={...} ' ..
					'local CASTER=TARGET[1] ' ..
					'table.remove(TARGET, 1) ' ..
					'return ' .. v)(eCaster, ...)
					if 'userdata' == type(v3) then
						ParticleManager:SetParticleControl(nPtclID, tonumber(nCtrl), v3)
					end
				end
			end
			table.insert(tEventID, nPtclID)
		end
	end

	EventManager:register("Event_UpdataSkin" .. typeSkin, function(tEvent)
		if tEvent.eCaster == eCaster then
			----过滤相同不更新
			if tEvent.tSkin and tEvent.tSkin.SkinID == tSkin.SkinID then
				tEvent.bIgnore = true
				return
			end
			----移除当前的
			for _, v in pairs(tEventID) do
				ParticleManager:DestroyParticle(v, false)
			end
			return true
		end
	end)
end
----信使类型皮肤
function SkinManager:_setCourier(typeSkin, eCaster, tSkin, ...)
	local nPos = SkinManager:getCourierPos()
	local eCourier = AMHC:CreateUnit('courier', nPos, RandomInt(1, 360), eCaster, DOTA_TEAM_GOODGUYS)
	if not IsValid(eCourier) then
		return
	end
	FindClearSpaceForUnit(eCourier, nPos, true)
	eCourier.m_tSkinInfo = tSkin
	eCourier.m_eBoss = eCaster
	eCourier:SetEntityName(tSkin.SkinID)
	eCourier:AddNewModifier(eCaster, nil, 'modifier_courier', {})

	---@type Player
	local player = PlayerManager:getPlayer(eCaster:GetPlayerOwnerID())
	if player then
		table.insert(player.m_tCourier, eCourier)
	end

	----监听更新
	EventManager:register("Event_UpdataSkin" .. typeSkin, function(tEvent)
		if tEvent.eCaster == eCaster then
			----过滤相同不更新
			if tEvent.tSkin and tEvent.tSkin.SkinID == tSkin.SkinID then
				tEvent.bIgnore = true
				return
			end
			if player then
				for i, e in ipairs(player.m_tCourier) do
					if e == eCourier then
						table.remove(player.m_tCourier, i)
						break
					end
				end
			end
			if IsValid(eCourier) then
				eCourier:Destroy()
			end
			return true
		end
	end)
end
function SkinManager:getCourierPos()
	if 0 < #self.m_tCourierPoint then
		local i = RandomInt(1, #self.m_tCourierPoint)
		for n = #self.m_tCourierPoint, 1, -1 do
			local e = self.m_tCourierPoint[i]
			if not e._bCD then
				e._bCD = true
				Timers:CreateTimer(2, function()
					e._bCD = nil
				end)
				return e:GetAbsOrigin()
			end
			i = i - 1
			if i >= 0 then
				i = #self.m_tCourierPoint
			end
		end
	end
	return Vector(0, 0, 0)
end

----事件回调-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----注册事件
function SkinManager:registerEvent()
	EventManager:register("Event_Service_AllData", SkinManager.onEvent_Service_PlayerAllItems, SkinManager)
	EventManager:register("Event_Service_AllData", SkinManager.onEvent_Service_UseSkin, SkinManager)
	EventManager:register("Event_Service_PlayerAllItems", SkinManager.onEvent_Service_PlayerAllItems, SkinManager)
	EventManager:register("Event_Service_UseSkin", SkinManager.onEvent_Service_UseSkin, SkinManager)
	-- EventManager:register("Event_EndGame", SkinManager.onEvent_EndGame, SkinManager)
	ListenToGameEvent("player_connect_full", Dynamic_Wrap(SkinManager, "onEvent_playerConnectFull"), SkinManager)
end

function SkinManager:onEvent_playerConnectFull(tEvent)
	tEvent.PlayerID = tEvent.userid
	if not SkinManager.m_tPlayerSkin[tEvent.PlayerID] then
		SkinManager.m_tPlayerSkin[tEvent.PlayerID] = {}
	end
	if not SkinManager.m_tPlayerSkinUse[tEvent.PlayerID] then
		SkinManager.m_tPlayerSkinUse[tEvent.PlayerID] = {}
		SkinManager.m_tPlayerSkinUseBase[tEvent.PlayerID] = {}
	end
end

----后台过来的玩家拥有皮肤数据
function SkinManager:onEvent_Service_PlayerAllItems(tEvent)
	-- PrintTable(tEvent)
	---- gameid: 3
	---- query_all_items:
	---- 		76561198089564854:
	----记录拥有的皮肤
	local tPlayerSink = tEvent[ACTION_QUERY_ALL_ITEMS]
	if tPlayerSink then
		for i, _ in pairs(PlayerManager.m_tabPlayers) do
			local tSink = tPlayerSink[tostring(PlayerResource:GetSteamID(i))]
			if tSink then
				self.m_tPlayerSkin[i] = {}
				for _, tData in pairs(tSink) do
					local tab = string.split(tData['skin_id'], '_')
					-- local typeSkin = tonumber(tab[1])
					table.insert(self.m_tPlayerSkin[i], tData['skin_id'])
				end
			end
		end
	end

	self:updateNetTables()
end
----后台过来的皮肤使用数据
function SkinManager:onEvent_Service_UseSkin(tEvent)
	---- gameid: 3
	---- query_use_skin:
	---- 		76561198089564854:
	---- 				skintype_1: 1_1
	---- 				skintype_2: 2_3
	----记录使用的皮肤
	local tSinkUse = tEvent[ACTION_QUERY_USE_SKIN]
	if not tSinkUse then
		return
	end
	for i, _ in pairs(PlayerManager.m_tabPlayers) do
		local tSinkOne = tSinkUse[tostring(PlayerResource:GetSteamID(i))]
		if tSinkOne then
			self.m_tPlayerSkinUseBase[i] = {}
			for type, id in pairs(tSinkOne) do
				local tab = string.split(type, '_')
				local typeSkin = tonumber(tab[2])
				if 2 <= #tab then
					self.m_tPlayerSkinUseBase[i][typeSkin] = id
				end
			end
			EventManager:fireEvent("Event_UseSkinChange", { player = PlayerManager:getPlayer(i) })
		end
	end
	-- SkinManager.m_tPlayerSkinUseBase = clone(SkinManager.m_tPlayerSkinUse)
	if not SkinManager._bInitSkinUse then
		SkinManager._bInitSkinUse = true
		SkinManager.m_tPlayerSkinUse = clone(SkinManager.m_tPlayerSkinUseBase)
		self:updateNetTables()
	end
end
----玩家结束游戏,同步皮肤使用数据到后台
function SkinManager:onEvent_EndGame(tEvent)
	local tSyncSkinUseData = {}
	----获取与后台不同的皮肤
	for _, nPlayerID in pairs(tEvent.tPlayerID) do
		local tSkinUse = SkinManager.m_tPlayerSkinUse[nPlayerID]
		local tBase = SkinManager.m_tPlayerSkinUseBase[nPlayerID]
		local sSteamID = tostring(PlayerResource:GetSteamID(nPlayerID))
		for typeSkin, sSkinID in pairs(tSkinUse) do
			if not tBase or sSkinID ~= tBase[typeSkin] then
				if not tSyncSkinUseData[sSteamID] then
					tSyncSkinUseData[sSteamID] = {}
				end
				if sSkinID == '' then
					table.insert(tSyncSkinUseData[sSteamID], {
						skin_id = tBase[typeSkin],
						unload = true,
					})
				else
					table.insert(tSyncSkinUseData[sSteamID], {
						skin_id = sSkinID
					})
				end
			end
		end
	end
	print('EndGame tSyncSkinUseData=============')
	PrintTable(tSyncSkinUseData)
	----同步到后台
	for _, _ in pairs(tSyncSkinUseData) do
		Service:RequestUseSkin(tSyncSkinUseData)
		return
	end
end


----信使控制buff
COURIER_FAY_SPEED = 400
COURIER_FOLLOW_DIR = 200
COURIER_PLAY_RANGE = 200
COURIER_ATK_RANGE = 400
TCOURIER_STATE = {
	STATE_Play = 1,
	STATE_Idle = ACT_DOTA_IDLE,
	STATE_Atk = ACT_DOTA_ATTACK,
}
LinkLuaModifier("modifier_courier", "mode/SkinManager.lua", LUA_MODIFIER_MOTION_NONE)
modifier_courier = class({})
function modifier_courier:IsHidden()
	return true
end
function modifier_courier:IsDebuff()
	return false
end
function modifier_courier:IsPurgable()
	return false
end
function modifier_courier:IsPurgeException()
	return false
end
function modifier_courier:AllowIllusionDuplicate()
	return false
end
function modifier_courier:RemoveOnDeath()
	return false
end
function modifier_courier:OnDestroy()
	if IsClient() then
		return
	end
	self:StartIntervalThink(-1)
	EventManager:unregister('Event_OrderMoveToPos', self.onEvent_OrderMoveToPos, self)
	for k, v in pairs(SkinManager.m_tCourier) do
		if v == self.eCourier then
			table.remove(SkinManager.m_tCourier, k)
			break
		end
	end
end
function modifier_courier:OnCreated(kv)
	if IsClient() then
		return
	end
	self.eCourier = self:GetParent()
	self.m_typeState = TCOURIER_STATE.STATE_Idle
	self.m_nSpeedAdd = 0
	if self.eCourier.m_tSkinInfo.Aggressive and '0' ~= self.eCourier.m_tSkinInfo.Aggressive then
		self.m_bAggressive = true
	end
	----模型大小
	self:updataModel()
	self.ModelScale = tonumber(self.eCourier.m_tSkinInfo.ModelScale or 1)
	self.eCourier:SetModelScale(self.ModelScale)

	----设置模型皮肤
	if self.eCourier.m_tSkinInfo.Skin then
		self.eCourier:SetSkin(tonumber(self.eCourier.m_tSkinInfo.Skin))
	end

	self:StartIntervalThink(1)
	EventManager:register('Event_OrderMoveToPos', self.onEvent_OrderMoveToPos, self)
	table.insert(SkinManager.m_tCourier, self.eCourier)
end
function modifier_courier:OnIntervalThink()
	local eCourier = self.eCourier
	if not IsValid(eCourier) then
		self:Destroy()
		return
	end
	local eBoss = eCourier.m_eBoss
	if not IsValid(eBoss) then
		return
	end
	----根据状态做事情
	----攻击检测
	-- if self.m_bAggressive then
	--	 for _, v in pairs(SkinManager.m_tCourier) do
	--		 if IsValid(v) and v ~= eCourier then
	--			 local nDis = (v:GetAbsOrigin() - eCourier:GetAbsOrigin()):Length()
	--			 if nDis < COURIER_ATK_RANGE then
	--				 self.m_typeState = TCOURIER_STATE.STATE_Atk
	--				 self:attack(v)
	--				 return
	--			 end
	--		 end
	--	 end
	-- end
	if self.m_typeState == TCOURIER_STATE.STATE_Idle then
		----检测与大哥的距离
		local nDis = (eBoss:GetAbsOrigin() - eCourier:GetAbsOrigin()):Length()
		if nDis > COURIER_FOLLOW_DIR then
			----跟上去
			self:follow(eBoss)
			return
		end
	elseif self.m_typeState == TCOURIER_STATE.STATE_Play then
		self:play()
		return
	end

	----同步移动速度
	eCourier:SetBaseMoveSpeed(eBoss:GetIdealSpeed())
	self:updataModel()
	----让信使具有不同的反应时间
	self:StartIntervalThink(RandomFloat(0.1, 2))
end
----更新模型
function modifier_courier:updataModel(bFay)
	if self._bUpdataModel or not IsValid(self.eCourier) then
		return
	end

	local sModel
	local sEffect = self.eCourier.m_tSkinInfo.EffectName
	if bFay or self.eCourier:GetBaseMoveSpeed() + self.m_nSpeedAdd > COURIER_FAY_SPEED then
		-- self.eCourier:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
		sModel = self.eCourier.m_tSkinInfo.ModelFlying
		sEffect = self.eCourier.m_tSkinInfo.EffectNameFlying or sEffect
	else
		-- self.eCourier:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
		sModel = self.eCourier.m_tSkinInfo.Model
	end

	if self.eCourier:GetModelName() ~= sModel then
		self.eCourier:SetModel(sModel)
		self.eCourier:SetOriginalModel(sModel)

		if self.m_nPtcl then
			ParticleManager:DestroyParticle(self.m_nPtcl, false)
			self.m_nPtcl = nil
		end
		if sEffect then
			self.m_nPtcl = ParticleManager:CreateParticle(sEffect, self:GetEffectAttachType(), self.eCourier)
			ParticleManager:SetParticleControlEnt(self.m_nPtcl, 0, self.eCourier, PATTACH_POINT_FOLLOW, "attach_hitloc", self.eCourier:GetAbsOrigin(), true)
		end

		----切换模型CD
		self._bUpdataModel = true
		Timers:CreateTimer(1, function()
			self._bUpdataModel = false
		end)
	end
end
----跟随主人
function modifier_courier:follow(eTarget)
	----移动到大哥身后
	local eCourier = self:GetParent()

	----持续跟踪移动
	local sTime
	local tMoveData = {
		vPos = eTarget:GetAbsOrigin()
	}
	self:move(tMoveData, function()
		if sTime then
			Timers:RemoveTimer(sTime)
		end
	end)
	local nRange = COURIER_FOLLOW_DIR * 0.5
	sTime = Timers:CreateTimer(function()
		if IsValid(eTarget) then
			tMoveData.vPos = eTarget:GetAbsOrigin() + Vector(RandomInt(-nRange, nRange), RandomInt(-nRange, nRange), 0)
			return 0.1
		end
	end)
end
----移动
function modifier_courier:move(tMoveData, funCallBack)
	self:StartIntervalThink(-1)
	if self.m_sTimeMove then
		Timers:RemoveTimer(self.m_sTimeMove)
		self.m_sTimeMove = nil
	end
	local eCourier = self:GetParent()
	local eBoss = eCourier.m_eBoss

	----更新移动前的模型
	local nDis = (tMoveData.vPos - eCourier:GetAbsOrigin()):Length()

	if nDis > 10000 then
		eCourier:SetAbsOrigin(tMoveData.vPos)
		if funCallBack then
			funCallBack()
		end
		self:StartIntervalThink(1)
		return
	end

	if IsValid(eBoss) then
		eCourier:SetBaseMoveSpeed(eBoss:GetIdealSpeed())
	else
		eCourier:SetBaseMoveSpeed(300)
	end
	self:addSpeed(nDis)
	self:updataModel(not GridNav:CanFindPath(eCourier:GetAbsOrigin(), tMoveData.vPos))

	----持续跟踪移动
	local nRange = COURIER_FOLLOW_DIR * 0.5
	self.m_sTimeMove = Timers:CreateTimer(function()
		if IsValid(self) and IsValid(eCourier) then
			----按距离增加速
			nDis = (tMoveData.vPos - eCourier:GetAbsOrigin()):Length()
			if IsValid(eBoss) then
				eCourier:SetBaseMoveSpeed(eBoss:GetIdealSpeed())
			end
			self:addSpeed(nDis)

			----移动
			PathManager:moveToPos(eCourier, tMoveData.vPos, function(bSuccess)
				if bSuccess then
					if self.m_sTimeMove then
						Timers:RemoveTimer(self.m_sTimeMove)
						self.m_sTimeMove = nil
					end
					self:StartIntervalThink(1)
					if funCallBack then
						funCallBack()
					end
				end
			end)
			return 0.1
		end
	end)
end
----玩耍
function modifier_courier:play()
	if 0 >= self.m_nPlayTime then
		self.m_vPlayOrigin = nil
		self.m_typeState = TCOURIER_STATE.STATE_Idle
		return
	end

	----忽略控制
	self.m_bIgnoreOrder = true
	self:StartIntervalThink(-1)

	local eCourier = self:GetParent()
	if not self.m_vPlayOrigin then
		self.m_vPlayOrigin = eCourier:GetAbsOrigin()
	end
	local tMoveData = {
		vPos = self.m_vPlayOrigin + Vector(RandomInt(-COURIER_PLAY_RANGE, COURIER_PLAY_RANGE), RandomInt(-COURIER_PLAY_RANGE, COURIER_PLAY_RANGE), 0)
	}
	self:move(tMoveData, function()
		self.m_nPlayTime = self.m_nPlayTime - 1
		self.m_bIgnoreOrder = false
		self:StartIntervalThink(1)
		self:OnIntervalThink()
	end)
end
----攻击
function modifier_courier:attack(eTarget)
	self.eCourier:SetTeam(DOTA_TEAM_BADGUYS)
	self.eCourier:MoveToTargetToAttack(eTarget)
end
----计算加速
function modifier_courier:addSpeed(x)
	self.m_nSpeedAdd = x ^ 2 / 4000
end
----玩家移动订单
function modifier_courier:onEvent_OrderMoveToPos(tEvent)
	if not IsValid(self) or not IsValid(self:GetParent()) then
		return true
	end
	if self.m_bIgnoreOrder or tEvent.issuer_player_id_const ~= self:GetParent():GetPlayerOwnerID() then
		return
	end
	----信使前去探索
	local tMoveData = {
		vPos = Vector(tEvent.position_x, tEvent.position_y, tEvent.position_z)
	}
	self:move(tMoveData, function()
		----到达，让信使进入玩耍状态
		self.m_nPlayTime = RandomInt(0, 4)
		self.m_typeState = TCOURIER_STATE.STATE_Play
	end)
end
function modifier_courier:DeclareFunctions()
	return {
		-- MODIFIER_PROPERTY_MODEL_CHANGE,
		-- MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}
end
----起飞速度
function modifier_courier:GetVisualZDelta(params)
	if self:GetParent():GetBaseMoveSpeed() > COURIER_FAY_SPEED then
		return 200
	end
	return 0
end
----增加移速
function modifier_courier:GetModifierMoveSpeed_Absolute(params)
	if IsServer() then
		return self:GetParent():GetBaseMoveSpeed() + self.m_nSpeedAdd
	end
end
-- function modifier_courier:GetModifierModelChange(params)
--	 return "models/courier/baby_rosh/babyroshan.vmdl"
-- end
-- function modifier_courier:GetModifierModelScale(params)
--	 return 1
-- end
-- function modifier_courier:GetEffectName()
--	 local tSinkInfo = KeyValues.SkinsKv['SkinType_' .. TSINK_COURIER]['SkinID_' .. self:GetParent():GetName()]
--	 if tSinkInfo then
--		 return tSinkInfo.EffectName
--	 end
-- end
function modifier_courier:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end