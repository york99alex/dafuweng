if Mechanics == nil then
	Mechanics = class({})
end
local public = Mechanics

local mechanics = {
	require("mechanics/spawner"),
	require("mechanics/attribute"),
	require("mechanics/build_system"),
	require("mechanics/game_mode"),
	require("mechanics/items"),
	require("mechanics/ability_events"),
	require("mechanics/restriction_ability"),
	require("mechanics/draw"),
	require("mechanics/player_data"),
	require("mechanics/elite_bonus"),
	require("mechanics/crystal_shop"),
	require("mechanics/notification"),
	require("mechanics/asset_modifiers"),
}

local classes = {
	require("class/building"),
}

function public:init(bReload)
	-- 初始化类
	for k, v in pairs(classes) do
		_G[k] = v
		if v.init ~= nil then v.init(bReload) end
	end

	-- 初始化系统
	for k, v in pairs(mechanics) do
		_G[k] = v
		if v.init ~= nil then v:init(bReload) end
	end
end

return public