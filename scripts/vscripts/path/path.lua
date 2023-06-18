--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----路径基类
if nil == Path then
    -----@class Path
    Path = class({
        m_nID = nil					----路径ID
        , m_typePath = nil			----路径类型

        , m_entity = nil			----路径实体
        , m_eLog = nil			    ----路径Log实体
        , m_eUnit = nil			    ----路径单位

        , m_tabEJoin = nil          ----停留在路径上的实体
        , m_tabPos = nil            ----全部身位

        , m_typeState = nil         ----领地状态
    })
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function Path:constructor(e)
    if not e then
        return
    end

    self.m_entity = e
    self.m_typePath = e:GetIntAttr('PathType')
    self.m_tabEJoin = {}
    ---- self.m_tabPos = {}
    ----截取ID
    local strName = e:GetName()
    strName = string.reverse(strName)
    strName = string.sub(strName, 1, string.find(strName, '_') - 1)
    strName = string.reverse(strName)
    self.m_nID = tonumber(strName)

    self.m_eLog = Entities:FindByName(nil, "PathLog_" .. self.m_nID)
    if self.m_eLog then
        ----创建log单位
        self.m_eUnit = CreateUnitByName("PathLog_" .. self.m_nID, self.m_eLog:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
        self.m_eUnit.m_path = self
        ---- entity:SetModel(self.m_eLog:GetModelName())
        ---- entity:SetOriginalModel(self.m_eLog:GetModelName())
        ---- entity:SetForwardVector(self.m_eLog:GetForwardVector())
        ---- self.m_eLog:SetOrigin(self.m_eLog:GetOrigin() - Vector(0, 0, 1000))
    end

    self:initNilPos()
    self:setState(TypePathState.None)
end

function Path:setState(typeState)
    self.m_typeState = typeState
end

----触发路径
function Path:onPath(oPlayer)
    EventManager:fireEvent("Event_OnPath", { path = self, entity = oPlayer.m_eHero })
end

----初始化空位数据
function Path:initNilPos()
    self.m_tabPos = {
        {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * 75 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * -75 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * 75 + self.m_entity:GetForwardVector() * 50 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * -75 + self.m_entity:GetForwardVector() * 50 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * 75 - self.m_entity:GetForwardVector() * 50 + self.m_entity:GetAbsOrigin()
        }
        , {
            entity = nil
            , vPos = self.m_entity:GetRightVector() * -75 - self.m_entity:GetForwardVector() * 50 + self.m_entity:GetAbsOrigin()
        }
    }
end

----添加l路径上的实体
function Path:setEntityAdd(e)
    local bHas = false
    for k, v in pairs(self.m_tabEJoin) do
        if v == e then
            bHas = true
            break
        end
    end
    if not bHas then
        table.insert(self.m_tabEJoin, e)
    end

    ----设置朝向下一个路径
    local pathNext = PathManager:getNextPath(self, 1)
    local v3 = pathNext.m_entity:GetAbsOrigin() - self.m_entity:GetAbsOrigin()
    v3 = v3:Normalized()
    Timers:CreateTimer(0.1, function()
        e:MoveToPosition(e:GetAbsOrigin() + v3)
    end)
end
----移除路径上实体
function Path:setEntityDel(e)
    for k, v in pairs(self.m_tabEJoin) do
        if v == e then
            table.remove(self.m_tabEJoin, k)

            ----从身位中移除
            for k2, v2 in pairs(self.m_tabPos) do
                if e == v2.entity then
                    v2.entity = nil
                    return
                end
            end
            return
        end
    end
end
----是否有实体
function Path:isHasEntity(e)
    for _, v in pairs(self.m_tabEJoin) do
        if v == e then
            return true
        end
    end
    return false
end

----加入的实体移动到正确的位置
function Path:join(e)
    for _, v in pairs(self.m_tabPos) do
        if nil == v.entity then
            ----空位置，移动
            PathManager:moveToPos(e, v.vPos, function(bSuccess)
                ----设置朝向下一个路径
                if bSuccess then
                    Timers:CreateTimer(0.1, function()
                        local pathNext = PathManager:getNextPath(self, 1)
                        local v3 = pathNext.m_entity:GetAbsOrigin() - self.m_entity:GetAbsOrigin()
                        v3 = v3:Normalized()
                        e:MoveToPosition(e:GetAbsOrigin() + v3)
                    end)
                end
            end)
            v.entity = e
            return
        end
    end
end

----获得一个空位，并占用
function Path:getNilPos(e)
    for _, v in pairs(self.m_tabPos) do
        if nil == v.entity then
            ----空位置
            v.entity = e
            return v.vPos
        end
    end
    return self.m_entity:GetAbsOrigin()
end
----获得单位已经占用的位置
function Path:getUsePos(e)
    for _, v in pairs(self.m_tabPos) do
        if e == v.entity then
            return v.vPos
        end
    end
    return self.m_entity:GetAbsOrigin()
end

----获取驻足在此地英雄
function Path:getJoinEnt()
    local tE = {}
    for _, e in pairs(self.m_tabEJoin) do
        if IsValid(e) then
            local path = PathManager:getClosePath(e:GetAbsOrigin())
            if path == self then
                table.insert(tE, e)
            end
        end
    end
    return tE
end