if PrecacheItems then
    table.insert(PrecacheItems, "particles/econ/items/storm_spirit/storm_spirit_orchid_hat/storm_spirit_orchid.vpcf")
end

----紫苑
if nil == Card_ITEM_orchid then
    Card_ITEM_orchid = class({
    }, nil, Card)
    LinkLuaModifier("modifier_item_orchid_chenmo", "Card/Cards/Card_ITEM_orchid.lua", LUA_MODIFIER_MOTION_NONE)
end

----构造函数
function Card_ITEM_orchid:constructor(tInfo, nPlayerID)
    Card_ITEM_orchid.__base__.constructor(self, tInfo, nPlayerID)
end

function Card_ITEM_orchid:CastFilterResultTarget(hTarget)
    self.m_eTarget = hTarget
    if not self:CanUseCard(hTarget) then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
----能否在移动时释放
function Card_ITEM_orchid:isCanCastMove()
    return true
end
----能否在监狱时释放
function Card_ITEM_orchid:isCanCastInPrison()
    return true
end
----能否在攻击时释放
function Card_ITEM_orchid:isCanCastHeroAtk()
    return true
end
----能否对幻象释放
function Card_ITEM_orchid:isCanCastIllusion()
    return false
end
----能否对兵卒释放
function Card_ITEM_orchid:isCanCastBZ()
    return false
end
----能否对英雄释放
function Card_ITEM_orchid:isCanCastHero()
    return true
end
----能否对野怪释放
function Card_ITEM_orchid:isCanCastMonster()
    return false
end
----能否对监狱中玩家释放
function Card_ITEM_orchid:isCanCastInPrisonTarget()
    return true
end

----卡牌释放
function Card_ITEM_orchid:OnSpellStart()
    local player = PlayerManager:getPlayer(self:GetCaster():GetPlayerOwnerID())
    local playerTarget = PlayerManager:getPlayer(self:GetCursorTarget():GetPlayerOwnerID())
    if not player and not playerTarget then
        return
    end

    ----音效
    EmitGlobalSound("DOTA_Item.Orchid.Activate")

    ----给目标添加沉默
    -- self:GetCursorTarget():AddNewModifier(self:GetCaster(), nil, 'modifier_item_orchid_chenmo', nil)
    for _, v in pairs(playerTarget.m_tabBz) do
        AbilityManager:setCopyBuff('modifier_item_orchid_chenmo', v, player.m_eHero)
    end
    local buff = AbilityManager:setCopyBuff('modifier_item_orchid_chenmo', playerTarget.m_eHero, player.m_eHero)

    ----兵卒创建更新buff
    if buff then
        buff.unUpdataBZBuffByCreate = AbilityManager:updataBZBuffByCreate(playerTarget, nil, function(eBZ)
            AbilityManager:setCopyBuff('modifier_item_orchid_chenmo', eBZ, player.m_eHero)
        end)
    end

    ----监听结束
    -- local nDuration = 1
    -- EventManager:register("Event_PlayerRoundBegin", function(tEvent)
    --     if tEvent.oPlayer == player then
    --         if 1 == nDuration then
    --             ----移除buff
    --             for _, v in pairs(playerTarget.m_tabBz) do
    --                 if IsValid(v) then
    --                     v:RemoveModifierByNameAndCaster("modifier_item_orchid_chenmo", player.m_eHero)
    --                 end
    --             end
    --             if IsValid(playerTarget.m_eHero) then
    --                 playerTarget.m_eHero:RemoveModifierByNameAndCaster("modifier_item_orchid_chenmo", player.m_eHero)
    --             end
    --             unUpdataBZBuffByCreate()
    --             return true
    --         end
    --         nDuration = nDuration - 1
    --     end
    -- end)
end

----沉默buff
modifier_item_orchid_chenmo = class({})
function modifier_item_orchid_chenmo:IsDebuff()
    return true
end
function modifier_item_orchid_chenmo:IsPurgable()
    return true
end
function modifier_item_orchid_chenmo:GetTexture()
    return "item_orchid"
end
function modifier_item_orchid_chenmo:GetEffectName()
    return "particles/econ/items/storm_spirit/storm_spirit_orchid_hat/storm_spirit_orchid.vpcf"
end
function modifier_item_orchid_chenmo:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_item_orchid_chenmo:OnCreated(kv)
    ---- self.m_nDuration = self:GetAbility():GetSpecialValueFor("light_strike_array_stun_duration")
    if IsServer() and IsValid(self:GetCaster()) then
        self.m_nRound = 1
        AbilityManager:judgeBuffRound(self:GetCaster():GetPlayerOwnerID(), self)
    end
end
function modifier_item_orchid_chenmo:OnDestroy()
    if self.unUpdataBZBuffByCreate then
        self.unUpdataBZBuffByCreate()
    end
end
function modifier_item_orchid_chenmo:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
    }
    return funcs
end
function modifier_item_orchid_chenmo:GetBonusDayVision()
    if IsClient() then
        return 1
    end
end
function modifier_item_orchid_chenmo:CheckState()
    return {
        [MODIFIER_STATE_SILENCED] = true,
    }
end