if PrecacheItems then
	table.insert(PrecacheItems, "particles/generic_hero_status/hero_levelup.vpcf")
	table.insert(PrecacheItems, "particles/units/heroes/hero_oracle/oracle_false_promise_cast_enemy.vpcf")
	table.insert(PrecacheItems, "particles/neutral_fx/roshan_spawn.vpcf")
end

--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
-----玩家类
if nil == Player then
	-----@class Player
	Player = class({
		m_bRoundFinished = nil			----此轮中已结束回合
		, m_bDisconnect = nil		   ----断线
		, m_bDie = nil				  ----死亡
		, m_bAbandon = nil			  ----放弃
		, m_bDeathClearing = nil		----亡国清算中
		, m_tMuteTradePlayers = {}	  ----交易屏蔽玩家id

		, m_nPlayerID = nil				----玩家ID
		, m_nUserID = nil				----userID
		, m_nSteamID = nil				----SteamID
		, m_nWageGold = nil			 ----每次工资
		, m_nGold = 0				   ----拥有的金币
		, m_nSumGold = 0				----总资产
		, m_nPassCount = nil			----剩余要跳过的回合数
		, m_nCDSub = nil				----冷却减缩固值
		, m_nManaSub = nil			  ----耗魔减缩固值
		, m_nLastAtkPlayerID = nil	  ----最后攻击我的玩家ID
		, m_nKill = nil				 ----击杀数
		, m_nGCLD = nil				 ----攻城数
		, m_nDamageHero = nil		   ----英雄伤害
		, m_nDamageBZ = nil			 ----兵卒伤害
		, m_nGoldMax = nil			  ----巅峰资产数
		, m_nBuyItem = nil			  ----可购装备数
		, m_nRank = nil				 ----游戏排名
		, m_nOprtOrder = nil			----操作顺序,根据m_PlayersSort中的index
		, m_nRollMove = nil			 ----roll点移动的次数（判断入狱给阎刃卡牌）
		, m_nMoveDir = nil			  ----方向	1=正向 -1=逆向

		, m_typeState = PS_None			----玩家状态
		, m_typeBuyState = TBuyItem_None----购物状态
		, m_typeTeam = nil			  ----自定义队伍

		, m_oCDataPlayer = nil			----官方CDOTAPlayer脚本
		, m_eHero = nil					----英雄单位

		, m_pathCur = nil				----当前英雄所在路径
		, m_pathLast = nil				----上次英雄停留路径
		, m_pathPassLast = nil			----上次英雄经过路径
		, m_pathMoveStart = nil			----上次移动起点路径

		, m_tabMyPath = nil				----占领的路径<路径类型,路径{}>
		, m_tabBz = nil					----兵卒
		, m_tabHasCard = nil			----手上的卡牌
		, m_tabUseCard = nil			----已使用的卡牌
		, m_tabDelCard = nil			----已移除的卡牌
		, m_tCourier = nil			  ----信使
	})
end

----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function Player:constructor(nPlayerID)
	self.m_nPlayerID = nPlayerID
	self.m_nSteamID = PlayerResource:GetSteamID(self.m_nPlayerID)
	self.m_nCDSub = 0
	self.m_nManaSub = 0
	self.m_nWageGold = 0
	self.m_nGold = 0
	self.m_nSumGold = 0
	self.m_nGoldMax = 0
	self.m_nPassCount = 0
	self.m_nLastAtkPlayerID = -1
	self.m_nKill = 0
	self.m_nGCLD = 0
	self.m_nDamageHero = 0
	self.m_nDamageBZ = 0
	self.m_tabMyPath = {}
	self.m_tabBz = {}
	self.m_tabHasCard = {}
	self.m_tabUseCard = {}
	self.m_tabDelCard = {}
	self.m_typeState = PS_None
	self.m_nBuyItem = 0
	self.m_typeBuyState = TBuyItem_None
	self.m_bDie = false
	self.m_bAbandon = false
	self.m_typeTeam = CUSTOM_TEAM[nPlayerID + 1]
	self.m_pathCur = nil
	self.m_nRollMove = 0
	self.m_nMoveDir = 1
	self.m_tMuteTradePlayers = {}
	self.m_tCourier = {}

	PlayerResource:SetCustomTeamAssignment(nPlayerID, DOTA_TEAM_GOODGUYS)
	self:registerEvent()

	----同步玩家网表信息
	self:setNetTableInfo()

	local tabData = CustomNetTables:GetTableValue("GameingTable", "all_playerids")
	if not tabData then tabData = {} end
	tabData[self.m_nPlayerID] = self.m_nPlayerID
	CustomNetTables:SetTableValue("GameingTable", "all_playerids", tabData)
	DeepPrint(tabData)

end

----玩家初始化
function Player:initPlayer()
	self.__init = true

	----控制权
	Timers:CreateTimer(0.1, function()
		self.m_eHero:SetControllableByPlayer(self.m_bDisconnect and -1 or self.m_nPlayerID, true)
	end)
	----队伍
	---- self.m_eHero:SetTeam(self.m_typeTeam)
	---- self.m_eHero:SetControllableByPlayer(self.m_nPlayerID, false)
	----碰撞
	self.m_eHero:SetHullRadius(1)
	----视野
	self.m_eHero:SetDayTimeVisionRange(300)
	self.m_eHero:SetNightTimeVisionRange(300)
	----禁止攻击
	self:setHeroCanAttack(false)
	self.m_eHero:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
	----禁止自动寻找最短路径
	----self.m_eHero:SetMustReachEachGoalEntity(true)
	----0升级点
	self.m_eHero:SetAbilityPoints(0)
	----0回蓝
	Timers:CreateTimer(0.1, function()
		self.m_eHero:SetMaxMana(0)
		self.m_eHero:SetBaseManaRegen(0)
		self.m_eHero:SetBaseManaRegen(-(self.m_eHero:GetManaRegen()))
	end)
	----0回血
	Timers:CreateTimer(0.1, function()
		self.m_eHero:SetBaseHealthRegen(0)
		local nHR = self.m_eHero:GetHealthRegen()
		self.m_eHero:SetBaseHealthRegen(-nHR)
	end)
	-----智力buff:修改智力增加的技能增强
	self.m_eHero.hIntModifier = self.m_eHero:AddNewModifier(self.m_eHero, nil, "modifier_intellect", {})
	----初始金币
	self:setGold(INITIAL_GOLD)
	self:setGoldUpdata()


	--[[d 移除饰品
	local children = self.m_eHero:GetChildren()
	for k,child in pairs(children) do
		if child:GetClassname() == "dota_item_wearable" then
			child:RemoveSelf()
		end
	end
	----]]
	----清空英雄物品
	for slot = 0, 9 do
		if self.m_eHero:GetItemInSlot(slot) ~= nil then
			self.m_eHero:RemoveItem(self.m_eHero:GetItemInSlot(slot))
		end
	end

	for i = 0, 23 do
		local oAblt = self.m_eHero:GetAbilityByIndex(i)
		if nil ~= oAblt then
			oAblt:SetLevel(1)
		end
	end

	----设置起点路径
	self:setPath(PathManager:getPathByType(TP_START)[1])

	----魔法修改触发事件
	local SpendMana = self.m_eHero.SpendMana
	self.m_eHero.SpendMana = function(eHero, nMana, oAblt)
		SpendMana(eHero, nMana, oAblt)
		EventManager:fireEvent("Event_HeroManaChange", { player = self, oAblt = oAblt })
	end
	local GiveMana = self.m_eHero.GiveMana
	self.m_eHero.GiveMana = function(eHero, nMana)
		GiveMana(eHero, nMana)
		EventManager:fireEvent("Event_HeroManaChange", { player = self })
	end
	local SetMana = self.m_eHero.SetMana
	self.m_eHero.SetMana = function(eHero, nMana)
		SetMana(eHero, nMana)
		EventManager:fireEvent("Event_HeroManaChange", { player = self })
	end

	----玩家死亡杀死英雄
	if self.m_bDie then
		self.m_eHero:SetRespawnsDisabled(true)
		self.m_eHero:ForceKill(true)
	end

	----更新皮肤
	self:updataSkin()

	----设置共享主单位
	ItemShare:setShareOwner(self.m_eHero)
end

----队伍
function Player:initTeam()
	self.m_typeTeam = PlayerResource:GetTeam(self.m_nPlayerID)
	PlayerResource:SetCustomTeamAssignment(self.m_nPlayerID, DOTA_TEAM_GOODGUYS)
	PlayerResource:UpdateTeamSlot(self.m_nPlayerID, DOTA_TEAM_GOODGUYS, self.m_nPlayerID)
	-- self.m_eHero:SetTeam(DOTA_TEAM_GOODGUYS)
end

