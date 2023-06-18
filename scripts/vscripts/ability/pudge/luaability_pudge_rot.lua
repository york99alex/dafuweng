require("Ability/LuaAbility")

----技能：腐烂    英雄：屠夫帕吉
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
LuaAbility_pudge_rot = class({
    m_tabPtclID = {}
}, nil, LuaAbility)
LinkLuaModifier("modifier_LuaAbility_pudge_rot_aura", "Ability/pudge/LuaAbility_pudge_rot.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_LuaAbility_pudge_rot_debuff", "Ability/pudge/LuaAbility_pudge_rot.lua", LUA_MODIFIER_MOTION_NONE)
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_pudge_rot:constructor()
    self.__base__.constructor(self)
    self.m_tabPtclID = {}
end

----施法距离
function LuaAbility_pudge_rot:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("range")
end

----选择无目标时
function LuaAbility_pudge_rot:CastFilterResult()
    if not self:isCanCast() then
        return UF_FAIL_CUSTOM
    end

    ----至少要1点魔法
    if 1 > self:GetCaster():GetMana() then
        self.m_strCastError = "LuaAbilityError_NeedMana_1"
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end

----开始技能效果
function LuaAbility_pudge_rot:OnSpellStart()
    if IsClient() then
        return
    end

    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    ---- if "number" == type(ACT_DOTA_CAST2_STATUE) then
    ----     oPlayer.m_eHero:StartGesture(ACT_DOTA_CAST2_STATUE)
    ---- end
    if 0 == #self.m_tabPtclID then
        ----开启腐烂
        self.m_tabPtclID[1] = AMHC:CreateParticle("particles/units/heroes/hero_pudge/pudge_rot.vpcf"
        , PATTACH_POINT_FOLLOW, false, self:GetCaster())

        local nRange = self:GetSpecialValueFor("range")
        ParticleManager:SetParticleControl(self.m_tabPtclID[1], 1, Vector(nRange, 0, 0))  ----范围

        ----注册移动监听
        EventManager:register("Event_Move", self.onEvent_Move, self)
        ----注册英雄魔法修改
        EventManager:register("Event_HeroManaChange", self.onEvent_ManaChang, self)

        ----音效
        EmitSoundOn("Hero_Pudge.Rot", self:GetCaster())
        Timers:CreateTimer(2, function()
            StopSoundOn("Hero_Pudge.Rot", self:GetCaster())
        end)
    else
        ----关闭
        for _, nPctlID in pairs(self.m_tabPtclID) do
            ParticleManager:DestroyParticle(nPctlID, false)
        end
        self.m_tabPtclID = {}

        StopSoundOn("Hero_Pudge.Rot", self:GetCaster())

        EventManager:unregister("Event_Move", self.onEvent_Move, self)
        EventManager:unregister("Event_HeroManaChange", self.onEvent_ManaChang, self)
    end

end

