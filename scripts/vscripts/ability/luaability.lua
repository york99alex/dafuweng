----Lua技能
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility then
    LuaAbility = class({
        m_strCastError = nil,
        m_tBaseManaCost = nil,
        m_tBaseCooldown = nil,
    })
end
local this = LuaAbility
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function this:constructor()
    self.__init = true
    self.m_tBaseManaCost = {}
    self.m_tBaseCooldown = {}

    local tInfo
    if IsClient() then
        tInfo = KeyValues.AbilitiesKv[self:GetName()]
    else
        tInfo = KeyValues.AbilitiesKv[self:GetAbilityName()]
    end

    if tInfo then
        if tInfo['AbilityManaCost'] then
            local tab = string.split(tInfo['AbilityManaCost'], " ")
            for _, v in pairs(tab) do
                table.insert(self.m_tBaseManaCost, tonumber(v))
            end
        end
        if tInfo['AbilityCooldown'] then
            local tab = string.split(tInfo['AbilityCooldown'], " ")
            for _, v in pairs(tab) do
                table.insert(self.m_tBaseCooldown, tonumber(v))
            end
        end
    end
end
----
----选择目标单位时
----@param 目标单位
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function this:CastFilterResultTarget(eTarget)
    if nil == eTarget then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
----
----自定义目标单位错误
----@param 目标单位
----@return 本地化键值
function this:GetCustomCastErrorTarget(eTarget)
    return self.m_strCastError
end

----
----选择目标地点时
----@param 目标地点vector
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function this:CastFilterResultLocation(vLocation)
    return UF_SUCCESS
end
----
----自定义目标地点错误
----@param 目标地点vector
----@return 本地化键值
function this:GetCustomCastErrorLocation(vLocation)
    return self.m_strCastError
end

----
----选择无目标时
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function this:CastFilterResult()
    return UF_SUCCESS
end
----
----自定义无目标错误
----@return 本地化键值
function this:GetCustomCastError()
    return self.m_strCastError
end

----
----当开始施法的时候，资源尚未被消耗
----@return bool 返回True可以正确释放，返回false则释放失败
function this:OnAbilityPhaseStart()
    return true
end

----
----当施法以任何理由被取消
---- function this:OnAbilityPhaseInterrupted()
---- end
----
---- 当施法前摇结束，资源（魔法什么的）已经被消耗，大多数技能是在这个时候开始正式生效的
---- function this:OnSpellStart()
---- end
----
---- 当持续施法完成的时候
----@param 代表技能是否释放完成
---- function this:OnChannelFinish(bInterrupted)
---- end
----
---- 如果这个技能创建了一个弹道，那么这个函数会在这个弹道还在飞的时候调用很多次
----@param 弹道的当前位置
---- function this:OnProjectileThink(vLocation)
---- end
----
---- 如果弹道已经到达最远距离，或者碰到了任何有效的东西
----@param 如果eTarget是null的话，那么意味着弹道是达到了最远距离了
----@return bool 返回true将会让弹道被销毁，返回false那么弹道会继续飞（比如说有一个线性弹道，返回false可以让弹道在击中一个单位后继续向前飞行，可以击中多个单位，直到达到最远距离或者返回true为止）
---- function this:OnProjectileHit(eTarget, vLocation)
---- end
----
---- 获取Modifier的名称
----@return string 返回这个技能被动施加的那个Modifier的名称
---- function this:GetIntrinsicModifierName()
---- end
----
---- 当技能升级的时候
function this:OnUpgrade()
    if not self.__init then
        self:constructor()
    end
end

--[[d 施法类型
和普通的技能一样的，Lua技能也会从npc_abilities_custom.txt来读取一大堆东西。
比如说目标类型啦，魔法消耗啦，目标标签啦，队伍啦，还有施法类型什么的。
如果你的技能需要在不同的条件下表现出不同的效果的话，那么你可以在你的文件中对他进行重写。
]]
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----
---- 定义了技能的释放类型
----@return DOTA_ABILITY_BEHAVIOR枚举值 如：DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
---- function this:GetBehavior()
---- end
----
---- 定义了技能释放之后的冷却时间
----@return float
function this:GetCooldown(nLevel)
    if not self.__init and IsClient() then
        self:constructor()
    end

    ----获取冷却减缩
    local nCDSub = 0
    if self:isCanCDSub() then
        local tabPlayerInfo = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self:GetCaster():GetPlayerOwnerID())
        if tabPlayerInfo and tabPlayerInfo.nCDSub then
            nCDSub = tabPlayerInfo.nCDSub
        end
    end

    ----计算技能等级索引
    if - 1 == nLevel then
        nLevel = self:GetLevel()
    else
        nLevel = 1 + nLevel
    end

    if self.m_tBaseCooldown then
        if nLevel > #self.m_tBaseCooldown then
            nLevel = #self.m_tBaseCooldown
        end
        if self.m_tBaseCooldown[nLevel] and nCDSub < self.m_tBaseCooldown[nLevel] then
            return self.m_tBaseCooldown[nLevel] - nCDSub
        end
    end
    return 0