----发送消息给玩家
function Player:sendMsg(strMsgID, tabData)
	CustomGameEventManager:Send_ServerToPlayer(self.m_oCDataPlayer, strMsgID, tabData)
end

----更新皮肤
function Player:updataSkin()
	----足迹
	SkinManager:setSink(TSINK_FOOTPRINT, self.m_eHero)
	----信使
	SkinManager:setSink(TSINK_COURIER, self.m_eHero)
	-- for _, e in pairs(self.m_tCourier) do
	--	 SkinManager:setSink(TSINK_FOOTPRINT, e)
	-- end
end

----设置玩家网表信息
function Player:setNetTableInfo()
	local tabData = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID)
	if not tabData then
		tabData = {
			bRoundFinished = self.m_bRoundFinished
			, nPathCurID = 1
			, nSteamID64 = PlayerResource:GetSteamAccountID(self.m_nPlayerID)
			, nSteamID32 = PlayerResource:GetSteamID(self.m_nPlayerID)
		}
	end

	if self.m_pathCur then
		tabData["nPathCurID"] = self.m_pathCur.m_nID
	end

	----拥有路径信息
	local tab1 = {}
	for _, tabPath in pairs(self.m_tabMyPath) do
		for _, oPath in pairs(tabPath) do
			table.insert(tab1, oPath.m_nID)
		end
	end
	tabData["tabPath"] = tab1

	----有兵卒的路径信息
	local tab3 = {}
	for typePath, tabPath in pairs(self.m_tabMyPath) do
		if TP_DOMAIN_1 <= typePath and 0 < #tabPath[1].m_tabENPC then
			table.insert(tab3, typePath)
		end
	end
	tabData["tabPathHasBZ"] = tab3

	tabData["nGold"] = self.m_nGold
	tabData["nSumGold"] = self.m_nSumGold
	tabData["nCard"] = #self.m_tabHasCard
	tabData["nCDSub"] = self.m_nCDSub
	tabData["nManaSub"] = self.m_nManaSub
	tabData["nKill"] = self.m_nKill
	tabData["nGCLD"] = self.m_nGCLD
	tabData["nBuyItem"] = self.m_nBuyItem
	tabData["typeBuyState"] = self.m_typeBuyState
	tabData["bDeathClearing"] = self.m_bDeathClearing
	tabData["nOprtOrder"] = self.m_nOprtOrder
	tabData["tMuteTradePlayers"] = self.m_tMuteTradePlayers or {}
	tabData["typeTeam"] = self.m_typeTeam

	---- tabData["tabHasCard"] = json.encode(self.m_tabHasCard)
	----设置网表
	CustomNetTables:SetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID, tabData)

	---- PrintTable(tabData)
end

function Player:GetGold()
	return self.m_nGold
end

----设置金钱
function Player:setGold(nGold)
	----if 10000 <= math.abs(nGold) then
	----print(debug.traceback("Stack trace"))
	----print(debug.getinfo(1))
	----print("error set gold=" .. nGold)
	----end
	local lastnGold = self.m_nGold

	-- if self.m_nGold > 0 and self.m_nGold < self.m_eHero:GetGold() then
	--	 self.m_nGold = self.m_eHero:GetGold()
	-- end
	-- if self.m_nGold <= 0 and self.m_eHero:GetGold() > 0 then
	--	 self.m_nGold = self.m_nGold + self.m_eHero:GetGold()
	-- end
	--
	nGold = nGold + self.m_nGold
	self.m_nGold = nGold

	-- if nGold > 0 then
	--	 self.m_eHero:SetGold(nGold, false)
	-- end
	-- self.m_eHero:SetGold(0, true)
	----设置网表
	local info = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID)
	info["nGold"] = self.m_nGold
	CustomNetTables:SetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID, info)

	if (lastnGold >= 0) ~= (nGold >= 0) then
		EventManager:fireEvent(DeathClearing.EvtID.Event_TO_SendDeathClearing, { nPlayerID = self.m_nPlayerID })
	end

	Timers:CreateTimer(0.1, function()
		self:setSumGold()
	end)
end
----给其他玩家金钱
function Player:giveGold(nGold, player)
	self.m_nLastAtkPlayerID = player.m_nPlayerID
	self:setGold(-nGold)
	player:setGold(nGold)
end
function Player:setGoldUpdata()
	Timers:CreateTimer(function()
		if not IsValid(self.m_eHero) then
			return
		end
		if 0 < self.m_nGold then
			self.m_eHero:SetGold(self.m_nGold, false)
		else
			self.m_eHero:SetGold(0, false)
		end
		self.m_eHero:SetGold(0, true)
		return 0.1
	end)
end

----工资
function Player:SetWageGold(nGold)
	self.m_nWageGold = nGold
end
function Player:getWageGold()
	return self.m_nWageGold
end

----设置总资产
function Player:setSumGold()
	self.m_nSumGold = self.m_nGold
	----统计领地
	for k, v in pairs(self.m_tabMyPath) do
		self.m_nSumGold = self.m_nSumGold + (PATH_TO_PRICE[k] * #v)
	end

	----统计装备
	local function getItemSunGold(e)
		for slot = 0, 8 do
			local item = e:GetItemInSlot(slot)
			if item then
				local nGoldCost = GetItemCost(item:GetAbilityName())
				self.m_nSumGold = self.m_nSumGold + nGoldCost
			end
		end
	end
	getItemSunGold(self.m_eHero)

	----统计兵卒
	if 0 < #self.m_tabBz then
		-- getItemSunGold(self.m_tabBz[1])
		for k, v in pairs(self.m_tabBz) do
			if not v:IsNull() then
				local ablt = v:FindAbilityByName("xj_" .. v.m_path.m_typePath)
				if ablt then
					for i = ablt:GetLevel() - 1, 0, -1 do
						local nGoldCost = ablt:GetGoldCost(i)
						self.m_nSumGold = self.m_nSumGold + nGoldCost * -2
					end
				end
			end
		end
	end

	if self.m_nGoldMax < self.m_nSumGold then
		self.m_nGoldMax = self.m_nSumGold
	end

	----设置网表
	local info = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID)
	info["nSumGold"] = self.m_nSumGold
	CustomNetTables:SetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID, info)
end
----禁止交易
function Player:setPlayerMuteTrade(nPlayerID, bMute)
	if 1 == bMute then
		if not exist(self.m_tMuteTradePlayers, nPlayerID) then
			table.insert(self.m_tMuteTradePlayers, nPlayerID)
		end
	else
		remove(self.m_tMuteTradePlayers, nPlayerID)
	end
	if DEBUG then
		print('debug setPlayerMuteTrade: ', nPlayerID, bMute)
		PrintTable(self.m_tMuteTradePlayers)
	end
	self:setNetTableInfo()
end
---- 是否已屏蔽交易玩家
function Player:isPlayerMuteTrade(nPlayerID)
	return exist(self.m_tMuteTradePlayers, nPlayerID)
end

