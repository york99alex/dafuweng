-----拉野
if nil == Card_MONSTER_brush_field then
    -----@class Card_MONSTER_brush_field : Card
    Card_MONSTER_brush_field = class({
        mTargetpath = nil,
        TP_MONSTER = {
            TP_MONSTER_1,
            TP_MONSTER_2,
            TP_MONSTER_3,
        }
    }, nil, Card)
end

-----拉野~
-----@type Card_MONSTER_brush_field
local this = Card_MONSTER_brush_field

----构造函数
function this:constructor(tInfo, nPlayerID)
    this.__base__.constructor(self, tInfo, nPlayerID)
end

----选择目标单位时
----@param 目标单位
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function this:CastFilterResultLocation(tagPos)
    print("TCard_MONSTER_brush_field~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    if not TESTCARD and not self:CanUseCard(nil, tagPos) then
        return UF_FAIL_CUSTOM
    end

    for i, path in ipairs(PathManager.m_tabPaths) do
        local dis = (tagPos - path.m_entity:GetAbsOrigin()):Length2D()
        if dis < 450 and exist(self.TP_MONSTER, path.m_typePath) then
            self.mTargetPath = path
            return UF_SUCCESS
        end
    end

    self.m_strCastError = "LuaAbilityError_MonsterPath"
    return UF_FAIL_CUSTOM
end
----能否在移动时释放
function this:isCanCastMove()
    return true
end
----能否在监狱时释放
function this:isCanCastInPrison()
    return true
end
----能否在攻击时释放
function this:isCanCastHeroAtk()
    return true
end

----卡牌释放
function this:OnSpellStart()
    self.mTargetPath:spawnMonster()
end