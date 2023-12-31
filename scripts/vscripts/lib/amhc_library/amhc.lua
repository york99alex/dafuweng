
----------------------
-- 作者：裸奔的代码
-- 参与者：
-- 创建日期：2015/6/11
-- 修改日期：2015/6/11
----------------------

if AMHC == nil then
	AMHC = class({})
end

--初始化
function AMHCInit()

require("lib/amhc_library/KV")

--------------------
--这里定义私有变量--
--------------------

--颜色
local __msg_type = {}
local __color = {
	red 	={255,0,0},
	orange	={255,127,0},
	yellow	={255,255,0},
	green 	={0,255,0},
	blue 	={0,0,255},
	indigo 	={0,255,255},
	purple 	={255,0,255},
}

--------------------------
--从这里开始定义成员函数--
--------------------------
--====================================================================================================
--判断实体有效，存活，非存活于一体的函数
--返回true	有效且存活
--返回false	有效但非存活
--返回nil	无效实体
function AMHC:IsAlive( entity )
	if type(entity)~="table" then
		error("AMHC:IsAlive param 0: not entity",2);
	end

	if IsValidEntity(entity) then
		if entity:IsAlive() then
			return true
		end
		return false
	end
	return nil
end
--====================================================================================================


--====================================================================================================
--创建计时器

function AMHC:Timer( name,fun,delay,entity )
	if type(name)~="string" then
		error("AMHC:Timer param 0: not String",2);
	end
	if type(fun)~="function" then
		error("AMHC:Timer param 1: not function",2);
	end

	delay = delay or 0
	if type(delay)~="number" then
		error("AMHC:Timer param 2: not number",2);
	end

	local ent = nil;
	if(entity ~= nil)then
		if type(entity)~="table" then
			error("AMHC:Timer param 3: not entity",2);
		end
		if self:IsAlive(entity)==nil then
			error("AMHC:Timer param 3: not valid entity",2);
		end
		ent = entity;
	else
		ent = GameRules:GetGameModeEntity();
	end

	local time = GameRules:GetGameTime()
	ent:SetContextThink(DoUniqueString(name),function( )

		if GameRules:GetGameTime()-time >= delay then
			ent:SetContextThink(DoUniqueString(name),function( )

				if not GameRules:IsGamePaused() then
					return fun();
				end

				return 0.01
			end,0)
			return nil
		end

		return 0.01
	end,0)
		
end

--便于实体直接调用
function CBaseEntity:Timer(fun,delay)
	if type(fun)~="function" then
		error("CBaseEntity:Timer param 0: not function",2);
	end

	delay = delay or 0
	if type(delay)~="number" then
		error("CBaseEntity:Timer param 1: not number",2);
	end
	AMHC:Timer( self:GetClassname()..tostring(RandomInt(1,10000)),fun,delay,self )
end

--====================================================================================================


--====================================================================================================
--创建带有计时器的特效，计时器结束删除特效，并有一个callback函数
function AMHC:CreateParticle(particleName,particleAttach,immediately,owningEntity,duration,callback)
	if type(particleName)~="string" then
		error("AMHC:CreateParticle param 0: not string",2);
	end
	if type(particleAttach)~="number" then
		error("AMHC:CreateParticle param 1: not number",2);
	end
	if type(immediately)~="boolean" then
		error("AMHC:CreateParticle param 2: not boolean",2);
	end
	if type(owningEntity)~="table" then
		error("AMHC:CreateParticle :param 3 is not handle",2);
		if self:IsAlive(owningEntity)==nil then
			error("AMHC:CreateParticle param 3: not valid entity",2);
		end
	end
	if callback~=nil then
		if type(callback)~="function" then
			error("AMHC:CreateParticle param 5: is not function",2);
		end
	end
	
	local p = ParticleManager:CreateParticle(particleName,particleAttach,owningEntity)

	if type(duration)=="number" then
		local time = GameRules:GetGameTime();
		self:Timer(particleName,function()
			if (GameRules:GetGameTime()-time)>=duration then
				ParticleManager:DestroyParticle(p,immediately)
				if callback~=nil then callback() end
				return nil
			end

			return 0.01
		end,0)
	end

	return p