----设置玩家状态
function Player:setState(typeState, ...)
	if 0 < typeState then
		local typeNew = bit.bor(typeState, self.m_typeState)
		typeState = typeNew - self.m_typeState
		self.m_typeState = typeNew
	else
		typeState = bit.band(-typeState, self.m_typeState)
		self.m_typeState = self.m_typeState - typeState
	end

	----判断是否有修改过以下状态
	if 0 < bit.band(PS_AtkBZ, typeState) then
		----设置兵卒可否攻击
		local arg = { ... }
		self:setAllBzAttack()
	end
	if 0 < bit.band(PS_AtkHero, typeState) then
		----设置英雄可否攻击
		local bCan = 0 < bit.band(PS_AtkHero, self.m_typeState)
		self:setHeroCanAttack(bCan)
		self.m_eHero.m_bBattle = bCan
		if bCan then
			----攻击移除隐身状态
			self:setState(-PS_Invis)
		end

		----计算卡牌可用状态
		self:setCardCanCast()

	end
	if 0 < bit.band(PS_MagicImmune, typeState) then
		----设置英雄魔免
		if 0 < bit.band(PS_MagicImmune, self.m_typeState) then
			AMHC:AddAbilityAndSetLevel(self.m_eHero, "magic_immune")
		else
			AMHC:RemoveAbilityAndModifier(self.m_eHero, "magic_immune")
		end
	end
	if 0 < bit.band(PS_PhysicalImmune, typeState) then
		----设置英雄物免
		if 0 < bit.band(PS_PhysicalImmune, self.m_typeState) then
			AMHC:AddAbilityAndSetLevel(self.m_eHero, "physical_immune")
		else
			AMHC:RemoveAbilityAndModifier(self.m_eHero, "physical_immune")
		end
	end
	if 0 < bit.band(PS_Rooted, typeState) then
		----设置英雄禁止移动
		if 0 < bit.band(PS_Rooted, self.m_typeState) then
			AMHC:AddAbilityAndSetLevel(self.m_eHero, "rooted")
		else
			AMHC:RemoveAbilityAndModifier(self.m_eHero, "rooted")

			----触发事件：禁止移动取消
			EventManager:fireEvent("Event_RootedDisable", { player = self })

		end
	end
	if 0 < bit.band(PS_InPrison, typeState) then
		----设置兵卒攻击状态
		self:setAllBzAttack()
		----计算卡牌可用状态
		self:setCardCanCast()
	end
	if 0 < bit.band(PS_Moving, typeState) then
		if 0 < bit.band(PS_Moving, self.m_typeState) then
			----玩家开始移动
			EventManager:fireEvent("Event_PlayerMove", { player = self })
		else
			----玩家结束移动
			EventManager:fireEvent("Event_PlayerMoveEnd", { player = self })
		end

		----计算卡牌可用状态
		Timers:CreateTimer(function()
			self:setCardCanCast()
		end)
	end
	if 0 < bit.band(PS_Pass, typeState) then
		if 0 < bit.band(PS_Moving, self.m_typeState) then
			EventManager:fireEvent("Event_PlayerPass", { player = self })
		else
			EventManager:fireEvent("Event_PlayerPassEnd", { player = self })
		end
	end
	if 0 < bit.band(PS_Invis, typeState) then
		if 0 < bit.band(PS_Invis, self.m_typeState) then
			EventManager:fireEvent("Event_PlayerInvis", { player = self })

			----监听施法解隐身
			self._setState_Invis_onUsedAbltID = EventManager:register('dota_player_used_ability', function(tEvent)
				if not NULL(self.m_eHero) and tEvent.caster_entindex == self.m_eHero:GetEntityIndex() then
					self:setState(-PS_Invis)
					return true
				end
			end)
		else
			EventManager:fireEvent("Event_PlayerInvisEnd", { player = self })
			EventManager:unregisterByID(self._setState_Invis_onUsedAbltID, 'dota_player_used_ability')
			self._setState_Invis_onUsedAbltID = nil
		end
	end
end

----设置跳过回合
function Player:setPass(nCount, typeAnmt)
	if 0 >= self.m_nPassCount then
		self:setState(PS_Pass)
		self.m_nPassCount = nCount
		----监听玩家回合开始，跳过回合
		local function onEventPlayerRoundBegin(tabEvent)
			if tabEvent.oPlayer == self then
				----跳过一回合
				tabEvent.bIgnore = true
				tabEvent.bRoll = false
				self.m_nPassCount = self.m_nPassCount - 1
				EventManager:fireEvent("Event_PlayerPassOne", { player = self })
				-- GMManager:setState(GS_Finished)
				GSManager:setState(GS_Finished)
				----次数达到不再跳过
				if 0 >= self.m_nPassCount then
					self:setState(-PS_Pass)
					return true
				end
			end
		end

		EventManager:register("Event_PlayerRoundBegin", onEventPlayerRoundBegin)
		----监听pass状态解除
		EventManager:register("Event_PlayerPassEnd", function(tabEvent)
			if tabEvent.player == self then
				EventManager:unregister("Event_PlayerRoundBegin", onEventPlayerRoundBegin)
				self.m_nPassCount = 0
				return true
			end
		end)
	elseif nCount > self.m_nPassCount then
		----解除上一次
		self:setState(-PS_Pass)
		----再次设置
		self:setPass(nCount)
	end
end

----设置玩家自己回合结束
function Player:setRoundFinished(bVal)
	self.m_bRoundFinished = bVal

	if self.m_bRoundFinished then
		----触发玩家回合结束事件
		EventManager:fireEvent("Event_PlayerRoundFinished", self)
	end

	----同步玩家网表信息
	self:setNetTableInfo()
end

----移动到坐标
function Player:moveToPos(v3, funCallBack)
	----验证能否到达
	if not self.m_eHero:HasFlyMovementCapability() and not GridNav:CanFindPath(self.m_eHero:GetOrigin(), v3) then
		if funCallBack then
			funCallBack(false)
		end
		return
	end

	----开始移动
	self:setState(PS_Moving)
	local funMoveEnd
	-- local funContinue = function(tabEvent)
	--	 -- if nil ~= tabEvent and tabEvent.player ~= self then
	--	 if nil == tabEvent or tabEvent.player ~= self or self.m_bDie then
	--		 return
	--	 end
	--	 PathManager:moveToPos(self.m_eHero, v3, funMoveEnd)
	-- end
	----注册监听禁止移动结束事件:没移动完继续移动
	-- EventManager:register("Event_RootedDisable", funContinue)
	----设置移动
	funMoveEnd = function(bSuccess)
		-- EventManager:unregister("Event_RootedDisable", funContinue)
		self:setState(-PS_Moving)
		if nil ~= funCallBack then
			funCallBack(bSuccess)
		end
		----解除事件注册
	end
	PathManager:moveToPos(self.m_eHero, v3, funMoveEnd)

	----设置计时器监听移动结束，触发回调
	---- Timers:CreateTimer(0, function()
	----	 local nDis = (self.m_eHero:GetOrigin() - v3):Length2D()
	----	 local nCheckDis = 30
	----	 nCheckDis = self.m_eHero:GetIdealSpeed() * 0.35 - 75
	----	 if 30 > nCheckDis then
	----		 nCheckDis = 30
	----	 end
	----	 if nCheckDis > nDis then
	----		 ----移动结束
	----		 self:setState(-PS_Moving)
	----		 if nil ~= funCallBack then
	----			 funCallBack()
	----		 end
	----		 ----解除事件注册
	----		 EventManager:unregister("Event_RootedDisable", funMove)
	----		 return nil
	----	 end
	----	 return 0.1
	---- end)
end
----移动到路径
function Player:moveToPath(path, funCallBack)
	----开始移动
	self:setState(PS_Moving)
	self.m_pathMoveStart = self.m_pathCur

	if path ~= self.m_pathCur then
		----触发离开路径
		EventManager:fireEvent("Event_LeavePath", { player = self, path = self.m_pathMoveStart })
	end

	----注册监听禁止移动结束事件:没移动完继续移动
	local funMoveEnd
	-- local function funContinue(tabEvent)
	--	 -- if nil ~= tabEvent and tabEvent.player ~= self and self.m_bDie then
	--	 if nil == tabEvent or tabEvent.player ~= self or self.m_bDie then
	--		 return
	--	 end
	--	 PathManager:moveToPath(self.m_eHero, path, true, funMoveEnd)
	-- end
	-- EventManager:register("Event_RootedDisable", funContinue)
	----监听移动经过路径
	local function funPassingPath(tabEvent)
		if tabEvent.entity == self.m_eHero then
			self:setPath(tabEvent.path, true)
		end
	end
	EventManager:register("Event_PassingPath", funPassingPath)

	----设置移动
	funMoveEnd = function(bSuccess)
		-- EventManager:unregister("Event_RootedDisable", funContinue)
		EventManager:unregister("Event_PassingPath", funPassingPath)
		self:setState(-PS_Moving)
		if bSuccess and not self.m_bDie then
			self:setPath(path)
		end
		if nil ~= funCallBack then
			funCallBack(bSuccess)
		end
	end
	PathManager:moveToPath(self.m_eHero, path, true, funMoveEnd)
end
function Player:moveStop()
	PathManager:moveStop(self.m_eHero, false)
end
----闪现到路径
function Player:blinkToPath(path)
	self.m_eHero:SetOrigin(path.m_entity:GetOrigin())
	FindClearSpaceForUnit(self.m_eHero, path:getNilPos(self.m_eHero), true)

	----设置当前路径
	self.m_pathMoveStart = self.m_pathCur

	if path ~= self.m_pathCur then
		----触发离开路径
		EventManager:fireEvent("Event_LeavePath", { player = self, path = self.m_pathMoveStart })
	end

	self:setPath(path)
end
----复位在当前路径
function Player:resetToPath()
	----复位
	self.m_eHero:SetOrigin(self.m_pathCur.m_entity:GetOrigin())
	FindClearSpaceForUnit(self.m_eHero, self.m_pathCur:getNilPos(self.m_eHero), true)

	----朝向下一路径
	local pathNext = PathManager:getNextPath(self.m_pathCur, 1)
	local v3 = pathNext.m_entity:GetAbsOrigin() - self.m_pathCur.m_entity:GetAbsOrigin()
	v3 = v3:Normalized()
	self.m_eHero:MoveToPosition(self.m_eHero:GetAbsOrigin() + v3)
end
----获取领地数量
function Player:getPathCount()
	local sum = 0
	for k, v in pairs(self.m_tabMyPath) do
		sum = sum + #v
	end
	return sum
