require('Path/PathFactory')
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----路径管理模块
if not PathManager then
    PathManager = {
        ----全部路径
        m_tabPaths = nil
        , m_tabMoveData = nil
    }
end

----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function PathManager:init(bReload)
    if not bReload then
        ----获取全部路径实体
        self.m_tabPaths = {}
        self.m_tabMoveData = {}
        local tabAllPathEntities = Entities:FindAllByClassname('path_corner')
        for k, v in pairs(tabAllPathEntities) do
            if string.sub(v:GetName(), 1, 4) == "path" then
                ----生成对象
                local oPath = PathFactory:create(v)
                table.insert(self.m_tabPaths, oPath)
                ----路径视野
                AddFOWViewer(DOTA_TEAM_GOODGUYS, v:GetAbsOrigin() + Vector(0, 0, 500), 400, -1, true)
            end
        end

        table.sort(self.m_tabPaths, function(a, b)
            return a.m_nID < b.m_nID
        end)

        ----同步网表路径信息
        self:setNetTableInfo()
    end
end

----获取路径对象
function PathManager:getPathByID(nID)
    for i, v in ipairs(self.m_tabPaths) do
        if nID == v.m_nID then
            return v
        end
    end
end
function PathManager:getPathByType(type)
    local tabPath = {}
    for i, v in ipairs(self.m_tabPaths) do
        if type == v.m_typePath then
            table.insert(tabPath, v)
        end
    end
    return tabPath
end
function PathManager:getPathByClass(Class)
    local tabPath = {}
    for i, v in ipairs(self.m_tabPaths) do
        if instanceof(v, Class) then
            table.insert(tabPath, v)
        end
    end
    return tabPath
end
---- 获取可占领领地
function PathManager:getCanOccupyPaths()
    local paths = concat(PathManager:getPathByClass(PathDomain), PathManager:getPathByClass(PathTP))
    local canOccupy = FindAll(paths, function(path)
        if not path.m_nOwnerID then
            print('PathManager:getCanOccupyPaths: path id = ', path.m_nID)
            print('PathManager:getCanOccupyPaths: path ownerID = ', path.m_nOwnerID)
            return true
        end
    end)
    local res = {}
    for k, v in pairs(canOccupy) do
        table.insert(res, v.value)
    end
    return res
end
---- 随机一块可占领领地
---- @return number 领地ID 没有则返回nil
function PathManager:RandomACanOccupyPath()
    local canOccupy = PathManager:getCanOccupyPaths()
    return #canOccupy > 0 and canOccupy[RandomInt(1, #canOccupy)] or nil
end

----通过路径上的兵卒获取路径
function PathManager:getPathByBZEntity(entity)
    for i, path in ipairs(self.m_tabPaths) do
        if path.m_tabENPC and #path.m_tabENPC > 0 then
            for _, npc in pairs(path.m_tabENPC) do
                if npc and npc == entity then
                    return path
                end
            end
        end
    end
end

----设置玩家网表信息
function PathManager:setNetTableInfo()
    local tabData = {}
    for _, v in pairs(self.m_tabPaths) do
        tabData[v.m_nID] = {
            vPos = {
                x = v.m_entity:GetAbsOrigin().x
                , y = v.m_entity:GetAbsOrigin().y
                , z = v.m_entity:GetAbsOrigin().z
            }
        }
    end

    ----设置网表
    CustomNetTables:SetTableValue("GameingTable", "path_info", tabData)
end