end

--创建带有计时器的特效，只对某玩家显示，计时器结束删除特效，并有一个callback函数
function AMHC:CreateParticleForPlayer(particleName,particleAttach,immediately,owningEntity,owningPlayer,duration,callback)
	if type(particleName)~="string" then
		error("AMHC:CreateParticleForPlayer param 0: not string",2);
	end
	if type(particleAttach)~="number" then
		error("AMHC:CreateParticleForPlayer param 1: not number",2);
	end
	if type(immediately)~="boolean" then
		error("AMHC:CreateParticleForPlayer param 2: not boolean",2);
	end
	if type(owningEntity)~="table" then
		error("AMHC:CreateParticleForPlayer param 3: not handle",2);
		if self:IsAlive(owningEntity)==nil then
			error("AMHC:CreateParticleForPlayer param 3: not valid entity",2);
		end
	end
	if type(owningPlayer)~="table" then
		error("AMHC:CreateParticleForPlayer param 4: not handle",2);
	end
	if type(duration)~="number" then
		error("AMHC:CreateParticleForPlayer param 5: not number",2);
	end
	if callback~=nil then
		if type(callback)~="function" then
			error("AMHC:CreateParticleForPlayer param 6: not function",2);
		end
	end
	
	local p = ParticleManager:CreateParticleForPlayer(particleName,particleAttach,owningEntity,owningPlayer)

	local time = GameRules:GetGameTime();
	self:Timer(particleName,function()
		if (GameRules:GetGameTime()-time)>=duration then
			ParticleManager:DestroyParticle(p,immediately)
			if callback~=nil then callback() end
			return nil
		end

		return 0.01
	end,0)

	return p
end
--====================================================================================================


--====================================================================================================
--定义常量
AMHC.MSG_BLOCK 		= "particles/msg_fx/msg_block.vpcf"
AMHC.MSG_ORIT 		= "particles/msg_fx/msg_crit.vpcf"
AMHC.MSG_DAMAGE 	= "particles/msg_fx/msg_damage.vpcf"
AMHC.MSG_EVADE 		= "particles/msg_fx/msg_evade.vpcf"
AMHC.MSG_GOLD 		= "particles/msg_fx/msg_gold.vpcf"
AMHC.MSG_HEAL 		= "particles/msg_fx/msg_heal.vpcf"
AMHC.MSG_MANA_ADD 	= "particles/msg_fx/msg_mana_add.vpcf"
AMHC.MSG_MANA_LOSS 	= "particles/msg_fx/msg_mana_loss.vpcf"
AMHC.MSG_MISS 		= "particles/msg_fx/msg_miss.vpcf"
AMHC.MSG_POISION 	= "particles/msg_fx/msg_poison.vpcf"
AMHC.MSG_SPELL 		= "particles/msg_fx/msg_spell.vpcf"
AMHC.MSG_XP 		= "particles/msg_fx/msg_xp.vpcf"

table.insert(__msg_type,AMHC.MSG_BLOCK)
table.insert(__msg_type,AMHC.MSG_ORIT)
table.insert(__msg_type,AMHC.MSG_DAMAGE)
table.insert(__msg_type,AMHC.MSG_EVADE)
table.insert(__msg_type,AMHC.MSG_GOLD)
table.insert(__msg_type,AMHC.MSG_HEAL)
table.insert(__msg_type,AMHC.MSG_MANA_ADD)
table.insert(__msg_type,AMHC.MSG_MANA_LOSS)
table.insert(__msg_type,AMHC.MSG_MISS)
table.insert(__msg_type,AMHC.MSG_POISION)
table.insert(__msg_type,AMHC.MSG_SPELL)
table.insert(__msg_type,AMHC.MSG_XP)

