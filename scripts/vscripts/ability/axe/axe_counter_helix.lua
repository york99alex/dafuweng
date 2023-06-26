----技能：反击螺旋    英雄：斧王
function onAblt_axe_counter_helix(keys)
    local oPlayer = PlayerManager:getPlayerByHeroName("npc_dota_hero_axe")
    local oAblt = keys.ability
    if not oAblt:IsCooldownReady() then
        return
    end
    local nLevel = oAblt:GetLevel()
    local nAblt = oPlayer.m_eHero:GetAbilityByIndex(1)
    local trigger_chances = {15,20,25}
    local nChance = trigger_chances[nLevel]
    local oRandomInt = RandomInt(1, 100)
    if oRandomInt > nChance then
        --概率不足,结束
        return
    end
    --概率成功
    --[[d         Function: onAblt_axe_counter_helix
                ScriptFile: scripts/vscripts/Ability/axe/axe_counter_helix.lua
                ability:
                        __self: userdata: 0x002209c0
                attacker:
                        __self: userdata: 0x00271338
                caster:
                        GiveMana: function: 0x00275e20
                        SetMana: function: 0x00275f30
                        SpendMana: function: 0x00275db8
                        __recorder__:
                                mana: 18
                        __recorder__modified_data__:
                                mana: 0
                        __self: userdata: 0x00217368
                caster_entindex: 897
                target: table: 0x00217328
    ]]
    oAblt:StartCooldown(oAblt:GetCooldown(oAblt:GetLevel() - 1))
    EmitSoundOn("Hero_Axe.CounterHelix", keys.caster)
    keys.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_3)
    keys.caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
    ----获取范围中的敌人
    local nRadius = 300
    local tab
    if keys.caster:IsHero() then
        ----英雄
        local oPlayer = PlayerManager:getPlayer(keys.caster:GetPlayerOwnerID())
        if oPlayer then
            if 0 < bit.band(PS_AtkMonster, oPlayer.m_typeState) then
                ----打野只伤害野怪
                tab = FindUnitsInRadius(
                    DOTA_TEAM_NEUTRALS,
                    keys.caster:GetAbsOrigin(),
                    nil,
                    nRadius,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            elseif 0 < bit.band(PS_AtkHero, oPlayer.m_typeState) then
                ----攻城只伤害攻城兵卒,和攻击者
                if oPlayer.m_pathCur.m_tabENPC then
                    tab = { keys.attacker }
                    for _, v in pairs(oPlayer.m_pathCur.m_tabENPC) do
                        if keys.attacker ~= v then
                            table.insert(tab, v)
                        end
                    end
                end
            else
                ----伤害范围内的兵卒
                tab = FindUnitsInRadius(
                    DOTA_TEAM_BADGUYS,
                    keys.caster:GetAbsOrigin(),
                    nil,
                    nRadius,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
                for k, v in pairs(tab) do
                    if v:IsHero() then
                        tab[k] = nil
                    end
                end
            end
        end
    else
        ----兵卒仅伤害攻击者
        tab = { keys.attacker }
    end

    ----伤害
    local nDamage = 140
    if tab then
        for _, v in pairs(tab) do
            if v and not v:IsNull() and v:IsAlive() then
                AMHC:Damage(keys.caster, v, nDamage, oAblt:GetAbilityDamageType(), oAblt)
            end
        end
    end
end
