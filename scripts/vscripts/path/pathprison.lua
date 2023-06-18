if PrecacheItems then
    table.insert(PrecacheItems, "particles/ui/ui_game_start_hero_spawn.vpcf")
end

--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----监狱路径
if nil == PathPrison then
    PathPrison = class({
        m_tabENPC = nil				----路径上的全部NPC实体（监狱玩家）
        , m_tabCount = nil          ----玩家持续在监狱的次数记录

        , m_eCity = nil				----建筑点实体
    }, nil, Path)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function PathPrison:constructor(e)
    PathPrison.__base__.constructor(self, e)
    self.m_eCity = Entities:FindByName(nil, "city_" .. self.m_nID)
    self:initNilPos()
    self.m_tabENPC = {}
    self.m_tabCount = {}

    ----游戏开始生成三只恶鬼
    EventManager:register("Event_GameStart", function()
        for i = 5, 7 do
            Timers:CreateTimer(i, function()
                -- local eEG = AMHC:CreateUnit("prison_eg", self.m_entity:GetAbsOrigin(), self.m_entity:GetAnglesAsVector().y, nil, DOTA_TEAM_GOODGUYS)
                -- local eEG = AMHC:CreateUnit("prison_eg", self.m_entity:GetAbsOrigin(), self.m_entity:GetAnglesAsVector().y, nil, DOTA_TEAM_GOODGUYS)
                AMHC:CreateUnitAsync("prison_eg", self.m_entity:GetAbsOrigin(), self.m_entity:GetAnglesAsVector().y, nil, DOTA_TEAM_GOODGUYS, function(eEG)
                    eEG:StartGestureWithPlaybackRate(ACT_DOTA_INTRO, 0.5)
                    eEG:SetAbsOrigin(self.m_eCity:GetAbsOrigin() + Vector(-100, 100, -100))
                end)
            end)
        end
        return true
    end)
    EventManager:register("Event_Roll", self.onEvent_Roll, self)
    EventManager:register("Event_PlayerRoundBegin", self.onEvent_PlayerRoundBegin, self)
end

----触发路径
function PathPrison:onPath(oPlayer, ...)
    self.__base__.onPath(self, oPlayer, ...)

    ----玩家进入监狱
    self:setInPrison(oPlayer)
    ----设置游戏记录
    GameRecord:setGameRecord(TGameRecord_InPrison, oPlayer.m_nPlayerID)

    ----触发阎刃卡
    if 1 == oPlayer.m_nRollMove then
        local card = CardFactory:create(TCard_MAGIC_InfernalBlade, oPlayer.m_nPlayerID)
        if card then
            oPlayer:setCardAdd(card)
            local tabKV = {}
            tabKV["strCard"] = GameRecord:encodeLocalize("Card_" .. card.m_typeCard)
            GameRecord:setGameRecord(TGameRecord_String, oPlayer.m_nPlayerID, {
                strText = GameRecord:encodeGameRecord(GameRecord:encodeLocalize('GameRecord_' .. TGameRecord_InPrisonByStart, tabKV))
            })
        end
    end
end

