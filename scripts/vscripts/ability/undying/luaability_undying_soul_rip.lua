require("Ability/LuaAbility")

if LuaAbility_undying_soul_rip == nil then
    LuaAbility_undying_soul_rip = class({}, nil, LuaAbility)
end
function LuaAbility_undying_soul_rip:isCanCastSelf()
    return true
end
function LuaAbility_undying_soul_rip:isCanCastBZ()
    return true
end
function LuaAbility_undying_soul_rip:isCanCastMonster()
    return false
end
function LuaAbility_undying_soul_rip:CastFilterResultTarget(hTarget)
    if not self:isCanCast(hTarget) then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end
function LuaAbility_undying_soul_rip:OnSpellStart()
    if not IsServer() then
        return
    end
    print("debug on spell start")
    local hTarget = self:GetCursorTarget()
    local hCaster = self:GetCaster()

    local bIsFriend = hCaster == hTarget
    local hPlayer = PlayerManager:getPlayer(hCaster:GetPlayerOwnerID())
    for _, hBZ in pairs(hPlayer.m_tabBz) do
        if hBZ == hTarget then
            bIsFriend = true
            break
        end
    end

    local bIsTombstone = hTarget:IsOther() and string.find(hTarget:GetUnitName(), "npc_dota_unit_tombstone") ~= nil

    local iDamage = self:GetSpecialValueFor("damage_per_unit")
    local iDamageCount = 0
    local sParticleName = bIsFriend
    and "particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf"
    or "particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf"

    local tEnemies = FindUnitsInRadius(
    hCaster:GetTeamNumber(),
    hCaster:GetOrigin(),
    nil,
    9999,
    DOTA_UNIT_TARGET_TEAM_BOTH,
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
    FIND_ANY_ORDER,
    false
    )

    for _, hUnit in pairs(tEnemies) do
        if hUnit ~= hTarget then
            iDamageCount = iDamageCount + 1

            local iParticle = ParticleManager:CreateParticle(sParticleName, PATTACH_POINT_FOLLOW, hTarget)
            ParticleManager:SetParticleControlEnt(iParticle, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(iParticle, 1, hUnit, PATTACH_POINT_FOLLOW, "attach_hitloc", hUnit:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(iParticle)

            AMHC:Damage(hCaster, hUnit, iDamage, self:GetAbilityDamageType(), self, 1, {
                bIgnoreDamageSelf = true
            })
        end
    end

    -- for _, hPlayer in pairs(PlayerManager.m_tabPlayers) do
    --     if hPlayer.m_eHero ~= hTarget then
    --         iDamageCount = iDamageCount + 1
    --         AMHC:Damage(hCaster, hPlayer.m_eHero, iDamage, self:GetAbilityDamageType(), self, 1, {
    --             bIgnoreDamageSelf = true
    --         })
    --         local iParticle = ParticleManager:CreateParticle(sParticleName, PATTACH_POINT_FOLLOW, hTarget)
    --         ParticleManager:SetParticleControlEnt(iParticle, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
    --         ParticleManager:SetParticleControlEnt(iParticle, 1, hPlayer.m_eHero, PATTACH_POINT_FOLLOW, "attach_hitloc", hPlayer.m_eHero:GetAbsOrigin(), true)
    --         ParticleManager:ReleaseParticleIndex(iParticle)
    --     end
    --     for _, hBZ in pairs(hPlayer.m_tabBz) do
    --         if hBZ ~= hTarget then
    --             iDamageCount = iDamageCount + 1
    --             AMHC:Damage(hCaster, hBZ, iDamage, self:GetAbilityDamageType(), self, 1, {
    --                 bIgnoreDamageSelf = true
    --             })
    --             local iParticle = ParticleManager:CreateParticle(sParticleName, PATTACH_POINT_FOLLOW, hTarget)
    --             ParticleManager:SetParticleControlEnt(iParticle, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
    --             ParticleManager:SetParticleControlEnt(iParticle, 1, hBZ, PATTACH_POINT_FOLLOW, "attach_hitloc", hBZ:GetAbsOrigin(), true)
    --             ParticleManager:ReleaseParticleIndex(iParticle)
    --         end
    --     end
    -- end
    local fAmount = iDamage * iDamageCount

    if bIsFriend then
        if bIsTombstone then
            hTarget:Heal(fAmount, hCaster)
            SendOverheadEventMessage(hTarget:GetPlayerOwner(), OVERHEAD_ALERT_HEAL, hTarget, fAmount, hCaster:GetPlayerOwner())
        else
            hTarget:Heal(fAmount, hCaster)
            SendOverheadEventMessage(hTarget:GetPlayerOwner(), OVERHEAD_ALERT_HEAL, hTarget, fAmount, hCaster:GetPlayerOwner())
        end
    else
        if not bIsTombstone then
            AMHC:Damage(hCaster, hTarget, fAmount, self:GetAbilityDamageType(), self)
        end
    end

    EmitSoundOn("Hero_Undying.SoulRip.Cast", hCaster)

    ----触发耗蓝
    EventManager:fireEvent("Event_HeroManaChange", { player = hPlayer, oAblt = self })
    ----设置冷却
    AbilityManager:setRoundCD(hPlayer, self)
end