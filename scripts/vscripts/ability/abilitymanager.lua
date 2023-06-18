require("Ability/common")
require('modifiers/modifier_events')
LinkLuaModifier("modifier_events", "modifiers/modifier_events.lua", LUA_MODIFIER_MOTION_NONE)
require('modifiers/modifier_fix_damage')
LinkLuaModifier("modifier_fix_damage", "modifiers/modifier_fix_damage.lua", LUA_MODIFIER_MOTION_NONE)
require('modifiers/util/modifier_ignore_armor')
LinkLuaModifier("modifier_ignore_armor", "modifiers/util/modifier_ignore_armor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ignore_armor_debuff", "modifiers/util/modifier_ignore_armor.lua", LUA_MODIFIER_MOTION_NONE)
require('modifiers/util/modifier_xixue')
LinkLuaModifier("modifier_xixue", "modifiers/util/modifier_xixue.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_xixue_debuff", "modifiers/util/modifier_xixue.lua", LUA_MODIFIER_MOTION_NONE)
if PrecacheItems then
    table.insert(PrecacheItems, "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf")
    table.insert(PrecacheItems, "particles/custom/ability_mark.vpcf")
    table.insert(PrecacheItems, "particles/generic_gameplay/illusion_killed.vpcf")
    table.insert(PrecacheItems, "particles/econ/items/outworld_devourer/od_shards_exile/od_shards_exile_prison_start.vpcf")
    table.insert(PrecacheItems, "particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf")
    table.insert(PrecacheItems, "particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_ti6_arc_b.vpcf")
    table.insert(PrecacheItems, "particles/econ/items/shadow_shaman/shadow_shaman_ti8/shadow_shaman_ti8_ether_shock_target_snakes.vpcf")
    table.insert(PrecacheItems, "particles/neutral_fx/tornado_ambient.vpcf")
    table.insert(PrecacheItems, "particles/units/unit_greevil/loot_greevil_death.vpcf")
    table.insert(PrecacheItems, "particles/custom/path_ablt/path_ablt_nocdmana_1.vpcf")
    table.insert(PrecacheItems, "particles/custom/path_ablt/path_ablt_nocdmana_2.vpcf")
    table.insert(PrecacheItems, "particles/custom/path_ablt/path_ablt_nocdmana_3.vpcf")
end

----lua技能模块
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if not AbilityManager then
    AbilityManager = class({
        m_tabNullAbltCD = {},
        m_tabEntityItemCD = {}, ----记录一个单位的多个同物品中用来刷CD的那个物品{entid,{itemName,item}}
    })
end

----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
function AbilityManager:init(bReload)
    if not bReload then
        self.m_tabNullAbltCD = {}
        self.m_tabEntityItemCD = {}
    end
    ListenToGameEvent("dota_item_purchased", Dynamic_Wrap(AbilityManager, "onEvent_itemPurchased"), self)
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(AbilityManager, "onNPCFirstSpawned"), self)
end

----设置回合CD
function AbilityManager:setRoundCD(oPlayer, oAblt, nCD)
    if NULL(oAblt) then
        return
    end

    ---- EventManager:fireEvent("Event_HeroManaChange", { player = oPlayer, oAblt = oAblt })
    ----计算技能CD
    if not nCD then
        nCD = oAblt:GetCooldownTime()
    end
    if 0 >= nCD then
        nCD = 1
    end

    local bItem = oAblt:IsItem()
    local eCaster = oAblt:GetCaster()
    local nCasterID = eCaster:GetEntityIndex()
    local strName = oAblt:GetAbilityName()
    local tEventID = {}
    local sTink

    if not AbilityManager.m_tabEntityItemCD[oPlayer.m_nPlayerID] then
        AbilityManager.m_tabEntityItemCD[oPlayer.m_nPlayerID] = {}
    end

    ----CD完成
    local function onCDEnd()
        if not oAblt:IsNull() then
            oAblt:EndCooldown()
        end
        Timers:RemoveTimer(sTink)
        if not NIL(AbilityManager.m_tabEntityItemCD[oPlayer.m_nPlayerID]) then
            AbilityManager.m_tabEntityItemCD[oPlayer.m_nPlayerID][strName] = nil
        end
        for _, v in pairs(tEventID) do
            EventManager:unregisterByID(v)
        end
        tEventID = {}
    end

    ----物品还有CD则修改
    if bItem then
        local item = AbilityManager.m_tabEntityItemCD[oPlayer.m_nPlayerID][strName]
        if not IsValid(item) or not IsValid(item:GetCaster()) then
            item = oAblt
        elseif not item:IsCooldownReady() then
            EventManager:fireEvent("Event_LastCDChange", {
                strAbltName = strName,
                entity = eCaster,
                nCD = nCD,
            })
            return
        end

        AbilityManager.m_tabEntityItemCD[oPlayer.m_nPlayerID][strName] = oAblt

        ----监听物品移除切换刷CD物品
        --item = item,
        --entity = caster
        local nAbltEntID = item:GetEntityIndex()
        table.insert(tEventID, EventManager:register("Event_ItemDel", function(tEvent)
            if nAbltEntID == tEvent.nItemEntID then
                local itemNew = oPlayer:getItemFromAllByName(strName, item)
                if itemNew then
                    item = itemNew
                    oAblt = itemNew
                    nAbltEntID = itemNew:GetEntityIndex()
                    AbilityManager.m_tabEntityItemCD[oPlayer.m_nPlayerID][strName] = itemNew
                else
                    onCDEnd()
                end
            end
        end))
    end

    local nCDLast = nCD

    ----玩家回合开始事件
    table.insert(tEventID, EventManager:register("Event_PlayerRoundBegin", function(tEvent)
        if tEvent.oPlayer ~= oPlayer then
            return
        end
        ----倒计时的物品被放入背包
        if bItem then
            if 6 <= oAblt:GetItemSlot() then
                ----切换到在物品栏的同物品
                if IsValid(eCaster) then
                    local item = eCaster:get05ItemByName(strName)
                    if not item then
                        return  ----没有就不刷cd
                    end
                    oAblt = item
                end
            end
        end
        nCDLast = nCDLast - 1
        if 0 == nCDLast then
            onCDEnd()
        end
    end))

    ----监听修改CD事件
    table.insert(tEventID, EventManager:register("Event_LastCDChange", function(tEvent)
        if tEvent.strAbltName == strName and tEvent.entity == eCaster then
            nCDLast = tEvent.nCD
            if oAblt:IsNull() then
                onCDEnd()
            else
                oAblt:StartCooldown(nCDLast)
                if 0 == nCDLast then
                    onCDEnd()
                end
            end
        end
    end))

    ----持续设置CD
    oAblt:StartCooldown(nCDLast)
    sTink = Timers:CreateTimer(function()
        if oAblt:IsNull() then
            if not NIL(eCaster) and not eCaster:IsNull() then
                ----找其他同物品
                if bItem then
                    ---- if oAblt == AbilityManager.m_tabEntityItemCD[oPlayer.m_nPlayerID][strName] then
                    ----     local item = eCaster:get08ItemByName(strName, oAblt)
                    ----     if item then
                    ----         oAblt = item
                    ----         AbilityManager.m_tabEntityItemCD[oPlayer.m_nPlayerID][strName] = item
                    ----         return 0
                    ----     end
                    ---- end
                else
                    ----被移除了也要记录CD
                    -- if 0 < nCDLast then
                    --     ----技能或者物品被移除，自己记录CD
                    --     if not self.m_tabNullAbltCD[eCaster] then
                    --         self.m_tabNullAbltCD[eCaster] = {}
                    --     end
                    --     for k, v in pairs(self.m_tabNullAbltCD[eCaster]) do
                    --         if strName == v.strName then
                    --             if v.bDel then
                    --                 table.remove(self.m_tabNullAbltCD[eCaster], k)
                    --                 onCDEnd()
                    --                 return nil
                    --             end
                    --             v.nCD = nCDLast
                    --             return 0.9
                    --         end
                    --     end
                    --     table.insert(self.m_tabNullAbltCD[eCaster], {
                    --         nCD = nCDLast
                    --         , strName = strName
                    --     })
                    --     return 0.9
                    -- elseif 0 == nCDLast and self.m_tabNullAbltCD[eCaster] then
                    --     ----技能或者物品被移除，自己记录CD
                    --     for k, v in pairs(self.m_tabNullAbltCD[eCaster]) do
                    --         if strName == v.strName then
                    --             table.remove(self.m_tabNullAbltCD[eCaster], k)
                    --             break
                    --         end
                    --     end
                    --     if 0 == #self.m_tabNullAbltCD[eCaster] then
                    --         self.m_tabNullAbltCD[eCaster] = nil
                    --     end
                    -- end
                end
            end
        elseif 0 < nCDLast then
            oAblt:StartCooldown(nCDLast)
            return 0.9
        end
        onCDEnd()
        return nil
    end)
end

function AbilityManager:onEvent_itemPurchased()
    ----开启被出售的物品CD倒计时
    for e, tabAll in pairs(self.m_tabNullAbltCD) do
        for _, tab in pairs(tabAll) do
            for i = 0, 5 do
                local item = e:GetItemInSlot(i)
                if IsValid(item) and item:GetAbilityName() == tab.strName then
                    ----开启计时
                    tab.bDel = true
                    ----Timers:CreateTimer(0.1, function()
                    self:setRoundCD(PlayerManager:getPlayer(e:GetPlayerOwnerID()), item, tab.nCD)
                    ----end)
                    break
                end
            end
        end
    end
end

function AbilityManager:onNPCFirstSpawned(events)
    local spawnedUnit = EntIndexToHScript(events.entindex)
    if spawnedUnit == nil then return end
    -- 添加默认modifier
    local tData = KeyValues.UnitsKv[spawnedUnit:GetUnitName()]
    if tData ~= nil and tData.AmbientModifiers ~= nil and tData.AmbientModifiers ~= "" then
        local tList = string.split(string.gsub(tData.AmbientModifiers, " ", ""), "|")
        for i, sAmbientModifier in pairs(tList) do
            spawnedUnit:AddNewModifier(spawnedUnit, nil, sAmbientModifier, nil)
        end
    end
    -- 注册修正伤害
    spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_fix_damage", nil)
end

