----Lua物品
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaItem then
    LuaItem = class({
        m_strCastError = nil
    })
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function LuaItem:constructor()
    if self.__init then
        return
    end
    self.__init = true
end
----
----选择目标单位时
----@param 目标单位
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function LuaItem:CastFilterResultTarget(hTarget)
    if nil == hTarget then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
----
----自定义目标单位错误
----@param 目标单位
----@return 本地化键值
function LuaItem:GetCustomCastErrorTarget(hTarget)
    return self.m_strCastError
end

----
----选择目标地点时
----@param 目标地点vector
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function LuaItem:CastFilterResultLocation(vLocation)
    return UF_SUCCESS
end
----
----自定义目标地点错误
----@param 目标地点vector
----@return 本地化键值
function LuaItem:GetCustomCastErrorLocation(vLocation)
    return self.m_strCastError
end

----
----选择无目标时
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function LuaItem:CastFilterResult()
    return UF_SUCCESS
end
----
----自定义无目标错误
----@return 本地化键值
function LuaItem:GetCustomCastError()
    return self.m_strCastError
end

----获取被动luaModifier
function LuaItem:GetIntrinsicModifierName()
    self:constructor()
    return "modifier_" .. self:GetAbilityName()
end

function LuaItem:bindModifier(strBuffAblt)
    local oAblt = self:GetCaster():AddAbility(strBuffAblt)
    if oAblt then
        local e = self:GetCaster()
        local oBuff = e:FindModifierByName("modifiers_" .. oAblt:GetAbilityName())
        if not oBuff then
            oBuff = oAblt:ApplyDataDrivenModifier(e, e, "modifiers_" .. oAblt:GetAbilityName(), nil)
            ---- else oBuff:GetStackCount() >= 1 if
        end
        oBuff:IncrementStackCount()
        self:GetCaster():RemoveAbility(oAblt:GetAbilityName())
        ----物品失效
        Timers:CreateTimer(function()
            if not e:IsNull() then
                if not self:IsNull() then
                    for i = 0, 5 do
                        local item = e:GetItemInSlot(i)
                        if item == self then
                            return 1
                        end
                    end
                end
                if 1 == oBuff:GetStackCount() then
                    e:RemoveModifierByName(oBuff:GetName())
                else
                    oBuff:DecrementStackCount()
                end
            end
        end)
    end
end