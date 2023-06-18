--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----神符路径
if nil == PathRune then
    PathRune = class({
        m_eSpawn = nil          ----神符生产实体
        , m_eRune = nil         ----神符实体
        , m_nPtclID = nil       ----神符粒子特效ID
        , m_nUpdateRound = nil       ----更换神符回合
        , m_typeRune = nil      ----神符类型
        , m_typeRuneLast = nil  ----上次类型
    }, nil, Path)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function PathRune:constructor(e)
    self.__base__.constructor(self, e)
    self.m_eSpawn = Entities:FindByClassnameNearest("dota_item_rune_spawner", self.m_entity:GetOrigin(), 50)
    if nil == self.m_eSpawn then
        error("not find dota_item_rune_spawner!!!")
    end

    local tabPath = PathManager:getPathByType(TP_RUNE)
    if 0 == #tabPath or DOTA_RUNE_BOUNTY ~= tabPath[1].m_typeRuneLast then
        self.m_typeRuneLast = DOTA_RUNE_BOUNTY
    else
        self.m_typeRuneLast = DOTA_RUNE_INVALID
    end


    ----监听游戏回合更新：每两回合刷符
    EventManager:register("Event_GameStart", function()
        -- if 0 == GMManager.m_nRound % 2 then
        -- if 1 == GMManager.m_nRound then
        self:spawnRune()
        return true
        -- end
    end)
    EventManager:register('Event_UpdateRound', self.onEvent_UpdateRound, self)
end

----触发路径
function PathRune:onPath(oPlayer, ...)
    self.__base__.onPath(self, oPlayer, ...)

    if nil == self.m_eRune then
        return
    end

    ----玩家激活神符
    self:onRune(oPlayer, self.m_typeRune)
    self:destoryRune()
    Timers:CreateTimer(2, function()
        self:spawnRune()
    end)
end

----激活某神符
function PathRune:onRune(oPlayer, typeRune)
    if not RUNE_SETTINGS[typeRune] then
        return
    end
    EmitGlobalSound(RUNE_SETTINGS[typeRune].sound)
    ----设置游戏记录
    GameRecord:setGameRecord(TGameRecord_OnRune, oPlayer.m_nPlayerID, {
        typeRune = typeRune
    })

    ----隐身时在攻击状态中断
    if DOTA_RUNE_INVISIBILITY == typeRune then
        oPlayer:moveStop()
        EventManager:fireEvent("Event_ActionStop", {
            entity = oPlayer.m_eHero,
            bMoveBack = true,
        })
    end

    ----设置神符效果技能
    AMHC:AddAbilityAndSetLevel(oPlayer.m_eHero, "rune_" .. typeRune, 1)
end

----销毁神符
function PathRune:destoryRune()
    self.m_typeRuneLast = self.m_typeRune

    ParticleManager:DestroyParticle(self.m_nPtclID, false)
    self.m_nPtclID = nil

    self.m_eRune:RemoveSelf()
    self.m_eRune = nil
end

----刷新神符
function PathRune:spawnRune()

    ----销毁当前神符
    if nil ~= self.m_eRune then
        self:destoryRune()
    end

    if DOTA_RUNE_BOUNTY == self.m_typeRuneLast then
        ----上次是赏金这次不是
            repeat
            self.m_typeRune = RandomInt(DOTA_RUNE_INVALID + 1, DOTA_RUNE_COUNT - 1)
        until (DOTA_RUNE_BOUNTY ~= self.m_typeRune and RUNE_SETTINGS[self.m_typeRune])
    else
        self.m_typeRune = DOTA_RUNE_BOUNTY
    end
    self.m_eRune = self:createRune(self.m_eSpawn:GetAbsOrigin(), self.m_typeRune)

    ----俩回合更换
    self.m_nUpdateRound = GMManager.m_nRound + 2
end

----创建神符
function PathRune:createRune(v3Pos, typeRune)
    local settings = RUNE_SETTINGS[typeRune]
    if settings.z_modify then
        v3Pos.z = v3Pos.z + settings.z_modify
    end
    local entity = CreateUnitByName("rune_" .. typeRune, v3Pos, false, nil, nil, DOTA_TEAM_NEUTRALS)
    self.m_typeRune = typeRune
    entity.m_bRune = true
    entity.m_path = self
    entity:SetModel(settings.model)
    entity:SetOriginalModel(settings.model)
    -- entity:SetAbsOrigin(v3Pos)
    self.m_nPtclID = ParticleManager:CreateParticle(settings.particle, settings.particle_attach or PATTACH_ABSORIGIN_FOLLOW, entity)
    entity:StartGesture(ACT_DOTA_IDLE)
    return entity
end

----游戏回合更新，更新神符
function PathRune:onEvent_UpdateRound(tEvent)
    if self.m_nUpdateRound and self.m_nUpdateRound <= GMManager.m_nRound then
        self:spawnRune()
    end
end

if PrecacheItems then
    table.insert(PrecacheItems, "particles/generic_gameplay/rune_doubledamage.vpcf")
    table.insert(PrecacheItems, "particles/generic_gameplay/rune_haste.vpcf")
    table.insert(PrecacheItems, "particles/generic_gameplay/rune_illusion.vpcf")
    table.insert(PrecacheItems, "particles/generic_gameplay/rune_invisibility.vpcf")
    table.insert(PrecacheItems, "particles/generic_gameplay/rune_regeneration.vpcf")
    table.insert(PrecacheItems, "particles/generic_gameplay/rune_bounty.vpcf")
    table.insert(PrecacheItems, "particles/generic_gameplay/rune_arcane.vpcf")
end

----神符信息
RUNE_SETTINGS = {
    ----双倍
    [DOTA_RUNE_DOUBLEDAMAGE] = {
        model = "models/props_gameplay/rune_doubledamage01.vmdl",
        particle = "particles/generic_gameplay/rune_doubledamage.vpcf",
        sound = "Rune.DD"
    },
    ----极速
    [DOTA_RUNE_HASTE] = {
        model = "models/props_gameplay/rune_haste01.vmdl",
        particle = "particles/generic_gameplay/rune_haste.vpcf",
        sound = "Rune.Haste"
    },
    ----幻象
    -- [DOTA_RUNE_ILLUSION] = {
    --     model = "models/props_gameplay/rune_illusion01.vmdl",
    --     particle = "particles/generic_gameplay/rune_illusion.vpcf",
    --     sound = "Rune.Illusion",
    -- },
    ----隐身
    [DOTA_RUNE_INVISIBILITY] = {
        model = "models/props_gameplay/rune_invisibility01.vmdl",
        particle = "particles/generic_gameplay/rune_invisibility.vpcf",
        sound = "Rune.Invis",
    },
    ----回复
    [DOTA_RUNE_REGENERATION] = {
        model = "models/props_gameplay/rune_regeneration01.vmdl",
        particle = "particles/generic_gameplay/rune_regeneration.vpcf",
        sound = "Rune.Regen"
    },
    ----赏金
    [DOTA_RUNE_BOUNTY] = {
        model = "models/props_gameplay/rune_goldxp.vmdl",
        particle = "particles/generic_gameplay/rune_bounty.vpcf",
        sound = "Rune.Bounty"
    },
    ----奥数
    [DOTA_RUNE_ARCANE] = {
        model = "models/props_gameplay/rune_arcane.vmdl",
        particle = "particles/generic_gameplay/rune_arcane.vpcf",
        sound = "Rune.Arcane"
    }
}