----显示技能范围标识
function AbilityManager:showAbltMark(ablt, e, tabPathID)
    if ablt._timeAbltMark and 1 > GameRules:GetDOTATime(false, true) - ablt._timeAbltMark then
        return
    end
    local tabPath = CustomNetTables:GetTableValue("GameingTable", "path_info")
    if not tabPath then
        return
    end

    if ablt._tabAbltMarkPtcl then
        for _, v in pairs(ablt._tabAbltMarkPtcl) do
            ParticleManager:DestroyParticle(v, false)
        end
    end
    ablt._tabAbltMarkPtcl = {}
    ablt._timeAbltMark = GameRules:GetDOTATime(false, true)

    ----特效
    for _, v in pairs(tabPathID) do
        local tabPathInfo = tabPath[tostring(v)]
        if tabPathInfo then
            local vPos = Vector(tabPathInfo.vPos.x, tabPathInfo.vPos.y, tabPathInfo.vPos.z)
            local nPtclID = ParticleManager:CreateParticle("particles/custom/ability_mark.vpcf"
            , PATTACH_POINT, e)
            ParticleManager:SetParticleControl(nPtclID, 0, vPos)
            table.insert(ablt._tabAbltMarkPtcl, nPtclID)
        end
    end

    -- e:SetContextThink(DoUniqueString("showAbltMark"), function()
    --     print("1111")
    -- end, 1)
end

----更新兵卒的buff（用于在兵卒创建添加buff）
function AbilityManager:updataBZBuffByCreate(oPlayer, oAblt, funOnBuffApply)
    ----监听兵卒创建
    local function f(tabEvent)
        if tabEvent.entity:GetPlayerOwnerID() == oPlayer.m_nPlayerID then
            ----给升级的兵卒添加buff
            if oAblt and oAblt:IsNull() then
                return true ----BUFF被移除，注销事件
            end
            if nil ~= funOnBuffApply then
                return funOnBuffApply(tabEvent.entity)
            end
        end
    end
    EventManager:register("Event_BZCreate", f)
    return function()
        EventManager:unregister("Event_BZCreate", f)
    end
end
----更新兵卒的buff（用于在兵卒升级后添加buff）
function AbilityManager:updataBZBuffByLevel(eBZ, funOnBuffApply)
    local function f(tabEvent)
        if tabEvent.eBZ == eBZ then
            ----给升级的兵卒添加buff
            eBZ = tabEvent.eBZNew
            return funOnBuffApply(eBZ)
        end
    end
    EventManager:register("Event_BZLevel", f)
    return function()
        EventManager:unregister("Event_BZLevel", f)
    end
end

----兵卒能否放技能
function AbilityManager:isCanOnAblt(eBZ)
    local tabBuffs = eBZ:FindAllModifiers()
    for _, v in pairs(tabBuffs) do
        local strBuff = string.reverse(v:GetName())
        local nPos = string.find(strBuff, '_')
        if nPos then
            strBuff = string.sub(strBuff, 1, nPos - 1)
            strBuff = string.reverse(strBuff)
            if "chenmo" == strBuff then
                return false
            end
        end
    end
    return true
end

----buff计算回合结束
function AbilityManager:judgeBuffRound(nPlayerIDCaster, buff, funChange)
    if not IsValid(buff) or not buff.m_nRound or 1 > buff.m_nRound then
        return
    end
    EventManager:register("Event_PlayerRoundFinished", function(playerF)
        if playerF.m_nPlayerID == GMManager:getLastValidOrder(nPlayerIDCaster) then
            ----一轮结束
            buff.m_nRound = buff.m_nRound - 1
            if "function" == type(funChange) then
                funChange()
            end
            if 0 >= buff.m_nRound then
                if IsValid(buff) then
                    buff:Destroy()
                end
                return true
            end
        end
    end)
end

----添加可复制的buff
function AbilityManager:setCopyBuff(sBuff, eTarget, eCaster, ablt, tBuffData, bStack, _oBuffOld)
    local oBuff
    if IsValid(eTarget) then
        oBuff = eTarget:FindModifierByNameAndCaster(sBuff, eCaster)
    end
    if not oBuff then
        oBuff = eTarget:AddNewModifier(eCaster, ablt, sBuff, tBuffData)
        if oBuff then
            oBuff.copyBfToEnt = function(_, e)
                return AbilityManager:setCopyBuff(sBuff, e, eCaster, ablt, tBuffData, bStack, oBuff)
            end
            if _oBuffOld then
                oBuff.m_nRound = _oBuffOld.m_nRound
                oBuff:SetStackCount(_oBuffOld:GetStackCount())
            end
        end
    elseif bStack then
        if 0 == oBuff:GetStackCount() then oBuff:SetStackCount(1) end
        oBuff:IncrementStackCount()
    end
    return oBuff
end

----养精蓄锐
function onAblt_yjxr(keys)
    local cUnit = keys.caster
    local oAblt = keys.ability
    local nGold = oAblt:GetGoldCost(oAblt:GetLevel() - 1)
    ----升级
    local oPlayer = PlayerManager:getPlayer(cUnit:GetPlayerOwnerID())
    cUnit = oPlayer:setBzStarLevelUp(cUnit, 1)

    oPlayer:setGold(-nGold)
    ----通知UI显示花费
    GMManager:showGold(oPlayer, -nGold)

    ----设置游戏记录
    local tabKV = {}
    tabKV["[nGold]"] = nGold
    tabKV["[strBZName]"] = GameRecord:encodeLocalize(cUnit:GetUnitName())
    tabKV["[strPathName]"] = GameRecord:encodeLocalize("PathName_" .. cUnit.m_path.m_nID)
    GameRecord:setGameRecord(TGameRecord_String, oPlayer.m_nPlayerID, {
        strText = GameRecord:encodeGameRecord(GameRecord:encodeLocalize("GameRecord_" .. TGameRecord_YJXR, tabKV))
    })
end
----解甲归田
function onAblt_xj(keys)
    local cUnit = keys.caster
    local oAblt = keys.ability
    local nGold = oAblt:GetGoldCost(oAblt:GetLevel() - 1)
    ----降级
    local oPlayer = PlayerManager:getPlayer(cUnit:GetPlayerOwnerID())
    cUnit = oPlayer:setBzStarLevelUp(cUnit, -1)
    ----还钱
    oPlayer:setGold(-nGold)
    ----通知UI显示花费
    GMManager:showGold(oPlayer, -nGold)
    ----设置游戏记录
    local tabKV = {}
    tabKV["[nGold]"] = -nGold
    tabKV["[strBZName]"] = GameRecord:encodeLocalize(cUnit:GetUnitName())
    tabKV["[strPathName]"] = GameRecord:encodeLocalize("PathName_" .. cUnit.m_path.m_nID)
    GameRecord:setGameRecord(TGameRecord_String, oPlayer.m_nPlayerID, {
        strText = GameRecord:encodeGameRecord(GameRecord:encodeLocalize("GameRecord_" .. TGameRecord_XJ, tabKV))
    })
end

----双倍神符
function onAblt_rune_0(keys)
    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerID())
    if nil == oPlayer then
        return
    end

    local oAblt = keys.ability

    ----给玩家全部单位双倍buff
    ----local oAblt = AMHC:AddAbilityAndSetLevel(oPlayer.m_eHero, "rune_0")
    oAblt.m_strBuffBZ = "modifier_" .. oAblt:GetAbilityName()
    for _, eBZ in pairs(oPlayer.m_tabBz) do
        oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
        ---- AMHC:AddAbilityAndSetLevel(eBZ, "rune_0")
    end
    AbilityManager:updataBZBuffByCreate(oPlayer, oAblt, function(eBZ)
        oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
    end)

    ----监听持续时间回合结束
    local nRoundEnd = GMManager.m_nRound + oAblt:GetLevelSpecialValueFor("duration", 1) - 1
    EventManager:register("Event_PlayerRoundFinished", function(oPlayerFinished)
        if nRoundEnd == GMManager.m_nRound and oPlayerFinished == oPlayer and oPlayer.m_bRoundFinished then
            ----移除buff
            for _, eBZ in pairs(oPlayer.m_tabBz) do
                eBZ:RemoveModifierByName("modifier_" .. oAblt:GetAbilityName())
            end
            AMHC:RemoveAbilityAndModifier(oPlayer.m_eHero, oAblt:GetAbilityName())
            return true
        end
    end)
end

----极速神符
function onAblt_rune_1(keys)
    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerID())
    if nil == oPlayer then
        return
    end

    local oAblt = keys.ability

    ----监听持续时间回合结束
    local nRoundEnd = GMManager.m_nRound + oAblt:GetLevelSpecialValueFor("duration", 1) - 1
    EventManager:register("Event_PlayerRoundFinished", function(oPlayerFinished)
        if nRoundEnd == GMManager.m_nRound and oPlayerFinished == oPlayer and oPlayer.m_bRoundFinished then
            ----移除buff
            AMHC:RemoveAbilityAndModifier(oPlayer.m_eHero, oAblt:GetAbilityName())
            return true
        end
    end)
end

----幻象神符
function onAblt_rune_2(keys)
    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerID())
    if nil == oPlayer then
        return
    end

    local oAblt = keys.ability

    ----给玩家全部单位幻象buff
    oAblt.m_strBuffBZ = "modifier_" .. oAblt:GetAbilityName()
    for _, eBZ in pairs(oPlayer.m_tabBz) do
        oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
    end
    AbilityManager:updataBZBuffByCreate(oPlayer, oAblt, function(eBZ)
        oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
    end)

    ----监听持续时间回合结束
    local nRoundEnd = GMManager.m_nRound + oAblt:GetLevelSpecialValueFor("duration", 1) - 1
    EventManager:register("Event_PlayerRoundFinished", function(oPlayerFinished)
        if nRoundEnd == GMManager.m_nRound and oPlayerFinished == oPlayer and oPlayer.m_bRoundFinished then
            ----移除buff
            for _, eBZ in pairs(oPlayer.m_tabBz) do
                eBZ:RemoveModifierByName("modifier_" .. oAblt:GetAbilityName())
            end
            AMHC:RemoveAbilityAndModifier(oPlayer.m_eHero, oAblt:GetAbilityName())
            return true
        end
    end)
end
function onAblt_rune_2_beAtk(keys)
    local oAblt = keys.ability
    local nChance = oAblt:GetSpecialValueFor("beatk_chance")   ----幻象被攻击概率
    if RandomInt(1, 100) > nChance then
        return
    end
    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerOwnerID())
    ----创建幻象
    ---- local eIllusion = AMHC:CreateIllusion(keys.caster)
    ---- eIllusion:SetAbsOrigin(eIllusion:GetAbsOrigin() - keys.attacker:GetForwardVector() * 100)
    ----
    ----添加受伤事件
    EventManager:register("Event_BeAtk", function(tabEvent)
        if tabEvent.entindex_attacker_const == keys.attacker:GetEntityIndex()
        and tabEvent.entindex_victim_const == keys.caster:GetEntityIndex() then
            ----模拟分身被击杀特效
            ----eIllusion:ForceKill(false)
            local nPtclID = AMHC:CreateParticle("particles/generic_gameplay/illusion_killed.vpcf"
            , PATTACH_ABSORIGIN, false, keys.caster, 2)
            ----取消本次伤害
            tabEvent.damage = 0
            tabEvent.bIgnore = true ----忽略伤害订单
            return true
        end
    end, nil, 10000)
