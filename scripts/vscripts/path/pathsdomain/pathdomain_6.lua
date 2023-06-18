--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----领土路径-鵰巢
if nil == PathDomain_6 then
    -----@class PathDomain_6
    PathDomain_6 = class({
        m_eDiao = nil       ----鲷哥
    }, nil, PathDomain)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function PathDomain_6:constructor(e)
    PathDomain_6.__base__.constructor(self, e)
    local tabPath = PathManager:getPathByType(self.m_typePath)
    if 1 ~= #tabPath then
        return
    end
    ----创建鵰哥
    EventManager:register("Event_GameStart", function()
        tabPath = PathManager:getPathByType(self.m_typePath)
        AMHC:CreateUnitAsync("path_17_diao",
        self.m_eCity:GetOrigin() - (self.m_eCity:GetForwardVector() * 200),
        self.m_eCity:GetAnglesAsVector().y, self.m_tabENPC[1], DOTA_TEAM_BADGUYS, function(e)
            self.m_eDiao = e
            for i = 0, 23 do
                local oAbltDiao = self.m_eDiao:GetAbilityByIndex(i)
                if nil ~= oAbltDiao then
                    oAbltDiao:SetLevel(1)
                end
            end
            for _, v in pairs(tabPath) do
                v.m_eDiao = self.m_eDiao
            end
            ----控制动作
            self.m_eDiao.bIdle = true   ----是否闲置状态
            Timers:CreateTimer(function()
                self:setDiaoGesture(ACT_DOTA_IDLE)
                return 3
            end)
        end)
        return true
    end)
end

function PathDomain_6:setDiaoGesture(typeACT)
    if not IsValid(self.m_eDiao) then
        return
    end

    if not self.m_eDiao.bIdle then
        if ACT_DOTA_IDLE == typeACT then
            return
        elseif - ACT_DOTA_CAST_ABILITY_1 == typeACT then
            self.m_eDiao:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
            self.m_eDiao.bIdle = true
        end
    end
    if ACT_DOTA_CAST_ABILITY_1 == typeACT then
        self.m_eDiao.bIdle = false
        self.m_eDiao:RemoveGesture(ACT_DOTA_IDLE)
    end
    self.m_eDiao:StartGesture(typeACT)
end