if nil == EventManager then
	---@class EventManager
	EventManager = {
		m_tabEvent = {},
		m_nIncludeID = 0,

		---Fire阻塞器
		m_tBlockFire = nil,
	}
end
---@type EventManager
local public = EventManager

EVENT_LEVEL_NONE = 0
EVENT_LEVEL_LOW = 10000
EVENT_LEVEL_MEDIUM = 20000
EVENT_LEVEL_HIGH = 30000
EVENT_LEVEL_ULTRA = 40000

---注册事件
---@param strEvent 事件名
---@param funCallBack 回调函数or函数名 @回调返回true立即解注册
---@param oBind 绑定的对象 @nil则回调时不带对象
---@param nOrder 优先顺序 @值越大触发回调越优先，默认 EVENT_LEVEL_NONE
---@param bindID 绑定ID 可选 可以指定以某值做ID
---@return number
function public:register(strEvent, funCallBack, oBind, nOrder, bindID)
	if "string" ~= type(strEvent) then
		error("strEvent is not string")
	end
	if "function" ~= type(funCallBack) and "string" ~= type(funCallBack) then
		error("funCallBack is not function or string")
	end
	if not self:_getFun(funCallBack, oBind) then
		error("funCallBack is undefined")
	end
	if nil ~= oBind and "table" ~= type(oBind) then
		if "number" == type(oBind) then
			nOrder = oBind
			oBind = nil
		end
	end
	if "number" ~= type(nOrder) then
		nOrder = EVENT_LEVEL_NONE
	end

	local tab = self.m_tabEvent[strEvent]
	if nil == tab then
		tab = {}
		self.m_tabEvent[strEvent] = tab
	else
		for _, v in ipairs(tab) do
			if v.fun == funCallBack and v.oBind == oBind then
				if v.nOrder ~= nOrder then
					v.nOrder = nOrder
					table.sort(tab, function(a, b)
						return a.nOrder < b.nOrder
					end)
				end
				return v.nID
			end
		end
	end

	local nID
	if bindID then
		nID = bindID
		self:unregisterByID(bindID, strEvent)
	else
		nID = self:_getIncludeID()
	end

	table.insert(tab, {
		fun = funCallBack
		, oBind = oBind
		, nOrder = nOrder
		, nID = nID
	})

	table.sort(tab, function(a, b)
		return a.nOrder < b.nOrder
	end)
	return nID
end

---解注册
---@param strEvent 事件名
---@param funCallBack 注册的函数
---@param oBind 绑定的对象
function public:unregister(strEvent, funCallBack, oBind)
	if "string" ~= type(strEvent) then
		error("strEvent is not string")
	end
	if "function" ~= type(funCallBack) and "string" ~= type(funCallBack) then
		error("funCallBack is not function or string")
	end
	funCallBack = self:_getFun(funCallBack, oBind)
	if not funCallBack then
		error("funCallBack is undefined")
	end
	if nil ~= oBind and "table" ~= type(oBind) then
		error("oBind is not table")
	end

	local tab = self.m_tabEvent[strEvent]
	if nil == tab then
		return
	end
	for i, tabInfo in pairs(tab) do
		if funCallBack == self:_getFun(tabInfo.fun, tabInfo.oBind) and oBind == tabInfo.oBind then
			table.remove(tab, i)
			return true
		end
	end
end

---解注册
---@param nID 注册ID
---@param strEvent 事件名 @选填
function public:unregisterByID(nID, strEvent)
	if "string" == type(strEvent) then
		if self.m_tabEvent[strEvent] then
			for i, tabInfo in pairs(self.m_tabEvent[strEvent]) do
				if nID == tabInfo.nID then
					table.remove(self.m_tabEvent[strEvent], i)
					return true
				end
			end
		end
	else
		for _, v in pairs(self.m_tabEvent) do
			for i, tabInfo in pairs(v) do
				if nID == tabInfo.nID then
					table.remove(v, i)
					return true
				end
			end
		end
	end
	return false
end

---解注册（批量）
---@param tID 全部注册ID
function public:unregisterByIDs(tID)
	if "table" == type(tID) then
		for _, v in pairs(tID) do
			self:unregisterByID(v)
		end
	end
end

---触发事件
---@param strEvent 事件名
---@vararg 附带参数
function public:fireEvent(strEvent, ...)
	print("FireEvent==>eventName:",strEvent)
	if nil ~= self.m_tBlockFire then
		table.insert(self.m_tBlockFire, { strEvent, { ... } })
		return
	end

	local tab = self.m_tabEvent[strEvent]
	if nil == tab then
		return
	end

	local event = tab[#tab]

	local arrEvents = {}
	for _, v in ipairs(tab) do
		table.insert(arrEvents, v)
	end

	table.sort(arrEvents, function(a, b) return a.nOrder < b.nOrder end)

	for i = #arrEvents, 1, -1 do
		local event = arrEvents[i];
		local bDel
		if nil == event.fun then
			bDel = true
		else
			local fun = self:_getFun(event.fun, event.oBind)
			if fun then
				bDel = self:_call(fun, event.oBind, ...)
			else
				bDel = true
			end
		end
		if bDel then
			self:unregisterByID(event.id, strEvent)
		end
	end
end
---阻塞Fire
function public:blockFireEvent()
	self.m_tBlockFire = self.m_tBlockFire or {}
end
function public:unblockFireEvent()
	if nil ~= self.m_tBlockFire then
		local t = self.m_tBlockFire
		self.m_tBlockFire = nil
		for _, t2 in ipairs(t) do
			self:fireEvent(t2[1], unpack(t2[2]))
		end
	end
end

---@private
function public:_getIncludeID()
	self.m_nIncludeID = self.m_nIncludeID + 1
	return self.m_nIncludeID
end

---@private
function public:_getFun(fun, oBind)
	if 'function' ~= type(fun) then
		if nil == oBind then
			fun = _G[fun]
		else
			fun = oBind[fun]
		end
	end
	if 'function' == type(fun) then
		return fun
	end
	return false
end

---@private
function public:_call(fun, oBind, ...)
	local bSuccess, result = xpcall(function(...)
		if oBind then
			return fun(oBind, ...)
		else
			return fun(...)
		end
	end, self._err, ...)
	if not bSuccess then
		return false
	end
	return result
end
---@private
function public._err(...)
	debug.traceback(...)
end

return public