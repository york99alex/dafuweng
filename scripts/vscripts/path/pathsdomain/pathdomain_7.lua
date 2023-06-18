--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----领土路径-圣所
if nil == PathDomain_7 then
    -----@class PathDomain_7
    PathDomain_7 = class({
    }, nil, PathDomain)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function PathDomain_7:constructor(e)
    PathDomain_7.__base__.constructor(self, e)
end

----计算玩家领地buff等级
function PathDomain_7:getPathBuffLevel(oPlayer)
    ----根据全部兵卒等级
    local nLevel = 100
    local tabPath = PathManager:getPathByType(self.m_typePath)
    for _, v in pairs(tabPath) do
        if v.m_tabENPC[1] and v.m_nOwnerID == oPlayer.m_nPlayerID then
            local nLevelTmp = oPlayer:getBzStarLevel(v.m_tabENPC[1])
            if nLevel > nLevelTmp then
                nLevel = nLevelTmp
            end
        else
            return
        end
    end
    return nLevel
end