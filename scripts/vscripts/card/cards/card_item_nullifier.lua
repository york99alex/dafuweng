if PrecacheItems then
    table.insert(PrecacheItems, "particles/items4_fx/nullifier_proj.vpcf")
end

----否决
if nil == Card_ITEM_nullifier then
    Card_ITEM_nullifier = class({
    }, nil, Card)
end

----构造函数
function Card_ITEM_nullifier:constructor(tInfo, nPlayerID)
    Card_ITEM_nullifier.__base__.constructor(self, tInfo, nPlayerID)
end


function Card_ITEM_nullifier:CastFilterResultTarget(hTarget)
    self.m_eTarget = hTarget
    if not self:CanUseCard(hTarget) then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
----能否在移动时释放
function Card_ITEM_nullifier:isCanCastMove()
    return true
end
----能否在监狱时释放
function Card_ITEM_nullifier:isCanCastInPrison()
    return true
end
----能否在攻击时释放
function Card_ITEM_nullifier:isCanCastHeroAtk()
    return true
end
----能否对幻象释放
function Card_ITEM_nullifier:isCanCastIllusion()
    return false
end
----能否对兵卒释放
function Card_ITEM_nullifier:isCanCastBZ()
    return false
end
----能否对英雄释放
function Card_ITEM_nullifier:isCanCastHero()
    return true
end
----能否对野怪释放
function Card_ITEM_nullifier:isCanCastMonster()
    return false
end
----能否对监狱中玩家释放
function Card_ITEM_nullifier:isCanCastInPrisonTarget()
    return true
end

----卡牌释放
function Card_ITEM_nullifier:OnSpellStart()
    local oPlayer = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    if not oPlayer then
        return
    end

    ----设置技能时间增加
    local nAddCd = 2
    for i = 0, 23 do
        local oAblt = self.m_eTarget:GetAbilityByIndex(i)
        if nil ~= oAblt and not oAblt:IsCooldownReady() then
            EventManager:fireEvent("Event_LastCDChange", {
                strAbltName = oAblt:GetAbilityName(),
                entity = self.m_eTarget,
                nCD = nAddCd + math.ceil(oAblt:GetCooldownTimeRemaining())
            })
        end
    end
    for i = 0, 8 do
        local oItem = self.m_eTarget:GetItemInSlot(i)
        if nil ~= oItem and not oItem:IsCooldownReady() then
            EventManager:fireEvent("Event_LastCDChange", {
                strAbltName = oItem:GetAbilityName(),
                entity = self.m_eTarget,
                nCD = nAddCd + math.ceil(oItem:GetCooldownTimeRemaining())
            })
        end
    end

    ----特效
    ---- AMHC:CreateParticle("particles/items4_fx/nullifier_mute_debuff.vpcf"
    ---- , PATTACH_POINT, false, oPlayer.m_eHero, 2)
    ----音效
    EmitGlobalSound("DOTA_Item.Nullifier.Cast")
    local info =    {
        Ability = nil,
        EffectName = "particles/items4_fx/nullifier_proj.vpcf",
        vSourceLoc = oPlayer.m_eHero:GetAttachmentOrigin(oPlayer.m_eHero:ScriptLookupAttachment("attach_hitloc")),
        iMoveSpeed = 2000,
        Target = self.m_eTarget,
        Source = oPlayer.m_eHero,
        bProvidesVision = true,
        bDodgeable = false,
        iVisionTeamNumber = oPlayer.m_eHero:GetTeamNumber(),
        iVisionRadius = 0,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    }
    ProjectileManager:CreateTrackingProjectile(info)

    local timeDelay = (self.m_eTarget:GetAbsOrigin() - oPlayer.m_eHero:GetAbsOrigin()):Length2D() / info.iMoveSpeed
    Timers:CreateTimer(timeDelay, function()
        EmitGlobalSound("DOTA_Item.Nullifier.Target")
    end)
end