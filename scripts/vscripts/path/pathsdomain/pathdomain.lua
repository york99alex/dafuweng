if PrecacheItems then
    table.insert(PrecacheItems, "particles/units/heroes/hero_legion_commander/legion_duel_ring.vpcf")
    table.insert(PrecacheItems, "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf")
end

--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----领土路径
if nil == PathDomain then
    -----@class PathDomain
    PathDomain = class({
        m_tabENPC = nil				----路径上的全部NPC实体（城池的兵卒）
        , m_eCity = nil				----建筑点实体
        , m_eBanner = nil           ----横幅旗帜实体
        , m_nPrice = nil			----价值
        , m_nOwnerID = nil			----领主玩家ID
        , m_nPlayerIDGCLD = nil		----正在攻城玩家ID
        , m_nPtclIDGCLD = nil		----攻城特效ID
    }, nil, Path)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function PathDomain:constructor(e)
    PathDomain.__base__.constructor(self, e)

    self.m_eCity = Entities:FindByName(nil, "city_" .. self.m_nID)
    self.m_eBanner = Entities:FindByName(nil, "banner_" .. self.m_nID)
    self:setBanner()

    self.m_nPrice = PATH_TO_PRICE[self.m_typePath]

    self.m_tabENPC = {}

    EventManager:register("Event_PlayerRoundBefore", self.onEvent_PlayerRoundBefore, self, -987654321)
    EventManager:register("Event_FinalBattle", self.onEvent_FinalBattle, self)
    EventManager:register("Event_PlayerDie", self.onEvent_PlayerDie, self, 10000)
    EventManager:register("Event_BZLevel", self.onEvent_BZLevel, self)
end

----触发路径
function PathDomain:onPath(oPlayer, ...)
    PathDomain.__base__.onPath(self, oPlayer, ...)

    if nil == self.m_nOwnerID then
        ----无主之地,发送安营扎寨操作
        local tabOprt = {}
        tabOprt.nPlayerID = oPlayer.m_nPlayerID
        tabOprt.typeOprt = TypeOprt.TO_AYZZ
        tabOprt.typePath = self.m_typePath
        tabOprt.nPathID = self.m_nID

        GMManager:autoOprt(tabOprt.typeOprt, oPlayer)    ----操作前处理上一个（如果有的话）
        GMManager:sendOprt(tabOprt)
    elseif oPlayer.m_nPlayerID ~= self.m_nOwnerID then
        ----非己方城池
        local oPlayerOW = PlayerManager:getPlayer(self.m_nOwnerID)
        ----领主未进监狱
        if 0 == bit.band(PS_InPrison, oPlayerOW.m_typeState) then
            if 0 == #self.m_tabENPC then
                ----交过路费给领主
                local nGold = math.floor(self.m_nPrice * PATH_TOLL_RATE)
                oPlayer:giveGold(nGold, oPlayerOW)
                GMManager:showGold(oPlayerOW, nGold)
                GMManager:showGold(oPlayer, -nGold)
                ----给钱音效
                EmitGlobalSound("Custom.Gold.Sell")
            else
                ----有兵卒的城池，发送攻城略地操作
                if self.m_tabENPC[1]:IsInvisible()
                or self.m_tabENPC[1]:IsStunned() then
                    ----兵卒隐身，眩晕无法攻城
                    return
                end
                local tabEvent = {
                    entity = oPlayer.m_eHero,
                    path = self,
                    bIgnore = false,
                }
                EventManager:fireEvent("Event_GCLDReady", tabEvent)
                if tabEvent.bIgnore then
                    return
                end
                local tabOprt = {}
                tabOprt.nPlayerID = oPlayer.m_nPlayerID
                tabOprt.typeOprt = TypeOprt.TO_GCLD
                tabOprt.typePath = self.m_typePath
                tabOprt.nPathID = self.m_nID
                ----操作前处理上一个（如果有的话）
                GMManager:autoOprt(tabOprt.typeOprt, oPlayer)
                GMManager:sendOprt(tabOprt)
                EventManager:register("Event_CurPathChange", function(tEvent)
                    if tEvent.player == oPlayer and self ~= oPlayer.m_pathCur then
                        GMManager:autoOprt(TypeOprt.TO_GCLD, oPlayer)
                    end
                end)
            end
        end
    end
