if Items == nil then
	Items = class({})
end
local public = Items

-- 检测物品
CHECK_ITEM_RESULT_SUCCESS = 0				-- 成功
CHECK_ITEM_RESULT_FAIL_FALSE_OWNER = 1		-- 失败，非所属
CHECK_ITEM_RESULT_FAIL_UNQUALIFIED = 2		-- 失败，无资格

function public:init(bReload)
	self.ItemsData = {}
	for rarity, list in pairs(KeyValues.ItemsRarityKv) do
		for i, itemName in pairs(list) do
			self.ItemsData[itemName] = {
				rarity = tonumber(rarity),
			}
		end
	end

	local public_warehouse = Entities:FindByName(nil, "public_warehouse")
	if public_warehouse then
		local origin = public_warehouse:GetAbsOrigin()
		local angles = public_warehouse:GetAngles()
		local bounds = public_warehouse:GetBounds()
		local vMin = RotatePosition(Vector(0, 0, 0), angles, bounds.Mins)+origin
		local vMax = RotatePosition(Vector(0, 0, 0), angles, bounds.Maxs)+origin

		self.hPublicArea = {
			Vector(vMin.x, vMin.y, 0),
			Vector(vMax.x, vMin.y, 0),
			Vector(vMax.x, vMax.y, 0),
			Vector(vMin.x, vMax.y, 0),
		}
	end

	GameEvent("custom_inventory_contents_changed", Dynamic_Wrap(public, "OnInventoryChanged"), public)
end

function public:GetItemRarity(item)
	if type(item) == "table" then item = item:GetName() end
	if self.ItemsData[item] == nil then return 0 end
	return self.ItemsData[item].rarity
end

function public:GetUnitQualificationLevel(unit)
	return unit.Items_qualificationLevel
end

function public:SetUnitQualificationLevel(unit, iNewLevel)
	local iOldLevel = unit.Items_qualificationLevel or 0
	unit.Items_qualificationLevel = iNewLevel
	if iOldLevel ~= iNewLevel then
		self:FilterAllItems(unit)
	end
end

function public:IsUnitQualified(unit, item)
	if unit.Items_qualificationLevel == nil then return false end
	return unit.Items_qualificationLevel >= self:GetItemRarity(item)
end

function public:CheckItem(unit, item)
	local rarity = self:GetItemRarity(item)
	if type(item) == "string" then
		local unitPlayerID = unit:GetPlayerOwnerID()
		local hero = PlayerResource:GetSelectedHeroEntity(unitPlayerID)

		if hero ~= unit and not self:IsUnitQualified(unit, item) then
			return CHECK_ITEM_RESULT_FAIL_UNQUALIFIED
			-- return CHECK_ITEM_RESULT_SUCCESS
		end
	else
		local unitPlayerID = unit:GetPlayerOwnerID()
		local hero = PlayerResource:GetSelectedHeroEntity(unitPlayerID)

		item:SetCanBeUsedOutOfInventory(true)

		local itemContainer = item:GetContainer()
		if itemContainer ~= nil and IsPointInPolygon(itemContainer:GetAbsOrigin(), self.hPublicArea) then
			item:SetPurchaser(hero)
		end

		local itemName = item:GetName()
		local itemOwner = item:GetPurchaser()
		local itemOwnerPlayerID = itemOwner ~= nil and itemOwner:GetPlayerOwnerID() or -1

		if itemOwnerPlayerID ~= -1
		and itemOwnerPlayerID ~= unitPlayerID
		and itemOwner:IsAlive()
		and not (itemContainer ~= nil and IsPointInPolygon(itemContainer:GetAbsOrigin(), self.hPublicArea)) then
			return CHECK_ITEM_RESULT_FAIL_FALSE_OWNER
			-- return CHECK_ITEM_RESULT_SUCCESS
		-- elseif itemOwnerPlayerID == -1 then
		-- 	if hero ~= nil then
		-- 		item:SetPurchaser(hero)
		-- 	end
		end

		if hero ~= unit and not self:IsUnitQualified(unit, item) then
			return CHECK_ITEM_RESULT_FAIL_UNQUALIFIED
			-- return CHECK_ITEM_RESULT_SUCCESS
		end
	end

	return CHECK_ITEM_RESULT_SUCCESS
end

-- 筛选掉单位身上所有不能装备的物品
function public:FilterAllItems(unit)
	for i = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6, 1 do
		local item = unit:GetItemInSlot(i)
		if item then
			local result = self:CheckItem(unit, item)
			if result == CHECK_ITEM_RESULT_FAIL_FALSE_OWNER then
				ErrorMessage(unit:GetPlayerOwnerID(), "dota_hud_error_can_not_take_others_own_item")

				DropItemAroundUnit(unit, item)
			elseif result == CHECK_ITEM_RESULT_FAIL_UNQUALIFIED then
				ErrorMessage(unit:GetPlayerOwnerID(), "dota_hud_error_unqualified_unit")

				DropItemAroundUnit(unit, item)
			end
		end
	end
end

--[[
	监听
]]--
function public:OnInventoryChanged( events )
	local unit = EntIndexToHScript(events.EntityIndex)
	if unit:IsIllusion() or unit:IsTempestDouble() then return end
	if PlayerResource == nil then return end
	self:FilterAllItems(unit)
end

return public