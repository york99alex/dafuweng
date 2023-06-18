require("Ability/LuaAbility")
LinkLuaModifier("modifier_LuaAbility_undying_tombstone", "Ability/undying/LuaAbility_undying_tombstone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_LuaAbility_undying_tombstone_buff", "Ability/undying/LuaAbility_undying_tombstone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_LuaAbility_undying_tombstone_thinker", "Ability/undying/LuaAbility_undying_tombstone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_LuaAbility_undying_tombstone_zombie", "Ability/undying/LuaAbility_undying_tombstone.lua", LUA_MODIFIER_MOTION_NONE)

if LuaAbility_undying_tombstone == nil then
    LuaAbility_undying_tombstone = class({}, nil, LuaAbility)
end
function LuaAbility_undying_tombstone:GetIntrinsicModifierName()
    return "modifier_LuaAbility_undying_tombstone"
end
function LuaAbility_undying_tombstone:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("radius")
end

modifier_LuaAbility_undying_tombstone = class({})
function modifier_LuaAbility_undying_tombstone:IsDebuff()
    return false
end
function modifier_LuaAbility_undying_tombstone:IsHidden()
    return true
end
function modifier_LuaAbility_undying_tombstone:IsPaused()
    return false
end
function modifier_LuaAbility_undying_tombstone:OnCreated(table)
    if not IsServer() then
        return
    end
    Timers:CreateTimer(0, function()
        if not IsValid(self) or not IsValid(self:GetParent()) then
            return
        end
        self.hPlayer = PlayerManager:getPlayer(self:GetParent():GetPlayerOwnerID())

        local mPath = self:GetParent().m_path
        if mPath and IsValid(self:GetParent()) and mPath.bIsStomstone then
            AbilityManager:setCopyBuff('modifier_LuaAbility_undying_tombstone_buff', self:GetParent(), self.hPlayer.m_eHero, self:GetAbility())
            AbilityManager:setCopyBuff('modifier_LuaAbility_undying_tombstone_thinker', self:GetParent(), self.hPlayer.m_eHero, self:GetAbility())
        end

        self.evtid = EventManager:register('Event_GCLDEnd', function(data)
            if not IsValid(self) or not IsValid(self:GetParent()) then
                return true
            end
            self.hPlayer = PlayerManager:getPlayer(self:GetParent():GetPlayerOwnerID())
            local hParent = self:GetParent()

            if data.path.m_tabENPC[1] == hParent then
                local bIsTomstone = hParent:HasModifier("modifier_LuaAbility_undying_tombstone_buff")

                if data.bWin and (not bIsTomstone) then
                    data.bSwap = false

                    data.path.bIsStomstone = true
                    hParent:ModifyHealth(hParent:GetMaxHealth(), nil, false, 0)

                    AbilityManager:setCopyBuff('modifier_LuaAbility_undying_tombstone_buff', hParent, self.hPlayer.m_eHero, self:GetAbility())
                    AbilityManager:setCopyBuff('modifier_LuaAbility_undying_tombstone_thinker', hParent, self.hPlayer.m_eHero, self:GetAbility())
                else
                    data.path.bIsStomstone = false
                end
            end
        end)
    end)
end
function modifier_LuaAbility_undying_tombstone:OnDestroy()
    if IsServer() and self.evtid then
        EventManager:unregisterByID(self.evtid, "Event_GCLDEnd")
    end
end

modifier_LuaAbility_undying_tombstone_buff = class({})
function modifier_LuaAbility_undying_tombstone_buff:IsDebuff()
    return false
end
function modifier_LuaAbility_undying_tombstone_buff:IsHidden()
    return true
end
function modifier_LuaAbility_undying_tombstone_buff:IsPaused()
    return false
end
function modifier_LuaAbility_undying_tombstone_buff:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_DISARMED] = true
    }
end
function modifier_LuaAbility_undying_tombstone_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE,
    }
end
function modifier_LuaAbility_undying_tombstone_buff:GetModifierModelChange()
    return "models/heroes/undying/undying_tower.vmdl"
end

modifier_LuaAbility_undying_tombstone_thinker = class({})
function modifier_LuaAbility_undying_tombstone_thinker:IsDebuff()
    return false
end
function modifier_LuaAbility_undying_tombstone_thinker:IsHidden()
    return true
end
function modifier_LuaAbility_undying_tombstone_thinker:IsPurgable()
    return false