----路径寻路移动
function PathManager:moveToPath(entity, path, bEventEnable, funCallBack)
    local pathBegin
    local pathCur
    local pathNext

    if entity:IsHero() then
        ----玩家英雄直接向下一个路径开始寻路
        local oPlayer = PlayerManager:getPlayer(entity:GetPlayerID())
        pathBegin = oPlayer.m_pathCur
        pathCur = pathBegin
        if pathCur == path then
            ----当前路径就是目的地
            pathNext = pathCur
        else
            pathNext = PathManager:getNextPath(pathCur, 1)
        end
    else
        ----非玩家英雄则找最近的路径开始寻路
        pathBegin = PathManager:getClosePath(entity:GetOrigin())
        pathCur = pathBegin
        pathNext = pathBegin
    end

    local vNext
    local function getNextPos()
        if pathNext == path then
            vNext = pathNext:getNilPos(entity)  ----到站了找个空位
        else
            vNext = pathNext.m_entity:GetOrigin()
        end
    end
    getNextPos()

    entity:MoveToPosition(vNext)

    ----防卡死功能
    local nTimeKaSi = 0
    local v3Last = nil
    local function judgeKaSi()
        if v3Last == entity:GetAbsOrigin() then
            nTimeKaSi = nTimeKaSi + 1
            if TIME_MOVEKASI <= nTimeKaSi then
                ----卡死了，直接设置到目的地
                -- entity:SetAbsOrigin(vNext)
                entity:SetAbsOrigin(path:getNilPos(entity))
                FindClearSpaceForUnit(entity, entity:GetAbsOrigin(), true)
                PathManager:moveStop(entity, true)
                return false
            end
        else
            v3Last = entity:GetAbsOrigin()
        end
        return false
    end

    local nEntID = entity:GetEntityIndex()

    ----结束上次移动
    if self.m_tabMoveData[nEntID] then
        PathManager:moveStop(entity, false)
    end

    ----新的移动
    local tMoveData = {
        nEntID = nEntID,
        funCallBack = funCallBack,
    }
    self.m_tabMoveData[nEntID] = tMoveData

    ----持续寻路
    Timers:CreateTimer(function()
        if tMoveData ~= self.m_tabMoveData[nEntID] then
            return
        end
        if not IsValid(entity) or not entity:IsAlive() then
            PathManager:moveStop(entity, false)
            return
        end
        ----检验每个寻路点
        local nDis = (entity:GetOrigin() - vNext):Length2D()
        local nCheckDis = 30
        if pathNext ~= path then
            nCheckDis = entity:GetIdealSpeed() * 0.35 - 75
            if 30 > nCheckDis then
                nCheckDis = 30
            end
        end
        if nCheckDis > nDis or judgeKaSi() then
            ----触发事件：途径某路径
            if pathNext ~= pathBegin and bEventEnable then
                EventManager:fireEvent("Event_PassingPath", { path = pathNext, entity = entity })
            end
            if pathNext == path then
                ----移动结束
                PathManager:moveStop(entity, true)
                return nil
            else
                ----移动下一个路径点
                pathCur = pathNext
                pathNext = PathManager:getNextPath(pathCur, 1)
                if not pathNext or pathNext == pathCur then
                    PathManager:moveStop(entity, true)
                    return
                end
                getNextPos()
                -- entity:MoveToPosition(vNext)
            end
        end
        entity:MoveToPosition(vNext)
        return 0.1
    end)
    return true
end
----坐标寻路移动
function PathManager:moveToPos(entity, v3, funCallBack)
    if not IsValid(entity) then
        return
    end
    ----验证能否到达
    if not entity:HasFlyMovementCapability() and not GridNav:CanFindPath(entity:GetAbsOrigin(), v3) then
        if funCallBack then
            funCallBack(false)
        end
        return false
    end
    v3 = Vector(v3.x, v3.y, entity:GetAbsOrigin().z)

    ----开始移动
    ----entity:MoveToPosition(v3)
    ----防卡死功能
    local nTimeKaSi = 0
    local v3Last = nil
    local function judgeKaSi()
        if v3Last == entity:GetAbsOrigin() then
            nTimeKaSi = nTimeKaSi + 1
            if TIME_MOVEKASI <= nTimeKaSi then
                ----卡死了，直接设置到目的地
                entity:SetAbsOrigin(v3)
                FindClearSpaceForUnit(entity, entity:GetAbsOrigin(), true)
                PathManager:moveStop(entity, true)
                return false
            end
        else
            v3Last = entity:GetAbsOrigin()
        end
        return false
    end

    local nEntID = entity:GetEntityIndex()

    ----结束上次移动
    if self.m_tabMoveData[nEntID] then
        PathManager:moveStop(entity, false)
    end

    ----新的移动
    local tMoveData = {
        nEntID = nEntID,
        funCallBack = funCallBack,
    }
    self.m_tabMoveData[nEntID] = tMoveData

    ----设置计时器监听移动结束，触发回调
    Timers:CreateTimer(function()
        if tMoveData ~= self.m_tabMoveData[nEntID] then
            return
        end
        if not IsValid(entity) or not entity:IsAlive() then
            PathManager:moveStop(entity, false)
            return
        end
        local nDis = (entity:GetAbsOrigin() - v3):Length2D()

        local nCheckDis = 30
        nCheckDis = entity:GetIdealSpeed() * 0.35 - 75
        if 30 > nCheckDis then
            nCheckDis = 30
        end
        if nCheckDis > nDis or judgeKaSi() then
            ----移动结束
            PathManager:moveStop(entity, true)
            return nil
        end
        entity:MoveToPosition(v3)
        return 0.1
    end)
    return true
