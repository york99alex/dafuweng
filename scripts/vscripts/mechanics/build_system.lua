GRID_ALPHA = 30 -- Defines the transparency of the ghost squares (Panorama)
MODEL_ALPHA = 75 -- Defines the transparency of both the ghost model (Panorama) and Building Placed (Lua)
RECOLOR_GHOST_MODEL = true -- Whether to recolor the ghost model green/red or not
RECOLOR_BUILDING_PLACED = true -- Whether to recolor the queue of buildings placed (Lua)
BUILDING_SIZE = 2
BUILDING_ANGLE = -90

if BuildSystem == nil then
	BuildSystem = class({})
end

local public = BuildSystem

function public:init(bReload)
	if not bReload then
		self.hBlockers = {}

		self.cardBuildingInfo = {}

		DotaTD:EachCard(function(rarity, cardName, abilityName)
			local ghostName = ((KeyValues.UnitsKv[cardName] ~= nil and KeyValues.UnitsKv[cardName] ~= "") and KeyValues.UnitsKv[cardName].GhostModelUnitName or cardName) or cardName
			local unit = CreateUnitByName(ghostName, Vector(11000, 11000, 0), false, nil, nil, DOTA_TEAM_NOTEAM)
			unit:SetAngles(0, BUILDING_ANGLE, 0)
			self.cardBuildingInfo[cardName] = {
				rarity = rarity,
				ability_name = abilityName,
				entindex = unit:entindex(),
				size = BUILDING_SIZE,
				scale = unit:GetModelScale(),
				grid_alpha = GRID_ALPHA,
				model_alpha = MODEL_ALPHA,
				recolor_ghost = RECOLOR_GHOST_MODEL,
				attack_range = KeyValues.UnitsKv[cardName] ~= nil and (KeyValues.UnitsKv[cardName].AttackRange or 0) or 0,
			}
			unit:AddNoDraw()

			for i = 0, unit:GetAbilityCount()-1, 1 do
				local ability = unit:GetAbilityByIndex(i)
				if ability then
					ability:RemoveSelf()
				end
			end
		end)
		CustomNetTables:SetTableValue("common", "card_building_info", self.cardBuildingInfo)

		-- 禁止建造区域
		local building_disabled = Entities:FindAllByName("building_disabled")
		for k,v in pairs(building_disabled) do
			local origin = v:GetAbsOrigin()
			local angles = v:GetAngles()
			local bounds = v:GetBounds()
			local vMin = RotatePosition(Vector(0, 0, 0), angles, bounds.Mins)+origin
			local vMax = RotatePosition(Vector(0, 0, 0), angles, bounds.Maxs)+origin

			self:CreateBlocker({
				Vector(vMin.x, vMin.y, 0),
				Vector(vMax.x, vMin.y, 0),
				Vector(vMax.x, vMax.y, 0),
				Vector(vMin.x, vMax.y, 0),
			}, v)
		end

		self.tPlayerBuildings = {}
	end

	-- for hBuilding, iPlayerID in BuildSystem:BuildingIterator() do
	-- 	print(hBuilding, iPlayerID)
	-- end

	CustomUIEvent("UpgradeBuilding", Dynamic_Wrap(public, "OnUpgradeBuilding"), public)

	GameEvent("game_rules_state_change", Dynamic_Wrap(public, "OnGameRulesStateChange"), public)
	GameEvent("entity_killed", Dynamic_Wrap(public, "OnUnitKilled"), public)
	GameEvent("player_reconnected", Dynamic_Wrap(public, "OnPlayerReconnected"), public)

	self:UpdateNetTables()
end

function public:UpdateNetTables()
	CustomNetTables:SetTableValue("common", "player_buildings", self.tPlayerBuildings)
end

function public:IsBuilding(unit)
	return IsValid(unit) and unit.GetBuilding ~= nil
end