end

----初始化空位数据
function Path:initNilPos()
    self.m_tabPos = {
        {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * 75 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * 75 + self.m_entity:GetForwardVector() * 50 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * 75 - self.m_entity:GetForwardVector() * 50 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * -75 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * -75 + self.m_entity:GetForwardVector() * 50 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * -75 - self.m_entity:GetForwardVector() * 50 + self.m_entity:GetAbsOrigin()
        }
    }
end

----设置横幅旗帜
function PathDomain:setBanner(strHeroName)
    if nil == strHeroName then
        self.m_eBanner:SetOrigin(self.m_eCity:GetOrigin() - Vector(0, 0, 1000))
    else
        self.m_eBanner:SetOrigin(self.m_eCity:GetOrigin())
        self.m_eBanner:SetSkin(HERO_TO_BANNER[strHeroName])
    end
end

----设置领主
function PathDomain:setOwner(oPlayer, bSetBZ)
    bSetBZ = bSetBZ or true

    local nOwnerIDLast = self.m_nOwnerID

    if nil == oPlayer then
        self:setState(TypePathState.None)
        ----移除领主
        self:setBanner()

        self.m_nOwnerID = nil
    else
        ----设置新领主
        self:setBanner(oPlayer.m_eHero:GetUnitName())
        self.m_nOwnerID = oPlayer.m_nPlayerID

        ----占领音效
        ---- EmitGlobalSound("Custom.AYZZ")
        StartSoundEvent("Custom.AYZZ", oPlayer.m_eHero)
        ---- StopSoundEvent(string a, handle b)
        ---- EmitGlobalSound("Custom.AYZZ.All")
    end
    if nOwnerIDLast then
        self:setBuff(PlayerManager:getPlayer(nOwnerIDLast))
    end
    if bSetBZ then
        self:setBZ()
    end
    ----触发事件
    EventManager:fireEvent("Event_PathOwChange", { path = self, nOwnerIDLast = nOwnerIDLast })
end

----设置起兵
function PathDomain:setBZ()
    if not self.m_nOwnerID then
        ----无领主
        if 0 < #self.m_tabENPC then
            ----有兵卒
            self:setAllBZDel()
        end
    else
        ----有领主
        local oPlayer = PlayerManager:getPlayer(self.m_nOwnerID)
        if not oPlayer then
            return
        end

        if GAME_MODE == GAME_MODE_ALLPATH then
            ----连地模式，需要全部连地
            local bFalg = true
            local tabAllDomain = PathManager:getPathByType(self.m_typePath)
            for i = 1, #tabAllDomain do
                if tabAllDomain[i].m_nOwnerID ~= oPlayer.m_nPlayerID then
                    bFalg = false
                    break
                end
            end

            if bFalg then
                ----占领全部，创建兵卒
                for _, v in pairs(tabAllDomain) do
                    if 0 < #v.m_tabENPC then
                        if v.m_tabENPC[1]:GetPlayerOwnerID() ~= oPlayer.m_nPlayerID then
                            v:setAllBZDel()      ----他人兵卒移除
                            oPlayer:createBzOnPath(v, 1)
                        end
                    else
                        oPlayer:createBzOnPath(v, 1)
                    end
                    v:setBanner()
                end
                ----添加领地BUFF
                self:setBuff(oPlayer)
            elseif GMManager.m_bFinalBattle then
                ----决战时，占领即造兵
                if 0 < #self.m_tabENPC then
                    if self.m_tabENPC[1]:GetPlayerOwnerID() ~= oPlayer.m_nPlayerID then
                        ---- oPlayer:replaceBzOnPath(self)      ----他人兵卒移除
                        self:setAllBZDel()      ----他人兵卒移除
                        oPlayer:createBzOnPath(v, 1)
                    end
                else
                    oPlayer:createBzOnPath(self, 1)
                end
                self:setBanner()
            else
                ----不能起兵，有兵也移除
                self:setAllBZDel()
            end
        elseif GAME_MODE == GAME_MODE_ONEPATH then
            ----单地模式
            if BZ_OUT_ROUNT <= GMManager.m_nRound then
                if 0 < #self.m_tabENPC then
                    if self.m_tabENPC[1]:GetPlayerOwnerID() ~= oPlayer.m_nPlayerID then
                        ---- oPlayer:replaceBzOnPath(self)      ----有别人的兵卒替换
                        self:setAllBZDel()      ----他人兵卒移除
                        oPlayer:createBzOnPath(self, 1)
                    end
                else
                    oPlayer:createBzOnPath(self, 1)
                end
                self:setBanner()
                ----添加领地BUFF
                self:setBuff(oPlayer)
            else
                ----监听起兵回合
                EventManager:register("Event_UpdateRound", function()
                    if BZ_OUT_ROUNT <= GMManager.m_nRound then
                        if not GMManager._bOutBZ then
                            GMManager._bOutBZ = true
                            prt("#GameRecord_" .. TGameRecord_OUTBZ)
                            EmitGlobalSound("Custom.AYZZ.All")
                        end
                        if self.m_nOwnerID == oPlayer.m_nPlayerID and not self.m_tabENPC[1] then
                            oPlayer:createBzOnPath(self, 1)
                            self:setBanner()
                            ----添加领地BUFF
                            self:setBuff(oPlayer)
                        end
                        return true
                    end
                end)
            end
        end
    end
