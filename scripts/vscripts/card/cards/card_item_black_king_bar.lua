if PrecacheItems then
    table.insert(PrecacheItems, "particles/items_fx/black_king_bar_avatar.vpcf")
    table.insert(PrecacheItems, "particles/items_fx/black_king_bar_overhead.vpcf")
end

----bkb 黑皇杖
if nil == Card_ITEM_black_king_bar then
    Card_ITEM_black_king_bar = class({}, nil, Card)
    LinkLuaModifier("modifier_item_black_king_bar_buff", "Card/Cards/Card_ITEM_black_king_bar.lua", LUA_MODIFIER_MOTION_NONE)
end

----构造函数
function Card_ITEM_black_king_bar:constructor(tInfo, nPlayerID)
    Card_ITEM_black_king_bar.__base__.constructor(self, tInfo, nPlayerID)
end

----
----选择无目标时
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function Card_ITEM_black_king_bar:CastFilterResult()
    if not self:CanUseCard() then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
----能否在其他玩家回合时释放
function Card_ITEM_black_king_bar:isCanCastOtherRound()
    return true
end
----能否在沉默时释放
function Card_ITEM_black_king_bar:isCanCastChenMo()
    return true
end
----能否在移动时释放
function Card_ITEM_black_king_bar:isCanCastMove()
    return true
end
----能否在监狱时释放
function Card_ITEM_black_king_bar:isCanCastInPrison()
    return true
end
----能否在攻击时释放
function Card_ITEM_black_king_bar:isCanCastHeroAtk()
    return true
end

----卡牌释放
function Card_ITEM_black_king_bar:OnSpellStart()
    ----音效
    EmitGlobalSound("DOTA_Item.BlackKingBar.Activate")
    ----
    local player = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if NIL(player) then
        return
    end

    ----添加buff
    AbilityManager:setCopyBuff('modifier_item_black_king_bar_buff'
    , player.m_eHero, player.m_eHero)

    for _, v in pairs(player.m_tabBz) do
        AbilityManager:setCopyBuff('modifier_item_black_king_bar_buff'
        , v, v)
    end
    ----兵卒创建更新buff
    local unUpdateBZBuffByCreate = AbilityManager:updataBZBuffByCreate(player, nil, function(eBZ)
        AbilityManager:setCopyBuff('modifier_item_black_king_bar_buff'
        , eBZ, eBZ)
    end)

    ----监听结束
    EventManager:register("Event_PlayerRoundBegin", function(tEvent)
        if tEvent.oPlayer == player then
            ----移除buff
            for _, v in pairs(player.m_tabBz) do
                if IsValid(v) then
                    v:RemoveModifierByName("modifier_item_black_king_bar_buff")
                end
            end
            if IsValid(player.m_eHero) then
                player.m_eHero:RemoveModifierByName("modifier_item_black_king_bar_buff")
            end
            unUpdateBZBuffByCreate()
            return true
        end
    end)
end

----默认buff
modifier_item_black_king_bar_buff = class({})
function modifier_item_black_king_bar_buff:IsHidden()
    return false
end
function modifier_item_black_king_bar_buff:IsPurgable()
    return false
end
function modifier_item_black_king_bar_buff:GetTexture()
    return "item_black_king_bar"
end
function modifier_item_black_king_bar_buff:OnCreated(kv)
    if IsClient() then
        return
    end

    local eCaster = self:GetParent()
    self.player = PlayerManager:getPlayer(eCaster:GetPlayerOwnerID())
    if NIL(self.player) then
        return
    end

    ----设置技能免疫状态
    self.player:setState(PS_AbilityImmune)

    ----特效
    self.m_tPtclID = {}
    local nPtclID = AMHC:CreateParticle("particles/items_fx/black_king_bar_avatar.vpcf"
    , PATTACH_POINT_FOLLOW, false, eCaster)
    table.insert(self.m_tPtclID, nPtclID)

    nPtclID = AMHC:CreateParticle("particles/items_fx/black_king_bar_overhead.vpcf"
    , PATTACH_OVERHEAD_FOLLOW, false, eCaster)
    ---- ParticleManager:SetParticleControlEnt(nPtclID, 0, eCaster, PATTACH_POINT_FOLLOW, "attach_origin", eCaster:GetAbsOrigin(), true)
    table.insert(self.m_tPtclID, nPtclID)

    ----清除debuff
    local tBuff = eCaster:FindAllModifiers()
    for _, v in pairs(tBuff) do
        if not v:IsNull() and v.IsDebuff and v:IsDebuff() and v.IsPurgable and v:IsPurgable() then
            eCaster:RemoveModifierByName(v:GetName())
        end
    end
end
function modifier_item_black_king_bar_buff:OnDestroy()
    if IsClient() then
        return
    end

    ----解除免疫状态
    if self:GetParent() == self.player.m_eHero then
        self.player:setState(-PS_AbilityImmune)
    end

    for _, v in pairs(self.m_tPtclID) do
        ParticleManager:DestroyParticle(v, false)
    end
end