end
----
---- 定义技能的施法距离
----@return int
function this:GetCastRange(vLocation, eTarget)
    if IsClient() then
        local nRange = self:GetSpecialValueFor("range")
        if not nRange or 0 >= nRange then
            return 0
        end
        local tabPlayerInfo = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self:GetCaster():GetPlayerOwnerID())
        if not tabPlayerInfo then
            return
        end

        local nOffset = self:GetSpecialValueFor("offset")
        local tabPathID = {}
        local nPathID = PathManager:getNextPathID(tabPlayerInfo.nPathCurID, -math.floor((nRange - 1) * 0.5) + nOffset)
        for i = 1, nRange do
            table.insert(tabPathID, nPathID)
            nPathID = PathManager:getNextPathID(nPathID, 1)
        end
        AbilityManager:showAbltMark(self, self:GetCaster(), tabPathID)
    end
    return 0
end
----
---- 定义技能的持续施法时间
----@return float
---- function this:GetChannelTime()
---- end
----
---- 如果拉比克可以偷这个技能
----@return bool
---- function this:IsStealable()
---- end
----
---- 如果你释放这个技能之后敌人可以获得魔棒充能
----@return bool
---- function this:ProcsMagicStick()
---- end
----
---- 如果可以被刷新
----@return bool
---- function this:IsRefreshable()
---- end
----
---- 返回施法者的动画速度
----@return float
---- function this:GetPlaybackRateOverride()
---- end
----
---- 返回技能等级的魔法消耗
----@param int 技能等级
----@return int
function this:GetManaCost(nLevel)
    if not self.__init and IsClient() then
        self:constructor()
    end

    ----获取冷却减缩
    local nManaSub = 0
    if self:isCanManaSub() then
        local tabPlayerInfo = CustomNetTables:GetTableValue("GameingTable", "player_info_" .. self:GetCaster():GetPlayerOwnerID())
        if tabPlayerInfo and tabPlayerInfo.nManaSub then
            nManaSub = tabPlayerInfo.nManaSub
        end
    end

    ----计算技能等级索引
    if - 1 == nLevel then
        nLevel = self:GetLevel()
    else
        nLevel = 1 + nLevel
    end

    if self.m_tBaseManaCost then
        if nLevel > #self.m_tBaseManaCost then
            nLevel = #self.m_tBaseManaCost
        end
        if self.m_tBaseManaCost[nLevel] and nManaSub < self.m_tBaseManaCost[nLevel] then
            return self.m_tBaseManaCost[nLevel] - nManaSub
        end
    end

    return 0
end

----是否计算冷却减缩
function this:isCanCDSub()
    return true
end
----是否计算耗魔减缩
function this:isCanManaSub()
    return true
end

function this:ai()
    if IsClient() then
        return
    end
    ----监听兵卒可攻击
    EventManager:register("Event_BZCanAtk", function(tabEvent)
        if self:IsNull() then
            return true
        end
        if self:GetCaster() ~= tabEvent.entity then
            return
        end
        if not AbilityManager:isCanOnAblt(self:GetCaster()) then
            return
        end

        local nManaCast = self:GetManaCost(self:GetLevel() - 1)

        ----持续进行施法判断
        local tEventID = {}
        table.insert(tEventID, EventManager:register("Event_BZCastAblt", function(tEvent)
            if tEvent.ablt == self then
                tEvent.bIgnore = false
            end
        end))

        local strName = Timers:CreateTimer(function()
            if IsValid(self) then
                if IsValid(self:GetCaster().m_eAtkTarget)
                and self:IsCooldownReady()
                and self:GetCaster():GetMana() == nManaCast then
                    ----蓝满了施法技能
                    ExecuteOrderFromTable({
                        UnitIndex = self:GetCaster():entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                        TargetIndex = nil, --Optional.  Only used when targeting units
                        AbilityIndex = self:GetEntityIndex(), --Optional.  Only used when casting abilities
                        Position = nil, --Optional.  Only used when targeting the ground
                        Queue = 0 --Optional.  Used for queueing up abilities
                    })
                end
                return 0.1
            end
        end)

        ----监听攻击结束
        table.insert(tEventID, EventManager:register("Event_BZCantAtk", function(tabEvent2)
            if self:IsNull() or self:GetCaster() == tabEvent2.entity then
                Timers:RemoveTimer(strName)
                for _, v in pairs(tEventID) do
                    EventManager:unregisterByID(v)
                end
                return true
            end
        end))
    end)
end

