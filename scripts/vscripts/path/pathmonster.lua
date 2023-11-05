--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----野怪路径
if nil == PathMonster then
    PathMonster = class({
        m_eCity = nil				    ----建筑点实体

        , m_tabEHero = nil				----野区打野英雄实体
        , m_tabEMonster = nil		    ----野区生物实体
        , m_tabMonsterInfo = nil	    ----可刷新的野怪信息
        , m_tabAtker = nil              ----野怪可攻击的单位
        , m_tabTrophy = nil             ----打野英雄获取的战利品统计<e,tab>

        , m_typeMonsterCur = nil        ----当前野怪类型
        , m_typeMonsterLast = nil       ----上次野怪类型
    }, nil, Path)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function PathMonster:constructor(e)
    self.__base__.constructor(self, e)
    self.m_eCity = Entities:FindByName(nil, "city_" .. self.m_nID)
    print("self.m_eCity:GetClassname():", self.m_eCity:GetClassname())
    if self.m_eCity then
        self.m_eCity:SetForwardVector(Vector(0, 0, 0) - self.m_eCity:GetAbsOrigin())
        ----路径视野
        AddFOWViewer(DOTA_TEAM_GOODGUYS, self.m_eCity:GetAbsOrigin(), 500, -1, true)
    end
    self.m_tabEHero = {}
    self.m_tabEMonster = {}
    self.m_tabAtker = {}
    self.m_tabTrophy = {}

    self.m_tabMonsterInfo = {}
    if TP_MONSTER_1 == self.m_typePath then
        for i = 1, 2 do
            for _, v in pairs(MONSTER_SETTINGS[i]) do
                table.insert(self.m_tabMonsterInfo, v)
            end
        end
    elseif TP_MONSTER_2 == self.m_typePath then
        for i = 3, 3 do
            for _, v in pairs(MONSTER_SETTINGS[i]) do
                table.insert(self.m_tabMonsterInfo, v)
            end
        end
    elseif TP_MONSTER_3 == self.m_typePath then
        self.m_tabMonsterInfo = MONSTER_SETTINGS[4]
    end

    self:registerEvent()
end

----触发路径
function PathMonster:onPath(oPlayer, ...)
    self.__base__.onPath(self, oPlayer, ...)

    if 0 == #self.m_tabEMonster then
        return
    end
    local tabOprt = {}
    tabOprt.nPlayerID = oPlayer.m_nPlayerID
    tabOprt.typeOprt = TypeOprt.TO_AtkMonster
    tabOprt.typePath = self.m_typePath
    tabOprt.nPathID = self.m_nID
    ----操作前处理上一个（如果有的话）
    GMManager:autoOprt(tabOprt.typeOprt, oPlayer)
    GMManager:sendOprt(tabOprt)
    EventManager:register("Event_CurPathChange", function(tEvent)
        if tEvent.player == oPlayer and self ~= oPlayer.m_pathCur then
            GMManager:autoOprt(TypeOprt.TO_AtkMonster, oPlayer)
        end
    end)

    ----没人在打野，踩到的玩家去打
    -- if self:setAtkerAdd(oPlayer) then
    --     ----监听豹子判断，过滤掉
    --     local function onEvent_RollBaoZiJudge(tEvent)
    --         tEvent.bIgnore = true
    --     end
    --     EventManager:register("Event_RollBaoZiJudge", onEvent_RollBaoZiJudge)
    --     EventManager:register("Event_PlayerRoundFinished", function(tEvent)
    --         EventManager:unregister("Event_RollBaoZiJudge", onEvent_RollBaoZiJudge)
    --         return true
    --     end)
    -- end
end

