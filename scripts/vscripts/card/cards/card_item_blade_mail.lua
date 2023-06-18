if PrecacheItems then
    table.insert(PrecacheItems, "particles/items_fx/blademail.vpcf")
end

----刃甲
if nil == Card_ITEM_blade_mail then
    Card_ITEM_blade_mail = class({}, nil, Card)
    LinkLuaModifier("modifier_item_blade_mail_buff", "Card/Cards/Card_ITEM_blade_mail.lua", LUA_MODIFIER_MOTION_NONE)
end

----构造函数
function Card_ITEM_blade_mail:constructor(tInfo, nPlayerID)
    Card_ITEM_blade_mail.__base__.constructor(self, tInfo, nPlayerID)
end

----
----选择无目标时
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function Card_ITEM_blade_mail:CastFilterResult()
    if not self:CanUseCard() then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
----能否在其他玩家回合时释放
function Card_ITEM_blade_mail:isCanCastOtherRound()
    return true
end
----能否在移动时释放
function Card_ITEM_blade_mail:isCanCastMove()
    return true
end
----能否在监狱时释放
function Card_ITEM_blade_mail:isCanCastInPrison()
    return true
end
----能否在攻击时释放
function Card_ITEM_blade_mail:isCanCastHeroAtk()
    return true
end

----卡牌释放
function Card_ITEM_blade_mail:OnSpellStart()
    ----音效
    EmitGlobalSound("DOTA_Item.BladeMail.Activate")
    ----
    local player = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if NIL(player) then
        return
    end

    AbilityManager:setCopyBuff('modifier_item_blade_mail_buff', player.m_eHero, player.m_eHero)
    for _, v in pairs(player.m_tabBz) do
        AbilityManager:setCopyBuff('modifier_item_blade_mail_buff', v, v)
    end
    ----兵卒创建更新buff
    local unUpdataBZBuffByCreate = AbilityManager:updataBZBuffByCreate(player, nil, function(eBZ)
        AbilityManager:setCopyBuff('modifier_item_blade_mail_buff', eBZ, eBZ)
    end)

    ----监听结束
    EventManager:register("Event_PlayerRoundBegin", function(tEvent)
        if tEvent.oPlayer == player then
            ----移除buff
            for _, v in pairs(player.m_tabBz) do
                if IsValid(v) then
                    v:RemoveModifierByName("modifier_item_blade_mail_buff")
                end
            end
            if IsValid(player.m_eHero) then
                player.m_eHero:RemoveModifierByName("modifier_item_blade_mail_buff")
            end
            unUpdataBZBuffByCreate()
            return true
        end
    end)
end

----默认buff
modifier_item_blade_mail_buff = class({})
function modifier_item_blade_mail_buff:IsHidden()
    return false
end
function modifier_item_blade_mail_buff:IsPurgable()
    return true ----可驱散
end
function modifier_item_blade_mail_buff:GetTexture()
    return "item_blade_mail"
end
function modifier_item_blade_mail_buff:OnCreated(kv)
    if IsClient() then
        return
    end
    local eCaster = self:GetParent()

    EventManager:register("Event_OnDamage", self.onDamage, self, 0)

    self.m_tPtclID = {}
    local nPtclID = AMHC:CreateParticle("particles/items_fx/blademail.vpcf"
    , PATTACH_POINT_FOLLOW, false, eCaster)
    ParticleManager:SetParticleControlEnt(nPtclID, 0, eCaster, PATTACH_POINT_FOLLOW, "attach_origin", eCaster:GetAbsOrigin(), true)
    table.insert(self.m_tPtclID, nPtclID)

end
function modifier_item_blade_mail_buff:OnDestroy()
    if IsClient() then
        return
    end

    EventManager:unregister("Event_OnDamage", self.onDamage, self)

    for _, v in pairs(self.m_tPtclID) do
        ParticleManager:DestroyParticle(v, false)
    end

end

----触发反伤
function modifier_item_blade_mail_buff:onDamage(tEvent)
    if
    tEvent.bBladeMail
    or tEvent.entindex_victim_const ~= self:GetParent():GetEntityIndex()
    or tEvent.entindex_victim_const == tEvent.entindex_attacker_const   ----自身伤害不反弹
    then
        return
    end
    ----敌人打自己
    local eAtk = EntIndexToHScript(tEvent.entindex_attacker_const)
    if not IsValid(eAtk) then
        return
    end

    tEvent.bIgnoreAddGold = true    ----不加钱

    ----反伤
    local nDamage = tEvent.damage
    if tEvent.damage_crimson_guard then
        nDamage = nDamage + tEvent.damage_crimson_guard
    end
    AMHC:Damage(self:GetParent(), eAtk, nDamage, tEvent.damagetype_const, tEvent.ability, nil, {
        bBladeMail = true,
        bIgnoreAddGold = true,
    })
    EmitSoundOn("DOTA_Item.BladeMail.Activate", self:GetParent())