end

----移除全部兵卒
function PathDomain:setAllBZDel()
    for i = #self.m_tabENPC, 1, -1 do
        if self.m_tabENPC[i] and not self.m_tabENPC[i]:IsNull() then
            local player = PlayerManager:getPlayer(self.m_tabENPC[i]:GetPlayerOwnerID())
            if player then
                player:removeBz(self.m_tabENPC[i])
            end
        else
            table.remove(self.m_tabENPC, i)
        end
    end
end

----设置领地BUFF
function PathDomain:setBuff(oPlayer)
    self:delBuff(oPlayer)
    ----获取路径等级
    local nLevel = self:getPathBuffLevel(oPlayer)
    if not nLevel or 0 >= nLevel then
        return
    end

    ----添加
    local strBuff = self:getBuffName(nLevel)
    local oAblt = AMHC:AddAbilityAndSetLevel(oPlayer.m_eHero, strBuff, nLevel)
    oAblt:SetLevel(nLevel)
end

----移除领地BUFF
function PathDomain:delBuff(oPlayer)
    for i = 1, 3 do
        local strBuffName = self:getBuffName(i)
        if oPlayer.m_eHero:HasAbility(strBuffName) then
            ----触发事件：领地技能移除
            EventManager:fireEvent("Event_PathBuffDel", { oPlayer = oPlayer, path = self, sBuffName = strBuffName })
            ----移除英雄buff技能
            AMHC:RemoveAbilityAndModifier(oPlayer.m_eHero, strBuffName)
        end
    end
end

----获取领地BUFFName
function PathDomain:getBuffName(nLevel)
    return "path_" .. self.m_typePath
end

----计算玩家领地buff等级
function PathDomain:getPathBuffLevel(oPlayer)
    local tabPath = PathManager:getPathByType(self.m_typePath)

    local tabBZLevelCount = { 0, 0, 0 }
    for _, v in pairs(tabPath) do
        if IsValid(v.m_tabENPC[1]) and v.m_nOwnerID == oPlayer.m_nPlayerID then
            local nLevelTmp = oPlayer:getBzStarLevel(v.m_tabENPC[1])
            if not tabBZLevelCount[nLevelTmp] then
                tabBZLevelCount[nLevelTmp] = 0
            end
            tabBZLevelCount[nLevelTmp] = tabBZLevelCount[nLevelTmp] + 1
        end
    end

    ----3级3共3星，2级2个2星。。。
    local nSum = 0
    for i = 3, 1, -1 do
        nSum = nSum + tabBZLevelCount[i]
        if i <= nSum then
            return i
        end
    end
