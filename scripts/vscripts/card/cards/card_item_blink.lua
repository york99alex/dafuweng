if PrecacheItems then
    table.insert(PrecacheItems, "particles/items_fx/blink_dagger_start.vpcf")
    table.insert(PrecacheItems, "particles/items_fx/blink_dagger_end.vpcf")
end

----闪烁匕首
if nil == Card_ITEM_blink then
    Card_ITEM_blink = class({
        m_pathTarget = nil
    }, nil, Card)
end

----构造函数
function Card_ITEM_blink:constructor(tInfo, nPlayerID)
    Card_ITEM_blink.__base__.constructor(self, tInfo, nPlayerID)
end

function Card_ITEM_blink:CastFilterResultTarget(hTarget)
    self.m_eTarget = hTarget
    if not self:CanUseCard(hTarget) then
        return UF_FAIL_CUSTOM
    end

    self.m_pathTarget = hTarget.m_path
    if NIL(self.m_pathTarget) then
        self.m_strCastError = "LuaAbilityError_TargetPath"
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

function Card_ITEM_blink:CastFilterResultLocation(vLocation)
    self.m_vTargetPos = vLocation
    if not self:CanUseCard(nil, vLocation) then
        return UF_FAIL_CUSTOM
    end

    ----获取最近的路径点
    self.m_pathTarget = PathManager:getClosePath(vLocation)
    if NIL(self.m_pathTarget) or 300 < (self.m_pathTarget.m_entity:GetAbsOrigin() - vLocation):Length2D() then
        self.m_strCastError = "LuaAbilityError_TargetPath"
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

----卡牌释放
function Card_ITEM_blink:OnSpellStart()
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if not oPlayer then
        return
    end

    ----特效
    local nPtclID = AMHC:CreateParticle("particles/items_fx/blink_dagger_start.vpcf"
    , PATTACH_ABSORIGIN, false, oPlayer.m_eHero, 2)
    ParticleManager:SetParticleControl(nPtclID, 0, oPlayer.m_eHero:GetAbsOrigin())

    ----音效
    EmitGlobalSound("DOTA_Item.BlinkDagger.Activate")

    ----闪现到路径
    oPlayer:blinkToPath(self.m_pathTarget)
    ----判断路径触发功能
    oPlayer.m_pathCur:onPath(oPlayer)

    nPtclID = AMHC:CreateParticle("particles/items_fx/blink_dagger_end.vpcf"
    , PATTACH_ABSORIGIN, false, oPlayer.m_eHero, 2)
    ParticleManager:SetParticleControl(nPtclID, 0, oPlayer.m_eHero:GetAbsOrigin())

    ----视角
    CameraManage:LookAt(oPlayer.m_nPlayerID, oPlayer.m_eHero:GetAbsOrigin(), 0.1)
end