end
----设置当前路径
-----@param path Path
function Player:setPath(path, bPass)
	if bPass then
		----经过某地
		self.m_pathPassLast = self.m_pathCur
	else
		----抵达目的地
		self.m_pathLast = self.m_pathMoveStart
		if self.m_pathLast then
			self.m_pathLast:setEntityDel(self.m_eHero)
		end
		if path then
			----加入
			path:setEntityAdd(self.m_eHero)
		end
	end

	if self.m_pathCur ~= path then
		----触发当前路径变更
		self.m_pathCur = path
		EventManager:fireEvent("Event_CurPathChange", { player = self })
	end
	self.m_eHero.m_path = path

	if not bPass then
		EventManager:fireEvent("Event_JoinPath", { player = self })
	end

	----同步玩家网表信息
	self:setNetTableInfo()
end
----是否拥有路径
function Player:isHasPath(nPathID)
	for _, v in pairs(self.m_tabMyPath) do
		for _, v2 in pairs(v) do
			if nPathID == v2.m_nID then
				return true
			end
		end
	end
	return false
end
----添加占领路径
function Player:setMyPathAdd(path)
	if self.m_bDie or self:isHasPath(path.m_nID) then
		return
	end

	if nil ~= self.m_tabMyPath[path.m_typePath] then
		table.insert(self.m_tabMyPath[path.m_typePath], path)
	else
		self.m_tabMyPath[path.m_typePath] = { path }
	end

	----领地添加领主
	path:setOwner(self)

	----计算总资产
	self:setSumGold()

	----同步玩家网表信息
	self:setNetTableInfo()
end
----删除占领路径
function Player:setMyPathDel(path)
	if not self:isHasPath(path.m_nID) then
		return
	end

	for i = 1, #self.m_tabMyPath[path.m_typePath] do
		if path.m_nID == self.m_tabMyPath[path.m_typePath][i].m_nID then
			if path.m_nOwnerID == self.m_nPlayerID then
				path:setOwner()
			end

			if path.m_tabENPC then
				for i = #path.m_tabENPC, 1, -1 do
					self:removeBz(path.m_tabENPC[i])
				end
			end

			table.remove(self.m_tabMyPath[path.m_typePath], i)
			if 0 == #self.m_tabMyPath[path.m_typePath] then
				self.m_tabMyPath[path.m_typePath] = nil
			end
			break
		end
	end

	----同步玩家网表信息
	self:setNetTableInfo()
end
----获取占领路径数量
function Player:getMyPathCount(funFilter)
	local nCount = 0
	for k, v in pairs(self.m_tabMyPath) do
		if funFilter then
			nCount = nCount + funFilter(k, v)
		else
			nCount = nCount + #v
		end
	end
	return nCount
end
----给其他玩家连地
function Player:setMyPathsGive(tPaths, player)
	----验证同类型
	local typePath
	for _, path in pairs(tPaths) do
		if not typePath then
			typePath = path.m_typePath
		elseif typePath ~= path.m_typePath then
			return
		end
	end

	local tPathAndBZLevel = {}

	for _, path in pairs(tPaths) do
		if path.m_tabENPC and path.m_tabENPC[1] and not path.m_tabENPC[1]:IsNull() then
			tPathAndBZLevel[path] = self:getBzStarLevel(path.m_tabENPC[1])
		end
		player:setMyPathAdd(path)
		self:setMyPathDel(path)
	end

	----还原兵卒等级
	for path, nLevel in pairs(tPathAndBZLevel) do
		if path.m_tabENPC[1] and not path.m_tabENPC[1]:IsNull() then
			nLevel = nLevel - player:getBzStarLevel(path.m_tabENPC[1])
			if 0 ~= nLevel then
				player:setBzStarLevelUp(path.m_tabENPC[1], nLevel)
			end
		end
	end
end