end
function onAblt_rune_2_atk(keys)

    local oAblt = keys.ability
    local nChance = oAblt:GetSpecialValueFor("atk_chance")   ----幻象攻击概率
    if RandomInt(1, 100) > nChance then
        return
    end
    ----创建幻象攻击目标
    local eIllusion = AMHC:CreateIllusion(keys.caster, nil, 0, 0)
    ---- local eIllusion = CreateIllusions(keys.caster, keys.caster, { outgoing_damage = 0, incoming_damage = 100 }, 1, 0, true, true)
    EmitSoundOn("DOTA_Item.Manta", eIllusion)
    AMHC:RemoveAbilityAndModifier(eIllusion, oAblt:GetAbilityName())
    eIllusion:SetControllableByPlayer(-1, true)
    eIllusion:Hold()
    Timers:CreateTimer(0.1, function()
        eIllusion:MoveToTargetToAttack(keys.target)
    end)

    ----隐藏原单位，且设置不可攻击
    ---- keys.caster:Stop()
    keys.caster:AddNoDraw()
    AMHC:AddAbilityAndSetLevel(keys.caster, "jiaoxie")

    local over

    ----监听幻象攻击结束
    local function onEvent_Atk(tabEvent)
        if tabEvent.entindex_attacker_const == eIllusion:GetEntityIndex()
        and tabEvent.entindex_victim_const == keys.target:GetEntityIndex() then
            Timers:CreateTimer(function()
                if not eIllusion:IsSequenceFinished() then
                    return 0.1      ----等待攻击后摇结束
                end
                over()
                return nil
            end)
            ----取消本次伤害
            tabEvent.bIgnore = true ----忽略伤害订单
            return true
        end
    end
    EventManager:register("Event_Atk", onEvent_Atk)

    over = function()
        ----攻击结束销毁分身
        AMHC:CreateParticle("particles/generic_gameplay/illusion_killed.vpcf"
        , PATTACH_ABSORIGIN, false, eIllusion, 1)
        eIllusion:ForceKill(false)
        ----还原原单位
        keys.caster:RemoveNoDraw()
        ---- keys.caster:StartGesture(ACT_DOTA_IDLE)
        AMHC:RemoveAbilityAndModifier(keys.caster, "jiaoxie")
        ---- keys.caster:Stop()
        keys.caster:MoveToTargetToAttack(keys.target)

        EventManager:unregister("Event_Atk", onEvent_Atk)
    end
    Timers:CreateTimer(keys.caster:GetAttackAnimationPoint(), function()
        over()
    end)
end

----隐形神符
function onAblt_rune_3(keys)
    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerID())
    if nil == oPlayer then
        return
    end

    local oAblt = keys.ability

    ----添加隐身
    local oBuff = keys.caster:AddNewModifier(keys.caster, oAblt, "modifier_rune_invis", {})
    oPlayer:setState(PS_Invis)

    ----监听隐身结束移除buff
    local function onEvent_PlayerInvisEnd(tEvent)
        if not oAblt or oAblt:IsNull() then
            return true
        end
        if tEvent.player == oPlayer then
            ----移除buff
            AMHC:RemoveAbilityAndModifier(keys.caster, oAblt:GetAbilityName())
            keys.caster:RemoveModifierByName("modifier_rune_invis")
            return true
        end
    end
    EventManager:register("Event_PlayerInvisEnd", onEvent_PlayerInvisEnd)

    ----监听持续时间回合结束
    local nRoundEnd = GMManager.m_nRound + oAblt:GetLevelSpecialValueFor("duration", 1) - 1
    EventManager:register("Event_PlayerRoundFinished", function(oPlayerFinished)
        if not oAblt or oAblt:IsNull() then
            return true
        end
        if nRoundEnd == GMManager.m_nRound and oPlayerFinished == oPlayer and oPlayer.m_bRoundFinished then
            ----移除buff
            AMHC:RemoveAbilityAndModifier(keys.caster, oAblt:GetAbilityName())
            keys.caster:RemoveModifierByName("modifier_rune_invis")
            EventManager:unregister("Event_PlayerInvisEnd", onEvent_PlayerInvisEnd)
            return true
        end
    end)
end

----回复神符
function onAblt_rune_4(keys)
    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerID())
    if nil == oPlayer then
        return
    end

    local oAblt = keys.ability

    ----设置玩家全部单位满蓝满血
    oPlayer.m_eHero:ModifyHealth(oPlayer.m_eHero:GetMaxHealth(), nil, false, 0)
    oPlayer.m_eHero:SetMana(oPlayer.m_eHero:GetMaxMana())

    for _, eBZ in pairs(oPlayer.m_tabBz) do
        eBZ:SetMana(eBZ:GetMaxMana())
        eBZ:ModifyHealth(eBZ:GetMaxHealth(), nil, false, 0)
    end


    ----加蓝特效
    local nPtclID = AMHC:CreateParticle("particles/econ/items/outworld_devourer/od_shards_exile/od_shards_exile_prison_start.vpcf"
    , PATTACH_OVERHEAD_FOLLOW, false, oPlayer.m_eHero, 2)
    ParticleManager:SetParticleControl(nPtclID, 0, oPlayer.m_eHero:GetOrigin())
    ParticleManager:SetParticleControl(nPtclID, 1, oPlayer.m_eHero:GetOrigin())
    for _, eBZ in pairs(oPlayer.m_tabBz) do
        nPtclID = AMHC:CreateParticle("particles/econ/items/outworld_devourer/od_shards_exile/od_shards_exile_prison_start.vpcf"
        , PATTACH_OVERHEAD_FOLLOW, false, eBZ, 2)
        ParticleManager:SetParticleControl(nPtclID, 0, eBZ:GetOrigin())
        ParticleManager:SetParticleControl(nPtclID, 1, eBZ:GetOrigin())
    end

    ----监听持续时间回合结束
    local nRoundEnd = GMManager.m_nRound + oAblt:GetLevelSpecialValueFor("duration", 1) - 1
    EventManager:register("Event_PlayerRoundFinished", function(oPlayerFinished)
        if nRoundEnd == GMManager.m_nRound and oPlayerFinished == oPlayer and oPlayer.m_bRoundFinished then
            ----移除buff
            AMHC:RemoveAbilityAndModifier(oPlayer.m_eHero, oAblt:GetAbilityName())
            return true
        end
    end)
end

----赏金神符
function onAblt_rune_5(keys)
    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerID())
    if nil == oPlayer then
        return
    end

    local oAblt = keys.ability

    ----设置玩家获得金币
    local nGold = oAblt:GetLevelSpecialValueFor("gold", 1)
    oPlayer:setGold(nGold)

    ----飘金
    GMManager:showGold(oPlayer, nGold)

    Timers:CreateTimer(0.01, function()
        AMHC:RemoveAbilityAndModifier(oPlayer.m_eHero, oAblt:GetAbilityName())
    end)
end

----奥术神符
function onAblt_rune_6(keys)
    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerID())
    if nil == oPlayer then
        return
    end

    local oAblt = keys.ability

    ----给玩家单位奥术buff
    oAblt.m_strBuffBZ = "modifier_" .. oAblt:GetAbilityName()
    for _, eBZ in pairs(oPlayer.m_tabBz) do
        oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
    end
    AbilityManager:updataBZBuffByCreate(oPlayer, oAblt, function(eBZ)
        oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
    end)

    ----设置冷却减缩
    local nCDSub = oAblt:GetLevelSpecialValueFor("cdsub", 1)
    oPlayer:setCDSub(oPlayer.m_nCDSub + nCDSub)
    ----设置魔法减缩
    local nManaSub = oAblt:GetLevelSpecialValueFor("manasub", 1)
    oPlayer:setManaSub(oPlayer.m_nManaSub + nManaSub)

    ----监听持续时间回合结束
    local nRoundEnd = GMManager.m_nRound + oAblt:GetLevelSpecialValueFor("duration", 1) - 1
    EventManager:register("Event_PlayerRoundFinished", function(oPlayerFinished)
        if nRoundEnd == GMManager.m_nRound and oPlayerFinished == oPlayer and oPlayer.m_bRoundFinished then
            ----移除buff
            for _, eBZ in pairs(oPlayer.m_tabBz) do
                eBZ:RemoveModifierByName("modifier_" .. oAblt:GetAbilityName())
            end
            AMHC:RemoveAbilityAndModifier(oPlayer.m_eHero, oAblt:GetAbilityName())
            oPlayer:setCDSub(oPlayer.m_nCDSub - nCDSub)
            oPlayer:setManaSub(oPlayer.m_nManaSub - nManaSub)
            return true
        end
    end)
end

----天辉路径技能
function onAblt_path_12(keys)
    if true then
        return
    end
    if not keys.caster:IsRealHero() then
        return
    end

    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerID())
    if nil == oPlayer then
        return
    end
    local oAblt = keys.ability

    ----给玩家全部兵卒buff
    Timers:CreateTimer(0.1, function()
        if oAblt:IsNull() then
            return
        end
        oAblt.m_strBuffBZ = "modifier_" .. oAblt:GetAbilityName()
        for _, eBZ in pairs(oPlayer.m_tabBz) do
            oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
        end
        AbilityManager:updataBZBuffByCreate(oPlayer, oAblt, function(eBZ)
            oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
        end)
    end)

    ----监听领地技能移除
    EventManager:register("Event_PathBuffDel", function(tabEvent)
        if tabEvent.oPlayer ~= oPlayer or TP_DOMAIN_1 ~= tabEvent.path.m_typePath then
            return
        end
        for _, eBZ in pairs(oPlayer.m_tabBz) do
            eBZ:RemoveModifierByName("modifier_" .. oAblt:GetAbilityName())
        end
        return true
    end)
