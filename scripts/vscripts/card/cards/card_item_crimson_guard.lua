if PrecacheItems then
    table.insert(PrecacheItems, "particles/custom/item_crimson_guard.vpcf")
end

----赤红甲
if nil == Card_ITEM_crimson_guard then
    Card_ITEM_crimson_guard = class({}, nil, Card)
    LinkLuaModifier("modifier_item_crimson_guard_buff", "Card/Cards/Card_ITEM_crimson_guard.lua", LUA_MODIFIER_MOTION_NONE)
end

----构造函数
function Card_ITEM_crimson_guard:constructor(tInfo, nPlayerID)
    Card_ITEM_crimson_guard.__base__.constructor(self, tInfo, nPlayerID)
end

----
----选择无目标时
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function Card_ITEM_crimson_guard:CastFilterResult()
    if not self:CanUseCard() then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
----能否在其他玩家回合时释放
function Card_ITEM_crimson_guard:isCanCastOtherRound()
    return true
end
----能否在移动时释放
function Card_ITEM_crimson_guard:isCanCastMove()
    return true
end
----能否在监狱时释放
function Card_ITEM_crimson_guard:isCanCastInPrison()
    return true
end
----能否在攻击时释放
function Card_ITEM_crimson_guard:isCanCastHeroAtk()
    return true
end

----卡牌释放
function Card_ITEM_crimson_guard:OnSpellStart()
    ----音效
    EmitGlobalSound("Item.CrimsonGuard.Cast")
    ----
    local player = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if NIL(player) then
        return
    end

    ----添加减甲debuff
    local function setDebuff(e, nBuffStack)
        local oAblt = e:AddAbility("item_crimson_guard_debuff")
        if not oAblt then
            return
        end

        oAblt:SetLevel(1)
        local nHuJia = oAblt:GetSpecialValueFor("hujia")

        local oBuff = e:FindModifierByName("modifier_item_crimson_guard_debuff")
        if not oBuff then
            oBuff = oAblt:ApplyDataDrivenModifier(e, e, "modifier_item_crimson_guard_debuff", nil)
            if not oBuff then
                return
            end
        end
        if oBuff then
            oBuff:SetStackCount(nBuffStack or (oBuff:GetStackCount() + nHuJia))
        end
        oBuff.copyBfToEnt = function(self, e)
            setDebuff(e, self:GetStackCount())
        end
        player.m_eHero:RemoveAbility(oAblt:GetAbilityName())
    end

    if AbilityManager:setCopyBuff('modifier_item_crimson_guard_buff', player.m_eHero, player.m_eHero) then
        setDebuff(player.m_eHero)
    end
    for _, v in pairs(player.m_tabBz) do
        if AbilityManager:setCopyBuff('modifier_item_crimson_guard_buff', v, v) then
            setDebuff(v)
        end
    end
    ----兵卒创建更新buff
    local unUpdateBZBuffByCreate = AbilityManager:updataBZBuffByCreate(player, nil, function(eBZ)
        if AbilityManager:setCopyBuff('modifier_item_crimson_guard_buff', eBZ, eBZ) then
            setDebuff(eBZ)
        end
    end)

    ----监听结束
    EventManager:register("Event_PlayerRoundBegin", function(tEvent)
        if tEvent.oPlayer == player then
            ----移除buff
            for _, v in pairs(player.m_tabBz) do
                if IsValid(v) then
                    v:RemoveModifierByName("modifier_item_crimson_guard_buff")
                end
            end
            if IsValid(player.m_eHero) then
                player.m_eHero:RemoveModifierByName("modifier_item_crimson_guard_buff")
            end
            unUpdateBZBuffByCreate()
            return true
        end
    end)
end

----默认buff
modifier_item_crimson_guard_buff = class({})
function modifier_item_crimson_guard_buff:IsHidden()
    return false
end
function modifier_item_crimson_guard_buff:IsPurgable()
    return true
end
function modifier_item_crimson_guard_buff:GetTexture()
    return "item_crimson_guard"
end
function modifier_item_crimson_guard_buff:OnCreated(kv)
    if IsClient() then
        return
    end

    local eCaster = self:GetParent()

    EventManager:register("Event_BeAtk", self.onMiss, self, -987654321)

    self.m_tPtclID = {}
    local nPtclID = AMHC:CreateParticle("particles/custom/item_crimson_guard.vpcf"
    , PATTACH_POINT_FOLLOW, false, eCaster)
    ---- ParticleManager:SetParticleControl(nPtclID, 1, eCaster:GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(nPtclID, 1, eCaster, PATTACH_POINT_FOLLOW, "attach_origin", eCaster:GetAbsOrigin(), true)
    ---- ParticleManager:SetParticleControl(nPtclID, 2, Vector(eCaster:GetModelRadius() * 1.5, 0, 0))
    table.insert(self.m_tPtclID, nPtclID)

end
function modifier_item_crimson_guard_buff:OnDestroy()
    if IsClient() then
        return
    end

    EventManager:unregister("Event_BeAtk", self.onMiss, self)

    for _, v in pairs(self.m_tPtclID) do
        ParticleManager:DestroyParticle(v, false)
    end

end
----触发抵挡物理攻击
function modifier_item_crimson_guard_buff:onMiss(tEvent)

    if tEvent.entindex_victim_const ~= self:GetParent():GetEntityIndex()
    or DAMAGE_TYPE_PHYSICAL ~= tEvent.damagetype_const
    then
        return
    end

    ----触发
    tEvent.damage_crimson_guard = tEvent.damage
    tEvent.damage = 0
end