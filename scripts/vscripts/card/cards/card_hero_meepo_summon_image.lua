require("Ability/meepo/LuaAbility_meepo_poof")
if PrecacheItems then
    table.insert(PrecacheItems, "particles/units/heroes/hero_meepo/meepo_loadout.vpcf")
end

-----米波 分则能成
if nil == Card_HERO_MEEPO_summon_image then
    -----@class Card_HERO_MEEPO_summon_image : Card 分则能成
    Card_HERO_MEEPO_summon_image = class({
        mTargetPath = nil,
    }, nil, Card)
end

-----@type Card_HERO_MEEPO_summon_image
local this = Card_HERO_MEEPO_summon_image

----构造函数
function this:constructor(tInfo, nPlayerID)
    this.__base__.constructor(self, tInfo, nPlayerID)
    self.m_typeCast = TCardCast_Pos
    self.m_tabAbltInfo = KeyValues.AbilitiesKv["LuaAbility_meepo_poof"]
    self.m_nManaCost = 10
    self.m_nManaCostBase = self.m_nManaCost
end

----选择目标单位时
----@param 目标单位
----@return UnitFilterResult枚举值    UF_SUCCESS(成功)| UF_FAIL_CUSTOM(失败,自定义错误)
function this:CastFilterResultLocation(tagPos)
    if not TESTCARD and not self:CanUseCard(nil, tagPos) then
        return UF_FAIL_CUSTOM
    end

    self.mTargetPath = nil
    for i, path in ipairs(PathManager.m_tabPaths) do
        local dis = (tagPos - path.m_entity:GetAbsOrigin()):Length2D()
        if dis < 80 then
            self.mTargetPath = path
            break
        end
    end

    if self.mTargetPath == nil then
        self.m_strCastError = "LuaAbilityError_TargetPath"
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end

----开始技能效果
function this:OnSpellStart()
    local side = Entities:FindByName(nil, "side" .. self.mTargetPath.m_nID)
    local path = self.mTargetPath
    local caster = self:GetCaster()
    local images_count = 1
    local illusions = CreateIllusions(caster, caster, { duration = -1, outgoing_damage = 0, incoming_damage = 0 }, images_count, 0, false, false)
    local illusion = illusions[1]
    illusion:SetOrigin(side:GetAbsOrigin())
    AMHC:AddAbilityAndSetLevel(illusion, "jiaoxie")
    AMHC:AddAbilityAndSetLevel(illusion, "no_bar")
    AMHC:AddAbilityAndSetLevel(illusion, "no_collision")
    AMHC:AddAbilityAndSetLevel(illusion, "magic_immune")
    AMHC:AddAbilityAndSetLevel(illusion, "rooted")
    illusion.m_path = path
    self:play(illusion)
end

function this:play(target)
    local oPlayer = self:GetOwner()
    local caster = self:GetCaster()
    local targetPath = self.mTargetPath

    ----离开的遁地特效
    local nPtclID = AMHC:CreateParticle("particles/units/heroes/hero_meepo/meepo_loadout.vpcf"
    , PATTACH_POINT, false, caster, 3)
    ----获取施法位置作用格数内的玩家
    local nRange = self:GetSpecialValueFor("range")
    ----获取伤害数值
    local nDamage = self:GetSpecialValueFor("poof_damage")
    local cBuff = oPlayer:getBuffByName("modifier_meepo_ransack")
    ----叠加洗劫提升的伤害
    nDamage = cBuff and nDamage + cBuff:GetStackCount() or nDamage
    ----获取伤害类型
    local nDamageType = self:GetAbilityDamageType()
    -----对玩家造成伤害
    local function atk(path)
        PlayerManager:findRangePlayer({}, path, nRange, nil, function(player)
            if player == oPlayer
            or 0 < bit.band(PS_AbilityImmune + PS_Die, player.m_typeState) then
                return false    ----排除死亡,自身,技能免疫
            end
            AMHC:Damage(caster, player.m_eHero, nDamage, nDamageType, this)
            return true
        end)
    end
    atk(oPlayer.m_pathCur)
    caster:SetOrigin(caster:GetOrigin() - Vector(0, 9999, 9999))
    Timers:CreateTimer(0.5, function()
        ----再现的遁地特效
        oPlayer:blinkToPath(targetPath)
        local nPtclID2 = AMHC:CreateParticle("particles/units/heroes/hero_meepo/meepo_loadout.vpcf"
        , PATTACH_POINT, false, caster, 3)
        ----再现声音
        EmitGlobalSound("Hero_Meepo.Poof.End")
        ----对玩家造成伤害
        atk(targetPath)
    end)

    CameraManage:LookAt(-1, targetPath.m_entity:GetAbsOrigin(), 0.5)
end