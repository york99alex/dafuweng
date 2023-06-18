if PrecacheItems then
    table.insert(PrecacheItems, "particles/items_fx/arcane_boots.vpcf")
end

----奥术鞋
if nil == Card_ITEM_arcane_boots then
    Card_ITEM_arcane_boots = class({}, nil, Card)
end

----构造函数
function Card_ITEM_arcane_boots:constructor(tInfo, nPlayerID)
    Card_ITEM_arcane_boots.__base__.constructor(self, tInfo, nPlayerID)
end
----
----选择无目标时
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function Card_ITEM_arcane_boots:CastFilterResult()
    if not self:CanUseCard() then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
----能否在移动时释放
function Card_ITEM_arcane_boots:isCanCastMove()
    return true
end
----能否在监狱时释放
function Card_ITEM_arcane_boots:isCanCastInPrison()
    return true
end
----能否在攻击时释放
function Card_ITEM_arcane_boots:isCanCastHeroAtk()
    return true
end

----卡牌释放
function Card_ITEM_arcane_boots:OnSpellStart()
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if not oPlayer then
        return
    end

    ----特效
    AMHC:CreateParticle("particles/items_fx/arcane_boots.vpcf"
    , PATTACH_POINT, false, oPlayer.m_eHero, 2)
    AMHC:CreateParticle("particles/items_fx/arcane_boots_recipient.vpcf"
    , PATTACH_POINT, false, oPlayer.m_eHero, 2)
    ----音效
    EmitGlobalSound("DOTA_Item.ArcaneBoots.Activate")

    ----恢复英雄魔法
    local nMana = 5
    oPlayer.m_eHero:GiveMana(nMana)
    ----回复全部兵卒魔法
    local nCount = 0
    for _, v in pairs(oPlayer.m_tabBz) do
        if IsValid(v) then
            v:GiveMana(v:GetMana() + 50)
            nCount = nCount + 1
            AMHC:CreateParticle("particles/items_fx/arcane_boots.vpcf"
            , PATTACH_POINT, false, v, 2)
            AMHC:CreateParticle("particles/items_fx/arcane_boots_recipient.vpcf"
            , PATTACH_POINT, false, v, 2)
        end
    end
end