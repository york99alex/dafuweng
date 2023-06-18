if RestrictionAbility == nil then
	RestrictionAbility = class({})
end
local public = RestrictionAbility

function public:init(bReload)
	GameEvent("custom_unit_ability_added", Dynamic_Wrap(public, "OnAbilityAdded"), public)
end

function public:OnAbilityAdded( events )
	local unit = EntIndexToHScript(events.entityIndex)
	local ability = EntIndexToHScript(events.abilityIndex)

	if ability.InitRestriction then
		ability:InitRestriction()
	end
end

return public