end

----设置攻城双方攻击
function PathDomain:setAttacking(entity)
    local oPlayer = PlayerManager:getPlayer(self.m_nPlayerIDGCLD)
    local oPlayerOw = PlayerManager:getPlayer(self.m_nOwnerID)
    if oPlayer and oPlayerOw and IsValid(entity) then
        for _, v in pairs(self.m_tabENPC) do
            if v == entity then
                entity.m_bBattle = true
                entity.m_bGCLD = true
                oPlayerOw:setBzAttack(entity, true)
                oPlayerOw:setBzAtker(entity, oPlayer.m_eHero)
                oPlayerOw:setBzBeAttack(entity, true)
                oPlayer.m_eHero:MoveToTargetToAttack(entity)
                return
            end
        end
    end
end

----玩家攻城
function PathDomain:atkCity(oPlayer)
    if not self.m_tabENPC[1] or self.m_tabENPC[1]:IsNull()
    or self.m_nPlayerIDGCLD or self.m_tabENPC[1].m_bBattle
    then
        return
    end
    self._tEventIDGCLD = {}

    oPlayer.m_eHero.m_bGCLD = true
    self.m_nPlayerIDGCLD = oPlayer.m_nPlayerID

    ----设置兵卒攻击
    self.m_tabENPC[1].m_bBattle = true
    self.m_tabENPC[1].m_bGCLD = true

    oPlayer:setState(PS_AtkHero)

    ----移动到兵卒前
    oPlayer:moveToPos(self.m_eCity:GetAbsOrigin() + self.m_eCity:GetForwardVector() * 100, function(bSuccess)
        if not bSuccess or self.m_nPlayerIDGCLD ~= oPlayer.m_nPlayerID then
            return
        end

        ----设置双方攻击
        self:setAttacking(self.m_tabENPC[1])

        ----决斗特效
        self.m_nPtclIDGCLD = AMHC:CreateParticle("particles/units/heroes/hero_legion_commander/legion_duel_ring.vpcf"
        , PATTACH_ABSORIGIN, false, oPlayer.m_eHero)
        ParticleManager:SetParticleControlOrientation(self.m_nPtclIDGCLD, 0, oPlayer.m_eHero:GetForwardVector(), oPlayer.m_eHero:GetRightVector(), oPlayer.m_eHero:GetUpVector())

        ----音效
        EmitSoundOn("Hero_LegionCommander.Duel", oPlayer.m_eHero)
    end)

    ----监听双方受伤事件
    table.insert(self._tEventIDGCLD, EventManager:register("Event_OnDamage", function(tabEvent)
        local e
        if self.m_tabENPC[1]:GetEntityIndex() == tabEvent.entindex_victim_const then
            e = self.m_tabENPC[1]
        elseif oPlayer.m_eHero:GetEntityIndex() == tabEvent.entindex_victim_const then
            e = oPlayer.m_eHero
        else
            return
        end
        tabEvent.bIgnoreGold = true     ----攻城时不扣钱
        if tabEvent.damage >= e:GetHealth() then
            ----一方死亡，战斗结束
            -- tabEvent.bIgnore = true
            tabEvent.damage = 0
            self:atkCityEnd(e == self.m_tabENPC[1])

            ----英雄死亡回满血
            if e == oPlayer.m_eHero then
                oPlayer.m_eHero:ModifyHealth(oPlayer.m_eHero:GetMaxHealth(), nil, false, 0)
            end
        end
    end, nil, -98765432))

    ----设置游戏记录
    GameRecord:setGameRecord(TGameRecord_GCLD, oPlayer.m_nPlayerID, {
        strPathName = GameRecord:encodeGameRecord(GameRecord:encodeLocalize("PathName_" .. self.m_nID))
    })

    ----攻城事件
    EventManager:fireEvent("Event_GCLD", {
        entity = oPlayer.m_eHero,
        path = self,
    })

    ----监听行为终止
    table.insert(self._tEventIDGCLD, EventManager:register("Event_ActionStop", function(tEvent)
        if tEvent.entity == oPlayer.m_eHero then
            ----攻城方被中断，不移动
            oPlayer:moveStop()
            self:atkCityEnd(false, tEvent.bMoveBack or false)
        elseif tEvent.entity:IsRealHero() and tEvent.entity:GetPlayerOwnerID() == self.m_nOwnerID then
            ----被攻城方中断，攻城者移动回去
            oPlayer:moveStop()
            self:atkCityEnd(false, tEvent.bMoveBack or true)
        end
    end))
