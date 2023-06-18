if PrecacheItems then
    table.insert(PrecacheItems, "particles/items2_fx/refresher.vpcf")
end

----刷新球
if nil == Card_ITEM_refresher then
    Card_ITEM_refresher = class({}, nil, Card)
end

----构造函数
function Card_ITEM_refresher:constructor(tInfo, nPlayerID)
    Card_ITEM_refresher.__base__.constructor(self, tInfo, nPlayerID)
end

----
----选择无目标时
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function Card_ITEM_refresher:CastFilterResult()
    if not self:CanUseCard() then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
----能否在移动时释放
function Card_ITEM_refresher:isCanCastMove()
    return true
end
----能否在监狱时释放
function Card_ITEM_refresher:isCanCastInPrison()
    return true
end
----能否在攻击时释放
function Card_ITEM_refresher:isCanCastHeroAtk()
    return true
end

----卡牌释放
function Card_ITEM_refresher:OnSpellStart()
    ----特效
    AMHC:CreateParticle("particles/items2_fx/refresher.vpcf"
    , PATTACH_POINT, false, self:GetCaster(), 2)
    ----音效
    EmitGlobalSound("DOTA_Item.Refresher.Activate")

    ----重置全部CD
    for i = 0, 23 do
        local oAblt = self:GetCaster():GetAbilityByIndex(i)
        if nil ~= oAblt and not oAblt:IsCooldownReady() then
            EventManager:fireEvent("Event_LastCDChange", {
                strAbltName = oAblt:GetAbilityName(),
                entity = self:GetCaster(),
                nCD = 0
            })
        end
    end
    local tRefresh = {}
    tRefresh["item_refresher"] = true
    for i = 0, 5 do
        local oItem = self:GetCaster():GetItemInSlot(i)
        if IsValid(oItem)
        and not oItem:IsCooldownReady()
        and not tRefresh[oItem:GetAbilityName()] then
            tRefresh[oItem:GetAbilityName()] = true
            EventManager:fireEvent("Event_LastCDChange", {
                strAbltName = oItem:GetAbilityName(),
                entity = self:GetCaster(),
                nCD = 0
            })
        end
    end
end