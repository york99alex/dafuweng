if Notification == nil then
	Notification = class({})
end
local public = Notification

function public:init(bReload)
	if not bReload then
	end

	self:UpdateNetTables()
end
function public:UpdateNetTables()
end
--[[
	表填写内如
	{
		message -> 必填，词条名称
		player_id -> 选填，会将词条内的{s:player_name}替换为此玩家ID的玩家名字
		player_id2 -> 选填，会将词条内的{s:player_name2}替换为此玩家ID的玩家名字
		teamnumber -> 选填，将会根据本地玩家与队伍的关系改变颜色
		int_* -> 整数类型，"*"为任意名字，会将词条内的{d:int_*}替换为该数值
		string_* -> 字符串类型，"*"为任意名字，会将词条内的{s:string_*}替换为该数值
	}
]]--

function public:Upper(tParams)
	CustomGameEventManager:Send_ServerToAllClients("notification_upper", tParams)
end

function public:Combat(tParams)
	CustomGameEventManager:Send_ServerToAllClients("notification_combat", tParams)
end

function public:CombatToPlayer(iPlayerID, tParams)
	local hPlayer = PlayerResource:GetPlayer(iPlayerID)
	if hPlayer then
		CustomGameEventManager:Send_ServerToPlayer(hPlayer, "notification_combat", tParams)
	end
end

return public