----通用判断技能施法
function this:isCanCast(eTarget, vPos)

    if nil ~= GMManager then

        ----非自己阶段不能施法
        if not self:isCanCastOtherRound() and self:GetCaster():GetPlayerOwnerID() ~= GMManager.m_nOrderID then
            self.m_strCastError = "LuaAbilityError_SelfRound"
            return false
        end
        ----移动阶段不能施法
        if not self:isCanCastMove() and GS_Move == GMManager.m_typeState then
            self.m_strCastError = "LuaAbilityError_Move"
            return false
        end
        ----补给阶段不能施法
        if not self:isCanCastSupply() and GS_Supply == GMManager.m_typeState then
            self.m_strCastError = "LuaAbilityError_Supply"
            return false
        end
        ----亡国阶段不能施法
        if GS_DeathClearing == GMManager.m_typeState then
            self.m_strCastError = "LuaAbilityError_DeathClearing"
            return false
        end
        ----等待
        if GS_Wait == GMManager.m_typeState and not self._GS then
            self.m_strCastError = "LuaAbilityError_Wait"
            return false
        end

        ----验证施法玩家
        local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
        if not NIL(oPlayer) then
            ----在监狱不能施法
            if not self:isCanCastInPrison() and 0 < bit.band(PS_InPrison, oPlayer.m_typeState) then
                self.m_strCastError = "LuaAbilityError_Prison"
                return false
            end
            ----在英雄攻击时不能施法
            if not self:isCanCastHeroAtk() and 0 < bit.band(PS_AtkHero, oPlayer.m_typeState) then
                self.m_strCastError = "LuaAbilityError_Battle"
                return false
            end
        end

        if not self:isCanCastAtk() and self:GetCaster().m_bBattle then
            self.m_strCastError = "LuaAbilityError_Battle"
            return false
        end

        ----验证目标单位
        if eTarget and not self:checkTarget(eTarget) then
            return false
        end
    end
    return true
end

----判断目标
function this:checkTarget(eTarget)
    if not eTarget or eTarget:IsNull() then
        return false
    end

    self.m_strCastError = "ERROR"

    ----对自己释放
    if eTarget == self:GetCaster() and not self:isCanCastSelf() then
        self.m_strCastError = "LuaAbilityError_SelfCant"
        return false
    end

    local oPlayer = PlayerManager:getPlayer(eTarget:GetPlayerOwnerID())
    if oPlayer then
        ----目标死亡
        if 0 < bit.band(PS_Die, oPlayer.m_typeState) then
            return false
        end
        ----目标在监狱
        if 0 < bit.band(PS_InPrison, oPlayer.m_typeState) then
            self.m_strCastError = "LuaAbilityError_Prison"
            return false
        end
        ----目标技能免疫
        if not self:isCanCastAbilityImmune() and 0 < bit.band(PS_AbilityImmune, oPlayer.m_typeState) then
            self.m_strCastError = "LuaAbilityError_AbilityImmune"
        end
    end

    ----目标是英雄
    if eTarget:IsHero() then
        if eTarget:IsIllusion() and not self:isCanCastIllusion() then
            ----不能是幻象
            self.m_strCastError = "LuaAbilityError_IllusionsCant"
        elseif not self:isCanCastHero() then
            ----不能是英雄
            self.m_strCastError = "LuaAbilityError_HeroCant"
        end
    elseif eTarget.m_bBZ then
        ----兵卒
        if not self:isCanCastBZ() then
            ----不能是兵卒
            self.m_strCastError = "LuaAbilityError_BZCant"
        end
    elseif eTarget.m_bMonster then
        ----野怪
        if not self:isCanCastMonster() then
            ----需要玩家控制，不能是野怪
            self.m_strCastError = "LuaAbilityError_MonsterCant"
        end
    else
        return false
    end

    if "ERROR" ~= self.m_strCastError then
        return false
    end
    return true
end

----能否在其他玩家回合时释放
function this:isCanCastOtherRound()
    return false
end
----能否在移动时释放
function this:isCanCastMove()
    return false
end
----能否在监狱时释放
function this:isCanCastInPrison()
    return false
end
----能否在轮抽时释放
function this:isCanCastSupply()
    return false
end
----能否在英雄攻击时释放
function this:isCanCastHeroAtk()
    return false
end
----能否在该单位攻击时释放
function this:isCanCastAtk()
    return false
end
----能否对自身释放
function this:isCanCastSelf()
    return false
end
----能否对技能免疫释放
function this:isCanCastAbilityImmune()
    local sSpellImmunityType = KeyValues.AbilitiesKv[self:GetAbilityName()]["SpellImmunityType"]
    return sSpellImmunityType and "SPELL_IMMUNITY_ENEMIES_YES" == sSpellImmunityType
end
----能否对幻象释放
function this:isCanCastIllusion()
    return 0 == bit.band(DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, self:GetAbilityTargetFlags())
end
----能否对兵卒释放
function this:isCanCastBZ()
    return 0 < bit.band(DOTA_UNIT_TARGET_BASIC, self:GetAbilityTargetType())
end
----能否对英雄释放
function this:isCanCastHero()
    return 0 < bit.band(DOTA_UNIT_TARGET_HERO, self:GetAbilityTargetType())
end
----能否对野怪释放
function this:isCanCastMonster()
    return 0 == bit.band(DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, self:getAbilityTargetFlags())
end