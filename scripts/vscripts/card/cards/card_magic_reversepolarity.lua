-----两级反转
if nil == Card_MAGIC_ReversePolarity then
    ---@class Card_MAGIC_ReversePolarity : Card
    Card_MAGIC_ReversePolarity = class({}, nil, Card)
    if PrecacheItems then
        table.insert(PrecacheItems, "particles/units/heroes/hero_magnataur/magnataur_reverse_polarity.vpcf")
        table.insert(PrecacheItems, "soundevents/game_sounds_heroes/game_sounds_magnataur.vsndevts")
    end
end

---@type Card_MAGIC_ReversePolarity
local this = Card_MAGIC_ReversePolarity

----构造函数
function this:constructor(tInfo, nPlayerID)
    this.__base__.constructor(self, tInfo, nPlayerID)
end

----卡牌释放
function this:OnSpellStart()
    ---@type Player
    local owner = self:GetOwner()
    ----获取前方一格的位置
    local path = PathManager:getNextPath(owner.m_pathCur, 1 * owner.m_nMoveDir)
    if not path then
        return
    end

    ----其他玩家设置到该区域
    for _, player in pairs(PlayerManager.m_tabPlayers) do
        if player ~= owner
        and 0 == bit.band(PS_AbilityImmune + PS_InPrison + PS_Die + PS_AtkHero, player.m_typeState) then
            player:blinkToPath(path)
        end
    end

    ----特效
    EmitGlobalSound('Hero_Magnataur.ReversePolarity.Cast')
    local nPtclID = AMHC:CreateParticle('particles/units/heroes/hero_magnataur/magnataur_reverse_polarity.vpcf'
    , PATTACH_ABSORIGIN, false, owner.m_eHero, 3)
    ParticleManager:SetParticleControlEnt(nPtclID, 0, owner.m_eHero, PATTACH_POINT_FOLLOW, nil, owner.m_eHero:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(nPtclID, 1, Vector(500, 0, 0))
    ParticleManager:SetParticleControl(nPtclID, 2, Vector(0.3, 0, 0))
    ParticleManager:SetParticleControl(nPtclID, 3, path.m_entity:GetAbsOrigin())

    ----视角
    CameraManage:LookAt(-1, path.m_entity:GetAbsOrigin(), 0.1)
end