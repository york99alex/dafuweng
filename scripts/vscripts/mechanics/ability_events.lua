if AbilityEvents == nil then
	AbilityEvents = class({})
end
local public = AbilityEvents

function public:init(bReload)
	GameEvent("custom_npc_first_spawned", Dynamic_Wrap(public, "OnNPCFirstSpawned"), public)
	GameEvent("custom_unit_ability_added", Dynamic_Wrap(public, "OnAbilityAdded"), public)
end

function public:OnNPCFirstSpawned( events )
	local spawnedUnit = EntIndexToHScript( events.entindex )

	if IsValid(spawnedUnit) then
		spawnedUnit:AddAbility("ability_events")
	end
end
function public:OnAbilityAdded( events )
	local unit = EntIndexToHScript(events.entityIndex)
	local ability = EntIndexToHScript(events.abilityIndex)

	if ability.CreateSoldiers then
		ability:CreateSoldiers()
	end
	if ability.OnInit then
		ability:OnInit()
	end
end

return public