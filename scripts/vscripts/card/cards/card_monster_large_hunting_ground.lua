-----大型狩猎场
if nil == Card_MONSTER_large_hunting_ground then
    -----@class Card_MONSTER_large_hunting_ground : Card
    Card_MONSTER_large_hunting_ground = class({}, nil, Card)
end

-----小型狩猎场~
-----@type Card_MONSTER_large_hunting_ground
local this = Card_MONSTER_large_hunting_ground

----构造函数
function this:constructor(tInfo, nPlayerID)
    this.__base__.constructor(self, tInfo, nPlayerID)
end

----选择目标单位时
----@param 目标单位
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function this:CastFilterResult()
    print("Card_MONSTER_large_hunting_ground~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

    if not TESTCARD and not self:CanUseCard() then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end

----卡牌释放
function this:OnSpellStart()
    GMManager:autoOptionalOprt()
    -----@type Player
    local owner = self:GetOwner()
    local paths = PathManager:getPathByType(TP_MONSTER_2)
    for i = 1, #paths do

        if instanceof(owner.m_pathCur, PathShop) then
            if GLOBAL_SHOP_ROUND > GMManager.m_nRound then
                ----玩家在商店进入打野，回来不能再次购买
                local nBuy = owner.m_nBuyItem
                EventManager:register("Event_AtkMosterEnd", function(tEvent)
                    if tEvent.entity == owner.m_eHero then
                        if not tEvent.bInPrison then
                            ----打野结束返回商店路径，设置回原购买次数
                            EventManager:register("Event_SetBuyState", function(tEvent2)
                                if tEvent2.player == owner then
                                    tEvent2.nCount = nBuy
                                    return true
                                end
                            end)
                        end
                        return true
                    end
                end, nil, 1000)
            end
        elseif instanceof(owner.m_pathCur, PathStart) then
            ----在进入起点不刷钱
            EventManager:register("Event_WageGold", function(tEvent2)
                if tEvent2.player == owner then
                    tEvent2.bIgnore = true
                    return true
                end
            end)
        end

        paths[i]:setAtkerAdd(owner, owner.m_pathCur)
        GMManager:skipRoll(owner.m_nPlayerID)
        break
    end
end

-----能否释放卡牌技能
function this:CanUseCard(hTarget, vTargetPos)
    if not self.__base__.CanUseCard(self, hTarget, vTargetPos) then
        return false
    end

    local paths = PathManager:getPathByType(TP_MONSTER_2)
    if 1 > #paths then
        return false
    end
    local path = paths[RandomInt(1, #paths)]
    return path.m_tabEMonster and 0 < #path.m_tabEMonster
end