--显示数字特效，可指定颜色，符号
function AMHC:CreateNumberEffect( entity,number,duration,msg_type,color,icon_type )
	if type(entity)~="table" then
		error("AMHC:CreateNumberEffect param 0: not entity",2);
		if self:IsAlive(entity)==nil then
			error("AMHC:CreateNumberEffect :param 0 is not valid entity",2);
		end
	end
	if type(number)~="number" then
		error("AMHC:CreateNumberEffect param 1: not number",2);
	end
	if type(duration)~="number" then
		error("AMHC:CreateNumberEffect param 2: not number",2);
	end
	if type(color)~="table" and type(color)~="string" then
		error("AMHC:CreateNumberEffect param 4: not table or string",2);
	end

	--判断实体
	if self:IsAlive(entity)==nil then
		return
	end

	icon_type = icon_type or 9

	--对采用的特效进行判断
	local is_msg_type = false
	for k,v in pairs(__msg_type) do
		if msg_type == v then
			is_msg_type = true;
			break;
		end
	end

	if not is_msg_type then
		error("AMHC:CreateNumberEffect param 3: not valid msg type;example:AMHC.MSG_GOLD",2);
	end

	--判断颜色
	if type(color)=="string" then
		color = __color[color] or {255,255,255}
	else
		if #color ~=3 then
			error("AMHC:CreateNumberEffect param 4: color error; format example:{255,255,255}",2);
		end
	end
	local color_r = tonumber(color[1]) or 255;
	local color_g = tonumber(color[2]) or 255;
	local color_b = tonumber(color[3]) or 255;
	local color_vec = Vector(color_r,color_g,color_b);

	--处理数字
	number = math.floor(number)
	local number_count = #tostring(number) + 1

	--创建特效
    local particle = AMHC:CreateParticle(msg_type,PATTACH_CUSTOMORIGIN_FOLLOW,false,entity,duration)
    ParticleManager:SetParticleControlEnt(particle,0,entity,5,"attach_hitloc",entity:GetOrigin(),true)
    ParticleManager:SetParticleControl(particle,1,Vector(10,number,icon_type))
    ParticleManager:SetParticleControl(particle,2,Vector(duration,number_count,0))
    ParticleManager:SetParticleControl(particle,3,color_vec)
end

--====================================================================================================


--====================================================================================================
--查找table1中指定的table2
function AMHC:FindTable( src,target )
	if type(src)~="table" and type(target)~="table" then
		error("AMHC:RemoveTable :source or target is not table",2)
	end

	for k,v in pairs(src) do
		if v == target then
			return k,v
		end
	end
	return nil
end

--删除table1中指定的table2
--table1中必须是按照数字进行排列的
function AMHC:RemoveTable( src,target )
	if type(src)~="table" and type(target)~="table" then
		error("AMHC:RemoveTable :source or target is not table",2)
	end

	local k = self:FindTable( src,target )

	if k == nil then
		error("AMHC:RemoveTable :the source table have not target table",2)
	end

	if type(k) ~= "number" then
		error("AMHC:RemoveTable :the source table exist Non-numeric mark's element",2)
	end

	return table.remove(src,k)
end
--====================================================================================================


--====================================================================================================
--创建单位
function AMHC:CreateUnit( unitName,origin,face,owner,teamNumber,callback )
	if type(unitName)~="string" then
		error("AMHC:CreateUnit param 0: not string",2)
	end
	if type(origin)~="userdata" then
		error("AMHC:CreateUnit param 1: not vector",2)
	end
	if type(face)~="userdata" and type(face)~="number" then
		error("AMHC:CreateUnit param 2: not userdata or number",2)
	end
	if owner ~= nil then
		if type(owner)~="table" then
			error("AMHC:CreateUnit param 3: not table",2)
		end
	end
	if type(teamNumber)~="number" then
		error("AMHC:CreateUnit param 4: not number",2)
	end
	if callback ~= nil then
		if type(callback)~="function" then
			error("AMHC:CreateUnit param 5: not function",2)
		end
	end
	
	--创建单位
	local unit = CreateUnitByName(unitName,origin,false,nil,nil,teamNumber)

	if unit then

		--设置单位面朝方向
		if type(face)=="number" then
			unit:SetAngles(0,face,0)
		elseif type(face)=="userdata" then
			unit:SetForwardVector(face)
		end

		--如果有召唤者
		if owner ~= nil then
			unit:SetOwner(owner)
			--unit:SetParent(owner,owner:GetUnitName())
			unit:SetControllableByPlayer(owner:GetPlayerOwnerID(),true)
		end
	end

	--回调函数
	if callback ~= nil then
		callback(unit)
	end

	return unit