end
-- function modifier_item_blade_mail_buff:onDamage(tEvent)
--     if tEvent.entindex_victim_const ~= self:GetParent():GetEntityIndex()
--     or tEvent.entindex_victim_const == tEvent.entindex_attacker_const
--     then
--         return
--     end
--     ----敌人打自己
--     tEvent.bIgnoreAddGold = true    ----不加钱
--     local eAtk = EntIndexToHScript(tEvent.entindex_attacker_const)
--     if IsValid(eAtk) then
--         ----自身伤害不反弹
--         local tEvent2 = {
--             attacker = eAtk,
--             victim = self:GetParent(),
--             damage_type = tEvent.damagetype_const,
--         }
--         EventManager:fireEvent("Event_item_blade_mail_fanshang", tEvent2)
--         if not tEvent2.bIgnore then
--             ----监听攻击者受到反伤，设置不加钱
--             local tEventID = {}
--             table.insert(tEventID, EventManager:register("Event_Atk", function(tEvent3)
--                 if tEvent3.entindex_victim_const == eAtk:GetEntityIndex()
--                 and tEvent3.entindex_attacker_const == self:GetParent():GetEntityIndex()
--                 then
--                     tEvent3.bIgnoreAddGold = true    ----不加钱
--                     return true
--                 end
--             end, nil, 987654321))
--             table.insert(tEventID, EventManager:register("Event_item_blade_mail_fanshang", function(tEvent3)
--                 if tEvent3.attacker == self:GetParent()
--                 and tEvent3.victim == eAtk
--                 then
--                     tEvent3.bIgnore = true    ----不重复
--                     return true
--                 end
--             end))
--             ----监听攻击者的刃甲接收到的伤害，设置不重复
--             Timers:CreateTimer(0.1, function()
--                 for _, nEventID in pairs(tEventID) do
--                     EventManager:unregisterByID(nEventID)
--                 end
--             end)
--             ----反伤
--             AMHC:Damage(self:GetParent(), eAtk, tEvent.damage, tEvent.damagetype_const, tEvent.ability, nil, {
--                 bBladeMail = true
--             })
--             EmitSoundOn("DOTA_Item.BladeMail.Activate", self:GetParent())
--         end
--     end
-- end
function modifier_item_blade_mail_buff:DeclareFunctions()
    return {
    -- MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT,
    }
end
function modifier_item_blade_mail_buff:GetModifierIncomingSpellDamageConstant(params)
    local eAtk = params.attacker
    if IsValid(eAtk) then
        ----自身伤害不反弹
        if eAtk ~= self:GetParent() then
            local tEvent = {
                attacker = eAtk,
                victim = self:GetParent(),
                damage_type = params.damage_type,
            }
            EventManager:fireEvent("Event_item_blade_mail_fanshang", tEvent)
            if not tEvent.bIgnore then
                ----监听攻击者受到反伤，设置不加钱
                local tEventID = {}
                table.insert(tEventID, EventManager:register("Event_Atk", function(tEvent2)
                    if tEvent2.entindex_victim_const == eAtk:GetEntityIndex()
                    and tEvent2.entindex_attacker_const == self:GetParent():GetEntityIndex()
                    then
                        tEvent2.bIgnoreAddGold = true    ----不加钱
                        return true
                    end
                end, nil, 987654321))
                table.insert(tEventID, EventManager:register("Event_item_blade_mail_fanshang", function(tEvent2)
                    if tEvent2.attacker == self:GetParent()
                    and tEvent2.victim == eAtk
                    then
                        tEvent2.bIgnore = true    ----不重复
                        return true
                    end
                end))

                ----监听攻击者的刃甲接收到的伤害，设置不重复
                Timers:CreateTimer(0.1, function()
                    for _, nEventID in pairs(tEventID) do
                        EventManager:unregisterByID(nEventID)
                    end
                end)
                ----反伤
                AMHC:Damage(self:GetParent(), eAtk, params.damage, params.damage_type)
                EmitSoundOn("DOTA_Item.BladeMail.Activate", self:GetParent())
            end
        end
    end
end