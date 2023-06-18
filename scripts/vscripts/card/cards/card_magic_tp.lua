-----传送
if nil == Card_MAGIC_TP then
    ---@class Card_MAGIC_TP : Card
    Card_MAGIC_TP = class({}, nil, Card)
end

---@type Card_MAGIC_TP
local this = Card_MAGIC_TP

----构造函数
function this:constructor(tInfo, nPlayerID)
    this.__base__.constructor(self, tInfo, nPlayerID)
end

----选择目标地点时
function this:CastFilterResultLocation(vLocation)
    self.m_vTargetPos = vLocation
    if not self:CanUseCard() then
        return UF_FAIL_CUSTOM
    end
    self.m_strCastError = "Error_Card_TP"
    ---@type Path
    local path = PathManager:getClosePath(vLocation)
    local dis = (vLocation - path.m_entity:GetAbsOrigin()):Length2D()
    if dis > 300 then
        return UF_FAIL_CUSTOM
    end
    self.mTargetPath = path
    if TP_TP == path.m_typePath then
        return UF_SUCCESS
    end
    -- if instanceof(path, PathDomain)
    -- and self:GetOwner().m_nPlayerID == path.m_nOwnerID then
    --     return UF_SUCCESS
    -- end
    return UF_FAIL_CUSTOM
end
----选择目标单位时
function this:CastFilterResultTarget(hTarget)
    if IsValid(hTarget) then
        return self:CastFilterResultLocation(hTarget:GetAbsOrigin())
    end
    return UF_FAIL_CUSTOM
end

----卡牌释放
function this:OnSpellStart()
    ---@type Player
    local owner = self:GetOwner()
    ---@type PathTP
    local path = self.mTargetPath
    if not owner or not path then
        return
    end

    ----过掉其他操作
    GMManager:autoOptionalOprt(owner)

    ----特效
    SkinManager:setSink(TSink_TP, owner.m_eHero, path.m_entity)
    EmitSoundOn("Custom.TP.Begin", owner.m_eHero)

    ----传送动作2.5秒
    -- local typeState = GMManager.m_typeState
    -- GMManager:setState(GS_Wait)
    self._YieldStateCO = GSManager:yieldState()
    GSManager:setState(GS_Wait)
    owner.m_eHero:StartGesture(ACT_DOTA_TELEPORT)
    Timers:CreateTimer(2.5, function()
        ----传送
        StopSoundOn("Custom.TP.Begin", owner.m_eHero)
        EmitSoundOn("Custom.TP.End", owner.m_eHero)

        owner.m_eHero:RemoveGesture(ACT_DOTA_TELEPORT)
        owner.m_eHero:StartGesture(ACT_DOTA_TELEPORT_END)

        if 0 < bit.band(PS_InPrison, owner.m_typeState) then
            return
        end
        ---- owner.m_eHero:RemoveGesture(ACT_DOTA_TELEPORT_END)
        ----设置游戏记录
        GameRecord:setGameRecord(TGameRecord_TP, owner.m_nPlayerID, {
            strPathBegin = GameRecord:encodeGameRecord(
            GameRecord:encodeLocalize("PathName_" .. owner.m_pathCur.m_nID)
            ),
            strPathEnd = GameRecord:encodeGameRecord(GameRecord:encodeLocalize("PathName_" .. path.m_nID))
        })

        owner:blinkToPath(path)
        -- if GS_Wait == GMManager.m_typeState
        -- or GS_DeathClearing == GMManager.m_typeState then
        --     GMManager:setState(typeState)
        -- end
        GSManager:resumeState(self._YieldStateCO)

        ----别人的tp点给钱
        if nil ~= path.m_nOwnerID
        and path.m_nOwnerID ~= owner.m_nPlayerID then
            path:onPath(owner)
        end
    end)
end