end
function AMHC:CreateUnitAsync( unitName,origin,face,owner,teamNumber,callback )
	if type(unitName)~="string" then
		error("AMHC:CreateUnit param 0: not string",2)
	end
	if type(origin)~="userdata" then
		error("AMHC:CreateUnit param 1: not vector",2)
	end
	if type(face)~="userdata" and type(face)~="number" then
		error("AMHC:CreateUnit param 2: not userdata or number",2)
	end
	if owner ~= nil then
		if type(owner)~="table" then
			error("AMHC:CreateUnit param 3: not table",2)
		end
	end
	if type(teamNumber)~="number" then
		error("AMHC:CreateUnit param 4: not number",2)
	end
	if callback ~= nil then
		if type(callback)~="function" then
			error("AMHC:CreateUnit param 5: not function",2)
		end
	end
	
	--创建单位
	CreateUnitByNameAsync(unitName, origin, false, nil,nil, teamNumber, function (unit)
		if unit then
			--设置单位面朝方向
			if type(face)=="number" then
				unit:SetAngles(0,face,0)
			elseif type(face)=="userdata" then
				unit:SetForwardVector(face)
			end
	
			--如果有召唤者
			if owner ~= nil then
				unit:SetOwner(owner)
				--unit:SetParent(owner,owner:GetUnitName())
				unit:SetControllableByPlayer(owner:GetPlayerOwnerID(),true)
			end
		end
	
		--回调函数
		if callback ~= nil then
			callback(unit)
		end
	end)
end

--====================================================================================================


--====================================================================================================
--复活英雄
function AMHC:RespawnHero( hero,origin )
	if type(hero) ~= "table" then
		error("AMHC:RespawnHero param 0: not hero",2)
	end
	if type(origin) ~= "userdata" then
		error("AMHC:RespawnHero param 1: not vector",2)
	end
	if not hero:IsHero() then
		error("AMHC:RespawnHero error: this unit is not hero",2)
	end
	if self:IsAlive(hero)==false then
		hero:RespawnHero(true,true,true)
		hero:SetAbsOrigin(origin)
	end
end
--====================================================================================================


--====================================================================================================
--给予玩家金钱
function AMHC:GivePlayerGold( playerid,gold )
	if type(playerid) ~= "number" then
		error("AMHC:GivePlayerGold param 0: not number",2)
	end
	if type(gold) ~= "number" then
		error("AMHC:GivePlayerGold param 1: not number",2)
	end

	local player = PlayerResource:GetPlayer(playerid)

	if player then
		local hero = player:GetAssignedHero()

		if hero then
			hero:EmitSoundParams("General.Sell",200,200,1)
			PlayerResource:SetGold(playerid,PlayerResource:GetReliableGold(playerid) + gold,true)
			self:CreateNumberEffect( hero,gold,1,self.MSG_GOLD,"yellow",0 )
		end
	end
end
--====================================================================================================