end
----河道路径技能
function onAblt_path_13(keys)

    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerID())
    if nil == oPlayer then
        return
    end
    -- SetIgnoreMagicResistanceValue(unit, value, key)
    local tabPaths = PathManager:getPathByType(TP_DOMAIN_2)
    if 0 == #tabPaths then
        return
    end

    local oAblt = keys.ability

    local function getBuffType(path)
        if tabPaths[1] == path then
            return "_mokang"
        else
            return "_hujia"
        end
    end

    for _, v in pairs(tabPaths) do
        if v.m_nOwnerID == oPlayer.m_nPlayerID then
            local strBuffBZ = "modifier_" .. oAblt:GetAbilityName() .. getBuffType(v)
            ----给玩家全部兵卒buff
            Timers:CreateTimer(0.1, function()
                if not oAblt:IsNull() then
                    for _, eBZ in pairs(oPlayer.m_tabBz) do
                        oAblt:ApplyDataDrivenModifier(eBZ, eBZ, strBuffBZ, {})
                    end
                    AbilityManager:updataBZBuffByCreate(oPlayer, oAblt, function(eBZ)
                        oAblt:ApplyDataDrivenModifier(eBZ, eBZ, strBuffBZ, {})
                    end)
                end
            end)
        end
    end

    ----监听领地技能移除
    EventManager:register("Event_PathBuffDel", function(tabEvent)
        if tabEvent.oPlayer ~= oPlayer or TP_DOMAIN_2 ~= tabEvent.path.m_typePath then
            return
        end
        oPlayer.m_eHero:RemoveModifierByName("modifier_" .. oAblt:GetAbilityName() .. "_mokang")
        oPlayer.m_eHero:RemoveModifierByName("modifier_" .. oAblt:GetAbilityName() .. "_hujia")
        for _, eBZ in pairs(oPlayer.m_tabBz) do
            eBZ:RemoveModifierByName("modifier_" .. oAblt:GetAbilityName() .. "_mokang")
            eBZ:RemoveModifierByName("modifier_" .. oAblt:GetAbilityName() .. "_hujia")
        end
        return true
    end)

    -- oAblt.m_strBuffBZ = "modifier_" .. oAblt:GetAbilityName() .. "_BZ_"
    ----给玩家全部兵卒buff
    -- Timers:CreateTimer(0.1, function()
    --     if oAblt:IsNull() then
    --         return
    --     end
    --     for _, eBZ in pairs(oPlayer.m_tabBz) do
    --         if TP_DOMAIN_2 == eBZ.m_path.m_typePath then
    --             oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ .. getBuffType(eBZ.m_path), {})
    --         end
    --     end
    --     AbilityManager:updataBZBuffByCreate(oPlayer, oAblt, function(eBZ)
    --         if TP_DOMAIN_2 == eBZ.m_path.m_typePath then
    --             oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ .. getBuffType(eBZ.m_path), {})
    --         end
    --     end)
    -- end)
    ----监听玩家路过某路径事件
    -- EventManager:register("Event_PassingPath", function(tabEvent)
    --     if oAblt:IsNull() then
    --         return true     ----BUFF被移除，注销事件
    --     end
    --     if TP_DOMAIN_2 == tabEvent.path.m_typePath
    --     and tabEvent.path.m_nOwnerID == oPlayer.m_nPlayerID
    --     and tabEvent.entity ~= keys.caster
    --     and 0 == bit.band(PS_InPrison, oPlayer.m_typeState) then
    --         local oPlayerTarget = PlayerManager:getPlayer(tabEvent.entity:GetPlayerOwnerID())
    --         if nil == oPlayerTarget or 0 < bit.band(oPlayerTarget.m_typeState, PS_AbilityImmune) then
    --             return  ----技能免疫
    --         end
    --         local strBuffType = getBuffType(tabEvent.path)
    --         ----获取等级
    --         local nCount
    --         if tabEvent.path.m_tabENPC[1] then
    --             local nLevel = oPlayer:getBzStarLevel(tabEvent.path.m_tabENPC[1])
    --             if nLevel then
    --                 nCount = oAblt:GetLevelSpecialValueFor(strBuffType, nLevel - 1)
    --             end
    --         end
    --         if not nCount then
    --             return
    --         end
    --         ----扣敌人对应等级防御
    --         local oBuff = oPlayerTarget:getBuffByName("modifier_" .. "path_13_DeBuff_" .. strBuffType)
    --         if nil == oBuff then
    --             oBuff = oAblt:ApplyDataDrivenModifier(tabEvent.entity, tabEvent.entity,
    --             "modifier_" .. "path_13_DeBuff_" .. strBuffType, {})
    --             oBuff:SetStackCount(nCount)
    --         else
    --             oBuff:SetStackCount(nCount + oBuff:GetStackCount())
    --         end
    --         ----特效
    --         local nPtclID = AMHC:CreateParticle("particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf"
    --         , PATTACH_CUSTOMORIGIN_FOLLOW, false, tabEvent.entity, 2)
    --         ParticleManager:SetParticleControlEnt(nPtclID, 0, tabEvent.entity, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", tabEvent.entity:GetOrigin() + Vector(0, 0, 300), true)
    --         ParticleManager:SetParticleControlEnt(nPtclID, 1, tabEvent.entity, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", tabEvent.entity:GetOrigin() + Vector(0, 0, 300), true)
    --         ParticleManager:SetParticleControlEnt(nPtclID, 2, tabEvent.entity, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", tabEvent.entity:GetOrigin() + Vector(0, 0, 300), true)
    --         EmitSoundOn("Hero_Slardar.Amplify_Damage", tabEvent.entity)
    --     end
    -- end)
end
----蛇沼路径技能
function onAblt_path_14(keys)
    if not keys.caster:IsRealHero() then
        return
    end
    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerID())
    if nil == oPlayer then
        return
    end

    local oAblt = keys.ability
    local nChance = oAblt:GetSpecialValueFor("chance")
    local nTime = oAblt:GetSpecialValueFor("time")
    local strIsTriggered = DoUniqueString("IsTriggered")

    local function checkBZ(eBZ)
        if not NULL(eBZ) then
            if 3 == oAblt:GetLevel() or TP_DOMAIN_3 == eBZ.m_path.m_typePath then
                return true
            end
        end
        return false
    end

    ----给玩家兵卒buff
    Timers:CreateTimer(0.1, function()
        if oAblt:IsNull() then
            return
        end

        oAblt.m_strBuffBZ = "modifier_" .. oAblt:GetAbilityName()
        for _, eBZ in pairs(oPlayer.m_tabBz) do
            if checkBZ(eBZ) then
                oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
            end
        end
        AbilityManager:updataBZBuffByCreate(oPlayer, oAblt, function(eBZ)
            if checkBZ(eBZ) then
                oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
            end
        end)
    end)

    ----监听玩家路过某路径事件
    EventManager:register("Event_PassingPath", function(tabEvent)
        if oAblt:IsNull() then
            return true     ----BUFF被移除，注销事件
        end
        if not tabEvent.entity.bTriggered
        and tabEvent.path.m_nOwnerID == oPlayer.m_nPlayerID
        and tabEvent.path.m_tabENPC and tabEvent.path.m_tabENPC[1] and checkBZ(tabEvent.path.m_tabENPC[1])
        and tabEvent.entity ~= keys.caster
        and 0 == bit.band(PS_InPrison, oPlayer.m_typeState) then
            local oPlayerTarget = PlayerManager:getPlayer(tabEvent.entity:GetPlayerOwnerID())
            if nil == oPlayerTarget or 0 < bit.band(oPlayerTarget.m_typeState, PS_AbilityImmune) then
                return  ----技能免疫
            end
            ---- 计算缠绕概率
            if RandomInt(1, 100) > nChance then
                return
            end
            ----触发
            tabEvent.entity.bTriggered = true
            EventManager:register("Event_MoveEnd", function(tabEvent2)
                if tabEvent2.entity == tabEvent.entity then
                    tabEvent.entity.bTriggered = nil  ----一次移动阶段只触发一次
                    return true
                end
            end)

            ----设置缠绕玩家禁止移动
            oPlayerTarget:setState(PS_Rooted)

            ----计算缠绕运动
            local nFps = 30
            local nFpsTime = 1 / nFps
            local v3Dis = Vector(0, 0, oPlayerTarget.m_eHero:GetModelRadius() * 2.5)
            local nTimeSum = nTime * 0.5 * nFps
            local v3Speed = v3Dis / nTimeSum
            local v3Cur = oPlayerTarget.m_eHero:GetAbsOrigin()
            local nTimeCur = math.floor(nTimeSum * 0.5)

            local nPtclID2 = AMHC:CreateParticle("particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_ti6_arc_b.vpcf"
            , PATTACH_POINT_FOLLOW, false, oPlayerTarget.m_eHero, nTime)
            ParticleManager:SetParticleControlOrientationFLU(nPtclID2, 3, Vector(0, 0, 1), Vector(0, 1, 0), Vector(1, 0, 0))

            ----向上缠绕
            EmitSoundOn("Hero_ShadowShaman.Shackles.Cast", oPlayerTarget.m_eHero)
            Timers:CreateTimer(0, function()
                v3Cur = v3Cur + v3Speed
                ParticleManager:SetParticleControl(nPtclID2, 3, v3Cur)
                nTimeCur = nTimeCur - 1
                if 0 < nTimeCur then
                    return nFpsTime
                end

                ----向下缠绕
                Timers:CreateTimer(nFpsTime, function()
                    v3Cur = v3Cur - v3Speed
                    ParticleManager:SetParticleControl(nPtclID2, 3, v3Cur)
                    nTimeCur = nTimeCur + 1
                    if nTimeSum > nTimeCur then
                        return nFpsTime
                    end

                    ----结束
                    ---- self:GetCaster():RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_1)
                    local nPtclID = AMHC:CreateParticle("particles/econ/items/shadow_shaman/shadow_shaman_ti8/shadow_shaman_ti8_ether_shock_target_snakes.vpcf"
                    , PATTACH_CENTER_FOLLOW, false, oPlayerTarget.m_eHero, 2)
                    ParticleManager:SetParticleControl(nPtclID, 0, oPlayerTarget.m_eHero:GetOrigin())
                    ParticleManager:SetParticleControl(nPtclID, 1, oPlayerTarget.m_eHero:GetOrigin() + Vector(0, 0, 10))
                    EmitSoundOn("Hero_Medusa.MysticSnake.Cast", oPlayerTarget.m_eHero)

                    ----设置缠绕玩家禁止移动取消
                    oPlayerTarget:setState(-PS_Rooted)
                    return nil
                end)
            end)
        end
    end)
    ----监听领地技能移除
    EventManager:register("Event_PathBuffDel", function(tabEvent)
        if tabEvent.oPlayer ~= oPlayer or TP_DOMAIN_3 ~= tabEvent.path.m_typePath then
            return
        end
        for _, eBZ in pairs(oPlayer.m_tabBz) do
            eBZ:RemoveModifierByName("modifier_" .. oAblt:GetAbilityName())
        end
        return true
    end)
end
----夜魇路径技能
function onAblt_path_15(keys)
    if not keys.caster:IsRealHero() then
        return
    end

    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerID())
    if nil == oPlayer then
        return
    end
    local oAblt = keys.ability
    local nLevel = oAblt:GetLevel()

    Timers:CreateTimer(0.1, function()
        ----给玩家全部兵卒buff
        if oAblt:IsNull() then
            return
        end
        oAblt.m_strBuffBZ = "modifier_" .. oAblt:GetAbilityName()
        for _, eBZ in pairs(oPlayer.m_tabBz) do
            local oBuff = oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
            if 3 == nLevel and TP_DOMAIN_4 == eBZ.m_path.m_typePath then
                oBuff:SetStackCount(2)
                oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ .. "_chenmo", {})
            end
        end
        AbilityManager:updataBZBuffByCreate(oPlayer, oAblt, function(eBZ)
            local oBuff = oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
            if 3 == nLevel and TP_DOMAIN_4 == eBZ.m_path.m_typePath then
                oBuff:SetStackCount(2)
                oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ .. "_chenmo", {})
            end
        end)
    end)

    ----监听领地技能移除
    EventManager:register("Event_PathBuffDel", function(tabEvent)
        if tabEvent.oPlayer ~= oPlayer or TP_DOMAIN_4 ~= tabEvent.path.m_typePath then
            return
        end
        for _, eBZ in pairs(oPlayer.m_tabBz) do
            eBZ:RemoveModifierByName("modifier_" .. oAblt:GetAbilityName())
            if TP_DOMAIN_4 == eBZ.m_path.m_typePath then
                eBZ:RemoveModifierByName("modifier_" .. oAblt:GetAbilityName() .. "_chenmo")
            end
        end
        return true
    end)
