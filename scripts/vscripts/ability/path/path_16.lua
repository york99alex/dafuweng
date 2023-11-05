require("Ability/LuaAbility")
----路径技能：龙谷
--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
if nil == path_16 then
    path_16 = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_path_16", "Ability/path/path_16.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_16_L1", "Ability/path/path_16.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_16_L2", "Ability/path/path_16.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_path_16_L3", "Ability/path/path_16.lua", LUA_MODIFIER_MOTION_NONE)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function path_16:constructor()
    path_16.__base__.constructor(self)
end
function path_16:GetIntrinsicModifierName()
    return "modifier_" .. self:GetAbilityName() .. "_L" .. self:GetLevel()
end

----默认buff
modifier_path_16_L1 = class({})
function modifier_path_16_L1:IsHidden()
    return false
end
function modifier_path_16_L1:IsDebuff()
    return false
end
function modifier_path_16_L1:IsPurgable()
    return false
end
function modifier_path_16_L1:GetTexture()
    return "path16"
end
function modifier_path_16_L1:OnDestroy()
    if self.oPlayer then
        for _, eBZ in pairs(self.oPlayer.m_tabBz) do
            if IsValid(eBZ) then
                eBZ:RemoveModifierByName(self:GetName())
            end
        end
    end
    if self.unUpdateBZBuffByCreate then
        self:unUpdateBZBuffByCreate()
    end
    if self.tEventID then
        for _, nID in pairs(self.tEventID) do
            EventManager:unregisterByID(nID)
        end
    end
end
function modifier_path_16_L1:OnCreated(kv)
    if not IsValid(self) then
        return
    end
    if not IsValid(self:GetAbility()) then
        return
    end
    local oAblt = self:GetAbility()
    self.huimo_bz = oAblt:GetSpecialValueFor("huimo_bz")
    self.huimo = oAblt:GetSpecialValueFor("huimo")
    self.shangxian = oAblt:GetSpecialValueFor("shangxian")
    self.no_cd_chance = oAblt:GetSpecialValueFor("no_cd_chance")
    self.no_mana_chance = oAblt:GetSpecialValueFor("no_mana_chance")
    self.spell_amp = oAblt:GetSpecialValueFor("spell_amp")

    if IsClient() or not self:GetParent():IsRealHero() then
        return
    end
    self.oPlayer = PlayerManager:getPlayer(self:GetParent():GetPlayerID())
    if not self.oPlayer then
        return
    end

    ----给玩家兵卒buff
    Timers:CreateTimer(0.1, function()
        if IsValid(self) and IsValid(self:GetAbility()) then
            for _, eBZ in pairs(self.oPlayer.m_tabBz) do
                eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self:GetName(), {})
            end
            self.unUpdateBZBuffByCreate = AbilityManager:updataBZBuffByCreate(self.oPlayer, self:GetAbility(), function(eBZ)
                if IsValid(self) then
                    eBZ:AddNewModifier(self.oPlayer.m_eHero, self:GetAbility(), self:GetName(), {})
                end
            end)
        end
    end)

    self.tEventID = {}

    ----提升英雄魔法上限
    self.oPlayer:setMaxMana(self.oPlayer.m_eHero:GetMaxMana() + self.shangxian)
    ----监听玩家回合回魔
    table.insert(self.tEventID, EventManager:register("Event_HeroHuiMoByRound", function(tabEvent)
        if self.oPlayer ~= tabEvent.oPlayer then
            return
        end
        tabEvent.nHuiMo = tabEvent.nHuiMo + self.huimo
    end))

    ----监听兵卒回魔事件：
    table.insert(self.tEventID, EventManager:register("Event_BZHuiMo", function(tabEvent)
        if tabEvent.eBz:GetPlayerOwnerID() ~= self.oPlayer.m_nPlayerID then
            return
        end
        ----额外回魔
        tabEvent.nHuiMoSum = tabEvent.nHuiMoSum + (tabEvent.getBaseHuiMo() * self.huimo_bz * 0.01)
    end))

    ----监听技能释放
    table.insert(self.tEventID, EventManager:register('dota_player_used_ability', function(tEvent)
        if oAblt:IsNull() then
            return true
        end
        local entity = EntIndexToHScript(tEvent.caster_entindex)
        if IsValid(entity) and entity:GetPlayerOwnerID() == self.oPlayer.m_nPlayerID then
            local oAblt2 = entity:FindAbilityByName(tEvent.abilityname)
            if oAblt2 then
                local nPrltName = 0
                if RandomInt(1, 100) <= self.no_cd_chance then
                    ----刷新技能CD
                    if entity:IsHero() then
                        Timers:CreateTimer(function()
                            EventManager:fireEvent("Event_LastCDChange", {
                                strAbltName = tEvent.abilityname,
                                entity = entity,
                                nCD = 0,
                            })
                        end)
                    else
                        oAblt2:EndCooldown()
                    end
                    nPrltName = nPrltName + 1
                end
                if RandomInt(1, 100) <= self.no_mana_chance then
                    ----返回魔法
                    Timers:CreateTimer(function()
                        entity:GiveMana(oAblt2:GetManaCost(oAblt2:GetLevel() - 1))
                    end)
                    nPrltName = nPrltName + 2
                end

                ----特效
                if 0 ~= nPrltName then
                    nPrltName = "particles/custom/path_ablt/path_ablt_nocdmana_" .. nPrltName .. ".vpcf"
                    local nPtclID = AMHC:CreateParticle(nPrltName, PATTACH_POINT_FOLLOW, false, entity, 3)
                    ParticleManager:SetParticleControl(nPtclID, 0, entity:GetAbsOrigin() + Vector(0, 0, 500))
                    ----音效
                    if entity:IsHero() then
                        EmitGlobalSound("DOTA_Item.Refresher.Activate")
                    else
                        EmitSoundOn("DOTA_Item.Refresher.Activate", entity)
                    end
                end
            end
        end
    end))
end

function modifier_path_16_L1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    -- MODIFIER_PROPERTY_BONUS_DAY_VISION,
    -- MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }
    return funcs
end

function modifier_path_16_L1:GetModifierSpellAmplify_Percentage(params)
    return self.spell_amp
end
-- function modifier_path_16_L1:GetBonusDayVision()
--     return self.damage
-- end
-- function modifier_path_16_L1:GetBonusNightVision()
--     return self.jiansu
-- end
modifier_path_16_L2 = class({}, nil, modifier_path_16_L1)
modifier_path_16_L3 = class({}, nil, modifier_path_16_L1)