--====================================================================================================
--伤害API简化
--AMHC:Damage( attacker,victim,damage,damageType,[percent] )
--@attacker 伤害来源
--@victim 受害者
--@damage 伤害
--@damageType 伤害类型
--@ability 伤害技能
--@percent 可选参数，伤害的比例
function AMHC:Damage( attacker,victim,damage,damageType,ability,scale,tData)
	if type(attacker) ~= "table" then
		error("AMHC:Damage param 0: not handle",2)
	end
	if type(victim) ~= "table" then
		error("AMHC:Damage param 1: not handle",2)
	end
	if type(damage) ~= "number" then
		error("AMHC:Damage param 2: not number",2)
	end
	if type(damageType) ~= "number" then
		error("AMHC:Damage param 3: not number",2)
	end
	if ability ~= nil then
		if type(ability) ~= "table" then
			error("AMHC:ability param 4: not table",2)
		end
	end
	if scale ~= nil then
		if type(scale) ~= "number" then
			error("AMHC:Damage param 5: not number",2)
		end
	end
	if tData ~= nil then
		if type(tData) ~= "table" then
			error("AMHC:Damage param 6: not table",2)
		end
	end

	if self:IsAlive(attacker)~=true or self:IsAlive(victim)~=true then
		return nil
	end

	scale = scale or 1

	if scale<0 then
		scale = 1
	end

	local damageTable = {
		victim = victim,
		attacker = attacker,
		damage = (damage * scale),
		damage_type = damageType,
		ability = ability
	}
	
	local tEntID = EventManager:register('Event_Atk',function (tEvent)
		if ability then
			tEvent.ability = ability
		end
		if tData then
			for k, v in pairs(tData) do
				tEvent[k] = v
			end
		end
	end,nil,997654321)
	ApplyDamage(damageTable)
	EventManager:unregisterByID(tEntID,'Event_Atk')
end

--提供一个便利的接口
function CDOTA_BaseNPC:Damage( victim,damage,damageType,ability,scale )
	AMHC:Damage( self,victim,damage,damageType,ability,scale )
end
--====================================================================================================


--====================================================================================================
--模型增大，并在一段时间内恢复原样
--@unit 单位
--@scale 增加比例,在1.0和5.0之间
--@duration 持续时间
function AMHC:AddModelScale( unit,scale,duration )
	if type(unit) ~= "table" then
		error("AMHC:AddModelScale param 0: not handle",2)
	end
	if type(scale) ~= "number" then
		error("AMHC:AddModelScale param 1: not number",2)
	end
	if type(duration) ~= "number" then
		error("AMHC:AddModelScale param 2: not number",2)
	end

	if scale<1.0 and scale>5.0 then
		return
	end

	if self:IsAlive(unit)~=true then
		return
	end

	if unit._amhc_AddModelScale_first == nil then
		unit._amhc_AddModelScale_first = true
		unit._amhc_AddModelScale_min_scale = unit:GetModelScale()
	end

	local unit_scale = unit:GetModelScale()
	local maxScale = unit_scale*scale
	local speed = 0.2
	local time = GameRules:GetGameTime()
	local _add = unit_scale

	local deah = function()
		if AMHC:IsAlive(unit) ~= true then
			return false
		end
		return true
	end

	AMHC:Timer("AddModelScale",function( )--逐渐增大模型

		if not deah() then
			unit:SetModelScale(unit._amhc_AddModelScale_min_scale)
			return nil
		end

		if _add <= maxScale then
			_add = _add + speed
			unit:SetModelScale(_add)
		else
			AMHC:Timer("AddModelScale",function()--持续时间内

				if not deah() then
					unit:SetModelScale(unit._amhc_AddModelScale_min_scale)
					return nil
				end
				
				if GameRules:GetGameTime()-time>=duration then

					AMHC:Timer("AddModelScale",function()--逐渐减小模型

						if not deah() then
							unit:SetModelScale(unit._amhc_AddModelScale_min_scale)
							return nil
						end

						if _add > unit._amhc_AddModelScale_min_scale then
							_add = _add - speed
							unit:SetModelScale(_add)
						else
							return nil
						end
						
						return 0.01
					end,0)

					return nil
				end

				return 0.01
			end,0)

			return nil
		end

		return 0.01
	end,0)
end

--====================================================================================================


