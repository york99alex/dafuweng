--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----领土路径-河道
if nil == PathDomain_2 then
    -----@class PathDomain_2
    PathDomain_2 = class({
    }, nil, PathDomain)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function PathDomain_2:constructor(e)
    PathDomain_2.__base__.constructor(self, e)
end

----计算玩家领地buff等级
function PathDomain_2:getPathBuffLevel(oPlayer)
    ----兵卒几级就几级
    if self.m_nOwnerID == oPlayer.m_nPlayerID then
        local nLevel = oPlayer:getBzStarLevel(self.m_tabENPC[1])
        return nLevel
    end
end

----获取领地BUFFName
function PathDomain_2:getBuffName(nLevel)
    local tPathSelfType = PathManager:getPathByType(self.m_typePath)
    if tPathSelfType[1] == self then
        return "path_" .. self.m_typePath .. "_hujia"
    else
        return "path_" .. self.m_typePath .. "_mokang"
    end
end

----设置领地BUFF
function PathDomain_2:setBuff(oPlayer)
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

    ----添加三级双河道
    -- if 3 == nLevel then
    --     local tPaths = PathManager:getPathByType(TP_DOMAIN_2)
    --     for _, v in pairs(tPaths) do
    --         if v ~= self then
    --             if 3 == v:getPathBuffLevel(oPlayer) then
    --                 local oAblt = AMHC:AddAbilityAndSetLevel(oPlayer.m_eHero, "path_13_hundun", nLevel)
    --             end
    --             break
    --         end
    --     end
    -- end
end

----移除领地BUFF
function PathDomain_2:delBuff(oPlayer)
    local strBuffName = self:getBuffName()
    if oPlayer.m_eHero:HasAbility(strBuffName) then
        ----触发事件：领地技能移除
        EventManager:fireEvent("Event_PathBuffDel", { oPlayer = oPlayer, path = self, sBuffName = strBuffName })
        ----移除英雄buff技能
        AMHC:RemoveAbilityAndModifier(oPlayer.m_eHero, strBuffName)
        -- AMHC:RemoveAbilityAndModifier(oPlayer.m_eHero, "path_13_hundun")
    end
end