end
----龙谷路径技能
function onAblt_path_16(keys)
    if not keys.caster:IsRealHero() then
        return
    end

    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerID())
    if nil == oPlayer then
        return
    end
    local oAblt = keys.ability
    local nHuiMoBZ = oAblt:GetSpecialValueFor("huimo_bz")
    local nHuiMoHero = oAblt:GetSpecialValueFor("huimo")
    local nShangXian = oAblt:GetSpecialValueFor("shangxian")
    local nNoCDChance = oAblt:GetSpecialValueFor("no_cd_chance")
    local nNoManaChance = oAblt:GetSpecialValueFor("no_mana_chance")
    local nSpellAmp = oAblt:GetSpecialValueFor("spell_amp")

    ----提升英雄魔法上限
    oPlayer:setManaMax(oPlayer.m_eHero:GetMaxMana() + nShangXian)
    ----监听玩家回合回魔
    EventManager:register("Event_HeroHuiMoByRound", function(tabEvent)
        if oPlayer ~= tabEvent.oPlayer then
            return
        end
        if nil == oAblt or oAblt:IsNull() then
            return true
        end
        tabEvent.nHuiMo = tabEvent.nHuiMo + nHuiMoHero
    end)
    oAblt.m_strBuffBZ = "modifier_" .. oAblt:GetAbilityName() .. "_BZ"
    ----给玩家全部兵卒buff
    Timers:CreateTimer(0.1, function()
        if oAblt:IsNull() then
            return
        end
        for _, eBZ in pairs(oPlayer.m_tabBz) do
            local oBuff = oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
        end
        AbilityManager:updataBZBuffByCreate(oPlayer, oAblt, function(eBZ)
            oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
        end)

        ----监听兵卒回魔事件：
        EventManager:register("Event_BZHuiMo", function(tabEvent)
            if tabEvent.eBz:GetPlayerOwnerID() ~= keys.caster:GetPlayerID() then
                return
            end
            if nil == oAblt or oAblt:IsNull() then
                return true
            end
            ----额外回魔
            tabEvent.nHuiMoSum = tabEvent.nHuiMoSum + (tabEvent.getBaseHuiMo() * nHuiMoBZ * 0.01)
        end)
    end)

    ----监听技能释放
    EventManager:register('dota_player_used_ability', function(tEvent)
        if oAblt:IsNull() then
            return true
        end
        local entity = EntIndexToHScript(tEvent.caster_entindex)
        if IsValid(entity) and entity:GetPlayerOwnerID() == oPlayer.m_nPlayerID then
            local oAblt2 = entity:FindAbilityByName(tEvent.abilityname)
            if oAblt2 then
                local nPrltName = 0
                if RandomInt(1, 100) <= nNoCDChance then
                    ----刷新技能CD
                    if entity:IsHero() then
                        Timers:CreateTimer(function()
                            EventManager:fireEvent("Event_LastCDChange", {
                                strAbltName = tEvent.abilityname,
                                entity = entity,
                                nCD = 0,
                            })
                        end)
                    else
                        oAblt2:EndCooldown()
                    end
                    nPrltName = nPrltName + 1
                end
                if RandomInt(1, 100) <= nNoManaChance then
                    ----返回魔法
                    Timers:CreateTimer(function()
                        entity:GiveMana(oAblt2:GetManaCost(oAblt2:GetLevel() - 1))
                    end)
                    nPrltName = nPrltName + 2
                end

                ----特效
                if 0 ~= nPrltName then
                    nPrltName = "particles/custom/path_ablt/path_ablt_nocdmana_" .. nPrltName .. ".vpcf"
                    local nPtclID = AMHC:CreateParticle(nPrltName, PATTACH_POINT_FOLLOW, false, entity, 3)
                    ParticleManager:SetParticleControl(nPtclID, 0, entity:GetAbsOrigin() + Vector(0, 0, 500))
                    ----音效
                    if entity:IsHero() then
                        EmitGlobalSound("DOTA_Item.Refresher.Activate")
                    else
                        EmitSoundOn("DOTA_Item.Refresher.Activate", entity)
                    end
                end
            end
        end
    end)

    ----监听领地技能移除
    EventManager:register("Event_PathBuffDel", function(tabEvent)
        if tabEvent.oPlayer ~= oPlayer or TP_DOMAIN_5 ~= tabEvent.path.m_typePath then
            return
        end
        oPlayer:setManaMax(oPlayer.m_eHero:GetMaxMana() - nShangXian)
        for _, eBZ in pairs(oPlayer.m_tabBz) do
            eBZ:RemoveModifierByName(oAblt.m_strBuffBZ)
        end
        return true
    end)