--====================================================================================================
--增加或减少modifier数量
function AMHC:AddOrLowModifierCount( caster,ability,modifierName,_type,count )
	if type(ability) ~= "table" then
		error("AMHC:AddOrLowModifierCount param 0: not handle",2)
	end
	if type(modifierName) ~= "string" then
		error("AMHC:AddOrLowModifierCount param 1: not string",2)
	end
	if type(_type) ~= "string" then
		error("AMHC:AddOrLowModifierCount param 2: not string",2)
	end
	if type(count) ~= "number" then
		error("AMHC:AddOrLowModifierCount param 3: not number",2)
	end
end
--====================================================================================================


--====================================================================================================
--移动镜头
function AMHC:SetCamera( playerid,entity )
	if type(playerid) ~= "number" then
		error("AMHC:SetCamera param 0: not number",2)
	end
	if type(entity) ~= "table" then
		error("AMHC:SetCamera param 1: not handle",2)
	end
	PlayerResource:SetCameraTarget(playerid,entity)
	self:Timer("SetCamera",function( )
		print("SetCamera")
		PlayerResource:SetCameraTarget(playerid,nil)
		return nil
	end,0.01)
end
--====================================================================================================


--====================================================================================================
--通用方法之添加技能
function AMHC:AddAbilityAndSetLevel(u,a,l)
	if l == nil then
		l = 1
	end
	if u == nil or u:IsNull() == true then
		return
	end

	local oAblt
	if u:FindAbilityByName(a) == nil then
		oAblt = u:AddAbility(a)
		if u:FindAbilityByName(a) ~= nil then
			u:FindAbilityByName(a):SetLevel(l)
		end
	else
		oAblt = u:FindAbilityByName(a)
		oAblt:SetLevel(l)
	end
	return oAblt
end
function AMHC:RemoveAbilityAndModifier(u,a)
	if u == nil or u:IsNull() == true then
		return false
	end
	if u:FindAbilityByName(a) ~= nil then
		u:RemoveAbility(a)

		local strBuff = 'modifier_'..a
		local tabBuff = u:FindAllModifiers()
		for _, v in pairs(tabBuff) do
			if nil ~= string.find( v:GetName(),strBuff) then
				u:RemoveModifierByName(v:GetName())
			end
		end
		return true
	end
	return false
end
--====================================================================================================


--====================================================================================================
--收集多个单位的装备
function AMHC:GetAllItemsInUnits(units)
	--收集棋子的物品
	local items_table = {}
	for _,v in pairs(units) do
		if v ~= nil then
			for slot=0,8 do
				if v:GetItemInSlot(slot)~= nil then
					table.insert(items_table,v:GetItemInSlot(slot))
				end
			end
		end
	end
	return items_table
end
function AMHC:GetAllItemsNameInUnits(units)
	--收集棋子的物品
	local items_table = {}
	for _,v in pairs(units) do
		if v ~= nil then
			for slot=0,8 do
				if v:GetItemInSlot(slot)~= nil then
					table.insert(items_table,v:GetItemInSlot(slot):GetAbilityName())
				end
			end
		end
	end
	return items_table
end
--把装备给单位
function AMHC:GiveItems2UnitByName(items,unit)
	for _,v in pairs(items) do
		unit:AddItemByName(v)
	end
end
--把装备给单位
function AMHC:GiveOldItems2Unit(items,unit)
	for _,v in pairs(items) do
		unit:AddItem(v)
	end
end
--====================================================================================================


--====================================================================================================
--星星特效
function AMHC:ShowStarsOnUnit(unit, nCount, duration)
    if duration == nil then
        duration = 5
	end
	
	AMHC:AddAbilityAndSetLevel(unit,"no_bar")

    -- if cost > 5 then
    --     play_particle('effect/arrow/ssr/star1.vpcf', PATTACH_OVERHEAD_FOLLOW, unit, duration)
	-- end
	AMHC:CreateParticle('effect/arrow/' .. nCount + 2 .. '/star' .. nCount .. '.vpcf'
    , PATTACH_OVERHEAD_FOLLOW, false, unit, duration, function ()
		AMHC:RemoveAbilityAndModifier(unit,"no_bar")
	end)