function LuaAbility_pudge_rot:onEvent_Move(tabEvent)
    if not self:checkTarget(tabEvent.entity) then
        return
    end

    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if NIL(oPlayer) then
        return
    end

    local nRange = self:GetSpecialValueFor("range")
    local nDamage = self:GetSpecialValueFor("damage")
    local nTime = self:GetSpecialValueFor("time_damage")

    ----监听移动结束
    local bMoveEnd = false
    EventManager:register("Event_MoveEnd", function(tabEvenl2)
        if tabEvent.entity == tabEvenl2.entity then
            bMoveEnd = true
            if 0 == self:GetCaster():GetMana() then
                ----魔法用尽，结束技能
                self:OnSpellStart()
            end
            return true
        end
    end)

    local bDamageSelf = false        ----能否伤害自身
    local bSound = false            ----有无音效
    local bUseMana = false          ----是否扣了蓝
    local funCheck = function(eFoe) ----对敌人的检测
        ----持续判断范围
        Timers:CreateTimer(function()
            if bMoveEnd then
                ----移动结束，结束检测
                ---- if bSound then
                ----     print("move end stop sound")
                ----     StopSoundOn("Hero_Pudge.Rot", self:GetCaster())
                ----     bSound = false
                ---- end
                eFoe:RemoveModifierByName('modifier_LuaAbility_pudge_rot_debuff')
                return nil
            end

            ----判断距离
            local nDis = (eFoe:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length()
            if nDis > nRange then
                ---- if bSound then
                ----     bSound = false
                ----     print("nDis > nRange stop sound")
                ----     StopSoundOn("Hero_Pudge.Rot", self:GetCaster())
                ---- end
                eFoe:RemoveModifierByName('modifier_LuaAbility_pudge_rot_debuff')
                return 0.1
            end

            ----范围内
            ---- if not bSound then
            ----     bSound = true
            ----     print("nDis < nRange emit sound")
            ----     EmitSoundOn("Hero_Pudge.Rot", self:GetCaster())
            ---- end
            ----对敌人造成伤害
            AMHC:Damage(self:GetCaster(), eFoe, nDamage, self:GetAbilityDamageType(), self)
            eFoe:AddNewModifier(self:GetCaster(), self, 'modifier_LuaAbility_pudge_rot_debuff', nil)

            ---- if bDamageSelf then
            ----     ----对自身造成伤害
            ----     print("self damage == " .. nDamage)
            ----     AMHC:Damage(self:GetCaster(), self:GetCaster(), nDamage, self:GetAbilityDamageType(), self)
            ----     bDamageSelf = false
            ----     Timers:CreateTimer(nTime, function()
            ----         bDamageSelf = true
            ----     end)
            ---- end
            if not bUseMana then
                bUseMana = true
                self:GetCaster():SpendMana(1, self)
            end
            return nTime
        end)
    end

    if self:GetCaster() == tabEvent.entity then
        ----自己移动，伤害全部敌人英雄
        for _, v in pairs(PlayerManager.m_tabPlayers) do
            if tabEvent.entity ~= v.m_eHero then
                funCheck(v.m_eHero)
            end
        end
    else
        ----敌人移动
        funCheck(tabEvent.entity)
    end
end

function LuaAbility_pudge_rot:onEvent_ManaChang(tabEvent)
    if tabEvent.player.m_eHero ~= self:GetCaster() then
        return
    end
    if tabEvent.oAblt == self then
        return
    end
    if 1 > self:GetCaster():GetMana() then
        ----没蓝关闭技能
        if 0 ~= #self.m_tabPtclID then
            self:OnSpellStart()
        end
    end
end

----是否计算冷却减缩
function LuaAbility_pudge_rot:isCanCDSub()
    return false
end
----是否计算耗魔减缩
function LuaAbility_pudge_rot:isCanManaSub()
    return false
end
----能否对自身释放
function LuaAbility_pudge_rot:isCanCastSelf()
    return true
end

---------------------------------------------------------------------
--Modifiers
if modifier_LuaAbility_pudge_rot_debuff == nil then
    modifier_LuaAbility_pudge_rot_debuff = class({})
end
function modifier_LuaAbility_pudge_rot_debuff:IsDebuff()
    return true
end
function modifier_LuaAbility_pudge_rot_debuff:IsPurgable()
    return false
end
function modifier_LuaAbility_pudge_rot_debuff:OnCreated()
    self.rot_slow = self:GetAbility():GetSpecialValueFor("rot_slow")
end
function modifier_LuaAbility_pudge_rot_debuff:OnRefresh()
    self.rot_slow = self:GetAbility():GetSpecialValueFor("rot_slow")
end
function modifier_LuaAbility_pudge_rot_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end
function modifier_LuaAbility_pudge_rot_debuff:GetModifierMoveSpeedBonus_Percentage(params)
    return self.rot_slow
end

--
if modifier_LuaAbility_pudge_rot_aura == nil then
    modifier_LuaAbility_pudge_rot_aura = class({})
end
function modifier_LuaAbility_pudge_rot_aura:IsHidden()
    return true
end
function modifier_LuaAbility_pudge_rot_aura:IsPurgable()
    return false
end
function modifier_LuaAbility_pudge_rot_aura:IsAura()
    return true
end
function modifier_LuaAbility_pudge_rot_aura:GetModifierAura()
    return "modifier_LuaAbility_pudge_rot_debuff"
end
function modifier_LuaAbility_pudge_rot_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_LuaAbility_pudge_rot_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end
function modifier_LuaAbility_pudge_rot_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("range")
end