end

----玩家攻城结束
function PathDomain:atkCityEnd(bWin, bMoveBack)
    if bWin == nil then bWin = false end
    if bMoveBack == nil then bMoveBack = true end

    local oPlayerOw = PlayerManager:getPlayer(self.m_nOwnerID)
    local oPlayer = PlayerManager:getPlayer(self.m_nPlayerIDGCLD)
    ---- oPlayer.m_eHero:ModifyHealth(oPlayer.m_eHero:GetMaxHealth(), nil, false, 0)
    ----销毁特效
    if self.m_nPtclIDGCLD then
        ParticleManager:DestroyParticle(self.m_nPtclIDGCLD, false)
        self.m_nPtclIDGCLD = nil
    end
    StopSoundOn("Hero_LegionCommander.Duel", oPlayer.m_eHero)

    ----解除事件
    EventManager:unregisterByIDs(self._tEventIDGCLD)
    self._tEventIDGCLD = nil

    if IsValid(self.m_tabENPC[1]) then
        ----回复兵卒血量
        ---- self.m_tabENPC[1]:ModifyHealth(self.m_tabENPC[1]:GetMaxHealth(), nil, false, 0)
        self.m_tabENPC[1].m_bBattle = nil
        self.m_tabENPC[1].m_bGCLD = nil
        oPlayerOw:setBzAttack(self.m_tabENPC[1])
        oPlayerOw:setBzAtker(self.m_tabENPC[1], oPlayer.m_eHero, true)
        oPlayerOw:setBzBeAttack(self.m_tabENPC[1], false)
    end

    ---- 加经验
    local nLevelBZ = oPlayerOw:getBzStarLevel(self.m_tabENPC[1])
    local nExp = GCLD_EXP[nLevelBZ]
    oPlayer:setExpAdd(nExp)
    oPlayerOw:setExpAdd(nExp)

    ----英雄回到原位
    oPlayer:setState(-(PS_AtkHero))
    if bMoveBack then
        if oPlayer.m_eHero:IsStunned() then
            oPlayer:resetToPath()
        else
            oPlayer:moveToPos(self:getUsePos(), function(bSuccess)
                if bSuccess then
                    oPlayer:resetToPath()
                end
            end)
        end
    end

    oPlayer.m_eHero.m_bGCLD = nil

    local tGCLDEnd = {
        entity = oPlayer.m_eHero
        , path = self
        , bWin = bWin
        , bSwap = true
    }
    ----攻城结束事件
    EventManager:fireEvent("Event_GCLDEnd", tGCLDEnd)

    ----处理输赢
    if tGCLDEnd.bWin then
        ----攻城成功
        ----移除兵卒，更换领主
        ---- oPlayerOw:removeBz(self.m_tabENPC[1])
        if tGCLDEnd.bSwap then
            oPlayerOw:setMyPathDel(self)
            oPlayer:setMyPathAdd(self)
        end

        ----设置游戏记录
        local tabKV = {}
        tabKV["[strPathName]"] = GameRecord:encodeLocalize("PathName_" .. self.m_nID)
        tabKV["[nExp]"] = nExp
        GameRecord:setGameRecord(TGameRecord_String, oPlayer.m_nPlayerID, {
            strText = GameRecord:encodeGameRecord(GameRecord:encodeLocalize("GameRecord_" .. TGameRecord_GCLD_Win, tabKV))
        })
        oPlayer:setGCLDCountAdd(1)

        AMHC:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf"
        , PATTACH_ABSORIGIN, false, oPlayer.m_eHero)
        EmitGlobalSound("Hero_LegionCommander.Victory")
    else
        ----攻城失败
        local nLevelBZ = oPlayerOw:getBzStarLevel(self.m_tabENPC[1])
        ----扣钱
        local nGold = GCLD_GOLD[nLevelBZ]
        oPlayer:giveGold(nGold, oPlayerOw)
        GMManager:showGold(oPlayer, -nGold)
        GMManager:showGold(oPlayerOw, nGold)

        ----设置游戏记录
        local tabKV = {}
        tabKV["[strPathName]"] = GameRecord:encodeLocalize("PathName_" .. self.m_nID)
        tabKV["[nGold]"] = nGold
        tabKV["[nExp]"] = nExp
        GameRecord:setGameRecord(TGameRecord_String, oPlayer.m_nPlayerID, {
            strText = GameRecord:encodeGameRecord(GameRecord:encodeLocalize("GameRecord_" .. TGameRecord_GCLD_Fail, tabKV))
        })

        EmitGlobalSound("Hero_LegionCommander.Duel.Cast")
    end

    self.m_nPlayerIDGCLD = nil

    -- ----攻城结束事件
    -- EventManager:fireEvent("Event_GCLDEnd", {
    --     entity = oPlayer.m_eHero
    --     , path = self
    --     , bWin = bWin
    -- })