function public:PlaceBuilding(hero, name, location, angle)
	local playerID = hero:GetPlayerOwnerID()

	if KeyValues.UnitsKv[name] ~= nil and KeyValues.UnitsKv[name].UnitLabel == "HERO" then
		if #self.tPlayerBuildings[playerID].hero.list >= self.tPlayerBuildings[playerID].hero.max then
			ErrorMessage(hero:GetPlayerOwnerID(), "dota_hud_error_building_limit_reached")
			return false
		end
		local bHasSameHero = false
		self:EachHeroBuilding(playerID, function(hBuilding)
			if hBuilding:GetUnitEntityName() == name then
				bHasSameHero = true
				return true
			end
		end)
		if bHasSameHero then
			ErrorMessage(hero:GetPlayerOwnerID(), "dota_hud_error_has_same_hero")
			return false
		end
	else
		if #self.tPlayerBuildings[playerID].nonhero.list >= self.tPlayerBuildings[playerID].nonhero.max then
			ErrorMessage(hero:GetPlayerOwnerID(), "dota_hud_error_building_limit_reached")
			return false
		end
	end

	angle = angle or BUILDING_ANGLE
	local building = NewBuilding(name, location, angle, hero)

	if building:IsHero() then
		FireGameEvent("custom_update_player_building", {
			iPlayerID = playerID,
			iUnitEntIndex = building:GetUnitEntityIndex(),
			bIsHero = 1,
			bIsRemove = 0,
		})
		table.insert(self.tPlayerBuildings[playerID].hero.list, building:GetUnitEntityIndex())
	else
		FireGameEvent("custom_update_player_building", {
			iPlayerID = playerID,
			iUnitEntIndex = building:GetUnitEntityIndex(),
			bIsHero = 0,
			bIsRemove = 0,
		})
		table.insert(self.tPlayerBuildings[playerID].nonhero.list, building:GetUnitEntityIndex())
	end

	self:UpdateNetTables()

	if not hero:IsAlive() then
		self:RemoveBuilding(building)
	end

	return building
end

function public:MoveBuilding( building, location )
	if not self:IsBuilding(building) then
		return
	else
		building = building:GetBuilding()
	end

	return building:Move(location)
end

