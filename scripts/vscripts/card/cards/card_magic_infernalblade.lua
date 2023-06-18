-----阎刃
if nil == Card_MAGIC_InfernalBlade then
    ---@class Card_MAGIC_InfernalBlade : Card
    Card_MAGIC_InfernalBlade = class({}, nil, Card)
end

---@type Card_MAGIC_InfernalBlade
local this = Card_MAGIC_InfernalBlade

----构造函数
function this:constructor(tInfo, nPlayerID)
    this.__base__.constructor(self, tInfo, nPlayerID)
end

----能否在监狱时释放
function this:isCanCastInPrison()
    return true
end
----能否在攻击时释放
function this:isCanCastHeroAtk()
    return true
end
----能否对自身释放
function this:isCanCastSelf()
    return true
end
----能否对监狱中玩家释放
function this:isCanCastInPrisonTarget()
    return true
end

----选择目标单位时
function this:CastFilterResultTarget(hTarget)
    if IsValid(hTarget) then
        if not self:CanUseCard(hTarget) then
            return UF_FAIL_CUSTOM
        end
        ----验证目标是玩家单位
        if not PlayerManager:isAlivePlayer(hTarget:GetPlayerOwnerID()) then
            self.m_strCastError = "LuaAbilityError_TargetPlayerUnit"
            return UF_FAIL_CUSTOM
        end
        self.m_eTarget = hTarget
        return UF_SUCCESS
    end
    return UF_FAIL_CUSTOM
end

----卡牌释放
function this:OnSpellStart()
    if not IsValid(self.m_eTarget) then
        return
    end
    ---@type Player
    local owner = self:GetOwner()
    ---@type Player
    local playerTarget = PlayerManager:getPlayer(self.m_eTarget:GetPlayerOwnerID())
    ---@type PathPrison
    local path = PathManager:getPathByType(TP_PRISON)[1]
    if not owner or not playerTarget or not path then
        return
    end

    if path:isInPrison(playerTarget.m_eHero:GetEntityIndex()) then
        ----在监狱就出来
        path:setOutPrison(playerTarget)
        if GMManager.m_nOrderID == playerTarget.m_nPlayerID then
            ----当前在操作买活自动处理
            GMManager:autoOprt(TypeOprt.TO_PRISON_OUT, playerTarget)
        end
    else
        ----不在监狱就进入
        path:setInPrison(playerTarget)
    end
end