end

function PathManager:moveStop(entity, bSuccess)
    if not IsValid(entity) then
        return
    end
    local tMoveData = self.m_tabMoveData[entity:GetEntityIndex()]
    if not tMoveData then
        return
    end
    self.m_tabMoveData[entity:GetEntityIndex()] = nil
    if nil ~= tMoveData.funCallBack then
        tMoveData.funCallBack(bSuccess)
    end
end

----获取当前路径的下个路径
function PathManager:getNextPath(pathCur, nDis)
    for i = 1, #self.m_tabPaths do
        if self.m_tabPaths[i] == pathCur then
            local nIndex = i + nDis
            if nIndex > #self.m_tabPaths then
                nIndex = nIndex % #self.m_tabPaths
            elseif nIndex <= 0 then
                nIndex = nIndex + #self.m_tabPaths
            end
            return self.m_tabPaths[nIndex]
        end
    end
end
----获取下个路径ID
function PathManager:getNextPathID(nCurID, nDis)
    local nIndex = nCurID + nDis
    local nCount = self.m_tabPaths and #self.m_tabPaths or 40
    if nIndex > nCount then
        nIndex = nIndex % nCount
    elseif nIndex <= 0 then
        nIndex = nIndex + nCount
    end
    return nIndex
end
----获取距离目标地点最近的路径
function PathManager:getClosePath(v3)
    local path = nil
    local nMin = nil
    for _, v in pairs(self.m_tabPaths) do
        local nDis = (v3 - v.m_entity:GetOrigin()):Length2D()
        if nil == nMin or nDis < nMin then
            nMin = nDis
            path = v
        end
    end
    return path
end
----获取路径前方后方的尽头拐角点
function PathManager:getVertexPath(pathCur)
    local q, h = self:getVertexPathID(pathCur.m_nID)
    return self:getPathByID(q), self:getPathByID(h)
end
----获取路径前方后方的尽头拐角点路径ID
function PathManager:getVertexPathID(nCurID)
    local function isQ(nQ, nH)
        for i = 1, #PATH_VERTEX do
            if nQ == PATH_VERTEX[i] then
                if 1 < i then
                    return nH == PATH_VERTEX[i - 1]
                else
                    return nH == PATH_VERTEX[#PATH_VERTEX]
                end
            end
        end
        return false
    end

    local q, h
    for i = 1, #PATH_VERTEX do
        if PATH_VERTEX[i] < nCurID then
            if not h or isQ(PATH_VERTEX[i], h) then
                h = PATH_VERTEX[i]
            end
        elseif PATH_VERTEX[i] > nCurID then
            if not q or isQ(q, PATH_VERTEX[i]) then
                q = PATH_VERTEX[i]
            end
        end
    end
    if not q then
        q = PATH_VERTEX[1]
    end
    if not h then
        h = PATH_VERTEX[#PATH_VERTEX]
    end
    return q, h
end

----获取A路径到B路径的路径距离
function PathManager:getPathDistance(oPathBegin, oPathEnd, bReverse)
    if oPathBegin == oPathEnd then
        return 0
    end

    local nDis = 0
    local nBegin = nil

    for i = 1, #self.m_tabPaths do
        if oPathBegin == self.m_tabPaths[i] then
            for j = 1, #self.m_tabPaths do
                if oPathEnd == self.m_tabPaths[j] then
                    if bReverse then
                        nDis = i - j
                    else
                        nDis = j - i
                    end
                    if 0 > nDis then
                        nDis = #self.m_tabPaths + nDis
                    end
                    break
                end
            end
            break
        end
    end
    return nDis
end

----获取平均领地数量
function PathManager:getPathCountAge()
    local nPlayer = PlayerManager:getAlivePlayerCount()
    local nPaths = 0
    for _, v in pairs(self.m_tabPaths) do
        if instanceof(v, PathDomain) or instanceof(v, PathTP) then
            nPaths = nPaths + 1
        end
    end
    return math.floor(nPaths / nPlayer)
end