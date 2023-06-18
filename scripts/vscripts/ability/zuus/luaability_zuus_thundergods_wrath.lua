require("Ability/LuaAbility")
----技能：雷神之怒    英雄：zuus
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_zuus_thundergods_wrath then
    LuaAbility_zuus_thundergods_wrath = class({}, nil, LuaAbility)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaAbility_zuus_thundergods_wrath:constructor()
    self.__base__.constructor(self)
end