----创建兵卒到领地
function Player:createBzOnPath(path, nStarLevel, bLevelUp)
	if nil == path or not instanceof(path, PathDomain) then
		return
	end

	nStarLevel = nStarLevel or 1

	----创建单位
	local strName = HERO_TO_BZ[self.m_eHero:GetUnitName()]
	for i = nStarLevel, 2, -1 do
		strName = strName .. 1
	end

	local eBZ = AMHC:CreateUnit(strName, path.m_eCity:GetOrigin(), path.m_eCity:GetAnglesAsVector().y, self.m_eHero, DOTA_TEAM_GOODGUYS)
	eBZ:SetMaxHealth(eBZ:GetMaxHealth() + 500)
	-- eBZ:SetBaseMaxHealth(eBZ:GetBaseMaxHealth() * 2)
	eBZ:SetDayTimeVisionRange(300)
	eBZ:SetNightTimeVisionRange(300)
	-----添加数据
	table.insert(self.m_tabBz, eBZ)
	table.insert(path.m_tabENPC, eBZ)
	eBZ.m_path = path
	eBZ.m_bBZ = true

	----设置兵卒技等级
	eBZ.m_bAbltBZ = eBZ:GetAbilityByIndex(0)
	-- eBZ.m_bAbltBZ:SetLevel(nStarLevel)
	--
	----设置技能
	if BZ_MAX_LEVEL <= nStarLevel then
		----设置巅峰技能
		local oAblt2 = AMHC:AddAbilityAndSetLevel(eBZ, "yjxr_max", BZ_MAX_LEVEL)
		eBZ:SwapAbilities(eBZ.m_bAbltBZ:GetAbilityName(), "yjxr_max", true, true)
	else
		AMHC:AddAbilityAndSetLevel(eBZ, "yjxr_" .. path.m_typePath, nStarLevel)
		eBZ:SwapAbilities(eBZ.m_bAbltBZ:GetAbilityName(), "yjxr_" .. path.m_typePath, true, true)
	end
	if 1 ~= nStarLevel then
		AMHC:AddAbilityAndSetLevel(eBZ, "xj_" .. path.m_typePath, nStarLevel)
		local oAblt1 = eBZ:GetAbilityByIndex(1)
		if oAblt1 then
			eBZ:SwapAbilities(oAblt1:GetAbilityName(), "xj_" .. path.m_typePath, not oAblt1:IsHidden(), true)
		end
	end

	----重置能量
	eBZ:SetMana(0)

	----添加星星特效
	AMHC:ShowStarsOnUnit(eBZ, nStarLevel)

	----设置可否攻击
	self:setAllBzAttack()

	----设置可否被攻击
	self:setBzBeAttack(eBZ, false)

	----触发事件
	EventManager:fireEvent("Event_BZCreate", { entity = eBZ })

	----设置等级
	---- local tData = KeyValues.UnitsKv[eBZ:GetUnitName()]
	---- if tData and tData.Level_BG then
	----	 for i = 2, tData.Level_BG do
	----		 eBZ:LevelUp(false)
	----	 end
	---- end
	self:setBzLevelUp(eBZ)

	----同步玩家网表信息
	self:setNetTableInfo()

	----添加兵卒物品共享
	---- for k, v in pairs(self.m_tabBz) do
	----	 if v ~= eBZ then
	----		 v:syncItem(eBZ)----同步装备
	----		 ItemShare:setShareAdd(eBZ, v)   ----设置共享
	----		 break
	----	 end
	---- end
	self.m_eHero:syncItem(eBZ)				 ----同步装备
	ItemShare:setShareAdd(eBZ, self.m_eHero)   ----设置共享

	----特效
	if bLevelUp then
		AMHC:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_cast_enemy.vpcf", PATTACH_ABSORIGIN_FOLLOW, false, eBZ, 5)
	else
		local nPtclID = AMHC:CreateParticle("particles/neutral_fx/roshan_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, false, eBZ, 5)
		ParticleManager:SetParticleControl(nPtclID, 0, Vector(eBZ:GetOrigin().x, eBZ:GetOrigin().y, 0))
	end

	return eBZ
end
----替换兵卒到领地
function Player:replaceBzOnPath(path)
	local eBZ = path.m_tabENPC[1]
	table.remove(path.m_tabENPC, 1)
	local nLevel
	---- local tabItems = {}
	if nil ~= eBZ then
		nLevel = self:getBzStarLevel(eBZ)

		----获取身上装备
		---- tabItems = AMHC:GetAllItemsInUnits({ eBZ })
		---- for _, v in pairs(tabItems) do
		----	 eBZ:DropItemAtPositionImmediate(v, Vector(-3000, -3000, -3000))
		---- end
		----移除低级兵卒
		local oPlayerBZOwner = PlayerManager:getPlayer(eBZ:GetPlayerOwnerID())
		oPlayerBZOwner:removeBz(eBZ)
	end

	----造新兵卒
	eBZ = self:createBzOnPath(path, nLevel)

	----添加装备
	---- AMHC:GiveOldItems2Unit(tabItems, eBZ)
	return eBZ
end
----移除兵卒
function Player:removeBz(eBZ)
	if NULL(eBZ) then
		return
	end
	local bHas
	for k, v in pairs(self.m_tabBz) do
		if eBZ == v then
			table.remove(self.m_tabBz, k)
			bHas = true
			break
		end
	end
	if not bHas then
		return
	end

	for typePath, tabPath in pairs(self.m_tabMyPath) do
		if eBZ.m_path.m_typePath == typePath then
			for k, oPath in pairs(tabPath) do
				if eBZ.m_path == oPath then
					for k2, eBZ2 in pairs(oPath.m_tabENPC) do
						if eBZ == eBZ2 then
							table.remove(oPath.m_tabENPC, k2)
							break
						end
					end
					break
				end
			end
			break
		end
	end

	----触发事件
	EventManager:fireEvent("Event_BZDestroy", { entity = eBZ })

	----解除装备共享
	ItemShare:setShareDel(eBZ)

	----移除buff
	local tBuffs = eBZ:FindAllModifiers()
	for k, v in pairs(tBuffs) do
		eBZ:RemoveModifierByName(v:GetName())
	end

	----处理装备
	if 0 < #self.m_tabBz then
		----移除
		for slot = 0, 8 do
			ItemManager:removeItem(eBZ, eBZ:GetItemInSlot(slot))
		end
	else
		----最后的兵卒，装备给英雄
		---- local tItems = AMHC:GetAllItemsInUnits({ eBZ })
		---- local nItem = #tItems
		---- local nCount = nItem - (9 - self.m_eHero:getItemCount())
		---- if 0 < nCount then
		----	 table.sort(tItems, function(a, b)
		----		 return GetItemCost(a:GetAbilityName()) < GetItemCost(b:GetAbilityName())
		----	 end)
		----	 for i = 1, nCount do
		----		 eBZ:SellItem(tItems[i])
		----	 end
		---- else
		----	 nCount = 0
		---- end
		---- for i = nCount + 1, nItem do
		----	 eBZ:giveItem(self.m_eHero, tItems[i])
		---- end
	end

	eBZ:Destroy()

	----同步玩家网表信息
	self:setNetTableInfo()
end
----升级兵卒星级
function Player:setBzStarLevelUp(eBZ, nLevel)
	if NULL(eBZ) then
		return
	end

	local oPath = eBZ.m_path
	local nLevelCur = self:getBzStarLevel(eBZ)

	----造新兵卒
	local eBZNew = self:createBzOnPath(oPath, nLevelCur + nLevel, true)
	eBZNew:ModifyHealth(eBZ:GetHealth(), nil, false, 0)
	----血量
	if 0 < nLevel then
		eBZNew:ModifyHealth(eBZNew:GetMaxHealth(), nil, false, 0)
	else
		eBZNew:ModifyHealth(eBZ:GetHealthPercent() * eBZNew:GetMaxHealth(), nil, false, 0)
	end
	----魔法
	eBZNew:GiveMana(eBZ:GetMana())

	----复制buff
	local tBuff = eBZ:FindAllModifiers()
	for _, v in pairs(tBuff) do
		if v.copyBfToEnt then
			v:copyBfToEnt(eBZNew)
		end
	end

	----触发事件
	EventManager:fireEvent("Event_BZLevel", {
		eBZNew = eBZNew
		, eBZ = eBZ
	})

	Selection:RemoveFromSelection(self.m_nPlayerID, eBZ)
	----移除旧兵卒
	self:removeBz(eBZ)
	eBZ = eBZNew

	----添加装备
	-- if not eBZNew:GetItemInSlot(0) then
	--	 for k, v in pairs(tabItems) do
	--		 Timers:CreateTimer((k - 1) * 0.1, function()
	--			 eBZNew:AddItemByName(v)
	--		 end)
	--	 end
	--	 --AMHC:GiveItems2UnitByName(tabItems, eBZ)
	-- end
	----设置兵卒所在的领土技能等级
	eBZ.m_path:setBuff(self)

	Selection:NewSelection(self.m_nPlayerID, eBZ)
	return eBZ
end
----更新兵卒等级
function Player:setBzLevelUp(eBZ)
	if NULL(eBZ) then
		return
	end

	----获取要升级的等级
	local nLevel = BZ_LEVELMAX[self:getBzStarLevel(eBZ)]
	if self.m_eHero:GetLevel() < nLevel then
		nLevel = self.m_eHero:GetLevel()
	end
	nLevel = nLevel - eBZ:GetLevel()

	local tEvent = {
		eBZ = eBZ,
		nLevel = nLevel,
	}
	EventManager:fireEvent("Event_BZLevelUp", tEvent)
	nLevel = tEvent.nLevel

	local bLevelDown = nLevel < 0

	----升级特效
	if 0 < nLevel then
		AMHC:CreateParticle("particles/generic_hero_status/hero_levelup.vpcf", PATTACH_ABSORIGIN_FOLLOW, false, eBZ, 3)
	end

	----等级变更
	nLevel = math.abs(nLevel)
	for i = 1, nLevel do
		eBZ:LevelUp(false, bLevelDown)
	end

	----计算兵卒技能等级
	nLevel = math.floor(eBZ:GetLevel() * 0.1) + 1
	if 3 < nLevel then
		nLevel = 3
	end
	eBZ.m_bAbltBZ:SetLevel(nLevel)
end
----设置兵卒可否被攻击
function Player:setBzBeAttack(eBz, bCan)
	if NULL(eBz) then
		return
	end

	for _, v in pairs(self.m_tabBz) do
		if v == eBz then
			if bCan then
				---- AMHC:RemoveAbilityAndModifier(v, "magic_immune")
				AMHC:RemoveAbilityAndModifier(v, "physical_immune")
			else
				---- AMHC:AddAbilityAndSetLevel(v, "magic_immune")
				AMHC:AddAbilityAndSetLevel(v, "physical_immune")
			end
			return
		end
	end
end
----设置兵卒攻击状态
function Player:setBzAttack(eBz, bCan)
	if NULL(eBz) then
		return
	end

	if nil == bCan then
		bCan = 0 < bit.band(PS_AtkBZ, self.m_typeState) and 0 == bit.band(PS_InPrison, self.m_typeState)
	end

	for _, v in pairs(self.m_tabBz) do
		if v == eBz then
			if bCan then
				----if AMHC:RemoveAbilityAndModifier(v, "jiaoxie") then
				v:SetControllableByPlayer(-1, true) ----攻击时不能控制
				v:SetTeam(DOTA_TEAM_BADGUYS)	----攻击时需要为敌方
				---- v:AngerNearbyUnits()	----设置攻击警戒
				---- v:SetAggroTarget(PlayerManager:getPlayer(GMManager.m_nOrderID).m_eHero)	----设置仇恨为当前玩家
				EventManager:fireEvent("Event_BZCanAtk", { entity = v })	----触发兵卒可攻击事件
				----end
			else
				AMHC:AddAbilityAndSetLevel(v, "jiaoxie")
				if not self.m_bDisconnect then
					v:SetControllableByPlayer(self.m_nPlayerID, true)
				end
				v:SetTeam(DOTA_TEAM_GOODGUYS)
				v.m_eAtkTarget = nil
				---- v:Hold()
				EventManager:fireEvent("Event_BZCantAtk", { entity = v })	----触发兵卒不可攻击事件
			end
			return
		end
	end
end
----设置玩家全部兵卒可否攻击
function Player:setAllBzAttack()

	local bCan = 0 < bit.band(PS_AtkBZ, self.m_typeState)
	and 0 == bit.band(PS_InPrison, self.m_typeState)

	local function filter(eBZ)
		return not eBZ.m_bBattle  ----忽略战斗的兵卒
	end

	if bCan then
		for k, v in pairs(self.m_tabBz) do
			if IsValid(v) and filter(v) then
				----f AMHC:RemoveAbilityAndModifier(v, "jiaoxie") then
				v:SetControllableByPlayer(-1, true) ----攻击时不能控制
				v:SetTeam(DOTA_TEAM_BADGUYS)	----攻击时需要为敌方
				---- v:AngerNearbyUnits()	----设置攻击警戒
				---- v:SetAggroTarget(PlayerManager:getPlayer(GMManager.m_nOrderID).m_eHero)	----设置仇恨为当前玩家
				EventManager:fireEvent("Event_BZCanAtk", { entity = v })	----触发兵卒可攻击事件
				----end
			end
		end
	else
		for k, v in pairs(self.m_tabBz) do
			if IsValid(v) and filter(v) then
				AMHC:AddAbilityAndSetLevel(v, "jiaoxie")
				if not self.m_bDisconnect then
					v:SetControllableByPlayer(self.m_nPlayerID, true)
				end
				v:SetTeam(DOTA_TEAM_GOODGUYS)
				---- v:Hold()
				v.m_eAtkTarget = nil
				EventManager:fireEvent("Event_BZCantAtk", { entity = v })	----触发兵卒不可攻击事件
			end
		end
	end
end
----设置攻击目标给兵卒
function Player:setBzAtker(eBz, eAtker, bDel)
	if NULL(eBz) or not exist(self.m_tabBz, eBz) then
		return
	end

	if not eBz.m_tabAtker then
		eBz.m_tabAtker = {}
	end

	if bDel then
		removeAll(eBz.m_tabAtker, eAtker)
	else
		if not exist(eBz.m_tabAtker, eAtker) then
			table.insert(eBz.m_tabAtker, eAtker)
		end
		self:ctrlBzAtk(eBz)
	end
end

----设置攻击目标给全部兵卒
function Player:setAllBzAtker(eAtker, bDel, funFilter)
	for _, v in pairs(self.m_tabBz) do
		if not funFilter or funFilter(v) then
			if not v.m_tabAtker then
				v.m_tabAtker = {}
			end
			if bDel then
				for k, v2 in pairs(v.m_tabAtker) do
					if eAtker == v2 then
						table.remove(v.m_tabAtker, k)
						break
					end
				end
			else
				table.insert(v.m_tabAtker, eAtker)
				removeRepeat(v.m_tabAtker)
				self:ctrlBzAtk(v)
			end
		end
	end
end
----兵卒攻击控制器
function Player:ctrlBzAtk(eBz)
	if NULL(eBz) then
		return
	end

	if eBz:IsInvisible() then
		return	  ----兵卒隐身不能攻击
	end

	if eBz._ctrlBzAtk_thinkID then
		return
	end
	eBz._ctrlBzAtk_thinkID = Timers:CreateTimer(function()
		if eBz and not eBz:IsNull() then
			----获取在攻击范围的玩家
			--local tInRange = {}
			for _, v in pairs(eBz.m_tabAtker) do
				local nDis = (v:GetAbsOrigin() - eBz:GetAbsOrigin()):Length()
				local nRange = eBz:Script_GetAttackRange()
				if nDis <= nRange then
					----达到距离攻击
					--table.insert(tInRange, v)
					if AMHC:RemoveAbilityAndModifier(eBz, "jiaoxie") then
						-- eBz:Stop()
						eBz:SetDayTimeVisionRange(nRange)
						eBz:SetNightTimeVisionRange(nRange)
						eBz:MoveToTargetToAttack(v)
						eBz.m_eAtkTarget = v
						--eBz:SetAggroTarget(v)
						return 0.1
					end
				else
					AMHC:AddAbilityAndSetLevel(eBz, "jiaoxie")
					eBz.m_eAtkTarget = nil
				end
				return 0.1
			end
		end
		eBz._ctrlBzAtk_thinkID = nil
	end)
end
----获取兵卒的星级
function Player:getBzStarLevel(eBZ)
	if NULL(eBZ) then
		return
	end

	local strName = eBZ:GetUnitName()
	strName = string.reverse(strName)
	local nLevel = string.find(strName, '_')
	if nLevel then
		nLevel = nLevel - 1
	else
		nLevel = 0
	end
	return nLevel
end
----是否有该兵卒
function Player:hasBz(eBz_Or_nEntID)
	if not NIL(eBz_Or_nEntID) then
		if "table" == type(eBz_Or_nEntID) then
			for _, v in pairs(self.m_tabBz) do
				if eBz_Or_nEntID == v then
					return v
				end
			end
		else
			for _, v in pairs(self.m_tabBz) do
				if IsValid(v) then
					if eBz_Or_nEntID == v:GetEntityIndex() then
						return v
					end
				end
			end
		end
	end
end

----设置玩家英雄可否攻击
function Player:setHeroCanAttack(bCan)
	if bCan then
		AMHC:RemoveAbilityAndModifier(self.m_eHero, "jiaoxie")
		---- self.m_eHero:AngerNearbyUnits()
	else
		AMHC:AddAbilityAndSetLevel(self.m_eHero, "jiaoxie")
	end
end

----获取英雄身上某buff
function Player:getBuffByName(strBuffName)
	local tab = self.m_eHero:FindAllModifiersByName(strBuffName)
	for _, cBuff in pairs(tab) do
		if nil ~= cBuff then
			return cBuff
		end
	end
end

----设置英雄魔法上限
function Player:setManaMax(nVal)
	----不能影响当前魔法值
	local nManaCur = self.m_eHero:GetMana()

	----添加修改魔法上限的buff
	AMHC:RemoveAbilityAndModifier(self.m_eHero, "mana_max")
	local oAblt = self.m_eHero:AddAbility("mana_max")

	----删除之前
	local strBuff = "modifier_mana_max_mod_"
	local tabBuff = self.m_eHero:FindAllModifiers()
	for _, v in pairs(tabBuff) do
		if nil ~= string.find(v:GetName(), strBuff) then
			self.m_eHero:RemoveModifierByName(v:GetName())
		end
	end

	---- 二进制表
	local bitTable = { 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 }
	---- 如果有很大的数据，大于1023，那么增加N个512先干到512以下
	if nVal > 1023 then
		local out_count = math.floor(nVal / 512)
		for i = 1, out_count do
			oAblt:ApplyDataDrivenModifier(self.m_eHero, self.m_eHero, "modifier_mana_max_mod_" .. "512", nil)
		end
		nVal = nVal - out_count * 512
	end
	---- 循环增加Modifier，最终增加到正确个数的Modifier
	for p = 1, #bitTable do
		local val = bitTable[p]
		local count = math.floor(nVal / val)
		if count >= 1 then
			oAblt:ApplyDataDrivenModifier(self.m_eHero, self.m_eHero, "modifier_mana_max_mod_" .. val, nil)
			nVal = nVal - val
		end
	end

	self.m_eHero:RemoveAbility(oAblt:GetAbilityName())
	self.m_eHero:SetMana(nManaCur)
end

function Player:addHealth(nHealth)
	self.m_eHero:SetHealth(self.m_eHero:GetHealth() + nHealth)
end

-----是否拥有某卡牌
function Player:isHasCard(nCardID)
	for _, v in pairs(self.m_tabHasCard) do
		if nCardID == v.m_nID then
			return true
		end
	end
	return false
end
-----是否获得过某卡牌
-----@param typeCard number 卡牌类型
-----@return boolen
function Player:isOwnedCard(typeCard)
	for _, v in pairs(self.m_tabHasCard) do
		if typeCard == v.m_typeCard then
			return true
		end
	end
	for _, v in pairs(self.m_tabDelCard) do
		if typeCard == v.m_typeCard then
			return true
		end
	end
	return false
end
----添加卡牌
-----@param card Card
function Player:setCardAdd(card)
	if self:isHasCard(card.m_nID) then
		return false
	end

	card:setOwner(self)

	----通知客户端获得卡牌
	local jsonData = {
		card:encodeJsonData()
	}

	table.insert(self.m_tabHasCard, card)

	----同步玩家网表信息
	self:setNetTableInfo()

	jsonData = json.encode(jsonData)

	self:sendMsg("GM_CardAdd", {
		nPlayerID = self.m_nPlayerID,
		json = jsonData
	})

	self:setCardCanCast()
	return true
end
----删除卡牌
function Player:setCardDel(card, bUse)
	bUse = bUse or true
	for k, v in pairs(self.m_tabHasCard) do
		if card.m_nID == v.m_nID then
			if bUse then
				table.insert(self.m_tabUseCard, v)
			end
			table.insert(self.m_tabDelCard, v)
			table.remove(self.m_tabHasCard, k)
			----同步玩家网表信息
			self:setNetTableInfo()
			self:setCardCanCast()
			return true
		end
	end

	return false
end
----设置可用卡牌
function Player:setCardCanCast()
	local tCanCast = {}
	for _, v in pairs(self.m_tabHasCard) do
		if not NIL(v) then
			if v:CanUseCard() then
				table.insert(tCanCast, v.m_nID)
			end
		end
	end
	----设置网表
	local info = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID)
	info["tabCanCastCard"] = tCanCast
	CustomNetTables:SetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID, info)
