-----恶念瞥视
if nil == Card_MAGIC_Glimpse then
    ---@class Card_MAGIC_Glimpse : Card
    Card_MAGIC_Glimpse = class({}, nil, Card)
    if PrecacheItems then
        table.insert(PrecacheItems, "particles/units/heroes/hero_disruptor/disruptor_glimpse_targetstart.vpcf")
        table.insert(PrecacheItems, "particles/units/heroes/hero_disruptor/disruptor_glimpse_travel.vpcf")
        table.insert(PrecacheItems, "particles/units/heroes/hero_disruptor/disruptor_glimpse_targetend.vpcf")
        table.insert(PrecacheItems, "soundevents/game_sounds_heroes/game_sounds_disruptor.vsndevts")
    end
end

---@type Card_MAGIC_Glimpse
local this = Card_MAGIC_Glimpse

----构造函数
function this:constructor(tInfo, nPlayerID)
    this.__base__.constructor(self, tInfo, nPlayerID)
end
----能否对自身释放
function this:isCanCastSelf()
    return true
end

----卡牌释放
function this:OnSpellStart()
    local eTarget = self:GetCursorTarget()
    if not IsValid(eTarget) then
        return
    end
    ---@type Player
    local owner = self:GetOwner()
    ---@type Player
    local playerTarget = PlayerManager:getPlayer(eTarget:GetPlayerOwnerID())
    ----设置到上次的位置
    ---@type Path
    local path = playerTarget.m_pathLast
    if not path then
        path = playerTarget.m_pathCur
    end

    ----起始特效
    local nPtclID = AMHC:CreateParticle('particles/units/heroes/hero_disruptor/disruptor_glimpse_targetstart.vpcf'
    , PATTACH_POINT, false, owner.m_eHero, 3)
    ParticleManager:SetParticleControl(nPtclID, 0, playerTarget.m_eHero:GetAbsOrigin())
    nPtclID = AMHC:CreateParticle('particles/units/heroes/hero_disruptor/disruptor_glimpse_travel.vpcf'
    , PATTACH_POINT, false, owner.m_eHero, 3)
    ParticleManager:SetParticleControlEnt(nPtclID, 0, playerTarget.m_eHero, PATTACH_ABSORIGIN_FOLLOW, nil, playerTarget.m_eHero:GetOrigin(), true)
    ParticleManager:SetParticleControl(nPtclID, 1, path.m_entity:GetAbsOrigin())
    ParticleManager:SetParticleControl(nPtclID, 2, Vector(1, 1, 1))
    nPtclID = AMHC:CreateParticle('particles/units/heroes/hero_disruptor/disruptor_glimpse_targetend.vpcf'
    , PATTACH_POINT, false, owner.m_eHero, 3)
    ParticleManager:SetParticleControlEnt(nPtclID, 0, playerTarget.m_eHero, PATTACH_ABSORIGIN_FOLLOW, nil, playerTarget.m_eHero:GetOrigin(), true)
    ParticleManager:SetParticleControl(nPtclID, 1, path.m_entity:GetAbsOrigin())
    ParticleManager:SetParticleControl(nPtclID, 2, Vector(1, 1, 1))
    EmitGlobalSound('Hero_Disruptor.Glimpse.Target')

    ----特效球达到目的地
    Timers:CreateTimer(1, function()
        EmitGlobalSound('Hero_Disruptor.Glimpse.End')
        ----中断其他行为
        playerTarget:moveStop()
        EventManager:fireEvent("Event_ActionStop", {
            entity = playerTarget.m_eHero
        })
        playerTarget:blinkToPath(path)
        path:onPath(playerTarget)

        ----视角
        CameraManage:LookAt(playerTarget.m_nPlayerID, playerTarget.m_eHero:GetAbsOrigin(), 0.1)
        CameraManage:LookAt(owner.m_nPlayerID, playerTarget.m_eHero:GetAbsOrigin(), 0.1)
    end)
end