end
--====================================================================================================

--创建幻象
--====================================================================================================
--
--@param 实体
--@param 持续时间 nil=无限
--@param 攻击伤害百分百
--@param 受到伤害百分百
--@return 幻象实体
function AMHC:CreateIllusion(eUnit,nDuration,nOutgoingDamage,nIncomingDamage)
	local eIllusion = AMHC:CreateUnit(eUnit:GetUnitName(),eUnit:GetAbsOrigin()
	,eUnit:GetForwardVector(),eUnit,eUnit:GetTeam())
	eIllusion:MakeIllusion()
	eIllusion:SetDeathXP(0)
	eIllusion:AddNewModifier(eIllusion, nil, "modifier_illusion", { 
		duration = nDuration
		, outgoing_damage = nOutgoingDamage
		, incoming_damage = nIncomingDamage
		--, DestroyOnExpire  = true
	})

	
	--同步等级
	if eIllusion:IsHero() then
		eUnit:HeroLevelUp(true)
		for i = eUnit:GetLevel(), 2, -1  do
			eIllusion:HeroLevelUp(false)
		end
	else
		eIllusion:CreatureLevelUp(eUnit:GetLevel())
	end
	--同步技能
	for i = 0, 23 do
        local oAblt = eUnit:GetAbilityByIndex(i)
		if nil ~= oAblt then
			AMHC:AddAbilityAndSetLevel(eIllusion,oAblt:GetAbilityName(),oAblt:GetLevel())
        end
	end
	--同步装备
	for i = 0, 8 do
		local oItme = eUnit:GetItemInSlot(i)
        if  nil ~= oItme then
            eIllusion:AddItemByName(oItme:GetAbilityName())
        end
    end

	return eIllusion
end
--====================================================================================================


--====================================================================================================
--停止播放音效，两个接口，一个KV一个lua

--伤害系统
--触发器
--位移运动
--椭圆运动
--抛物运动
--同步技能等级
--增加或者减少modifier的数字
--弹射函数
--恢复生命值
--净化

--====================================================================================================
end


function prt(t)
    GameRules:SendCustomMessage(''..t,0,0)
end

--高级选取单位，适应所有team
function FindUnitsInRadiusByTeam(keys)
	local team = keys.team
	local role = keys.role or 1 --1=队友,2=敌人,3=全部
	local radius = keys.radius or 500
	local position = keys.position or Vector(0,0,0)
	local units = {}

	local all_units = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		Vector(0,0,0),
		nil,
		9999,
		DOTA_UNIT_TARGET_TEAM_BOTH,  --用BOTH可以选到所有team的单位
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false)

	for u,v in pairs(all_units) do
		if (v:GetAbsOrigin() - position):Length2D() <= radius then
			if role == 1 and v:GetTeam() == team then
				table.insert(units,v)
			end
			if role == 2 and v:GetTeam() ~= team then
				table.insert(units,v)
			end
			if role == 3 then
				table.insert(units,v)
			end
		end
	end

	return units
end

--触发感叹号点击动作
function fireMouseAction_symbol(vPos,hPlayer,bLocal)
	local nID
	if bLocal then
		EmitSoundOnClient("General.Ping", hPlayer)
		nID= AMHC:CreateParticleForPlayer("particles/ui_mouseactions/ping_world_hero_level.vpcf"
		,PATTACH_ABSORIGIN, false, hPlayer:GetAssignedHero(),hPlayer, 3)
	else
		EmitSoundOnLocationForAllies(vPos,"General.Ping", hPlayer)
		nID= AMHC:CreateParticle("particles/ui_mouseactions/ping_world_hero_level.vpcf"
		,PATTACH_ABSORIGIN, false, hPlayer:GetAssignedHero(), 3)
	end
	
	ParticleManager:SetParticleControl(nID, 0, vPos)
	ParticleManager:SetParticleControl(nID, 1, Vector(255,255,255))
	ParticleManager:SetParticleControl(nID, 12, Vector(0,0,0))
end