end
----发送手牌数据给客户端
function Player:sendHandCardData()
	local jsonData = {}
	for _, card in pairs(self.m_tabHasCard) do
		table.insert(jsonData, card:encodeJsonData())
	end

	jsonData = json.encode(jsonData)

	self:sendMsg("GM_CardAdd", {
		nPlayerID = self.m_nPlayerID,
		json = jsonData
	})
	return true
end

----扣蓝
function Player:spendMana(nMana)
	self.m_eHero:SpendMana(nMana)
end

----设置技能减缩
function Player:setCDSub(nVal)
	self.m_nCDSub = nVal
	----设置网表
	local info = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID)
	info["nCDSub"] = self.m_nCDSub
	CustomNetTables:SetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID, info)
end
----设置耗魔减缩
function Player:setManaSub(nVal)
	self.m_nManaSub = nVal

	----更新卡牌蓝耗
	for _, v in pairs(self.m_tabHasCard) do
		if not NIL(v) then
			v:updata()
		end
	end

	----设置卡牌可否释放
	self:setCardCanCast()

	----设置网表
	local info = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID)
	info["nManaSub"] = self.m_nManaSub
	CustomNetTables:SetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID, info)
end

----全军查找物品
function Player:getItemFromAllByName(sItemName, itemIgnore)
	local item = self.m_eHero:get08ItemByName(sItemName, itemIgnore)
	if item then
		return item
	end
	for _, v in pairs(self.m_tabBz) do
		item = v:get08ItemByName(sItemName, itemIgnore)
		if item then
			return item
		end
	end
