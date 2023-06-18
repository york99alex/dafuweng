--获取表中子元素个数
function getSize(table)
    if type(table) ~= "table" then
        return 0
    end

    local nSize = 0
    for _, _ in pairs(table) do
        nSize = nSize + 1
    end
    return nSize
end
-- 是否存在v
function exist(o, v)
    local isFunc = type(v) == "function"
    if o and v then
        for ki, vi in pairs(o) do
            if isFunc then
                if v(vi, ki) then
                    return true
                end
            else
                if vi == v then
                    return true
                end
            end
        end
        if o.__index then
            for ki, vi in pairs(o.__index) do
                if isFunc then
                    if v(ki, vi) then
                        return true
                    end
                else
                    if ki == v then
                        return true
                    end
                end
            end
        end
    end
    return false
end
-- 移除一个符合条件的 condition(v,k)
function remove(o, condition)
    local k
    if type(condition) == "function" then
        k = FIND(o, condition).key
    else
        k = KEY(o, condition)
    end
    if k then
        local v = o[k]
        if type(k) == "number" then
            table.remove(o, k)
        else
            o[k] = nil
        end
        return v
    end
    return nil
end
-- 移除所有符合条件的 condition(v,k)
function removeAll(o, condition)
    local kvs = FindAll(o, condition)
    for i = #kvs, 1, -1 do
        if type(kvs[i].key) == "number" then
            table.remove(o, kvs[i].key)
        else
            o[kvs[i].key] = nil
        end
    end
end
-- 移除重复元素
function removeRepeat(o)
    for k, v in pairs(o) do
        local tKVs = FindAll(o, function(v2) return v2 == v end)
        if 1 < #tKVs then
            local tNbKs = {}
            for i = #tKVs, 2, -1 do
                if 'number' == type(tKVs[i].key) then
                    table.insert(tNbKs, tKVs[i].key)
                else
                    o[tKVs[i].key] = nil
                end
            end
            if 0 < #tNbKs then
                table.sort(tNbKs, function(a, b)
                    return a > b
                end)
                for _, v2 in ipairs(tNbKs) do
                    table.remove(o, v2)
                end
            end
            return removeRepeat(o)
        end
    end
end
--- 查找一个符合条件的 condition(v,k)
---@return {key:any,value:any}
function FIND(o, condition)
    if o and condition and type(condition) == "function" then
        for ki, vi in pairs(o) do
            if condition(vi, ki) then
                return { key = ki, value = vi }
            end
        end
        if o.__index then
            for ki, vi in pairs(o.__index) do
                if condition(vi, ki) then
                    return { key = ki, value = vi }
                end
            end
        end
    end
    return { key = nil, value = nil }
end
--- 查找所有符合条件的 condition(v,k)
function FindAll(o, condition)
    ---@type {key:any, value:any}[]
    local result = {}
    local isFunc = type(condition) == "function"
    if o and condition then
        for ki, vi in pairs(o) do
            if isFunc then
                if condition(vi, ki) then
                    table.insert(result, { key = ki, value = vi })
                end
            else
                if vi == condition then
                    table.insert(result, { key = ki, value = vi })
                end
            end
        end
        if o.__index then
            for ki, vi in pairs(o.__index) do
                if isFunc then
                    if condition(vi, ki) then
                        table.insert(result, { key = ki, value = vi })
                    end
                else
                    if vi == condition then
                        table.insert(result, { key = ki, value = vi })
                    end
                end
            end
        end
    end
    return result
end
--- 通过value获取key
function KEY(o, v)
    local kf = nil
    if o and v then
        for ki, vi in pairs(o) do
            if vi == v then
                kf = ki
                break
            end
        end
        if not kf and o.__index then
            for ki, vi in pairs(o.__index) do
                if vi == v then
                    kf = ki
                    break
                end
            end
        end
    end
    return kf
end
--- 通过key获取value
function VALUE(o, k)
    local vf = nil
    if o and k then
        for ki, vi in pairs(o) do
            if ki == k then
                vf = vi
                break
            end
        end
        if not vf and o.__index then
            for ki, vi in pairs(o.__index) do
                if ki == k then
                    vf = vi
                    break
                end
            end
        end
    end
    return vf
end

