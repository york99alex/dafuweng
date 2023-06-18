require("Ability/LuaAbility")
----技能：古龙形态    英雄：龙骑士
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == LuaAbility_dragon_knight_elder_dragon_form then
    LuaAbility_dragon_knight_elder_dragon_form = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_dragon_knight_elder_dragon_form_bg", "Ability/dragon_knight/LuaAbility_dragon_knight_elder_dragon_form.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_dragon_knight_elder_dragon_form_debuff_0", "Ability/dragon_knight/LuaAbility_dragon_knight_elder_dragon_form.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_dragon_knight_elder_dragon_form_debuff_1", "Ability/dragon_knight/LuaAbility_dragon_knight_elder_dragon_form.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_dragon_knight_elder_dragon_form_debuff_2", "Ability/dragon_knight/LuaAbility_dragon_knight_elder_dragon_form.lua", LUA_MODIFIER_MOTION_NONE)
    if PrecacheItems then
        table.insert(PrecacheItems, "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf")
        table.insert(PrecacheItems, "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf")
        table.insert(PrecacheItems, "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf")
        table.insert(PrecacheItems, "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_blue.vpcf")
        table.insert(PrecacheItems, "models/heroes/dragon_knight/dragon_knight_dragon.vmdl")
    end
end
local this = LuaAbility_dragon_knight_elder_dragon_form
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function this:constructor()
    this.__base__.constructor(self)
end

function this:OnUpgrade()
    -- self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_dragon_knight_elder_dragon_form_bg', {})
end

----选择目标时
function this:CastFilterResult()
    if not self:isCanCast() then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
----能否在其他玩家回合时释放
function this:isCanCastOtherRound()
    return true
end
----能否在监狱时释放
function this:isCanCastInPrison()
    return true
end
----能否在移动时释放
function this:isCanCastMove()
    return not self:GetCaster():IsHero() or GMManager.m_nOrderID ~= self:GetCaster():GetPlayerOwnerID()
end
function this:isCanCastSupply()
    return true
end
----能否在英雄攻击时释放
function this:isCanCastHeroAtk()
    return true
end
----能否在该攻击时释放
function this:isCanCastAtk()
    return false
end
function this:GetIntrinsicModifierName()
    return 'modifier_dragon_knight_elder_dragon_form_bg'
end
----开始技能效果
function this:OnSpellStart()
    local hCaster = self:GetCaster()
    local nLevel = self:GetLevel() - 1
    if not self.m_nSkinID then self.m_nSkinID = -1 end
    self.m_nSkinID = self.m_nSkinID + 1
    if self.m_nSkinID > 2 then
        self.m_nSkinID = -1
    end
    --
    self.m_sModelBase = 'models/heroes/dragon_knight/dragon_knight.vmdl'
    self.m_sModelDragon = 'models/heroes/dragon_knight/dragon_knight_dragon.vmdl'
    local sModel = (0 <= self.m_nSkinID and self.m_sModelDragon or self.m_sModelBase)
    -- hCaster:SetModel(sModel)
    -- hCaster:SetOriginalModel(sModel)
    local typeAtkCap = (0 <= self.m_nSkinID and DOTA_UNIT_CAP_RANGED_ATTACK or DOTA_UNIT_CAP_MELEE_ATTACK)
    hCaster:SetAttackCapability(typeAtkCap)

    CustomNetTables:SetTableValue('common', 'modifier_dragon_knight_elder_dragon_form_bg' .. hCaster:GetEntityIndex(), {
        nLevel = self.m_nSkinID
    })
    hCaster:RemoveModifierByName('modifier_dragon_knight_elder_dragon_form_bg')
    local hBuff = hCaster:AddNewModifier(hCaster, self, 'modifier_dragon_knight_elder_dragon_form_bg', { nLevel = self.m_nSkinID })
    hBuff:SetStackCount(self.m_nSkinID + 1)

    hCaster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
    hCaster:SetSkin(self.m_nSkinID)

    if 0 <= self.m_nSkinID then
        hCaster:EmitSound('Hero_DragonKnight.ElderDragonForm')
    else
        hCaster:EmitSound('Hero_DragonKnight.ElderDragonForm.Revert')
    end
end