end

----设置断线
function Player:setDisconnect(bVal)
	----设置网表
	local info = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID)
	info["bDisconnect"] = bVal
	CustomNetTables:SetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID, info)

	self.m_bDisconnect = bVal
	self:updateCtrl()
	-- if self.m_bDisconnect then
	--	 if self.m_eHero and not self.m_eHero:IsNull() then
	--		 self.m_eHero:SetGold(0, false)
	--		 self.m_eHero:SetGold(0, true)
	--	 end
	--	 --PlayerResource:SetCustomTeamAssignment(self.m_nPlayerID, self.m_typeTeam)
	-- else
	--	 if self.m_eHero and not self.m_eHero:IsNull() then
	--		 self.m_eHero:SetGold(self.m_nGold, false)
	--		 self.m_eHero:SetGold(0, true)
	--	 end
	--	 --PlayerResource:SetCustomTeamAssignment(self.m_nPlayerID, DOTA_TEAM_GOODGUYS)
	-- end
end

----更新控制权限
function Player:updateCtrl()
	local nCtrlID
	if self.m_bDisconnect then
		nCtrlID = -1
	else
		nCtrlID = self.m_nPlayerID
	end
	if self.m_eHero and not self.m_eHero:IsNull() then
		self.m_eHero:SetControllableByPlayer(nCtrlID, true)
	end
	for _, v in pairs(self.m_tabBz) do
		if v and not v:IsNull() then
			v:SetControllableByPlayer(nCtrlID, true)
		end
	end
end

----增加击杀数
function Player:setKillCountAdd(nVal)
	self.m_nKill = nVal + self.m_nKill
	----设置网表
	local info = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID)
	info["nKill"] = nVal
	CustomNetTables:SetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID, info)
end
----设置攻城数
function Player:setGCLDCountAdd(nVal)
	self.m_nGCLD = nVal + self.m_nGCLD
	----设置网表
	local info = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID)
	info["nGCLD"] = nVal
	CustomNetTables:SetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID, info)
end

----设置购物状态
function Player:setBuyState(typeState, nCount)
	----可购物事件
	local tEvent = {
		nCount = nCount,
		typeState = typeState,
		player = self,
	}
	EventManager:fireEvent("Event_SetBuyState", tEvent)

	self.m_nBuyItem = tEvent.nCount
	self.m_typeBuyState = tEvent.typeState

	----设置网表
	local info = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID)
	info["nBuyItem"] = self.m_nBuyItem
	info["typeBuyState"] = self.m_typeBuyState
	CustomNetTables:SetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID, info)

end
----购买装备
function Player:getItemBuy(sItemName)
	self.m_nBuyItem = self.m_nBuyItem - 1
	self.m_eHero:AddItemByName(sItemName)
	self:setGold(-GetItemCost(sItemName))
	GMManager:showGold(self, -GetItemCost(sItemName))

	----设置网表
	local info = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID)
	info["nBuyItem"] = self.m_nBuyItem
	CustomNetTables:SetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID, info)

	----计算总资产
	self:setSumGold()
end

----增加经验
function Player:setExpAdd(nVal)
	local nAddExp = nVal
	local nCurExp = self.m_eHero:GetCurrentXP()
	local nLevelUpExp = LEVEL_EXP[self.m_eHero:GetLevel() + 1]
	self.m_eHero:AddExperience(nAddExp, 0, false, false)

	if nLevelUpExp and nLevelUpExp <= nCurExp + nAddExp then
		----升级，触发属性变更
		EventManager:fireEvent("Event_SxChange", { entity = self.m_eHero })

		----修改回蓝回血为0
		Timers:CreateTimer(0.1, function()
			self:updataRegen0()
		end)
		----整化魔法数值
		Timers:CreateTimer(0.05, function()
			self.m_eHero:SetMana(math.floor(self.m_eHero:GetMana() + 0.5))
		end)
		----清空技能点
		self.m_eHero:SetAbilityPoints(0)
		----设置技能等级
		local nLevel = math.floor(self.m_eHero:GetLevel() * 0.1) + 1
		local oAblt = self.m_eHero:GetAbilityByIndex(0)
		oAblt:SetLevel(nLevel)
		oAblt = self.m_eHero:GetAbilityByIndex(1)
		oAblt:SetLevel(nLevel)

		----更新全部兵卒等级
		for _, eBZ in pairs(self.m_tabBz) do
			self:setBzLevelUp(eBZ)
		end
	end
end

function Player:updataRegen0()
	self.m_eHero:SetBaseManaRegen(0)
	self.m_eHero:SetBaseManaRegen(-(self.m_eHero:GetManaRegen()))
	self.m_eHero:SetBaseHealthRegen(0)
	local nHR = self.m_eHero:GetHealthRegen()
	self.m_eHero:SetBaseHealthRegen(-nHR)
end

----事件触发--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Player:registerEvent()
	EventManager:register("Event_OnDamage", self.onEvent_OnDamage, self, -987654321)
	EventManager:register("Event_Atk", self.onEvent_Atk_bzHuiMo, self)
	EventManager:register("Event_PlayerRoundBegin", self.onEvent_PlayerRoundBegin, self)
	EventManager:register("Event_UpdateRound", self.onEvent_UpdateRound, self)
	EventManager:register("Event_Move", self.onEvent_Move, self)
	EventManager:register("Event_PlayerDie", self.onEvent_PlayerDie, self)
	EventManager:register("Event_HeroManaChange", self.onEvent_HeroManaChange, self)
	EventManager:register("Event_UseSkinChange", self.onEvent_UseSkinChange, self)
end

----受伤
function Player:onEvent_OnDamage(tabEvent)
	if tabEvent.bIgnore then
		return
	end
	----受伤者
	local e = EntIndexToHScript(tabEvent.entindex_victim_const)
	if IsValid(e) and (e == self.m_eHero or self:hasBz(e)) then
		tabEvent.bIgnore = true
		tabEvent.damage = math.ceil(tabEvent.damage)


		----攻击者
		local eAtk = EntIndexToHScript(tabEvent.entindex_attacker_const)
		local oPlayerAtk
		if IsValid(eAtk) then
			self.m_nLastAtkPlayerID = eAtk:GetPlayerOwnerID()
			oPlayerAtk = PlayerManager:getPlayer(eAtk:GetPlayerOwnerID())
			----统计伤害
			if oPlayerAtk then
				if eAtk:IsHero() then
					oPlayerAtk.m_nDamageHero = oPlayerAtk.m_nDamageHero + tabEvent.damage
				else
					oPlayerAtk.m_nDamageBZ = oPlayerAtk.m_nDamageBZ + tabEvent.damage
				end
			end
		end

		if 0 < tabEvent.damage then
			----扣钱
			if not tabEvent.bIgnoreGold then
				----自身设置金币
				if not (oPlayerAtk == self and tabEvent.bIgnoreDamageSelf) then
					self:setGold(-tabEvent.damage)
					GMManager:showGold(self, -tabEvent.damage)
					EventManager:fireEvent("Event_ChangeGold_Atk", {
						player = self
						, nGold = -tabEvent.damage
					})
				end

				print("debug oPlayerAtk ~= self is ", oPlayerAtk ~= self)
				print("debug oPlayerAtk", eAtk:GetPlayerOwnerID())

				----攻击者是敌军，给敌人玩家设置金币
				if not tabEvent.bIgnoreAddGold
				and oPlayerAtk
				and oPlayerAtk ~= self
				then
					oPlayerAtk:setGold(tabEvent.damage)
					GMManager:showGold(oPlayerAtk, tabEvent.damage)
					EventManager:fireEvent("Event_ChangeGold_Atk", {
						player = oPlayerAtk
						, nGold = tabEvent.damage
					})
				end
			end

			----是否扣血
			if eAtk.m_bBZ then
				----兵卒攻击不扣血
				if not eAtk.m_bGCLD then
					print("not eAtk.m_bGCLD damage = 0")
					tabEvent.damage = 0
				end
			end

			----兵卒受伤回魔
			if e.m_bBZ and not tabEvent.bIgnoreBZHuiMo then
				----计算回魔量
				local nHuiMoRate = BZ_HUIMO_BEATK_RATE
				local tabEventHuiMo = {
					eBz = e
					, nHuiMoSum = tabEvent.damage * nHuiMoRate
					, getBaseHuiMo = (function()
						local nHuiMoBase = tabEvent.damage * nHuiMoRate
						return function()
							return nHuiMoBase
						end
					end)()
				}
				----触发兵卒回魔事件
				EventManager:fireEvent("Event_BZHuiMo", tabEventHuiMo)
				if 0 < tabEventHuiMo.nHuiMoSum then
					----给兵卒回魔
					e:GiveMana(tabEventHuiMo.nHuiMoSum)
				end
			end

			----扣血
			local nHealth = e:GetHealth() - tabEvent.damage
			if 2 > nHealth then
				----即将死亡，设置成1血
				nHealth = 2
			end
			e:ModifyHealth(nHealth, nil, false, 0)
		end
		tabEvent.damage = 0
	end
