require("Ability/LuaAbility")
----技能：神圣路径解甲归田
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
xj_18 = class({
}, nil, LuaAbility)
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function xj_18:constructor()
    self.__base__.constructor(self)
end

----选择无目标时
function xj_18:CastFilterResult()
    if IsServer() and self:GetCaster():HasModifier("modifier_medusa_stone_gaze_stone") then
        self:OnSpellStart()
    end
    return UF_SUCCESS
end

----开始技能效果
function xj_18:OnSpellStart()
    if nil == PlayerManager then
        return
    end

    EmitGlobalSound("Hero_Omniknight.GuardianAngel")
    onAblt_xj({ caster = self:GetCaster(), ability = self })
end