end

----玩家回合开始：结束攻城
function PathDomain:onEvent_PlayerRoundBefore(tabEvent)
    if self.m_nPlayerIDGCLD ~= GMManager.m_nOrderID
    or GS_Begin ~= tabEvent.typeGameState then
        return
    end

    local oPlayer = PlayerManager:getPlayer(self.m_nPlayerIDGCLD)

    ----监听玩家移动回路径
    local function onMove(tabEvent2)
        if tabEvent2.player == oPlayer then
            ----如果要移动，游戏状态改为移动状态
            self._YieldStateCO = GSManager:yieldState()
            GSManager:setState(GS_Move)
            -- tabEvent.typeGameState = GS_Move
            EventManager:register("Event_PlayerMoveEnd", function(tabEvent3)
                if tabEvent3.player == oPlayer then
                    ----玩家移动结束，游戏重新进入begin状态
                    -- GMManager:setStateBeginReady()
                    GSManager:resumeState(self._YieldStateCO)
                    return true
                end
            end)
        end
        return true
    end
    EventManager:register("Event_PlayerMove", onMove)

    self:atkCityEnd(false)
    EventManager:unregister("Event_PlayerMove", onMove)
end

----玩家死亡：结束攻城
function PathDomain:onEvent_PlayerDie(tabEvent)
    if self.m_nPlayerIDGCLD then
        if self.m_nPlayerIDGCLD == tabEvent.player.m_nPlayerID then
            self:atkCityEnd(false, false)
        elseif self.m_nOwnerID == tabEvent.player.m_nPlayerID then
            self:atkCityEnd(true, true)
        end
    end
end

----终局决战开启
function PathDomain:onEvent_FinalBattle(tabEvent)
    if not self.m_nOwnerID or 0 ~= #self.m_tabENPC then
        return
    end

    local player = PlayerManager:getPlayer(self.m_nOwnerID)
    if NIL(player) then
        return
    end

    EmitGlobalSound("Custom.AYZZ")
    player:createBzOnPath(self, 1)
    self:setBanner()
end

----兵卒升级
function PathDomain:onEvent_BZLevel(tabEvent)
    if self.m_nPlayerIDGCLD and exist(self.m_tabENPC, tabEvent.eBZ) then
        ----在攻城，重新设置双方攻击
        self:setAttacking(tabEvent.eBZNew)
    end
end