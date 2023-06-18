-----隐身神符
if nil == Card_MAGIC_BottleInvisibility then
    ---@class Card_MAGIC_BottleInvisibility : Card
    Card_MAGIC_BottleInvisibility = class({}, nil, Card)
end

---@type Card_MAGIC_BottleInvisibility
local this = Card_MAGIC_BottleInvisibility

----构造函数
function this:constructor(tInfo, nPlayerID)
    this.__base__.constructor(self, tInfo, nPlayerID)
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
    ---@type Player
    local owner = self:GetOwner()
    local tPaths = PathManager:getPathByType(TP_RUNE)
    if 0 == #tPaths then
        return
    end
    ---@type PathRune
    local path = tPaths[1]
    if not path or not instanceof(path, PathRune) then
        return
    end
    path:onRune(owner, DOTA_RUNE_INVISIBILITY)
end