end
function modifier_LuaAbility_undying_tombstone_thinker:OnCreated(p)
    if not IsServer() then
        return
    end

    Timers:CreateTimer(0, function()
        if not IsValid(self) then
            return
        end

        local hAbility = self:GetParent():FindAbilityByName("LuaAbility_undying_tombstone")
        if not hAbility then
            return
        end

        self.tEvtIDs = {}
        self.tZombies = {}
        self.hPath = PathManager:getPathByBZEntity(self:GetParent())
        self.hPlayer = PlayerManager:getPlayer(self.hPath.m_nOwnerID)
        self.fRadius = hAbility:GetSpecialValueFor("radius")
        local interval = hAbility:GetSpecialValueFor("zombie_interval")

        local evtid = EventManager:register("Event_Move", function(data)
            if self.bIsGCLD then
                return
            end
            if data.entity ~= self.hPlayer.m_eHero then
                self.hTarget = data.entity
                self:StartIntervalThink(interval)
            end
        end)
        table.insert(self.tEvtIDs, evtid)

        evtid = EventManager:register("Event_GCLD", function(data)
            if exist(data.path.m_tabENPC, self:GetParent()) then
                self.bIsGCLD = true
                self.hTarget = data.entity
                self:StartIntervalThink(interval)
            end
        end)
        table.insert(self.tEvtIDs, evtid)

        evtid = EventManager:register("Event_MoveEnd", function(data)
            if data.entity == self.hTarget then
                self.hTarget = nil
                self:StartIntervalThink(-1)

                for k, hZombie in pairs(self.tZombies) do
                    hZombie:ForceKill(false)
                end

                self.tZombies = {}
            end
        end)
        table.insert(self.tEvtIDs, evtid)

        evtid = EventManager:register("Event_GCLDEnd", function(data)
            if exist(data.path.m_tabENPC, self:GetParent()) then
                self.bIsGCLD = nil
                self.hTarget = nil
                self:StartIntervalThink(-1)

                for k, hZombie in pairs(self.tZombies) do
                    hZombie:ForceKill(false)
                end

                self.tZombies = {}
            end
        end)
        table.insert(self.tEvtIDs, evtid)
    end)
end
function modifier_LuaAbility_undying_tombstone_thinker:OnDestroy()
    if IsServer() then
        if self.tZombies and #self.tZombies > 0 then
            for k, hZombie in pairs(self.tZombies) do
                hZombie:ForceKill(false)
            end
        end
        self.hTarget = nil
        self.bIsGCLD = nil
        self.tZombies = nil
        EventManager:unregisterByIDs(self.tEvtIDs)
        self.tEvtIDs = nil
    end
end
function modifier_LuaAbility_undying_tombstone_thinker:OnIntervalThink()
    if not IsServer() then
        return
    end
    if 0 < bit.band(PS_InPrison, self.hPlayer.m_typeState) then
        for k, hZombie in pairs(self.tZombies) do
            hZombie:ForceKill(false)
        end
        self.tZombies = {}
        return
    end
    if self.hTarget == nil then
        return
    end

    if not self:GetParent():IsPositionInRange(self.hTarget:GetOrigin(), self.fRadius) then
        return
    end

    local hAbility = self:GetParent():FindAbilityByName("LuaAbility_undying_tombstone")
    if not hAbility then
        return
    end

    local hZombie = CreateUnitByName(
    "npc_dota_unit_undying_zombie",
    self.hTarget:GetOrigin() + RandomVector(50),
    true,
    self.hPlayer.m_eHero,
    self.hPlayer.m_eHero,
    self:GetParent():GetTeamNumber()
    )
    if hZombie then
        hZombie:SetOwner(self.hPlayer.m_eHero)
        hZombie.m_bBZ = true

        if self.bIsGCLD then
            hZombie.m_bGCLD = true
        end

        hZombie:AddNewModifier(self:GetCaster(), hAbility, "modifier_LuaAbility_undying_tombstone_zombie", {})

        if hZombie:HasAbility("undying_tombstone_zombie_deathstrike") then
            hZombie:RemoveAbility("undying_tombstone_zombie_deathstrike")
        end

        if not hZombie:HasAbility("LuaAbility_undying_tombstone_zombie_deathstrike") then
            local hAbilityDeathstrike = hZombie:AddAbility("LuaAbility_undying_tombstone_zombie_deathstrike")
            hAbilityDeathstrike:SetLevel(hAbility:GetLevel())
        end

        hZombie:SetForceAttackTarget(self.hTarget)

        table.insert(self.tZombies, hZombie)
    end
end

modifier_LuaAbility_undying_tombstone_zombie = class({})
function modifier_LuaAbility_undying_tombstone_zombie:IsHidden()
    return true
end
function modifier_LuaAbility_undying_tombstone_zombie:IsPurgable()
    return false
end
function modifier_LuaAbility_undying_tombstone_zombie:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }
end