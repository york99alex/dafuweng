if EliteBonus== nil then
	EliteBonus= class({})
end
local public = EliteBonus

function public:init(bReload)
	if not bReload then
	end

	GameEvent("entity_killed", Dynamic_Wrap(public, "OnEntityKilled"), public)
	-- GameEvent("custom_round_changed", Dynamic_Wrap(public, "OnRoundChanged"), public)
	GameEvent("custom_elite_spawned", Dynamic_Wrap(public, "OnEliteSpawned"), public)

	self:UpdateNetTables()
end

function public:UpdateNetTables(events)

end

function public:OnEntityKilled( events )
	local hVictim = EntIndexToHScript(events.entindex_killed or -1)
	local hAttacker = EntIndexToHScript(events.entindex_attacker or -1)
	local iPlayerID = hAttacker ~= nil and hAttacker:GetPlayerOwnerID() or -1

	if IsValid(hAttacker) and IsValid(hVictim) and hVictim.EliteBonus_sItemName ~= nil then
		local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
		local hItem = CreateItem(hVictim.EliteBonus_sItemName, nil, hHero)
		if IsValid(hItem) then
			hItem:SetPurchaseTime(0)

			local vHitLoc = hVictim:GetAttachmentOrigin(hVictim:ScriptLookupAttachment("attach_hitloc"))

			local hItemPhysical = CreateItemOnPositionSync(vHitLoc, hItem)

			hItem:LaunchLootInitialHeight(false, vHitLoc.z, vHitLoc.z+200, 1.0, GetGroundPosition(hVictim:GetAbsOrigin(), hVictim))
		end
		hVictim.EliteBonus_sItemName = nil
	end
end

-- 精英怪诞生事件
function public:OnEliteSpawned(events)
	local hElite = EntIndexToHScript(events.iEntityIndex or -1)
	local iRound = events.iRound or -1
	local iPlayerID = events.iPlayerID or -1

	if IsValid(hElite) and iRound ~= -1 and PlayerResource:IsValidPlayerID(iPlayerID) then
		local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
		if IsValid(hHero) and PRD(hHero, WAVE_ELITE_DROP_CHANCE, "elite_drop_item") then
			local sReservoir
			if iRound > 0 and iRound <= 12 then
				sReservoir = "elite_bonus_1"
			elseif iRound > 12 and iRound <= 24 then
				sReservoir = "elite_bonus_2"
			elseif iRound > 24 and iRound <= 36 then
				sReservoir = "elite_bonus_3"
			elseif iRound > 36 and iRound <= 48 then
				sReservoir = "elite_bonus_4"
			elseif iRound > 48 and iRound <= 66 then
				sReservoir = "elite_bonus_5"
			end

			if sReservoir ~= nil then
				local sItemName = DotaTD:DrawReservoir(sReservoir)
				hElite.EliteBonus_sItemName = sItemName
			end
		end
	end
end

return public