function public:SellBuilding( building, fGoldReturn )
	if not self:IsBuilding(building) then
		print(1)
		return
	else
		building = building:GetBuilding()
	end

	fGoldReturn = fGoldReturn or 0.5

	local iGoldCost = building:GetGoldCost()
	local iGoldReturn = math.floor(iGoldCost*fGoldReturn)
	local hOwner = building:GetOwner()
	local hBuilding = building:GetUnitEntity()

	hOwner:ModifyGold(iGoldReturn, false, DOTA_ModifyGold_Unspecified)

	SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, hBuilding, iGoldReturn, nil)

	local particleID = ParticleManager:CreateParticle("particles/items_fx/item_sheepstick.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(particleID, 0, hBuilding:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particleID)
	
	EmitSoundOnLocationWithCaster(hBuilding:GetAbsOrigin(), "DOTA_Item.Sheepstick.Activate", hOwner)

	self:RemoveBuilding(building:GetUnitEntity())

	return iGoldReturn
end

function public:RemoveBuilding( building )
	if not self:IsBuilding(building) then
		return
	else
		building = building:GetBuilding()
	end

	local playerID = building:GetPlayerOwnerID()
	if building:IsHero() then
		FireGameEvent("custom_update_player_building", {
			iPlayerID = playerID,
			iUnitEntIndex = building:GetUnitEntityIndex(),
			bIsHero = 1,
			bIsRemove = 1,
		})
		ArrayRemove(self.tPlayerBuildings[playerID].hero.list, building:GetUnitEntityIndex())
	else
		FireGameEvent("custom_update_player_building", {
			iPlayerID = playerID,
			iUnitEntIndex = building:GetUnitEntityIndex(),
			bIsHero = 0,
			bIsRemove = 1,
		})
		ArrayRemove(self.tPlayerBuildings[playerID].nonhero.list, building:GetUnitEntityIndex())
	end

	building:RemoveSelf()

	self:UpdateNetTables()
end

function public:ReplaceBuilding( building, sName )
	if not self:IsBuilding(building) then
		return
	else
		building = building:GetBuilding()
	end

	local playerID = building:GetPlayerOwnerID()

	if building:IsHero() then
		FireGameEvent("custom_update_player_building", {
			iPlayerID = playerID,
			iUnitEntIndex = building:GetUnitEntityIndex(),
			bIsHero = 1,
			bIsRemove = 1,
		})
		ArrayRemove(self.tPlayerBuildings[playerID].hero.list, building:GetUnitEntityIndex())
	else
		FireGameEvent("custom_update_player_building", {
			iPlayerID = playerID,
			iUnitEntIndex = building:GetUnitEntityIndex(),
			bIsHero = 0,
			bIsRemove = 1,
		})
		ArrayRemove(self.tPlayerBuildings[playerID].nonhero.list, building:GetUnitEntityIndex())
	end

	local hUnit = building:Replace(sName)

	if building:IsHero() then
		FireGameEvent("custom_update_player_building", {
			iPlayerID = playerID,
			iUnitEntIndex = building:GetUnitEntityIndex(),
			bIsHero = 1,
			bIsRemove = 0,
		})
		table.insert(self.tPlayerBuildings[playerID].hero.list, building:GetUnitEntityIndex())
	else
		FireGameEvent("custom_update_player_building", {
			iPlayerID = playerID,
			iUnitEntIndex = building:GetUnitEntityIndex(),
			bIsHero = 0,
			bIsRemove = 0,
		})
		table.insert(self.tPlayerBuildings[playerID].nonhero.list, building:GetUnitEntityIndex())
	end

	self:UpdateNetTables()

	return hUnit
end

function public:UpgradeBuilding( building, upgradeAgent )
	if not self:IsBuilding(building) then
		return
	else
		building = building:GetBuilding()
	end

	if not building:CanUpgrade() then
		return false
	end
	local xp = 0
	if self:IsBuilding(upgradeAgent) then
		building:GetUnitEntity():EmitSound("Hero_DoomBringer.DevourCast")
		upgradeAgent:EmitSound("Hero_DoomBringer.Devour")

		local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_devour.vpcf", PATTACH_CUSTOMORIGIN, building:GetUnitEntity())
		ParticleManager:SetParticleControlEnt(particleID, 0, upgradeAgent, PATTACH_POINT_FOLLOW, "attach_hitloc", upgradeAgent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particleID, 1, building:GetUnitEntity(), PATTACH_POINT_FOLLOW, "attach_hitloc", building:GetUnitEntity():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particleID)

		upgradeAgent = upgradeAgent:GetBuilding()
		xp = upgradeAgent:GetCurrentXP() + (upgradeAgent:GetUnitEntityName() == "t35" and 2 or 1)
		self:RemoveBuilding(upgradeAgent:GetUnitEntity())
	elseif upgradeAgent.IsItem ~= nil and upgradeAgent:IsItem() then
		building:GetUnitEntity():EmitSound("Item.TomeOfKnowledge")
		xp = 1
		upgradeAgent:RemoveSelf()
	end
	building:AddXP(xp)

	self:UpdateNetTables()
end

function public:ValidPosition(size, location)
	local halfSide = (size/2)*64 - 1
	local leftBorderX = location.x-halfSide
	local rightBorderX = location.x+halfSide
	local topBorderY = location.y+halfSide
	local bottomBorderY = location.y-halfSide

	-- 已建造区域检测
	for blockerEntIndex, blocker in pairs(self.hBlockers) do
		if IsPointInPolygon(location, blocker.polygon) or
		IsPointInPolygon(Vector(leftBorderX, bottomBorderY, 0), blocker.polygon) or
		IsPointInPolygon(Vector(rightBorderX, bottomBorderY, 0), blocker.polygon) or
		IsPointInPolygon(Vector(rightBorderX, topBorderY, 0), blocker.polygon) or
		IsPointInPolygon(Vector(leftBorderX, topBorderY, 0), blocker.polygon) then
			return false
		end
	end

	return true
end

function public:GridNavSquare(size, location)
	SnapToGrid(size, location)

	local halfSide = (size/2)*64

	return {
		Vector(location.x-halfSide, location.y-halfSide, 0),
		Vector(location.x+halfSide, location.y-halfSide, 0),
		Vector(location.x+halfSide, location.y+halfSide, 0),
		Vector(location.x-halfSide, location.y+halfSide, 0),
	}
end

function public:CreateBlocker(polygon, blocker)
	blocker = blocker or SpawnEntityFromTableSynchronous("info_target", {origin = Vector(0,0,0)})

	blocker.polygon = polygon
	CustomNetTables:SetTableValue("build_blocker", tostring(blocker:entindex()), Polygon2D(polygon))
	self.hBlockers[blocker:entindex()] = blocker

	return blocker
end

function public:RemoveBlocker(blocker)
	CustomNetTables:SetTableValue("build_blocker", tostring(blocker:entindex()), nil)
	self.hBlockers[blocker:entindex()] = nil

	blocker:RemoveSelf()
end

function public:GetBlockerPolygon(blocker)
	return blocker.polygon
end

function public:SetBlockerPolygon(blocker, polygon)
	blocker.polygon = polygon
	CustomNetTables:SetTableValue("build_blocker", tostring(blocker:entindex()), Polygon2D(polygon))
end

-- 未使用功能
function public:BuildingIterator(iPlayerID)
	if iPlayerID == nil then
		local iPlayerID = 0
		local iMaxPlayerID = #self.tPlayerBuildings
		local isHero = true
		local iIndex
		return function()
			while true do
				-- print(1)
				local tData = self.tPlayerBuildings[iPlayerID]
				if tData then
					-- print(2)
					if isHero then
						-- print(3.1)
						iIndex = (iIndex or #tData.hero.list+1) - 1
						if iIndex <= 0 then
							-- print(4.1)
							isHero = false
							iIndex = nil
						else
							-- print(4.2)
							if tData.hero.list[iIndex] then
								-- print(5.1)
								local iUnitEntIndex = tData.hero.list[iIndex]
								local hUnit = EntIndexToHScript(iUnitEntIndex)
								if IsValid(hUnit) and self:IsBuilding(hUnit) then
									local hBuilding = hUnit:GetBuilding()
									return hBuilding, iPlayerID
								end
							else
								break
							end
						end
					else
						-- print(3.2)
						iIndex = (iIndex or #tData.nonhero.list+1) - 1
						if iIndex <= 0 then
							-- print(4.3)
							iPlayerID = iPlayerID + 1
							iIndex = nil
						else
							-- print(4.4)
							if tData.nonhero.list[iIndex] then
								-- print(5.2)
								local iUnitEntIndex = tData.nonhero.list[iIndex]
								local hUnit = EntIndexToHScript(iUnitEntIndex)
								if IsValid(hUnit) and self:IsBuilding(hUnit) then
									local hBuilding = hUnit:GetBuilding()
									return hBuilding, iPlayerID
								end
							else
								break
							end
						end
					end
				else
					break
				end
			end
		end
		-- return function()
		-- 	return hBuilding, iPlayerID
		-- end
	end
end

function public:EachBuilding(iPlayerID, func)
	if iPlayerID == nil then
		for iPlayerID, tData in pairs(self.tPlayerBuildings) do
			for _ = #tData.nonhero.list, 1, -1 do
				local iUnitEntIndex = tData.nonhero.list[_]
				local hUnit = EntIndexToHScript(iUnitEntIndex)
				if IsValid(hUnit) and self:IsBuilding(hUnit) then
					local hBuilding = hUnit:GetBuilding()
					if func(hBuilding, iPlayerID) == true then
						return
					end
				end
			end
			for _ = #tData.hero.list, 1, -1 do
				local iUnitEntIndex = tData.hero.list[_]
				local hUnit = EntIndexToHScript(iUnitEntIndex)
				if IsValid(hUnit) and self:IsBuilding(hUnit) then
					local hBuilding = hUnit:GetBuilding()
					if func(hBuilding, iPlayerID) == true then
						return
					end
				end
			end
		end
	else
		for _ = #self.tPlayerBuildings[iPlayerID].nonhero.list, 1, -1 do
			local iUnitEntIndex = self.tPlayerBuildings[iPlayerID].nonhero.list[_]
			local hUnit = EntIndexToHScript(iUnitEntIndex)
			if IsValid(hUnit) and self:IsBuilding(hUnit) then
				local hBuilding = hUnit:GetBuilding()
				if func(hBuilding, iPlayerID) == true then
					return
				end
			end
		end
		for _ = #self.tPlayerBuildings[iPlayerID].hero.list, 1, -1 do
			local iUnitEntIndex = self.tPlayerBuildings[iPlayerID].hero.list[_]
			local hUnit = EntIndexToHScript(iUnitEntIndex)
			if IsValid(hUnit) and self:IsBuilding(hUnit) then
				local hBuilding = hUnit:GetBuilding()
				if func(hBuilding, iPlayerID) == true then
					return
				end
			end
		end
	end
end

function public:EachHeroBuilding(iPlayerID, func)
	if iPlayerID == nil then
		for iPlayerID, tData in pairs(self.tPlayerBuildings) do
			for _ = #tData.hero.list, 1, -1 do
				local iUnitEntIndex = tData.hero.list[_]
				local hUnit = EntIndexToHScript(iUnitEntIndex)
				if IsValid(hUnit) and self:IsBuilding(hUnit) then
					local hBuilding = hUnit:GetBuilding()
					if func(hBuilding, iPlayerID) == true then
						return
					end
				end
			end
		end
	else
		for _ = #self.tPlayerBuildings[iPlayerID].hero.list, 1, -1 do
			local iUnitEntIndex = self.tPlayerBuildings[iPlayerID].hero.list[_]
			local hUnit = EntIndexToHScript(iUnitEntIndex)
			if IsValid(hUnit) and self:IsBuilding(hUnit) then
				local hBuilding = hUnit:GetBuilding()
				if func(hBuilding, iPlayerID) == true then
					return
				end
			end
		end
	end
end

function public:EachNonheroBuilding(iPlayerID, func)
	if iPlayerID == nil then
		for iPlayerID, tData in pairs(self.tPlayerBuildings) do
			for _ = #tData.nonhero.list, 1, -1 do
				local iUnitEntIndex = tData.nonhero.list[_]
				local hUnit = EntIndexToHScript(iUnitEntIndex)
				if IsValid(hUnit) and self:IsBuilding(hUnit) then
					local hBuilding = hUnit:GetBuilding()
					if func(hBuilding, iPlayerID) == true then
						return
					end
				end
			end
		end
	else
		for _ = #self.tPlayerBuildings[iPlayerID].nonhero.list, 1, -1 do
			local iUnitEntIndex = self.tPlayerBuildings[iPlayerID].nonhero.list[_]
			local hUnit = EntIndexToHScript(iUnitEntIndex)
			if IsValid(hUnit) and self:IsBuilding(hUnit) then
				local hBuilding = hUnit:GetBuilding()
				if func(hBuilding, iPlayerID) == true then
					return
				end
			end
		end
	end
end

--[[
	各个UI事件
]]--
-- 升级建筑
function public:OnUpgradeBuilding( eventSourceIndex, events )
	local playerID = events.PlayerID
	local building = EntIndexToHScript(events.buildingEntIndex)
	if building then
		self:UpgradeBuilding(building)
	end
end

--[[
	监听
]]--
function public:OnGameRulesStateChange()
	local state = GameRules:State_Get()

	if state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		DotaTD:EachPlayer(function(n, playerID)
			self.tPlayerBuildings[playerID] = {
				nonhero = {
					list = {},
					max = NONHERO_BUILDING_MAX_COUNT,
				},
				hero = {
					list = {},
					max = HERO_BUILDING_MAX_COUNT,
				},
			}
		end)

		self:UpdateNetTables()
	end
end
function public:OnUnitKilled( events )
	local unit = EntIndexToHScript(events.entindex_killed)
	local attacker = EntIndexToHScript(events.entindex_attacker)

	-- 玩家死亡
	if unit:IsRealHero() and unit:HasModifier("modifier_builder") then
		local iPlayerID = unit:GetPlayerOwnerID()
		self:EachBuilding(iPlayerID, function(hBuilding)
			self:RemoveBuilding(hBuilding:GetUnitEntity())
		end)
	end
end
function public:OnPlayerReconnected(events)
	local iPlayerID = events.PlayerID

	self:EachBuilding(iPlayerID, function(hBuilding)
		FireGameEvent("custom_update_player_building", {
			iPlayerID = iPlayerID,
			iUnitEntIndex = hBuilding:GetUnitEntityIndex(),
			bIsHero = hBuilding:IsHero() and 1 or 0,
			bIsRemove = 0,
		})
	end)
end

-- Common
function Vector2D(vector)
	return {x=vector.x,y=vector.y}
end

function Polygon2D(polygon)
	local new = {}
	for k,v in pairs(polygon) do
		new[k] = Vector2D(v)
	end
	return new
end

function SnapToGrid( size, location )
	if size % 2 ~= 0 then
		location.x = SnapToGrid32(location.x)
		location.y = SnapToGrid32(location.y)
	else
		location.x = SnapToGrid64(location.x)
		location.y = SnapToGrid64(location.y)
	end
end

function SnapToGrid64(coord)
	return 64*math.floor(0.5+coord/64)
end

function SnapToGrid32(coord)
	return 32+64*math.floor(coord/64)
end

return public