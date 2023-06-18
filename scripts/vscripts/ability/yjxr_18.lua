require("Ability/LuaAbility")
----技能：神圣路径养精蓄锐
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
yjxr_18 = class({
}, nil, LuaAbility)
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function yjxr_18:constructor()
    self.__base__.constructor(self)
end

----选择无目标时
function yjxr_18:CastFilterResult()
    if IsServer() and self:GetCaster():HasModifier("modifier_medusa_stone_gaze_stone") then
        self:OnSpellStart()
    end
    return UF_SUCCESS
end

----开始技能效果
function yjxr_18:OnSpellStart()
    if nil == PlayerManager then
        return
    end

    EmitGlobalSound("Hero_Omniknight.GuardianAngel")
    ---- local nGold = self:GetGoldCost(self:GetLevel() - 1)
    ---- local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    ---- oPlayer:setGold(-nGold)
    onAblt_yjxr({ caster = self:GetCaster(), ability = self })
end