end

----兵卒造成伤害回魔
function Player:onEvent_Atk_bzHuiMo(tabEvent)
	if tabEvent.bIgnore or tabEvent.bIgnoreBZHuiMo then
		return
	end
	local eBZ = self:hasBz(tabEvent.entindex_attacker_const)
	if not eBZ then
		return
	end

	----计算回魔量
	local nHuiMoRate = eBZ:IsRangedAttacker() and BZ_HUIMO_RATE_Y or BZ_HUIMO_RATE_J
	local tabEventHuiMo = {
		eBz = eBZ
		, nHuiMoSum = tabEvent.damage * nHuiMoRate
		, getBaseHuiMo = (function()
			local nHuiMoBase = tabEvent.damage * nHuiMoRate
			return function()
				return nHuiMoBase
			end
		end)()
	}

	----触发兵卒回魔事件
	EventManager:fireEvent("Event_BZHuiMo", tabEventHuiMo)
	if 1 > tabEventHuiMo.nHuiMoSum then
		return
	end

	----给兵卒回魔
	eBZ:GiveMana(tabEventHuiMo.nHuiMoSum)
end

----玩家回合开始
function Player:onEvent_PlayerRoundBegin(tabEvent)
	self:setCardCanCast()

	if tabEvent.oPlayer ~= self then
		return
	end

	----提高英雄魔法上限
	self.nManaMaxBase = self.nManaMaxBase or 0
	if 10 > self.nManaMaxBase then
		self.nManaMaxBase = self.nManaMaxBase + 1
		self:setManaMax(self.nManaMaxBase)
	end

	----英雄回蓝
	local tabEventHuiMo = {
		oPlayer = self
		, nHuiMo = 1
	}
	EventManager:fireEvent("Event_HeroHuiMoByRound", tabEventHuiMo)	 ----触发英雄回魔在回合开始
	self.m_eHero:GiveMana(tabEventHuiMo.nHuiMo)

	----英雄回血
	local tabEventHuiXue = {
		entity = self.m_eHero,
		nHuiXue = self.m_eHero:GetMaxHealth() * ROUNT_HERO_HUIXUE_ROTA
	}
	EventManager:fireEvent("Event_ItemHuiXueByRound", tabEventHuiXue)	 ----触发英雄回血在回合开始
	self:addHealth(tabEventHuiXue.nHuiXue)

	----兵卒回血
	for _, eBz in pairs(self.m_tabBz) do
		tabEventHuiXue = {
			entity = eBz,
			nHuiXue = eBz:GetMaxHealth() * ROUNT_BZ_HUIXUE_ROTA
		}
		EventManager:fireEvent("Event_ItemHuiXueByRound", tabEventHuiXue)
		eBz:SetHealth(eBz:GetHealth() + tabEventHuiXue.nHuiXue)
	end
end

----游戏回合更新
function Player:onEvent_UpdateRound()
	----重置玩家回合已结束的记录
	self:setRoundFinished(false)
	if 1 < GMManager.m_nRound then
		----加经验
		---- local nAddExp = 1 + PlayerManager:getPlayerCount() - PlayerManager:getAlivePlayerCount()
		local nAddExp = 1 + math.floor(GMManager.m_nRound / 10)
		self:setExpAdd(nAddExp)
	end
end

----玩家魔法修改
function Player:onEvent_HeroManaChange(tabEvent)
	if tabEvent.player == self then
		----设置卡牌可否释放
		self:setCardCanCast()
	end
end

----玩家移动
function Player:onEvent_Move(tabEvent)
	if tabEvent.entity ~= self.m_eHero then
		----其他玩家在移动
		local tEventID = {}

		----设置兵卒攻击,英雄魔免物免
		local nState = PS_AtkBZ
		if 0 == bit.band(PS_AtkMonster + PS_AtkHero, self.m_typeState) then
			nState = nState + PS_PhysicalImmune ----+PS_MagicImmune
		else
			table.insert(tEventID, EventManager:register("Event_GCLDEnd", function(tEvent)
				if tEvent.entity == self.m_eHero then
					nState = nState + PS_PhysicalImmune ----+PS_MagicImmune
					self:setState(PS_PhysicalImmune)
					return true
				end
			end))
			table.insert(tEventID, EventManager:register("Event_AtkMosterEnd", function(tEvent)
				if tEvent.entity == self.m_eHero then
					nState = nState + PS_PhysicalImmune ----+PS_MagicImmune
					self:setState(PS_PhysicalImmune)
					return true
				end
			end))
		end
		self:setState(nState)

		----设置兵卒攻击目标
		self:setAllBzAtker(tabEvent.entity, false)
		----监听兵卒创建继续设置目标
		table.insert(tEventID, EventManager:register("Event_BZCreate", function(tEvent)
			if tEvent.entity:GetPlayerOwnerID() == self.m_nPlayerID then
				self:setBzAtker(tEvent.entity, tabEvent.entity, false)
			end
		end))

		----监听移动结束：结束攻击
		EventManager:register("Event_MoveEnd", function()
			self:setState(-nState)
			self:setAllBzAtker(tabEvent.entity, true)
			EventManager:unregisterByIDs(tEventID)
			return true
		end)
	else
		----自己移动,记录移动中的金币变化
		local nGold = 0
		local function onEvent_ChangeGold(tabEvent2)
			if tabEvent2.player == self then
				nGold = nGold + tabEvent2.nGold
			end
		end
		EventManager:register("Event_ChangeGold_Atk", onEvent_ChangeGold)
		EventManager:register("Event_MoveEnd", function(tabEvent2)
			if tabEvent2.entity == self.m_eHero then
				EventManager:unregister("Event_ChangeGold_Atk", onEvent_ChangeGold)
				if 0 ~= nGold then
					local tabKV = {}
					tabKV["[nGold]"] = nGold
					GameRecord:setGameRecord(TGameRecord_String, self.m_nPlayerID, {
						strText = GameRecord:encodeGameRecord(GameRecord:encodeLocalize('GameRecord_' .. TGameRecord_ChangeGold_Move, tabKV))
					})
				end
				return true
			end
		end)
	end
end

----玩家死亡
function Player:onEvent_PlayerDie(tabEvent)
	if tabEvent.player ~= self then
		if tabEvent.player.m_nLastAtkPlayerID == self.m_nPlayerID then
			self:setKillCountAdd(1)
		end
		return
	end

	self.m_bDie = true
	self:setState(PS_Die)
	----设置网表
	local info = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID)
	info["bDie"] = true
	CustomNetTables:SetTableValue("GameingTable", "player_info_" .. self.m_nPlayerID, info)

	self:setState(PS_Pass)
	self:SetWageGold(0)

	if self.m_tabMyPath then
		for i = getSize(self.m_tabMyPath), 1, -1 do
			for _, paths in pairs(self.m_tabMyPath) do
				for j = #paths, 1, -1 do
					self:setMyPathDel(paths[j])
				end
				break
			end
		end
	end

	if self.m_eHero then
		self.m_eHero:SetRespawnsDisabled(true)
		self.m_eHero:ForceKill(true)
		---- self.m_eHero:SetTimeUntilRespawn(9999)
	end

	----
	EventManager:unregister("Event_OnDamage", self.onEvent_OnDamage, self)
	EventManager:unregister("Event_Atk", self.onEvent_Atk_bzHuiMo, self)
	EventManager:unregister("Event_PlayerRoundBegin", self.onEvent_PlayerRoundBegin, self)
	EventManager:unregister("Event_UpdateRound", self.onEvent_UpdateRound, self)
	EventManager:unregister("Event_Move", self.onEvent_Move, self)

	----音效
	EmitGlobalSound("Custom.Killed")
	return true
end

----使用皮肤更换
function Player:onEvent_UseSkinChange(tEvent)
	if tEvent.player == self then
		self:updataSkin()
	end
end