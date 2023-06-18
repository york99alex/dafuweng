local eventsTable = {}

-- 注册事件
function Event( event, func )
	eventsTable[event] = func
end

-- 触发服务器事件
function ServerEvent( event, PlayerID, data )
	local t = {}
	t.event = event
	t.PlayerID = PlayerID
	t._IsServer = true
	t.data = json.encode(data)
	EventHandleFunc(t)
end
_G["ServerEvent"] = ServerEvent

EventHandleFunc = function ( hData )
	local player = PlayerResource:GetPlayer(hData.PlayerID)
	if player == nil then return end

	local func = eventsTable[hData.event]
	if func == nil then return end

	local data = json.decode(hData.data)
	if data == nil then return end

	coroutine.wrap(function ()
		data.PlayerID = hData.PlayerID
		local result = func(data)
		if hData._IsServer ~= true and type(result) == "table" then
			CustomGameEventManager:Send_ServerToPlayer( player, "service_events_res", {
				result=json.encode(result), queueIndex=hData.queueIndex} )
		end
	end)()
end

-- 事件
CustomGameEventManager:RegisterListener( "service_events_req", function ( e, hData )
	EventHandleFunc(hData)
end)