----刷新野怪
function PathMonster:spawnMonster()
    if not self.m_eCity then
        return
    end

    ----随机一种野怪
    self.m_typeMonsterLast = self.m_typeMonsterCur
    local tabSpawn = {}
    for _, v in pairs(self.m_tabMonsterInfo) do
        if self.m_typeMonsterLast ~= v.typeMonster then
            table.insert(tabSpawn, v)
        end
    end

    local tabInfoOne
    if 0 < #tabSpawn then
        tabInfoOne = tabSpawn[RandomInt(1, #tabSpawn)]
    elseif 0 < #self.m_tabMonsterInfo then
        tabInfoOne = self.m_tabMonsterInfo[RandomInt(1, #self.m_tabMonsterInfo)]
    end
    if nil == tabInfoOne then
        return
    end
    ----tabInfoOne = self.m_tabMonsterInfo[1]
    self.m_typeMonsterCur = tabInfoOne.typeMonster

    ----创建野怪
    for strUnit, v in pairs(tabInfoOne.tabMonster) do
        for i = 1, v.nCount do
            local vPos = self.m_eCity:GetAbsOrigin()
            vPos = (vPos +
            self.m_eCity:GetForwardVector() * v.tabPos[i][1] +
            self.m_eCity:GetRightVector() * v.tabPos[i][2] +
            self.m_eCity:GetUpVector() * v.tabPos[i][3])

            local eMonster = AMHC:CreateUnit(strUnit, vPos, self.m_eCity:GetForwardVector(), nil, DOTA_TEAM_NEUTRALS)
            FindClearSpaceForUnit(eMonster, eMonster:GetOrigin(), true)
            eMonster.m_bMonster = true
            local nGold = eMonster:GetGoldBounty()
            eMonster:SetMaximumGoldBounty(nGold)
            eMonster:SetMinimumGoldBounty(nGold)
            table.insert(self.m_tabEMonster, eMonster)
            ----eMonster:GetAbsOrigin(eMonster:GetAbsOrigin() + Vector(v.tabPos[i][1], v.tabPos[i][2], v.tabPos[i][3]))
            ---- eEG:StartGestureWithPlaybackRate(ACT_DOTA_INTRO, 0.5)
            ---- eEG:SetAbsOrigin(self.m_eCity:GetAbsOrigin() + Vector(-100, 100, -100))
        end
    end

    ----设置野怪的攻击状态
    self:setMonsterAtk()
end

----设置野怪攻击状态
function PathMonster:setMonsterAtk()
    if 0 == #self.m_tabAtker then
        ----不可攻击
        for _, v in pairs(self.m_tabEMonster) do
            AMHC:AddAbilityAndSetLevel(v, "jiaoxie")
        end
    else
        ----可攻击
        for _, v in pairs(self.m_tabEMonster) do
            AMHC:RemoveAbilityAndModifier(v, "jiaoxie")
            v:MoveToTargetToAttack(self.m_tabAtker[1])
            ---- v:AngerNearbyUnits()    ----设置攻击警戒
            ---- v:SetAggroTarget(self.m_tabAtker[1])    ----设置仇恨目标
        end
    end
end

----设置玩家打野
-----@param oPlayer Player
function PathMonster:setAtkerAdd(oPlayer, blinkPath)
    if 0 == #self.m_tabEMonster then
        return false
    end

    self.m_tabTrophy[oPlayer.m_eHero] = { nGold = 0, nExp = 0 }
    table.insert(self.m_tabEHero, oPlayer.m_eHero)
    table.insert(self.m_tabAtker, oPlayer.m_eHero)
    oPlayer:setState(PS_AtkHero + PS_AtkMonster)

    -- local typeState = GMManager.m_typeState
    -- GMManager:setState(GS_Wait)
    self._YieldStateCO = GSManager:yieldState()
    GSManager:setState(GS_Wait)

    local function atk(bSuccess)
        -- if GS_Wait == GMManager.m_typeState
        -- or GS_DeathClearing == GMManager.m_typeState then
        --     GMManager:setState(typeState)
        -- end
        GSManager:resumeState(self._YieldStateCO)
        if bSuccess then
            oPlayer.m_eHero:MoveToTargetToAttack(self.m_tabEMonster[1])
            self:setMonsterAtk()
        end
    end

    if blinkPath then
        oPlayer:blinkToPath(self)
        oPlayer:moveToPos(self.m_eCity:GetAbsOrigin() + self.m_eCity:GetForwardVector() * 100, atk)
    else
        oPlayer:moveToPos(self.m_eCity:GetAbsOrigin() + self.m_eCity:GetForwardVector() * 100, atk)
    end

    local tEventID = {}
    table.insert(tEventID, EventManager:register("Event_AtkMosterEnd", function(tabEvent)
        if tabEvent.entity == oPlayer.m_eHero then
            if tabEvent.bMoveBack then
                ----结束打野并回到原位
                if blinkPath then
                    oPlayer:blinkToPath(blinkPath)
                else
                    oPlayer:moveToPos(self:getUsePos(), function(bSuccess)
                        if bSuccess then
                            oPlayer:resetToPath()
                        end
                    end)
                end
            end
            EventManager:unregisterByIDs(tEventID)
        end
    end))

    ----触发打野事件
    EventManager:fireEvent("Event_AtkMoster", { entity = oPlayer.m_eHero })

    ----监听行为终止
    table.insert(tEventID, EventManager:register("Event_ActionStop", function(tEvent)
        if tEvent.entity ~= oPlayer.m_eHero then
            return
        end
        oPlayer:moveStop()
        self:setAtkerDel(oPlayer, tEvent.bMoveBack or false, false)
    end))
    return true
end
----设置玩家结束打野
-----@param oPlayer Player
-----@param bMoveBack boolen
function PathMonster:setAtkerDel(oPlayer, bMoveBack, bInPrison)
    for k, v in pairs(self.m_tabEHero) do
        if v == oPlayer.m_eHero then
            table.remove(self.m_tabEHero, k)
            ---- v:ModifyHealth(v:GetMaxHealth(), nil, false, 0)
            oPlayer:setState(-(PS_AtkHero + PS_AtkMonster))

            ----设置打野记录
            if self.m_tabTrophy[oPlayer.m_eHero] then
                local tabKV = {}
                for k, v in pairs(self.m_tabTrophy[oPlayer.m_eHero]) do
                    tabKV["[" .. k .. "]"] = v
                end
                self.m_tabTrophy[oPlayer.m_eHero] = nil
                GameRecord:setGameRecord(TGameRecord_String, oPlayer.m_nPlayerID, {
                    strText = GameRecord:encodeGameRecord(GameRecord:encodeLocalize('GameRecord_' .. TGameRecord_AtkMonster, tabKV))
                })
            end

            ----触发打野结束事件
            EventManager:fireEvent("Event_AtkMosterEnd", {
                entity = oPlayer.m_eHero,
                bMoveBack = bMoveBack,
                bInPrison = bInPrison,
            })
            break
        end
    end
    for k, v in pairs(self.m_tabAtker) do
        if v == oPlayer.m_eHero then
            table.remove(self.m_tabAtker, k)
            self:setMonsterAtk()    ----刷新野怪攻击对象
            break
        end
    end
end

----结束打野
function PathMonster:EndBattle()
    ----移除全部打野玩家
    for i = #self.m_tabAtker, 1, -1 do
        local oPlayer = PlayerManager:getPlayer(self.m_tabAtker[i]:GetPlayerOwnerID())
        self:setAtkerDel(oPlayer, true)
    end
    ----设置野怪攻击状态
    self:setMonsterAtk()
end

----获取某类型野怪的exp
function PathMonster:getMonsterExp(strMonsterName)
    for _, v in pairs(MONSTER_SETTINGS) do
        for _, v2 in pairs(v) do
            for strName, info in pairs(v2.tabMonster) do
                if strName == strMonsterName then
                    return info.nExp or 0
                end
            end
        end
    end
    return 0
end

----事件回调-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----注册事件
function PathMonster:registerEvent()
    ListenToGameEvent("entity_killed", Dynamic_Wrap(PathMonster, "onEvent_entityKilled"), self)
    EventManager:register("Event_PlayerRoundBefore", self.onEvent_PlayerRoundBefore, self, -987654321)
    EventManager:register("Event_PlayerDie", self.onEvent_PlayerDie, self)
    EventManager:register("Event_Atk", self.onEvent_Atk, self)

    if TP_MONSTER_2 == self.m_typePath or TP_MONSTER_3 == self.m_typePath then
        EventManager:register("Event_UpdateRound", function()
            if 5 * (self.m_typePath - TP_MONSTER_2 + 1) == GMManager.m_nRound then
                self:spawnMonster()
                return true
            end
        end)
    else
        EventManager:register("Event_GameStart", function()
            self:spawnMonster()
            return true
        end)
    end
end
----野怪死亡
function PathMonster:onEvent_entityKilled(keys)
    ----     damagebits: 0
    ---- entindex_attacker: 90
    ---- entindex_killed: 465
    ---- splitscreenplayer: -1
    for k, v in pairs(self.m_tabEMonster) do
        if not NULL(v) and v:GetEntityIndex() == keys.entindex_killed then
            ----移除死亡野怪
            local eAtker = EntIndexToHScript(keys.entindex_attacker)
            if not NULL(eAtker) then
                local nExp = self:getMonsterExp(v:GetUnitName())
                ----增加经验
                local player = PlayerManager:getPlayer(eAtker:GetPlayerOwnerID())
                print("player: ", player)
                PrintTable(player)
                if not NIL(player) then
                    player:setExpAdd(nExp)
                end

                ----记录收获
                local nAddGold = v:GetGoldBounty()
                local tab = self.m_tabTrophy[eAtker]
                if tab then
                    tab.nExp = tab.nExp + nExp
                    tab.nGold = tab.nGold + nAddGold
                end
                player:setGold(nAddGold)
                GMManager:showGold(player, nAddGold)

                table.remove(self.m_tabEMonster, k)
                if 0 == #self.m_tabEMonster then
                    ----结束打野
                    self:EndBattle()
                    ----刷新野怪
                    self:spawnMonster()
                else
                    ----攻击者切换攻击对象
                    for _, v2 in pairs(self.m_tabAtker) do
                        if not NULL(v2) then
                            v2:MoveToTargetToAttack(self.m_tabEMonster[1])
                        end
                    end
                end

                ----监听死亡后可能造成的攻击忽略，5秒
                local nEventID = EventManager:register("Event_Atk", function(tabEvent)
                    if keys.entindex_killed == tabEvent.entindex_attacker_const then
                        tabEvent.bIgnoreGold = true
                    end
                end)
                Timers:CreateTimer(5, function()
                    EventManager:unregisterByID(nEventID, "Event_Atk")
                end)
            end
            break
        end
    end
end

----玩家回合开始：结束打野
function PathMonster:onEvent_PlayerRoundBefore(tabEvent)
    if GS_Begin ~= tabEvent.typeGameState then
        return
    end
    local oPlayer = PlayerManager:getPlayer(GMManager.m_nOrderID)
    for _, v in pairs(self.m_tabAtker) do
        if v == oPlayer.m_eHero then
            ----监听玩家从野区移动回路径
            local function onMove(tabEvent2)
                if tabEvent2.player == oPlayer then
                    ----如果要移动，游戏状态改为等待状态
                    self._YieldStateCO = GSManager:yieldState()
                    GSManager:setState(GS_Wait)
                    -- tabEvent.typeGameState = GS_Wait
                    EventManager:register("Event_PlayerMoveEnd", function(tabEvent3)
                        if tabEvent2.player == oPlayer then
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
            self:setAtkerDel(oPlayer, true)
            EventManager:unregister("Event_PlayerMove", onMove)
            return
        end
    end
end

----玩家死亡：结束打野
function PathMonster:onEvent_PlayerDie(tabEvent)
    for _, v in pairs(self.m_tabAtker) do
        if v == tabEvent.player.m_eHero then
            ----监听玩家从野区移动回路径
            self:setAtkerDel(tabEvent.player)
            return
        end
    end
end

----野怪攻击
function PathMonster:onEvent_Atk(tabEvent)
    if 0 == #self.m_tabEMonster then
        return
    end
    local bFlag
    for _, v in pairs(self.m_tabEMonster) do
        if v:GetEntityIndex() == tabEvent.entindex_attacker_const then
            bFlag = true
            break
        end
    end
    if not bFlag then
        return      ----攻击者不是野怪
    end
    local oPlayer
    for _, v in pairs(self.m_tabEHero) do
        if v:GetEntityIndex() == tabEvent.entindex_victim_const then
            oPlayer = PlayerManager:getPlayer(v:GetPlayerID())
            break
        end
    end
    if not oPlayer then
        ----伤者不是打野英雄，忽略这次伤害
        tabEvent.bIgnore = true
        return
    end

    if tabEvent.damage >= oPlayer.m_eHero:GetHealth() then
        ----被野怪打死，结束打野，进入地狱
        print("die by moster")
        tabEvent.bIgnore = true
        oPlayer.m_eHero:ModifyHealth(oPlayer.m_eHero:GetMaxHealth(), nil, false, 0)
        self:setAtkerDel(oPlayer, false, true)
        local pathPrison = PathManager:getPathByType(TP_PRISON)[1]
        pathPrison:setInPrison(oPlayer)
    else
        ----不扣钱,扣血
        tabEvent.bIgnoreGold = true
    end
end

----野怪类型
TypeMonster = {
    TM_S = 0          ----小野类型
    , TM_S1 = 1         ----鬼混
    , TM_S2 = 2         ----狗头人
    , TM_S3 = 3         ----豺狼
    , TM_M = 1000       ----中野类型
    , TM_M1 = 1001      ----3狼
    , TM_M2 = 1002      ----红胖
    , TM_M3 = 1003      ----小萨特
    , TM_L = 2000       ----大野类型
    , TM_L1 = 2001      ----西红柿马铃薯
    , TM_L2 = 2002      ----大萨特
    , TM_L3 = 2003      ----人马
    , TM_G = 3000       ----远古野类型
    , TM_G1 = 3001      ----3龙
    , TM_G2 = 3002      ----大石头
    , TM_G3 = 3003      ----老萨特
    , TM_G4 = 3004      ----雷霆蜥蜴
}
----野怪信息
MONSTER_SETTINGS = {
    ----小野
        {
        ----鬼混
            {
            typeMonster = TypeMonster.TM_S1
            , tabMonster = {
                npc_dota_neutral_ghost = {
                    nCount = 1
                    , nExp = 1
                    , tabPos = {
                        { 0, 0, 0 }
                    }
                }
                , npc_dota_neutral_fel_beast = {
                    nCount = 2
                    , tabPos = {
                        {-100, 50, 0 }
                        , {-100, -50, 0 }
                    }
                }
            }
        }
        ----狗头人
        , {
            typeMonster = TypeMonster.TM_S2
            , tabMonster = {
                npc_dota_neutral_kobold_taskmaster = {
                    nCount = 1
                    , nExp = 1
                    , tabPos = {
                        {-100, 0, 0 }
                    }
                }
                , npc_dota_neutral_kobold_tunneler = {
                    nCount = 1
                    , tabPos = {
                        {-100, 50, 0 }
                    }
                }
                , npc_dota_neutral_kobold = {
                    nCount = 3
                    , tabPos = {
                        { 0, 0, 0 }
                        , { 0, -50, 0 }
                        , { 0, 50, 0 }
                    }
                }
            }
        }
    ----豺狼
    ---- , {
    ----     typeMonster = TypeMonster.TM_S3
    ----     , nExp = 1
    ----     , tabMonster = {
    ----         npc_dota_neutral_gnoll_assassin = {
    ----             nCount = 3
    ----             , tabPos = {
    ----                 { 0, 0, 0 }
    ----                 , {-100, -50, 0 }
    ----                 , {-100, 50, 0 }
    ----             }
    ----         }
    ----     }
    ---- }
    }
    ----中野
    , {
        ----石头人
            ----     {
            ----     typeMonster = TypeMonster.TM_M1
            ----     , nExp = 1
            ----     , tabMonster = {
            ----         npc_dota_neutral_mud_golem = {
            ----             nCount = 2
            ----             , tabPos = {
            ----                 { 0, -50, 0 }
            ----                 , { 0, 50, 0 }
            ----             }
            ----         }
            ----     }
            ---- }
            ----
            ----3狼
            {
            typeMonster = TypeMonster.TM_M1
            , tabMonster = {
                npc_dota_neutral_alpha_wolf = {
                    nCount = 1
                    , nExp = 1
                    , tabPos = {
                        { 0, 0, 0 }
                    }
                }
                , npc_dota_neutral_giant_wolf = {
                    nCount = 2
                    , tabPos = {
                        {-100, -50, 0 }
                        , {-100, -50, 0 }
                    }
                }
            }
        }
        ----红胖
        , {
            typeMonster = TypeMonster.TM_M2
            , tabMonster = {
                npc_dota_neutral_ogre_magi = {
                    nCount = 1
                    , nExp = 1
                    , tabPos = {
                        { 0, 0, 0 }
                    }
                }
                , npc_dota_neutral_ogre_mauler = {
                    nCount = 2
                    , tabPos = {
                        {-100, -50, 0 }
                        , {-100, 50, 0 }
                    }
                }
            }
        }
        ----小萨特
        , {
            typeMonster = TypeMonster.TM_M3
            , tabMonster = {
                npc_dota_neutral_satyr_soulstealer = {
                    nCount = 2
                    , nExp = 1
                    , tabPos = {
                        { 0, -50, 0 }
                        , { 0, 50, 0 }
                    }
                }
                , npc_dota_neutral_satyr_trickster = {
                    nCount = 2
                    , tabPos = {
                        {-100, -50, 0 }
                        , {-100, 50, 0 }
                    }
                }
            }
        }
    }
    ----大野
    , {
        ----马铃薯西红柿
            {
            typeMonster = TypeMonster.TM_L1
            , tabMonster = {
                npc_dota_neutral_polar_furbolg_ursa_warrior = {
                    nCount = 1
                    , nExp = 2
                    , tabPos = {
                        { 0, -50, 0 }
                    }
                }
                , npc_dota_neutral_polar_furbolg_champion = {
                    nCount = 1
                    , nExp = 1
                    , tabPos = {
                        { 0, 50, 0 }
                    }
                }
            }
        }
        ----人马
        , {
            typeMonster = TypeMonster.TM_L3
            , tabMonster = {
                npc_dota_neutral_centaur_khan = {
                    nCount = 1
                    , nExp = 2
                    , tabPos = {
                        { 0, 0, 0 }
                    }
                }
                , npc_dota_neutral_centaur_outrunner = {
                    nCount = 2
                    , nExp = 0
                    , tabPos = {
                        { 0, 50, -50 }
                        , { 0, -50, -50 }
                    }
                }
            }
        }
        ----大萨特
        , {
            typeMonster = TypeMonster.TM_L2
            , tabMonster = {
                npc_dota_neutral_satyr_hellcaller = {
                    nCount = 1
                    , nExp = 1
                    , tabPos = {
                        { 0, 0, 0 }
                    }
                }
                , npc_dota_neutral_satyr_soulstealer = {
                    nCount = 1
                    , nExp = 1
                    , tabPos = {
                        { 0, 50, -50 }
                    }
                }
                , npc_dota_neutral_satyr_trickster = {
                    nCount = 1
                    , tabPos = {
                        { 0, -50, -50 }
                    }
                }
            }
        }
    }
    ----远古
    , {
        ----3龙
            {
            typeMonster = TypeMonster.TM_G1
            , tabMonster = {
                npc_dota_neutral_black_dragon = {
                    nCount = 1
                    , nExp = 3
                    , tabPos = {
                        { 0, 0, 0 }
                    }
                }
                , npc_dota_neutral_black_drake = {
                    nCount = 2
                    , nExp = 0
                    , tabPos = {
                        {-100, -50, 0 }
                        , {-100, 50, 0 }
                    }
                }
            }
        }
        ----大石头怪
        , {
            typeMonster = TypeMonster.TM_G2
            , tabMonster = {
                npc_dota_neutral_granite_golem = {
                    nCount = 1
                    , nExp = 3
                    , tabPos = {
                        { 0, 0, 0 }
                    }
                }
                , npc_dota_neutral_rock_golem = {
                    nCount = 2
                    , nExp = 0
                    , tabPos = {
                        {-100, -50, 0 }
                        , {-100, 50, 0 }
                    }
                }
            }
        }
        ----老萨特
        , {
            typeMonster = TypeMonster.TM_G3
            , tabMonster = {
                npc_dota_neutral_prowler_shaman = {
                    nCount = 1
                    , nExp = 3
                    , tabPos = {
                        { 0, 0, 0 }
                    }
                }
                , npc_dota_neutral_prowler_acolyte = {
                    nCount = 2
                    , nExp = 0
                    , tabPos = {
                        {-100, -50, 0 }
                        , {-100, 50, 0 }
                    }
                }
            }
        }
        ----雷霆蜥蜴
        , {
            typeMonster = TypeMonster.TM_G4
            , tabMonster = {
                npc_dota_neutral_big_thunder_lizard = {
                    nCount = 1
                    , nExp = 3
                    , tabPos = {
                        { 0, -50, 0 }
                    }
                }
                , npc_dota_neutral_small_thunder_lizard = {
                    nCount = 2
                    , nExp = 0
                    , tabPos = {
                        {-100, -50, 0 }
                        , {-100, 50, 0 }
                    }
                }
            }
        }
    }
}