end
----鵰巢路径技能
function onAblt_path_17(keys)
    -----@type Player
    if not keys.caster:IsRealHero() then
        return
    end
    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerID())
    if nil == oPlayer then
        return
    end
    local oAblt = keys.ability
    local nDamage = oAblt:GetSpecialValueFor("damage")

    local function checkBZ(eBZ)
        if not NULL(eBZ) then
            if 3 == oAblt:GetLevel() or TP_DOMAIN_6 == eBZ.m_path.m_typePath then
                return true
            end
        end
        return false
    end

    ----给玩家兵卒buff
    Timers:CreateTimer(0.1, function()
        if oAblt:IsNull() then
            return
        end
        oAblt.m_strBuffBZ = "modifier_" .. oAblt:GetAbilityName()
        for _, eBZ in pairs(oPlayer.m_tabBz) do
            if checkBZ(eBZ) then
                oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
            end
        end
        AbilityManager:updataBZBuffByCreate(oPlayer, oAblt, function(eBZ)
            if checkBZ(eBZ) then
                oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
            end
        end)
    end)

    local tabPath = PathManager:getPathByType(TP_DOMAIN_6)
    local pathMid = tabPath[2]
    local eDiao = pathMid.m_eDiao
    if not eDiao then
        return
    end

    ----监听敌人移动
    local tabMover = {}
    ----伤害检测
    local strDeBuffName = "modifier_" .. oAblt:GetAbilityName() .. "_DeBuff"
    local sDamageCD = "_onAblt_path_17_DamageCD" .. oAblt:GetEntityIndex()
    local sHasBuff
    if 2 <= oAblt:GetLevel() then
        ----2级以上带减速
        sHasBuff = "_onAblt_path_17_HasBuff" .. oAblt:GetEntityIndex()
    end
    local funOnDamage = function(v3, nID)
        if not IsValid(oAblt) then
            return
        end
        for _, v in pairs(tabMover) do
            if IsValid(v) then
                local nDis = (v:GetAbsOrigin() - v3):Length2D()
                if nDis > 200 then
                    if sHasBuff and v[sHasBuff .. nID] then
                        ----脱离范围删除减速buff
                        v[sHasBuff .. nID] = false
                        v:RemoveModifierByName(strDeBuffName)
                    end
                    return
                end

                if not v[sDamageCD .. nID] then
                    v[sDamageCD .. nID] = true
                    AMHC:Damage(oPlayer.m_eHero, v, nDamage, oAblt:GetAbilityDamageType(), oAblt)
                    Timers:CreateTimer(0.5, function()
                        v[sDamageCD .. nID] = false
                    end)
                end
                if sHasBuff and not v[sHasBuff .. nID] then
                    v[sHasBuff .. nID] = true
                    local oBuff = oAblt:ApplyDataDrivenModifier(oPlayer.m_eHero, v, strDeBuffName, nil)
                end
            end
        end
    end
    local funOnMove = function(tabEvent)
        if tabEvent.entity == oPlayer.m_eHero then
            return
        end
        if not IsValid(oAblt) then
            return true
        end
        if 0 < bit.band(PS_InPrison, oPlayer.m_typeState) then
            return
        end

        ----添加移动中的实体
        table.insert(tabMover, tabEvent.entity)

        ----获取要生成飓风的路径区
        local tPaths = { {} }
        for _, path in pairs(PathManager.m_tabPaths) do
            if instanceof(path, PathDomain)
            and path.m_nOwnerID == oPlayer.m_nPlayerID
            and path.m_tabENPC[1] and checkBZ(path.m_tabENPC[1]) then
                local tab = tPaths[#tPaths]
                if tab[#tab] and tab[#tab].m_nID + 1 ~= path.m_nID then
                    table.insert(tPaths, {})
                end
                table.insert(tPaths[#tPaths], path)
                if #PathManager.m_tabPaths == path.m_nID and tPaths[1][1] and 1 == tPaths[1][1].m_nID then
                    ----首位相连
                    tPaths[1] = concat(tPaths[1], tPaths[#tPaths])
                    table.remove(tPaths, #tPaths)
                end
            end
        end

        ----创建飓风
        for _, tab in pairs(tPaths) do
            local nPtclID = AMHC:CreateParticle("particles/neutral_fx/tornado_ambient.vpcf"
            , PATTACH_POINT, false, eDiao)
            ----刮风在路径上做往复移动
            local tabPathMove = { tab[1] }
            if 1 < #tab then
                table.insert(tabPathMove, tab[#tab])
            end
            local pathCur = tabPathMove[1]
            local function getNextPath()
                for i = #tabPathMove, 1, -1 do
                    if tabPathMove[i] == pathCur then
                        if tabPathMove[i + 1] then return tabPathMove[i + 1] end
                        if tabPathMove[1] then return tabPathMove[1] end
                    end
                end
                return pathCur
            end

            ----持续移动飓风
            local function funMoveFeng()
                ----下一个目标
                local pathNext = getNextPath()
                ----计算运动
                local nFps = 30
                local nFpsTime = 1 / nFps
                local v3Dis = pathNext.m_entity:GetAbsOrigin() - pathCur.m_entity:GetAbsOrigin()
                local nTimeSum = 2 * nFps
                local v3Speed = v3Dis / nTimeSum
                local v3Cur = pathCur.m_entity:GetAbsOrigin()
                local nTimeCur = math.floor(nTimeSum)

                Timers:CreateTimer(function()
                    if 0 < #tabMover and IsValid(oAblt) then
                        v3Cur = v3Cur + v3Speed
                        ParticleManager:SetParticleControl(nPtclID, 0, v3Cur)
                        funOnDamage(v3Cur, nPtclID)   ----触发伤害和减速
                        pathMid:setDiaoGesture(ACT_DOTA_CAST_ABILITY_1)
                        nTimeCur = nTimeCur - 1
                        if 0 < nTimeCur then
                            return nFpsTime
                        end
                        pathCur = pathNext
                        funMoveFeng()
                    else
                        tabEvent.entity:RemoveModifierByName(strDeBuffName)
                        ParticleManager:DestroyParticle(nPtclID, false)
                        pathMid:setDiaoGesture(-ACT_DOTA_CAST_ABILITY_1)

                        ----初始化伤害检测变量
                        tabEvent.entity[sDamageCD .. nPtclID] = false
                        tabEvent.entity[sDamageCD .. nPtclID] = false
                    end
                end)
            end
            funMoveFeng()
        end
    end
    if GS_Move == GMManager.m_typeState then
        ----当前已经在移动阶段，手动调用
        for _, v in pairs(PlayerManager.m_tabPlayers) do
            if 0 < bit.band(PS_Moving, v.m_typeState) then
                funOnMove({ entity = v.m_eHero })
            end
        end
    end
    EventManager:register("Event_Move", funOnMove)
    EventManager:register("Event_MoveEnd", function(tabEvent)
        if nil == oAblt or oAblt:IsNull() then
            return true
        end
        for k, v in pairs(tabMover) do
            if v == tabEvent.entity then
                table.remove(tabMover, k)
                break
            end
        end
    end)
    ----监听领地技能移除
    EventManager:register("Event_PathBuffDel", function(tabEvent)
        if tabEvent.oPlayer ~= oPlayer or TP_DOMAIN_6 ~= tabEvent.path.m_typePath then
            return
        end
        for _, eBZ in pairs(oPlayer.m_tabBz) do
            eBZ:RemoveModifierByName("modifier_" .. oAblt:GetAbilityName())
        end
        return true
    end)
end
----圣所路径技能
function onAblt_path_18(keys)
    if not keys.caster:IsRealHero() then
        return
    end

    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerID())
    if nil == oPlayer then
        return
    end
    local oAblt = keys.ability
    local nDamage = oAblt:GetSpecialValueFor("damage")
    local typeDamage = oAblt:GetAbilityDamageType()

    ----石化兵卒
    Timers:CreateTimer(0.5, function()
        if oAblt:IsNull() then
            return
        end
        for _, v in pairs(oPlayer.m_tabBz) do
            if TP_DOMAIN_7 == v.m_path.m_typePath and not v:HasModifier("modifier_medusa_stone_gaze_stone") then
                v:AddNewModifier(keys.caster, oAblt, "modifier_medusa_stone_gaze_stone", nil)
            end
        end
    end)
    ----监听兵卒创建了,石化
    EventManager:register("Event_BZCreate", function(tabEvent)
        if tabEvent.entity:GetPlayerOwnerID() == oPlayer.m_nPlayerID then
            if nil == oAblt or oAblt:IsNull() then
                return true
            end
            if TP_DOMAIN_7 == tabEvent.entity.m_path.m_typePath then
                Timers:CreateTimer(0.5, function()
                    if oAblt:IsNull() then
                        return
                    end
                    tabEvent.entity:AddNewModifier(keys.caster, oAblt, "modifier_medusa_stone_gaze_stone", nil)
                end)
            end
        end
    end)

    oAblt.m_strBuffBZ = "modifier_" .. oAblt:GetAbilityName() .. "_BZ"
    ----给玩家全部兵卒buff
    Timers:CreateTimer(0.1, function()
        if oAblt:IsNull() then
            return
        end
        for _, eBZ in pairs(oPlayer.m_tabBz) do
            if TP_DOMAIN_7 == eBZ.m_path.m_typePath then
                oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
            end
        end
        AbilityManager:updataBZBuffByCreate(oPlayer, oAblt, function(eBZ)
            if TP_DOMAIN_7 == eBZ.m_path.m_typePath then
                oAblt:ApplyDataDrivenModifier(eBZ, eBZ, oAblt.m_strBuffBZ, {})
            end
        end)
    end)

    ----监听单位触发路径
    EventManager:register("Event_OnPath", function(tabEvent)
        if TP_DOMAIN_7 ~= tabEvent.path.m_typePath or tabEvent.entity:GetPlayerOwnerID() == oPlayer.m_nPlayerID then
            return
        end
        if oAblt:IsNull() then
            return true
        end
        if 0 < bit.band(PS_InPrison, oPlayer.m_typeState) then
            return
        end

        ----圣光特效
        local nPtclID = AMHC:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf"
        , PATTACH_POINT, false, tabEvent.entity)
        EmitGlobalSound("Hero_Omniknight.Purification")

        ----造成伤害
        local nEventID = EventManager:register("Event_Atk", function(tEvent2)
            if
            -- IsValid(oPlayer.m_eHero) and IsValid(tabEvent.entity)
            -- and oPlayer.m_eHero:GetEntityIndex() == tEvent2.entindex_attacker_const
            -- and tabEvent.entity:GetEntityIndex() == tEvent2.entindex_victim_const
            -- and
            typeDamage == tEvent2.damagetype_const then
                tEvent2.damage = nDamage
            end
        end, nil, 987654321)
        AMHC:Damage(oPlayer.m_eHero, tabEvent.entity, nDamage, typeDamage, oAblt)
        EventManager:unregisterByID(nEventID, "Event_Atk")
    end)
    ----监听触发攻城
    EventManager:register("Event_GCLDReady", function(tabEvent)
        if TP_DOMAIN_7 ~= tabEvent.path.m_typePath or tabEvent.entity:GetPlayerOwnerID() == oPlayer.m_nPlayerID then
            return
        end
        if oAblt:IsNull() then
            return true
        end
        tabEvent.bIgnore = true
    end)

    ----监听领地技能移除
    EventManager:register("Event_PathBuffDel", function(tabEvent)
        if tabEvent.oPlayer ~= oPlayer or TP_DOMAIN_7 ~= tabEvent.path.m_typePath then
            return
        end
        for _, eBZ in pairs(oPlayer.m_tabBz) do
            if TP_DOMAIN_7 == eBZ.m_path.m_typePath then
                eBZ:RemoveModifierByName(oAblt.m_strBuffBZ)
                if eBZ:HasModifier("modifier_medusa_stone_gaze_stone") then
                    eBZ:RemoveModifierByName("modifier_medusa_stone_gaze_stone")
                end
            end
        end
        return true
    end)
end

----通用属性物品
function onItem_attributes(keys)
    if keys.State == "OnDestroy" then
        EventManager:fireEvent("Event_onItem_attributes_OnDestroy", keys)
        return
    end

    local tEventID = {}
    local function unregister()
        for _, v in pairs(tEventID) do
            EventManager:unregisterByID(v)
        end
    end

    local bonus_strength = keys.ability:GetSpecialValueFor("bonus_strength")
    local bonus_agility = keys.ability:GetSpecialValueFor("bonus_agility")
    local bonus_intellect = keys.ability:GetSpecialValueFor("bonus_intellect")

    if keys.caster.m_bBZ then
        keys.caster:ModifyStrength(bonus_strength)
        keys.caster:ModifyAgility(bonus_agility)
        keys.caster:ModifyIntellect(bonus_agility)
    end

    local player
    if keys.caster:IsRealHero() then
        player = PlayerManager:getPlayer(keys.caster:GetPlayerOwnerID())
        if player then
            player:updataRegen0()
        end
    end
    local nAbltEntID = keys.ability:GetEntityIndex()
    table.insert(tEventID, EventManager:register("Event_onItem_attributes_OnDestroy", function(tEvent)
        if nAbltEntID ~= tEvent.ability:GetEntityIndex() then
            return
        end
        if keys.caster.m_bBZ then
            keys.caster:ModifyStrength(-bonus_strength)
            keys.caster:ModifyAgility(-bonus_agility)
            keys.caster:ModifyIntellect(-bonus_agility)
        end
        unregister()
        if player then
            player:updataRegen0()
        end
    end))
    return unregister
end
----通用回魔物品
function onItem_huiMo(keys)
    if keys.State == "OnDestroy" then
        EventManager:fireEvent("Event_onItem_huiMo_OnDestroy", keys)
        return
    end

    local tEventID = {}
    local function unregister()
        for _, v in pairs(tEventID) do
            EventManager:unregisterByID(v)
        end
    end

    if keys.caster:IsRealHero() then
        ----英雄装备
        local nRegenHero = keys.ability:GetSpecialValueFor("bonus_mana_regen_hero")
        local nRound = keys.ability:GetSpecialValueFor("bonus_mana_regen_hero_round")
        local nRoundCD = nRound
        table.insert(tEventID, EventManager:register("Event_HeroHuiMoByRound", function(tabEvent)
            if keys.caster == tabEvent.oPlayer.m_eHero then
                nRoundCD = nRoundCD - 1
                if 0 >= nRoundCD then
                    nRoundCD = nRound
                    tabEvent.nHuiMo = nRegenHero + tabEvent.nHuiMo
                end
            end
        end))
    else
        ----兵卒装备
        local nRegenBZ = keys.ability:GetSpecialValueFor("bonus_mana_regen_bz")
        table.insert(tEventID, EventManager:register("Event_BZHuiMo", function(tabEvent)
            if keys.caster == tabEvent.eBz then
                tabEvent.nHuiMoSum = tabEvent.getBaseHuiMo() * nRegenBZ * 0.01 + tabEvent.nHuiMoSum
            end
        end))
    end

    local nAbltEntID = keys.ability:GetEntityIndex()
    table.insert(tEventID, EventManager:register("Event_onItem_huiMo_OnDestroy", function(tEvent)
        if nAbltEntID ~= tEvent.ability:GetEntityIndex() then
            return
        end
        unregister()
    end))
    return unregister
end
----通用魔法上限物品
function onItem_MaxMana(keys)
    if not keys.caster:IsRealHero() then
        return
    end
    local nMana = keys.ability:GetSpecialValueFor("bonus_mana")
    if keys.State == "OnDestroy" then
        ----解除装备
        local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerOwnerID())
        if oPlayer then
            oPlayer:setManaMax(oPlayer.m_eHero:GetMaxMana() - nMana)
        end
    elseif keys.State == "OnCreated" then
        ----装备
        -----@type Player
        local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerOwnerID())
        if oPlayer then
            oPlayer:setManaMax(oPlayer.m_eHero:GetMaxMana() + nMana)
        end
    end
end
----通用血量上限物品(兵卒)
function onItem_MaxHP(keys)
    if keys.caster:IsHero() then
        return
    end
    local nHP = keys.ability:GetSpecialValueFor("bonus_health")
    if keys.State == "OnDestroy" then
        ----解除装备
        nHP = keys.caster:GetMaxHealth() - nHP
    elseif keys.State == "OnCreated" then
        ----装备
        nHP = keys.caster:GetMaxHealth() + nHP
    end

    local hp_per = keys.caster:GetHealth() / keys.caster:GetMaxHealth()
    keys.caster:SetBaseMaxHealth(nHP)
    keys.caster:SetMaxHealth(nHP)
    keys.caster:SetHealth(nHP * hp_per)
end
----通用回血物品
function onItem_huiXue(keys)
    if keys.State == "OnDestroy" then
        EventManager:fireEvent("Event_onItem_huiXue_OnDestroy", keys)
        return
    end

    local oAblt = keys.ability
    local nAbltEntID = keys.ability:GetEntityIndex()

    local tEventID = {}
    local function unregister()
        for _, v in pairs(tEventID) do
            EventManager:unregisterByID(v)
        end
    end

    ----物品技能，替换oAblt为物品
    if keys.bItemAblt then
        keys.item = keys.caster:get05ItemByName(string.sub(keys.ability:GetAbilityName(), 9))
        if keys.item then
            oAblt = keys.item
        end
    end

    local nRegen = oAblt:GetSpecialValueFor("bonus_health_regen_hero")
    local nRound = oAblt:GetSpecialValueFor("bonus_health_regen_hero_round")
    local nRoundCD = nRound

    table.insert(tEventID, EventManager:register("Event_ItemHuiXueByRound", function(tabEvent)
        if keys.caster == tabEvent.entity then
            if NIL(keys.ability) then
                return true
            end
            nRoundCD = nRoundCD - 1
            if 0 >= nRoundCD then
                nRoundCD = nRound

                local nRegenCur = nRegen

                ----计算叠加
                local oBuff = keys.caster:FindModifierByName('modifier_' .. keys.ability:GetAbilityName())
                if oBuff then
                    nRegenCur = (oBuff:GetStackCount() + 1) * nRegenCur
                end

                ----额外回血
                -- tabEvent.entity:SetHealth(tabEvent.entity:GetHealth() + nRegenCur)
                tabEvent.nHuiXue = tabEvent.nHuiXue + nRegenCur
            end
        end
    end))

    table.insert(tEventID, EventManager:register("Event_onItem_huiXue_OnDestroy", function(tEvent)
        if nAbltEntID ~= tEvent.ability:GetEntityIndex() then
            return
        end
        unregister()
    end))
    return unregister
end
----通用激活卡牌
function onItem_getCard(keys)
    if keys.State == "OnDestroy" then
        return
    end
    ----幻象不刷牌
    if keys.caster:IsIllusion() then
        return
    end
    ----兵卒不刷牌
    if keys.caster.m_bBZ then
        return
    end

    local oAblt = keys.ability

    ----物品技能，替换oAblt为物品
    if keys.bItemAblt then
        keys.item = keys.caster:get08ItemByName(string.sub(keys.ability:GetAbilityName(), 9))
        if not keys.item then
            return
        end
        oAblt = keys.item
    end

    local player = PlayerManager:getPlayer(keys.caster:GetPlayerOwnerID())
    if not player then return end
    if not player._tGetCardItem then player._tGetCardItem = {} end

    local tItem = player._tGetCardItem[oAblt:GetSpecialValueFor("card_type")]
    if not tItem then
        tItem = {}
        player._tGetCardItem[oAblt:GetSpecialValueFor("card_type")] = tItem
    end

    for i = #tItem, 1, -1 do
        if not IsValid(tItem[i]) then
            table.remove(tItem, i)
        elseif oAblt == tItem[i] then
            return
        end
    end

    table.insert(tItem, oAblt)
    removeRepeat(tItem)

    if 1 < #tItem then
        ----只应用第一次
        ---- tItem[1]:syncCD(oAblt)  ----同步CD
        return
    end

    local tEventID = {}
    local nItemEntID = oAblt:GetEntityIndex()

    ----监听物品被移除
    table.insert(tEventID, EventManager:register("Event_ItemDel", function(tEvent)
        if tEvent.nItemEntID == nItemEntID then
            removeAll(tItem, function(v)
                return v:IsNull() or v == oAblt
            end)
            EventManager:fireEvent("Event_onItem_getCard_OnDestroy", { nItemEntID = nItemEntID })
        end
    end))

    local nMax = oAblt:GetSpecialValueFor("card_count")
    local typeCard

    local function getCardCD()
        local nGetCardCD = TESTCARD and 1 or oAblt:GetSpecialValueFor("cd_getcard")
        ----冷却减缩
        nGetCardCD = nGetCardCD - player.m_nCDSub
        if 0 >= nGetCardCD then
            nGetCardCD = 1
        end
        return nGetCardCD
    end
    local nCDLast = math.ceil(oAblt:GetCooldownTimeRemaining())
    if not nCDLast or 0 >= nCDLast then
        nCDLast = getCardCD()
    end

    local function unregister()
        removeAll(tItem, function(v)
            return v:IsNull() or v:GetCaster() ~= keys.caster
        end)
        if 0 < #tItem then
            ----有效物品
            if oAblt ~= tItem[1] then
                oAblt = tItem[1]
                local nCD = math.ceil(oAblt:GetCooldownTimeRemaining())
                if not keys.bItemAblt then
                    nItemEntID = oAblt:GetEntityIndex()
                end
                AbilityManager:setRoundCD(player, oAblt, nCD)
            end
            keys.caster = oAblt:GetCaster()
            return false
        else
            ----解除监听，不再刷牌
            for _, v in pairs(tEventID) do
                EventManager:unregisterByID(v)
            end
            return true
        end
    end

    ----物品技能时，监听此种物品失效失效
    if keys.bItemAblt and keys.item then
        local nItemEntID = keys.item:GetEntityIndex()
        local sItemName = keys.item:GetAbilityName()

        ----生效
        table.insert(tEventID, EventManager:register("Event_ItemValid", function(tEvent)
            if sItemName == tEvent.item:GetAbilityName() and tEvent.item:GetEntityIndex() ~= nItemEntID then
                table.insert(tItem, tEvent.item)
                removeRepeat(tItem)
            end
        end))
        ----失效
        table.insert(tEventID, EventManager:register("Event_ItemInvalid", function(tEvent)
            if nItemEntID == tEvent.nItemEntID then
                ----失效的是刷牌物品
                if not unregister(tEvent.sItemName) then
                    keys.item = oAblt
                    nItemEntID = keys.item:GetEntityIndex()
                end
            end
        end))
        ----移除
        table.insert(tEventID, EventManager:register("Event_ItemDel", function(tEvent)
            if sItemName == tEvent.sItemName then
                if tEvent.nItemEntID ~= nItemEntID then
                    removeAll(tItem, function(v)
                        return v:IsNull() or v:GetEntityIndex() == tEvent.nItemEntID
                    end)
                else
                    if nItemEntID == tEvent.nItemEntID then
                        ----失效的是刷牌物品
                        if not unregister(tEvent.sItemName) then
                            keys.item = oAblt
                            nItemEntID = keys.item:GetEntityIndex()
                        end
                    end
                end
            end
        end))
    end

    AbilityManager:setRoundCD(player, oAblt, nCDLast)

    local function checkCD()
        if oAblt:IsNull() then
            return unregister()
        end
        nCDLast = math.ceil(oAblt:GetCooldownTimeRemaining())
        if 1 >= nCDLast and 6 > oAblt:GetItemSlot() then
            ----等待CD结束
            ---- Timers:CreateTimer(nCDLast + 0.1, function()
            ----发牌
            typeCard = AbilityManager:getCardType(keys.CardType, player, oAblt)
            if typeCard then
                print('bug setCardAdd:  type=' .. typeCard .. " player id=" .. player.m_nPlayerID)
                local card = CardFactory:create(typeCard, player.m_nPlayerID)
                if card then
                    player:setCardAdd(card)
                end
            end

            ----判断继续刷牌
            local bSend = -1 == nMax or nMax > CardManager:getPlayerGetCardCount(player.m_nPlayerID, typeCard)

            ----继续倒计时刷牌
            nCDLast = getCardCD()
            if bSend then
                AbilityManager:setRoundCD(player, oAblt, nCDLast)
            else
                tItem = {}
                unregister()
                return true
            end
        end
    end

    table.insert(tEventID, EventManager:register("Event_PlayerRoundBegin", function(tEvent)
        if player == tEvent.oPlayer then
            return checkCD()
        end
    end, nil, -100))
    table.insert(tEventID, EventManager:register("Event_LastCDChange", function(tEvent)
        if 0 == tEvent.nCD
        and tEvent.entity:GetPlayerOwnerID() == player.m_nPlayerID
        and oAblt:GetAbilityName() == tEvent.strAbltName
        then
            return checkCD()
        end
    end, nil, -100))

    table.insert(tEventID, EventManager:register("Event_onItem_getCard_OnDestroy", function(tEvent)
        if nItemEntID ~= tEvent.nItemEntID then
            return
        end
        unregister()
    end))
    return unregister
end
----获取卡牌类型
function AbilityManager:getCardType(sCardTypeFlag, player, oAblt)
    ---- local player = PlayerManager:getPlayer(keys.caster:GetPlayerOwnerID())
    local typeCard = nil
    if sCardTypeFlag == "HERO" then
        local unitName = player.m_eHero:GetUnitName()
        local function checkUnitName(str) return string.find(string.lower(unitName), string.lower('_' .. str)) ~= nil end;
        if checkUnitName('LINA') then
            typeCard = TCard_HERO_LINA_laguna_blade
        elseif checkUnitName('AXE') then
            typeCard = TCard_HERO_AXE_berserkers_call
        elseif checkUnitName('ZUUS') then
            typeCard = TCard_HERO_ZUUS_thundergods_wrath
        elseif checkUnitName('PHANTOM') then
            typeCard = TCard_HERO_PHANTOM_strike
        elseif checkUnitName('MEEPO') then
            typeCard = TCard_HERO_MEEPO_summon_image
        end
    elseif sCardTypeFlag == "MONSTER" then
        -----野兽牌
        local TCard_MONSTER = {
            TCard_MONSTER_small_hunting_ground, ----小型狩猎场
            TCard_MONSTER_large_hunting_ground, ----大型狩猎场
            TCard_MONSTER_ancient_forbidden_land, ----远古禁地
            TCard_MONSTER_brush_field, ----拉野
        }
        local i = RandomInt(1, #TCard_MONSTER)
        typeCard = TCard_MONSTER[i]
    elseif sCardTypeFlag == "ITEM" then
        typeCard = oAblt:GetSpecialValueFor("card_type")
    end
    return typeCard
end
-----加打野伤害
function onItem_atkMonster(keys)
    local damage = keys.ability:GetSpecialValueFor("damage_bonus")
    local function atk(params)
        if keys.ability:IsNull() then
            return true
        end
        if DAMAGE_TYPE_PHYSICAL ~= params.damagetype_const then
            return
        end
        if keys.caster_entindex ~= params.entindex_attacker_const then
            return
        end
        local attacker = EntIndexToHScript(params.entindex_attacker_const)
        local victim = EntIndexToHScript(params.entindex_victim_const)
        if attacker:IsRealHero() and victim:IsNeutralUnitType() then
            if TESTHELP then
                print('onItem_atkMonster: damage is ', params.damage, ' add is ', damage)
            end
            if TESTCARD then
                params.damage = params.damage + 10000
            else
                params.damage = params.damage + damage
            end
            if TESTHELP then
                print('onItem_atkMonster: damage is ', params.damage)
            end
        end
    end
    if keys.State == "OnCreated" then
        if keys.caster:IsRealHero() then
            keys.ability.evt = EventManager:register("Event_Atk", atk)
        end
    elseif keys.State == "OnDestroy" then
        ---- EventManager:unregisterByID(keys.ability.evt)
    end
end
----通用冷却耗魔减缩物品
function onItem_CDManaSub(keys)
    local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerOwnerID())
    if not oPlayer then
        return
    end

    local nAdd

    if keys.State == "OnDestroy" then
        ----解除装备
        if 1 < oPlayer._tCDManaSub[keys.ability:GetAbilityName()] then
            oPlayer._tCDManaSub[keys.ability:GetAbilityName()] = oPlayer._tCDManaSub[keys.ability:GetAbilityName()] - 1
            return
        end
        oPlayer._tCDManaSub[keys.ability:GetAbilityName()] = nil
        nAdd = -1
    else
        ----装备
        if not oPlayer._tCDManaSub then
            oPlayer._tCDManaSub = {}
        elseif oPlayer._tCDManaSub[keys.ability:GetAbilityName()] then
            ----同物品只应用一次，不叠加
            oPlayer._tCDManaSub[keys.ability:GetAbilityName()] = oPlayer._tCDManaSub[keys.ability:GetAbilityName()] + 1
            return
        end
        oPlayer._tCDManaSub[keys.ability:GetAbilityName()] = 1
        nAdd = 1
    end

    local nManaSub = keys.ability:GetSpecialValueFor("mana_sub")
    if nManaSub and 0 < nManaSub then
        oPlayer:setManaSub(oPlayer.m_nManaSub + nManaSub * nAdd)
    end

    local nCDSub = keys.ability:GetSpecialValueFor("cd_sub")
    if nCDSub and 0 < nCDSub then
        oPlayer:setCDSub(oPlayer.m_nCDSub + nCDSub * nAdd)
    end
end


if IsServer() then

    ----获取技能目标Flags
    function CDOTABaseAbility:getAbilityTargetFlags()
        if KeyValues and KeyValues.AbilitiesKv then
            local tInfo = KeyValues.AbilitiesKv[self:GetAbilityName()]
            if tInfo and tInfo['AbilityUnitTargetFlags'] then
                local tFalgs = string.split(tInfo['AbilityUnitTargetFlags'], '|')
                local nFalgs = 0
                for _, v in pairs(tFalgs) do
                    nFalgs = nFalgs + load("return " .. v)()
                end
                if 0 ~= nFalgs then
                    return nFalgs
                end
            end
        end
        return self:GetAbilityTargetFlags()
    end

    ----同步技能CD
    function CDOTABaseAbility:syncCD(ablt)
        if not ablt or ablt:IsNull() then
            return
        end

        if not self._tSyncCD then
            self._tSyncCD = {}
            self._tSyncCD[self:GetEntityIndex()] = self
        end
        self._tSyncCD[ablt:GetEntityIndex()] = ablt

        if ablt._tSyncCD then
            ----合并
            if ablt._tSyncCD ~= self._tSyncCD then
                for k, v in pairs(ablt._tSyncCD) do
                    if not v:IsNull() then
                        self._tSyncCD[k] = v
                    end
                end
                for k, v in pairs(self._tSyncCD) do
                    if not v:IsNull() then
                        v._tSyncCD = self._tSyncCD
                    end
                end
            end
        else
            ablt._tSyncCD = self._tSyncCD
            ablt:syncCD(self)
            ---- CDOTABaseAbility.syncCD(ablt, self)
        end

        if self._bSyncCD then
            return
        end
        self._bSyncCD = true

        local funEndCooldown = self.EndCooldown
        self.EndCooldown = function(self, bSync)
            funEndCooldown(self)
            if not bSync then
                for k, v in pairs(self._tSyncCD) do
                    if v:IsNull() then
                        self._tSyncCD[k] = nil
                    else
                        v:EndCooldown(true)
                    end
                end
            end
        end

        local funStartCooldown = self.StartCooldown
        self.StartCooldown = function(self, fVal, bSync)
            funStartCooldown(self, fVal)
            if not bSync then
                for k, v in pairs(self._tSyncCD) do
                    if v:IsNull() then
                        self._tSyncCD[k] = nil
                    else
                        v:StartCooldown(fVal, true)
                    end
                end
            end
        end
    end

    if not CDOTA_Ability_DataDriven._ApplyDataDrivenModifier then
        CDOTA_Ability_DataDriven._ApplyDataDrivenModifier = CDOTA_Ability_DataDriven.ApplyDataDrivenModifier
    end
    function CDOTA_Ability_DataDriven:ApplyDataDrivenModifier(...)
        local oBuff = CDOTA_Ability_DataDriven._ApplyDataDrivenModifier(self, ...)
        if oBuff then
            local tAbltInfo = KeyValues.AbilitiesKv[self:GetAbilityName()]
            if tAbltInfo and tAbltInfo['Modifiers'] then
                oBuff.m_tInfo = tAbltInfo['Modifiers'][oBuff:GetName()]
            end
        end
        return oBuff
    end

    if not CDOTA_Item_DataDriven._ApplyDataDrivenModifier then
        CDOTA_Item_DataDriven._ApplyDataDrivenModifier = CDOTA_Item_DataDriven.ApplyDataDrivenModifier
    end
    function CDOTA_Item_DataDriven:ApplyDataDrivenModifier(...)
        local oBuff = CDOTA_Item_DataDriven._ApplyDataDrivenModifier(self, ...)
        if not oBuff then
            local hCaster, hTarget, pszModifierName, hModifierTable = ...
            oBuff = hTarget:FindModifierByNameAndCaster(pszModifierName, hCaster)
        end
        if oBuff then
            local tAbltInfo = KeyValues.ItemsKv[self:GetAbilityName()]
            if tAbltInfo and tAbltInfo['Modifiers'] then
                oBuff.m_tInfo = tAbltInfo['Modifiers'][oBuff:GetName()]
            end
        end
        return oBuff
    end

    ----BUFF是否Debuff
    function CDOTA_Buff:IsDebuff()
        if self.m_tInfo and self.m_tInfo['IsDebuff'] and "0" ~= self.m_tInfo['IsDebuff'] then
            return true
        end
        return false
    end
    ----BUFF能否驱散
    function CDOTA_Buff:IsPurgable()
        if self.m_tInfo and self.m_tInfo['IsPurgable'] and "0" ~= self.m_tInfo['IsPurgable'] then
            return true
        end
        return false
    end

    if not CDOTA_BaseNPC._Heal then
        CDOTA_BaseNPC._Heal = CDOTA_BaseNPC.Heal
    end
    function CDOTA_BaseNPC:Heal(flAmount, hInflictor, ...)
        local tEvent = {
            flAmount = flAmount,
            hInflictor = hInflictor,
            entity = self,
        }
        EventManager:fireEvent("Event_HuiXue", tEvent)
        CDOTA_BaseNPC._Heal(self, tEvent.flAmount, tEvent.hInflictor, ...)
    end
else
    --计时器
    function C_BaseEntity:Timer(sContextName, fInterval, funcThink)
        if funcThink == nil then
            funcThink = fInterval
            fInterval = sContextName
            sContextName = DoUniqueString("Timer")
        end
        self:SetContextThink(sContextName, function()
            return funcThink()
        end, fInterval)
        return sContextName
    end
    --游戏计时器
    function C_BaseEntity:GameTimer(sContextName, fInterval, funcThink)
        if funcThink == nil then
            funcThink = fInterval
            fInterval = sContextName
            sContextName = DoUniqueString("GameTimer")
        end
        local fTime = GameRules:GetGameTime() + fInterval
        return self:Timer(sContextName, fInterval, function()
            if GameRules:GetGameTime() >= fTime then
                local result = funcThink()
                if type(result) == "number" then
                    fTime = fTime + result
                end
                return result
            end
            return 0
        end)
    end
    --暂停计时器
    function C_BaseEntity:StopTimer(sContextName)
        self:SetContextThink(sContextName, nil, 0)
    end

    ---- function onEvent_gameStateChange()
    ----     if GameRules:State_Get() == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    ----         ----等待玩家加载界面
    ----     elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
    ----         ----选择队伍界面
    ----     elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
    ----         ----进入地图
    ----     elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    ----         ----游戏开始
    ----     end
    ---- end
    ---- ListenToGameEvent("game_rules_state_change", onEvent_gameStateChange, nil)
    ---- function onEvent_NPCSpawned(keys)
    ---- end
    ---- ListenToGameEvent("npc_spawned", onEvent_NPCSpawned, nil)
end