local HOOKs = {}
function HOOK(ctx, from, to)
    local ret = nil
    local err = nil
    if ctx and to and type(ctx) == "table" and type(to) == "function" then
        local isString = false
        if type(from) == "function" then
            from = KEY(ctx, from)
        elseif type(from) == "string" then
            isString = true
        else
            from = nil
            err = "Hook failed caused by invalid arg 'from'."
        end
        if from then
            if not HOOKs[ctx] then HOOKs[ctx] = {} end
            if not HOOKs[ctx][from] then
                ret = VALUE(ctx, from)
                if ret and type(ret) == "function" then
                    ctx[from] = to
                    HOOKs[ctx][from] = ret
                elseif isString then
                    ret = to
                    ctx[from] = to
                else
                    err = "Hook failed caused by nil or invalid target."
                end
            else
                err = "Hook failed caused by multiple hook."
            end
        end
    else
        err = "Hook failed caused by invalid args."
    end
    if err then
        print(err)
    end
    return ret, err
end

function UNHOOK(ctx, from)
    local ret = nil
    local err = nil
    if ctx and type(ctx) == "table" then
        local isString = false
        if type(from) == "function" then
            from = KEY(ctx, from)
        elseif type(from) == "string" then
            isString = true
        else
            from = nil
            err = "Unhook failed caused by invalid arg 'from'."
        end
        if from then
            if HOOKs[ctx] then
                ret = HOOKs[ctx][from]
                if ret and type(ret) == "function" then
                    ctx[from] = ret
                elseif isString then
                    ctx[from] = nil
                else
                    err = "Unhook failed caused by nil or invalid target."
                end
                HOOKs[ctx][from] = nil
            else
                err = "Unhook failed caused by nil hook map."
            end
        end
    else
        err = "Unhook failed caused by invalid args."
    end
    if err then
        print(err)
    end
    return ret
end

--克隆
function clone(obj)
    local InTable = {};
    local function Func(obj)
        if type(obj) ~= "table" then   --判断表中是否有表
            return obj;
        end
        local NewTable = {};  --定义一个新表
        InTable[obj] = NewTable;  --若表中有表，则先把表给InTable，再用NewTable去接收内嵌的表
        for k, v in pairs(obj) do  --把旧表的key和Value赋给新表
            NewTable[Func(k)] = Func(v);
        end
        return setmetatable(NewTable, getmetatable(obj))--赋值元表
    end
    return Func(obj) --若表中有表，则把内嵌的表也复制了
end
--拷贝
function copy(ori)
    if type(ori) == "table" then
        local tb = {}
        for k, v in pairs(ori) do
            tb[k] = v
        end
        return tb
    else
        return ori
    end

end
--参数绑定
function bind(fun, ...)
    local param = { ... }
    local strParam = ""
    for i = 1, #param do
        strParam = strParam .. (1 < i and ',' or '') .. "param[" .. i .. "]"
    end
    return (load(string.format([[
        local arg = { ... }
        local param = arg[1]
        return function(...)
            return arg[2](%s, ...)
        end
    ]], strParam)))(param, fun)
end
--表合并
function concat(...)
    local arg = { ... }
    local tab = {}
    for _, v in pairs(arg) do
        if "table" ~= type(v) then
            table.insert(tab, v)
        else
            local i
            for k, v2 in ipairs(v) do
                i = k
                table.insert(tab, v2)
            end
            for k, v2 in pairs(v) do
                if "number" ~= type(k) or (1 > k or i < k) then
                    tab[k] = v2
                end
            end
        end
    end
    return tab
end
--表随机
function randomTab(o)
    local oTmp = copy(o)
    local o2 = {}
    for i = #oTmp, 1, -1 do
        local index = RandomInt(1, #oTmp)
        table.insert(o2, oTmp[index])
        table.remove(oTmp, index)
    end
    return o2
end

--矢量角度
function AngleBetween(v1, v2)
    local sin = v1.x * v2.y - v2.x * v1.y;
    local cos = v1.x * v2.x + v1.y * v2.y;
    local a = math.atan2(sin, cos) * (180 / math.pi)
    local sign = v1:Cross(v2):Normalized():Dot(v1:Normalized():Cross(v2:Normalized()))
    return a * sign
end