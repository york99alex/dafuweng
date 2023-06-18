-- 分割字符串
function string.split(str, delimiter)
	if str == nil or str == '' or delimiter == nil then
		return nil
	end

	local result = {}
	for match in (str..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match)
	end
	return result
end

-- 分割字符串的字母
function string.gsplit(str)
	local str_tb = {}
	if string.len(str) ~= 0 then
		for i=1,string.len(str) do
			new_str= string.sub(str,i,i)			
			if (string.byte(new_str) >=48 and string.byte(new_str) <=57) or (string.byte(new_str)>=65 and string.byte(new_str)<=90) or (string.byte(new_str)>=97 and string.byte(new_str)<=122) then
				table.insert(str_tb,string.sub(str,i,i))				
			else
				return nil
			end
		end
		return str_tb
	else
		return nil
	end
end

-- 返回表的值数量
function TableCount( t )
	local n = 0
	for _ in pairs( t ) do
		n = n + 1
	end
	return n
end

-- 获取表里随机一个值
function RandomValue( t )
	local iRandom = RandomInt(1, TableCount(t))
	local n = 0
	for k, v in pairs( t ) do
		n = n + 1
		if n == iRandom then
			return v
		end
	end
end

-- 获取数组里随机一个值
function GetRandomElement( table )
	return table[RandomInt(1, #table)]
end

-- 从表里寻找值的键
function TableFindKey( t, v )
	if t == nil then
		return nil
	end

	for _k, _v in pairs( t ) do
		if v == _v then
			return _k
		end
	end
	return nil
end

-- 从表里移除值
function ArrayRemove( t, v )
	for i = #t, 1, -1 do
		if t[i] == v then
			table.remove(t, i)
		end
	end
end

-- 深拷贝
function deepcopy(orig)
	local copy
	if type(orig) == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end

-- 浅拷贝
function shallowcopy(orig)
	local copy
	if type(orig) == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

-- table覆盖
function TableOverride(mainTable, table)
	if mainTable == nil then
		return table
	end
	if table == nil or type(table) ~= "table" then
		return mainTable
	end

	for k, v in pairs( table ) do
		if type(v) == "table" then
			mainTable[k] = TableOverride(mainTable[k], v)
		else
			mainTable[k] = v
		end
	end
	return mainTable
end

-- 四舍五入，s为精度
function Round(n, s)
	local sign = 1
	if n < 0 then
		n = math.abs(n)
		sign = -1
	end
	s = s or 1
	if n ~= nil then
		local d = n/s
		local w = math.floor(d)
		if d - w >= 0.5 then
			return (w+1)*s * sign
		else
			return w*s * sign
		end
	end
	return 0
end

-- 将c++里传出来的str形式的vector转换为vector
function StringToVector(str)
	if str == nil then return end
	local table = string.split(str, " ")
	return Vector(tonumber(table[1]), tonumber(table[2]), tonumber(table[3])) or nil
end

-- 以逆时针方向旋转
function Rotation2D(vVector, radian)
	local fLength2D = vVector:Length2D()
	local vUnitVector2D = vVector / fLength2D
	local fCos = math.cos(radian)
	local fSin = math.sin(radian)
	return Vector(vUnitVector2D.x*fCos-vUnitVector2D.y*fSin, vUnitVector2D.x*fSin+vUnitVector2D.y*fCos, vUnitVector2D.z)*fLength2D
end

-- 判断点是否在不规则图形里（不规则图形里是点集，点集每个都是固定住的）
function IsPointInPolygon(point, polygonPoints)
	local j = #polygonPoints
	local bool = 0
	for i = 1, #polygonPoints, 1 do
		local polygonPoint1 = polygonPoints[j]
		local polygonPoint2 = polygonPoints[i]
		if ((polygonPoint2.y < point.y and polygonPoint1.y >= point.y) or (polygonPoint1.y < point.y and polygonPoint2.y >= point.y)) and (polygonPoint2.x <= point.x or polygonPoint1.x <= point.x) then
			bool = bit.bxor(bool, ((polygonPoint2.x + (point.y-polygonPoint2.y)/(polygonPoint1.y-polygonPoint2.y)*(polygonPoint1.x-polygonPoint2.x)) < point.x and 1 or 0))
		end
		j = i
	end
	return bool == 1
end

-- 控制台打印单位所有的modifier
function PrintAllModifiers(hUnit)
	local modifiers = hUnit:FindAllModifiers()
	for n, modifier in pairs(modifiers) do
		local str = ""
		str = str .. "modifier name: "..modifier:GetName()
		if modifier:GetCaster() ~= nil then
			str = str .. "\tcaster: "..modifier:GetCaster():GetName()
			str = str .. "\t("..tostring(modifier:GetCaster())..")"
		end
		if modifier:GetAbility() ~= nil then
			str = str .. "\tability: "..modifier:GetAbility():GetName()
			str = str .. "\t("..tostring(modifier:GetAbility())..")"
		end
		print(str)
	end
end

-- 显示错误信息
function ErrorMessage(playerID, message, sound)
	if message == nil then
		sound = message
		message = playerID
		playerID = nil
	else
		assert(type(playerID) == "number", "playerID is not a number")
	end
	if playerID == nil then
		CustomGameEventManager:Send_ServerToAllClients("error_message", {message=message,sound=sound})
	else
		local player = PlayerResource:GetPlayer(playerID)
		CustomGameEventManager:Send_ServerToPlayer(player, "error_message", {message=message,sound=sound})
	end
end

function DropItemAroundUnit(unit, item)
	local position = unit:GetAbsOrigin() + Vector(RandomFloat(-50, 50), RandomFloat(-50, 50), 0)
	unit:DropItemAtPositionImmediate(item, position)
end

-- 判断一个handle是否为无效值
function IsValid(h)
	return h ~= nil and not h:IsNull()
end

if IsClient() then
	-- 计时器
	function C_BaseEntity:Timer(sContextName, fInterval, funcThink)
		if funcThink == nil then
			funcThink = fInterval
			fInterval = sContextName
			sContextName = DoUniqueString("Timer")
		end
		self:SetContextThink(sContextName, function()
			return funcThink()
		end, fInterval)
		return sContextName
	end
	-- 游戏计时器
	function C_BaseEntity:GameTimer(sContextName, fInterval, funcThink)
		if funcThink == nil then
			funcThink = fInterval
			fInterval = sContextName
			sContextName = DoUniqueString("GameTimer")
		end
		local fTime = GameRules:GetGameTime() + fInterval
		return self:Timer(sContextName, fInterval, function()
			if GameRules:GetGameTime() >= fTime then
				local result = funcThink()
				if type(result) == "number" then
					fTime = fTime + result
				end
				return result
			end
			return 0
		end)
	end
	-- 暂停计时器
	function C_BaseEntity:StopTimer(sContextName)
		self:SetContextThink(sContextName, nil, 0)
	end
end

if IsServer() then
	--[[
		计时器
		sContextName，计时器索引，可缺省
		fInterval，第一次运行延迟
		funcThink，回调函数，函数返回number将会再次延迟运行
		例：
		hUnit:GameTimer(0.5, function()
			hUnit:SetModelScale(1.5)
		end)
		GameRules:GetGameModeEntity():GameTimer(0.5, function()
			print(math.random())
			return 0.5
		end)
	]]--
	function CBaseEntity:Timer(sContextName, fInterval, funcThink)
		if funcThink == nil then
			funcThink = fInterval
			fInterval = sContextName
			sContextName = DoUniqueString("Timer")
		end
		self:SetContextThink(sContextName, function()
			return funcThink()
		end, fInterval)
		return sContextName
	end
	--[[
		游戏计时器，游戏暂停会停下
	]]--
	function CBaseEntity:GameTimer(sContextName, fInterval, funcThink)
		if funcThink == nil then
			funcThink = fInterval
			fInterval = sContextName
			sContextName = DoUniqueString("GameTimer")
		end
		local fTime = GameRules:GetGameTime() + fInterval
		return self:Timer(sContextName, fInterval, function()
			if GameRules:GetGameTime() >= fTime then
				local result = funcThink()
				if type(result) == "number" then
					fTime = fTime + result
				end
				return result
			end
			return 0
		end)
	end
	--[[
		暂停计时器，包括游戏计时器
	]]--
	function CBaseEntity:StopTimer(sContextName)
		self:SetContextThink(sContextName, nil, 0)
	end

	function CDOTA_BaseNPC:GetItemSlot(hItem)
		if hItem == nil or not hItem:IsItem() then
			return -1
		end
		for i = 0, 14 do
			local item = self:GetItemInSlot(i)
			if item ~= nil and item == hItem then
				return i
			end
		end
		return -1
	end

	function CDOTA_BaseNPC_Creature:ModifyMaxHealth(fChanged)
		local hAbilities = {}
		for i = 0, self:GetAbilityCount()-1, 1 do
			local hAbility = self:GetAbilityByIndex(i)
			if hAbility then
				hAbilities[i] = {
					iLevel = hAbility:GetLevel(),
					bAutoCastState = hAbility:GetAutoCastState(),
					bToggleState = hAbility:GetToggleState(),
				}
				hAbility.bNoRefresh = true
			end
		end

		if self.fBaseManaRegen == nil then
			self.fBaseManaRegen = self:GetManaRegen() - self:GetBonusManaRegen()
		end

		local fManaPercent = self:GetMana()/self:GetMaxMana()
		local fHealthPercent = self:GetHealth()/self:GetMaxHealth()
		self:SetHPGain(fChanged)
		self:CreatureLevelUp(1)
		self:SetHPGain(0)
		self:CreatureLevelUp(-1)
		self:SetBaseManaRegen(self.fBaseManaRegen)
		self:SetHealth(fHealthPercent*self:GetMaxHealth())
		self:SetMana(fManaPercent*self:GetMaxMana())

		for i, tData in pairs(hAbilities) do
			local hAbility = self:GetAbilityByIndex(i)
			if hAbility then
				hAbility:SetLevel(tData.iLevel)
				if hAbility:GetAutoCastState() ~= tData.bAutoCastState then hAbility:ToggleAutoCast() end
				if hAbility:GetToggleState() ~= tData.bToggleState then hAbility:ToggleAbility() end
	
				if tData.iLevel == 0 then
					self:RemoveModifierByName(hAbility:GetIntrinsicModifierName() or "")
				end

				hAbility.bNoRefresh = false
			end
		end
	end
	function CDOTA_BaseNPC_Creature:SetMaxHealth(fNewMaxHealth)
		self:ModifyMaxHealth(fNewMaxHealth - self:GetMaxHealth())
	end

	function CDOTA_BaseNPC_Creature:ModifyMaxMana(fChanged)
		local hAbilities = {}
		for i = 0, self:GetAbilityCount()-1, 1 do
			local hAbility = self:GetAbilityByIndex(i)
			if hAbility then
				hAbilities[i] = {
					iLevel = hAbility:GetLevel(),
					bAutoCastState = hAbility:GetAutoCastState(),
					bToggleState = hAbility:GetToggleState(),
				}
				hAbility.bNoRefresh = true
			end
		end

		if self.fBaseManaRegen == nil then
			self.fBaseManaRegen = self:GetManaRegen() - self:GetBonusManaRegen()
		end

		local fManaPercent = self:GetMana()/self:GetMaxMana()
		local fHealthPercent = self:GetHealth()/self:GetMaxHealth()
		self:SetManaGain(fChanged)
		self:CreatureLevelUp(1)
		self:SetManaGain(0)
		self:CreatureLevelUp(-1)
		self:SetBaseManaRegen(self.fBaseManaRegen)
		self:SetHealth(fHealthPercent*self:GetMaxHealth())
		self:SetMana(fManaPercent*self:GetMaxMana())

		for i, tData in pairs(hAbilities) do
			local hAbility = self:GetAbilityByIndex(i)
			if hAbility then
				hAbility:SetLevel(tData.iLevel)
				if hAbility:GetAutoCastState() ~= tData.bAutoCastState then hAbility:ToggleAutoCast() end
				if hAbility:GetToggleState() ~= tData.bToggleState then hAbility:ToggleAbility() end
	
				if tData.iLevel == 0 then
					self:RemoveModifierByName(hAbility:GetIntrinsicModifierName() or "")
				end

				hAbility.bNoRefresh = false
			end
		end
	end
	function CDOTA_BaseNPC_Creature:SetMaxMana(fNewMaxMana)
		self:ModifyMaxMana(fNewMaxMana - self:GetMaxMana())
	end
end

Hashtables = Hashtables or {}
function CreateHashtable()
	local new_hastable = {}
	local index = 1
	while Hashtables[index] ~= nil do
		index = index + 1
	end
	Hashtables[index] = new_hastable
	return new_hastable
end
function RemoveHashtable(hastable)
	local index
	if type(hastable) == "number" then
		index = hastable
	else
		index = GetHashtableIndex(hastable) or 0
	end
	Hashtables[index] = nil
end
function GetHashtableIndex(hastable)
	for index, h in pairs(Hashtables) do
		if h == hastable then
			return index
		end
	end
	return nil
end
function GetHashtableByIndex(index)
	return Hashtables[index]
end
function HashtableCount()
	local n = 0
	for index, h in pairs(Hashtables) do
		n = n + 1
	end
	return n
end