if not modifier_dragon_knight_elder_dragon_form_bg then
    modifier_dragon_knight_elder_dragon_form_bg = class({})
end
function modifier_dragon_knight_elder_dragon_form_bg:IsHidden()
    return true
end
function modifier_dragon_knight_elder_dragon_form_bg:OnCreated(kv)
    self.nLevel = -1
    self:OnRefresh(kv)
end
function modifier_dragon_knight_elder_dragon_form_bg:OnRefresh(kv)
    self.magic_resistance_bonus = self:GetAbility():GetSpecialValueFor('magic_resistance_bonus')
    self.armor_bonus = self:GetAbility():GetSpecialValueFor('armor_bonus')
    self.atk_range = self:GetAbility():GetSpecialValueFor('atk_range')

    if IsServer() then
        if kv.nLevel then
            self.nLevel = kv.nLevel
        end
        self.deuff_max_count = self:GetAbility():GetSpecialValueFor('deuff_' .. self.nLevel .. '_max_count')
        self.deuff_duration = self:GetAbility():GetSpecialValueFor('deuff_duration')

        if self.nLevel == 1 then
            self.particlePath = "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf"
        elseif self.nLevel == 2 then
            self.particlePath = "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_blue.vpcf"
        elseif self.nLevel == 0 then
            self.particlePath = "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf"
        end
        if self.particlePath then
            local particleID = ParticleManager:CreateParticle(self.particlePath, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:ReleaseParticleIndex(particleID)
        end
    else
        kv = CustomNetTables:GetTableValue('common', 'modifier_dragon_knight_elder_dragon_form_bg' .. self:GetParent():GetEntityIndex())
        if kv and kv.nLevel then
            self.nLevel = kv.nLevel
        end
    end
end
function modifier_dragon_knight_elder_dragon_form_bg:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        -- MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        -- MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end
function modifier_dragon_knight_elder_dragon_form_bg:OnAttackLanded(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            ----添加攻击附加Debuff
            local hTarget = params.target
            if IsValid(hTarget) then
                if IsValid(self:GetAbility()) and not self:GetAbility():isCanCastAbilityImmune() then
                    local playerTarget = PlayerManager:getPlayer(hTarget:GetPlayerOwnerID())
                    if playerTarget and 0 < bit.band(PS_AbilityImmune, playerTarget.m_typeState) then
                        return
                    end
                end
                local hBuff = hTarget:FindModifierByName('modifier_dragon_knight_elder_dragon_form_debuff_' .. self.nLevel)
                if not IsValid(hBuff) then
                    if 0 == self.nLevel then
                        hTarget:AddNewModifier(params.attacker, self:GetAbility(), 'modifier_dragon_knight_elder_dragon_form_debuff_' .. self.nLevel, { duration = self.deuff_duration })
                    elseif 1 == self.nLevel then
                        hTarget:AddNewModifier(params.attacker, self:GetAbility(), 'modifier_dragon_knight_elder_dragon_form_debuff_' .. self.nLevel, {})
                    elseif 2 == self.nLevel then
                        hTarget:AddNewModifier(params.attacker, self:GetAbility(), 'modifier_dragon_knight_elder_dragon_form_debuff_' .. self.nLevel, { duration = self.deuff_duration })
                    else
                        return
                    end
                else
                    ----存在BUFF加层数
                    -- self:SetStackCount(math.ceil(self:GetRemainingTime()))
                    hTarget:AddNewModifier(params.attacker, self:GetAbility(), hBuff:GetName(), { duration = hBuff:GetDuration() })
                    if 0 >= self.deuff_max_count or hBuff:GetStackCount() < self.deuff_max_count then
                        hBuff:IncrementStackCount()
                    end
                end
            end
        end
    end
end
function modifier_dragon_knight_elder_dragon_form_bg:GetModifierProjectileName(params)
    if self.nLevel == 1 then
        return "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire.vpcf"
    elseif self.nLevel == 2 then
        return "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_frost.vpcf"
    elseif self.nLevel == 0 then
        return "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_corrosive.vpcf"
    end
    return "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_corrosive.vpcf"
end
function modifier_dragon_knight_elder_dragon_form_bg:GetModifierModelChange(params)
    if self.nLevel >= 0 then
        return "models/heroes/dragon_knight/dragon_knight_dragon.vmdl"
    end
    return 'models/heroes/dragon_knight/dragon_knight.vmdl'
end
function modifier_dragon_knight_elder_dragon_form_bg:GetAttackSound(params)
    if self.nLevel == 1 then
        return "Hero_DragonKnight.ElderDragonShoot2.Attack"
    elseif self.nLevel == 2 then
        return "Hero_DragonKnight.ElderDragonShoot3.Attack"
    elseif self.nLevel == 0 then
        return "Hero_DragonKnight.ElderDragonShoot1.Attack"
    end
    return "Hero_DragonKnight.Attack"
end
function modifier_dragon_knight_elder_dragon_form_bg:GetModifierAttackRangeBonus()
    if 0 <= self.nLevel then
        return self.atk_range
    end
    return 0
end
function modifier_dragon_knight_elder_dragon_form_bg:GetModifierPhysicalArmorBonus()
    if 0 <= self.nLevel then
        return 0
    end
    return self.armor_bonus
end
function modifier_dragon_knight_elder_dragon_form_bg:GetModifierMagicalResistanceBonus()
    if 0 <= self.nLevel then
        return 0
    end
    return self.magic_resistance_bonus
end

--Debuff
----毒
if not modifier_dragon_knight_elder_dragon_form_debuff_0 then
    modifier_dragon_knight_elder_dragon_form_debuff_0 = class({})
end
function modifier_dragon_knight_elder_dragon_form_debuff_0:IsDebuff()
    return true
end
function modifier_dragon_knight_elder_dragon_form_debuff_0:IsPurgable()
    return true ----可净化
end
function modifier_dragon_knight_elder_dragon_form_debuff_0:GetTexture()
    return 'dragon_knight_elder_dragon_form'
end
function modifier_dragon_knight_elder_dragon_form_debuff_0:OnCreated(kv)
    self.deuff_armor_sub = self:GetAbility():GetSpecialValueFor('deuff_armor_sub')
    self.deuff_move_speed_sub = self:GetAbility():GetSpecialValueFor('deuff_move_speed_sub')
    self.deuff_fire_damage = self:GetAbility():GetSpecialValueFor('deuff_fire_damage')
    self:SetStackCount(1)
    -- if IsServer() then
    --     self:StartIntervalThink(1)
    -- end
end
function modifier_dragon_knight_elder_dragon_form_debuff_0:OnRefresh(kv)
    self.deuff_armor_sub = self:GetAbility():GetSpecialValueFor('deuff_armor_sub')
    self.deuff_move_speed_sub = self:GetAbility():GetSpecialValueFor('deuff_move_speed_sub')
    self.deuff_fire_damage = self:GetAbility():GetSpecialValueFor('deuff_fire_damage')
end
function modifier_dragon_knight_elder_dragon_form_debuff_0:OnIntervalThink()
    self:DecrementStackCount()
end
function modifier_dragon_knight_elder_dragon_form_debuff_0:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end
function modifier_dragon_knight_elder_dragon_form_debuff_0:GetModifierPhysicalArmorBonus()
    return self.deuff_armor_sub * self:GetStackCount()
end
----火
if not modifier_dragon_knight_elder_dragon_form_debuff_1 then
    modifier_dragon_knight_elder_dragon_form_debuff_1 = class({}, nil, modifier_dragon_knight_elder_dragon_form_debuff_0)
end
function modifier_dragon_knight_elder_dragon_form_debuff_1:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP
    }
end
function modifier_dragon_knight_elder_dragon_form_debuff_1:OnTooltip()
    return self:GetStackCount() * self.deuff_fire_damage
end
----冰
if not modifier_dragon_knight_elder_dragon_form_debuff_2 then
    modifier_dragon_knight_elder_dragon_form_debuff_2 = class({}, nil, modifier_dragon_knight_elder_dragon_form_debuff_0)
end
function modifier_dragon_knight_elder_dragon_form_debuff_2:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end
function modifier_dragon_knight_elder_dragon_form_debuff_2:GetModifierMoveSpeedBonus_Percentage()
    return self.deuff_move_speed_sub * self:GetStackCount()
end