----入狱
function PathPrison:setInPrison(oPlayer)
    GMManager:skipRoll(oPlayer.m_nPlayerID)

    ----中断其他行为
    oPlayer:moveStop()
    EventManager:fireEvent("Event_ActionStop", {
        entity = oPlayer.m_eHero
    })

    ----设置到监狱
    table.insert(self.m_tabENPC, oPlayer.m_eHero)

    if oPlayer.m_pathCur ~= self then
        oPlayer:blinkToPath(self)
    end
    oPlayer.m_eHero:SetAbsOrigin(self:getUsePos(oPlayer.m_eHero, true))   ----设置到监狱内
    oPlayer:setState(PS_InPrison)

    ----设置动作，添加监狱buff特效
    oPlayer.m_eHero:StartGesture(ACT_DOTA_FLAIL)
    AMHC:AddAbilityAndSetLevel(oPlayer.m_eHero, "prison")
    for _, v in pairs(oPlayer.m_tabBz) do
        if IsValid(v) and not v.m_bBattle then
            v:StartGesture(ACT_DOTA_FLAIL)
            AMHC:AddAbilityAndSetLevel(v, "prison")
        end
    end
    EmitGlobalSound("Hero_DoomBringer.ScorchedEarthAura")

    local tEventID = {}
    ----监听兵卒创建，更新监狱buff
    table.insert(tEventID, EventManager:register("Event_BZCreate", function(tEvent)
        if IsValid(tEvent.entity) and tEvent.entity:GetPlayerOwnerID() == oPlayer.m_nPlayerID then
            AMHC:AddAbilityAndSetLevel(tEvent.entity, "prison")
            tEvent.entity:StartGesture(ACT_DOTA_FLAIL)
        end
    end))
    ----监听攻城失败给兵卒更新监狱buff
    table.insert(tEventID, EventManager:register("Event_GCLDEnd", function(tEvent)
        if (not tEvent.bWin)
        and IsValid(tEvent.path.m_tabENPC[1])
        and tEvent.path.m_tabENPC[1]:GetPlayerOwnerID() == oPlayer.m_nPlayerID then
            AMHC:AddAbilityAndSetLevel(tEvent.path.m_tabENPC[1], "prison")
            tEvent.path.m_tabENPC[1]:StartGesture(ACT_DOTA_FLAIL)
            oPlayer:setBzAttack(tEvent.path.m_tabENPC[1], false)
        end
    end))
    ----监听出狱
    table.insert(tEventID, EventManager:register("Event_PrisonOut", function(tEvent)
        if tEvent.player == oPlayer then
            EventManager:unregisterByIDs(tEventID)
            return true
        end
    end))


    ----结束玩家全部操作
    ---- Timers:CreateTimer(0.1, function()
    ----     GMManager:autoOprt(nil, oPlayer)
    ---- end)
end

----出狱
function PathPrison:setOutPrison(oPlayer)
    for k, v in pairs(self.m_tabENPC) do
        if v == oPlayer.m_eHero then
            table.remove(self.m_tabENPC, k)

            ---- EmitGlobalSound()
            oPlayer:blinkToPath(self)----设置到路径点
            oPlayer:setState(-PS_InPrison)

            ----移除动作
            oPlayer.m_eHero:RemoveGesture(ACT_DOTA_FLAIL)
            for _, v in pairs(oPlayer.m_tabBz) do
                if IsValid(v) then
                    v:RemoveGesture(ACT_DOTA_FLAIL)
                end
            end

            ----移除buff特效
            AMHC:RemoveAbilityAndModifier(oPlayer.m_eHero, "prison")
            for _, v in pairs(oPlayer.m_tabBz) do
                if IsValid(v) then
                    AMHC:RemoveAbilityAndModifier(v, "prison")
                end
            end

            self.m_tabCount[oPlayer.m_nPlayerID] = nil

            ----音效
            EmitGlobalSound("Custom.Respawn")
            ----重生特效
            local nPtclID = AMHC:CreateParticle("particles/ui/ui_game_start_hero_spawn.vpcf"
            , PATTACH_POINT_FOLLOW, false, oPlayer.m_eHero, 5)

            ----触发事件
            EventManager:fireEvent("Event_PrisonOut", { player = oPlayer })
            return
        end
    end
end

----初始化空位数据
function PathPrison:initNilPos()
    if not IsValid(self.m_eCity) then
        return
    end
    self.m_tabPos = {
        {
            entity = nil
            , vPos = self.m_eCity:GetRightVector() * 150 + self.m_eCity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_eCity:GetRightVector() * -150 + self.m_eCity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_eCity:GetRightVector() * 150 + self.m_eCity:GetForwardVector() * 150 + self.m_eCity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_eCity:GetRightVector() * -150 + self.m_eCity:GetForwardVector() * 150 + self.m_eCity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_eCity:GetRightVector() * 150 - self.m_eCity:GetForwardVector() * 150 + self.m_eCity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_eCity:GetRightVector() * -150 - self.m_eCity:GetForwardVector() * 150 + self.m_eCity:GetAbsOrigin()
        }
    }
end
----获得一个空位，并占用
function PathPrison:getNilPos(e)
    for _, v in pairs(self.m_tabPos) do
        if nil == v.entity then
            ----空位置
            v.entity = e
            break
        end
    end
    return self.m_entity:GetAbsOrigin()
