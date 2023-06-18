require("Ability/zuus/LuaAbility_zuus_thundergods_wrath")
if PrecacheItems then
    table.insert(PrecacheItems, "particles/units/heroes/hero_zuus/zeus_loadout.vpcf")
    table.insert(PrecacheItems, "particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf")
    table.insert(PrecacheItems, "particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf")
end

----卡牌基类
if nil == Card_HERO_ZUUS_thundergods_wrath then
    -----@class Card_HERO_ZUUS_thundergods_wrath : Card 雷神之怒
    Card_HERO_ZUUS_thundergods_wrath = class({}, nil, Card)
end

----构造函数
function Card_HERO_ZUUS_thundergods_wrath:constructor(tInfo, nPlayerID)
    Card_HERO_ZUUS_thundergods_wrath.__base__.constructor(self, tInfo, nPlayerID)
    self.m_typeCast = TCardCast_Nil
    self.m_tabAbltInfo = KeyValues.AbilitiesKv["LuaAbility_zuus_thundergods_wrath"]
    self.m_nManaCost = tonumber(self.m_tabAbltInfo["AbilityManaCost"])
    self.m_nManaCostBase = self.m_nManaCost
end

----返回伤害类型
function Card_HERO_ZUUS_thundergods_wrath:GetAbilityDamageType()
    return load("return " .. self.m_tabAbltInfo["AbilityUnitDamageType"])()
end

----
----选择无目标时
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function Card_HERO_ZUUS_thundergods_wrath:CastFilterResult()

    if not self:CanUseCard() then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

----卡牌释放
function Card_HERO_ZUUS_thundergods_wrath:OnSpellStart()
    -----@type hero
    local eCaster = self:GetCaster()
    local oOwner = self:GetOwner()

    EmitGlobalSound("Hero_Zuus.GodsWrath.PreCast")
    local nHeroPtlID1 = AMHC:CreateParticle("particles/units/heroes/hero_zuus/zeus_loadout.vpcf", PATTACH_CENTER_FOLLOW, true, eCaster, 3)

    Timers:CreateTimer(0.3, function()
        ----抬手动作
        local nAnmt = _G[self.m_tabAbltInfo["AbilityCastAnimation"]]
        eCaster:StartGesture(nAnmt)

        Timers:CreateTimer(self.m_tabAbltInfo["AbilityCastPoint"], function()

            EmitGlobalSound("Hero_Zuus.GodsWrath.Target")
            local nHeroPtlID2 = AMHC:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_CENTER_FOLLOW, false, eCaster, 3)
            ParticleManager:SetParticleControl(nHeroPtlID2, 0, eCaster:EyePosition())
            ParticleManager:SetParticleControl(nHeroPtlID2, 1, eCaster:EyePosition())

            for k, player in pairs(PlayerManager.m_tabPlayers) do
                if player ~= oOwner and PlayerManager:isAlivePlayer(player.m_nPlayerID) then
                    ----目标技能免疫
                    if 0 == bit.band(PS_AbilityImmune, player.m_typeState) then
                        self:play(player.m_eHero)
                        for _, bz in pairs(player.m_tabBz) do
                            self:play(bz)
                        end
                    end
                end
            end
        end)
    end)
end

function Card_HERO_ZUUS_thundergods_wrath:play(entity)
    local nPtl = AMHC:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf", PATTACH_POINT, false, entity, 1)
    local ori = entity:GetAbsOrigin()
    local upOri = Vector(0, 0, 1000) + ori
    ParticleManager:SetParticleControl(nPtl, 0, ori)
    ParticleManager:SetParticleControl(nPtl, 1, upOri)
    ----造成伤害
    AMHC:Damage(self:GetCaster(), entity, self:GetSpecialValueFor("damage"), self:GetAbilityDamageType(), self)
end