end
----获得单位已经占用的位置
function PathPrison:getUsePos(e, bInPrison)
    if bInPrison then
        for _, v in pairs(self.m_tabPos) do
            if e == v.entity then
                return v.vPos
            end
        end
    end
    return self.m_entity:GetAbsOrigin()
end

----是否在监狱
function PathPrison:isInPrison(nEIndex)
    for _, v in pairs(self.m_tabENPC) do
        if v:GetEntityIndex() == nEIndex then
            return true
        end
    end
    return false
end

----获取罚款
function PathPrison:getFineGold(nCount)
    if 3 > nCount then
        return 0
    end
    return (2 ^ (nCount - 3)) * 100
end

----事件回调-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PathPrison:onEvent_Roll(tabEvent)
    if self:isInPrison(tabEvent.player.m_eHero:GetEntityIndex()) then
        ----判断是否出狱
        tabEvent.bIgnore = true
        if tabEvent.nNum1 == tabEvent.nNum2 then
            ----豹子出狱
            self:setOutPrison(tabEvent.player)
            ----发送roll点操作
            GMManager:broadcastOprt({
                typeOprt = TypeOprt.TO_Roll
                , nPlayerID = tabEvent.player.m_nPlayerID
            })
            ----设置游戏记录
            GameRecord:setGameRecord(TGameRecord_OutPrisonByRoll, tabEvent.player.m_nPlayerID, {
                nRoll = GameRecord:encodeGameRecord(tabEvent.nNum1 + tabEvent.nNum2)
            })
        else
            ----不是豹子，不能移动，发送完成回合操作
            GMManager:broadcastOprt({
                typeOprt = TypeOprt.TO_Finish
                , nPlayerID = tabEvent.player.m_nPlayerID
            })

            ----不出狱扣钱
            local nCount = self.m_tabCount[tabEvent.player.m_nPlayerID]
            nCount = nCount and nCount + 1 or 1
            self.m_tabCount[tabEvent.player.m_nPlayerID] = nCount
            local nGold = self:getFineGold(nCount)
            if 0 < nGold then
                tabEvent.player.m_nLastAtkPlayerID = -1 ----攻击者为系统
                tabEvent.player:setGold(-nGold)
                GMManager:showGold(tabEvent.player, -nGold)
            end
        end
    elseif tabEvent.nNum1 == tabEvent.nNum2 then
        GMManager.m_nBaoZi = GMManager.m_nBaoZi + 1
        if PRISON_BAOZI_COUNT == GMManager.m_nBaoZi then
            ----达到入狱豹子次数
            self:setInPrison(tabEvent.player)
            tabEvent.bIgnore = true
            ----设置游戏记录
            GameRecord:setGameRecord(TGameRecord_InPrisonByRoll, tabEvent.player.m_nPlayerID)
            ----发送完成回合操作
            GMManager:broadcastOprt({
                typeOprt = TypeOprt.TO_Finish
                , nPlayerID = tabEvent.player.m_nPlayerID
            })
        end
    end
end
function PathPrison:onEvent_PlayerRoundBegin(tabEvent)
    if tabEvent.bIgnore then
        return
    end
    if not self:isInPrison(tabEvent.oPlayer.m_eHero:GetEntityIndex()) then
        return
    end

    ---- if tabEvent.oPlayer:GetGold() < 500 then
    ----     return
    ---- end
    ----发送出狱操作
    local tabOprt = {}
    tabOprt.nPlayerID = GMManager.m_nOrderID
    tabOprt.typeOprt = TypeOprt.TO_PRISON_OUT
    tabOprt.nGold = GOLD_OUT_PRISON
    GMManager:sendOprt(tabOprt)
    ----进入等待操作阶段
    -- GMManager:setState(GS_WaitOperator)
    GSManager:setState(GS_WaitOperator)
    if tabEvent.oPlayer.m_bDisconnect then
        GMManager.m_timeOprt = TIME_OPERATOR_DISCONNECT
    else
        GMManager.m_timeOprt = TIME_OPERATOR
    end
    ----取消roll操作
    tabEvent.bRoll = false
end