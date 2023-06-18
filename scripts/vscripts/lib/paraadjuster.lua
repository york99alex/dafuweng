--[[    用来修正平衡性常数的东西
    根据的是DOTA标准常数
    每点力量增加20点血
    每点智力12点蓝
    每点敏捷增加0.01点攻击速度
    每点敏捷增加0.2点护甲
 
    如果你设置的常数和这个常数不一致
    则需要同样拷贝本项目中
    scripts\npc\npc_abilities_custom.txt中的内容中关于
    ability_health_modifier
    ability_mana_modifier
    ability_atkspeed_modifier
    ability_armor_modifier
    四个技能的内容放到你自己的npc_abilities_custom.txt中
    之后在你的游戏模式的Init（确保在任何玩家选择出了任何英雄的时候）函数中
    require本文件，并调用 ParaAdjuster:Init()
]]
-- 初始化常数修正
if ParaAdjuster == nil then
    ParaAdjuster = class({})
end
function ParaAdjuster:Init()
    -- 监听单位出生事件
    -- ListenToGameEvent("npc_spawned", Dynamic_Wrap(ParaAdjuster, "OnNPCSpawned"), self)
    -- 监听玩家选择英雄事件
    ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(ParaAdjuster, "OnPlayerPicked"), self)
    -- 初始化变量
    self.__sth_para = 0
    self.__itm_para = 0
    self.__ats_para = 0
    self.__ata_para = 0
    -- 储存正在修正的单位列表
    self.__adjusting_units = {}
end

-- [Comment]
-- API: 设置每点力量加多少点血的平衡性常数
function ParaAdjuster:SetStrToHealth(value)
    self.__sth_para = value - 20
end
-- [Comment]
-- API: 设置每点智力加多少点蓝的平衡性常数
function ParaAdjuster:SetIntToMana(value)
    self.__itm_para = value - 12
end
-- [Comment]
-- API: 设置每点敏捷加多少点攻击速度的平衡性常数
function ParaAdjuster:SetAgiToAtkSpd(value)
    self.__ats_para = value - 0.01
end
-- [Comment]
-- API: 设置每点敏捷加多少点护甲的平衡性常数
function ParaAdjuster:SetAgiToAmr(value)
    self.__ata_para = value - 0.14
end

-- 当玩家选择英雄，若有设置某个常数，且和DOTA的不一样，则开始调用修正函数
function ParaAdjuster:OnPlayerPicked(event)
    local unit = EntIndexToHScript(event.heroindex)
    if self.__sth_para ~= 0 then
        self:ModifyData(unit, self.__sth_para, "health")
    end
    if self.__itm_para ~= 0 then
        self:ModifyData(unit, self.__itm_para, "mana")
    end
    if self.__ats_para ~= 0 then
        self:ModifyData(unit, self.__ats_para, "atkspeed")
    end
    if self.__ata_para ~= 0 then
        self:ModifyData(unit, self.__ata_para, "armor")
    end
    table.insert(self.__adjusting_units, unit)
end
-- 当某个单位创建，比如说，创造了幻象，英雄重生的时候，则相当于调用一次玩家选择英雄事件
function ParaAdjuster:OnNPCSpawned(event)
    local unit = EntIndexToHScript(event.entindex)
    if unit:IsHero() then
        if self.__adjusting_units.unit then
            -- 重置已经记录的数值，因为英雄死亡，或者其他情况下，可能会移除英雄的某个Modifier
            unit.__recorder__ = nil
            unit.__recorder__modified_data__ = nil
            self:OnPlayerPicked({ heroindex = unit:entindex() })
        end
    end
end

-- [Comment]
-- 修正函数
-- unit: 要修正的单位
-- data: 平衡性常数修正值，为相对DOTA标准数值的偏差，例如说你要设置力量-血量平衡性常数为15，那么这个data数值会为-4
-- mod_name: 修正类型
-- 如果你要修正你再自定义的某种数值，那么就需要你在npc_abilities_custom.txt中有
-- ability_[修正类型]_modifier这个技能
-- 这个技能中要有 modifier_[修正类型]_mod_[1,2,4,8,16,32,64,128,256,512,-1,-2,-4,-8,-16,-32,-64,-128,-256,-512]
-- 这些modifier，具体可以参考我写的 ability_health_modifier
-- 再在if mod_name == "health" then current_data = unit:GetStrength() modified_data = unit:GetMaxHealth() end这些行的位置
-- 增加你的当前数值内容和修正后的数值
-- 例如，要设置力量和生命回复的修正，这里就应该是
-- if mod_name == "health_regen" then current_data = unit:GetStrength() modified_data = unit:GetHealthRegen() end
-- 当然，你也可以更自由地设置
-- 比如说，设置每点智力增加金钱获取速度，每点敏捷增加[偷盗成功概率]什么的，2333
-- 貌似如果你设置的是一个自定义的数值，那么反倒容易一些，因为那样就没有必要这么复杂地用Modifier了
-- 举一反三，适当精简
--
function ParaAdjuster:ModifyData(unit, data, mod_name)
    -- 为单位启动循环计时器，这个计时器是为了尽量在单位的数值发生变更的时候，
    --unit:SetContextThink(DoUniqueString("modify_data"),
    local function funUpdata()
        -- 如果数据储存不存在，则初始化之
        if unit.__recorder__ == nil then unit.__recorder__ = {} end
        if unit.__recorder__modified_data__ == nil then unit.__recorder__modified_data__ = {} end
        if unit.__recorder__[mod_name] == nil then unit.__recorder__[mod_name] = 0 end
        if unit.__recorder__modified_data__[mod_name] == nil then unit.__recorder__modified_data__[mod_name] = 0 end

        -- 获取当前数值和修正后的对应数值
        local current_data = nil
        local modified_data = nil
        if mod_name == "health" then current_data = unit:GetStrength() modified_data = unit:GetMaxHealth() end
        if mod_name == "mana" then current_data = unit:GetIntellect() modified_data = unit:GetMaxMana() end
        if mod_name == "atkspeed" then current_data = unit:GetAgility() modified_data = unit:GetAttackSpeed() end
        if mod_name == "armor" then current_data = unit:GetAgility() modified_data = unit:GetPhysicalArmorValue() end

        -- 如果当前的数值和储存的数值不一致（则说明单位的力量等数值发生了变更）
        if current_data ~= unit.__recorder__[mod_name]
        -- or
            -- 或者修正后的数值和储存的修正后的数值不一致，（说明单位的Modifier可能受到了影响，这里先禁用）
            -- modified_data ~= unit.__recorder__modified_data__[mod_name]
            then
            -- 设置技能名称和对应的正数/负数Modifier名
            local ability_name = 'ability_' .. mod_name .. '_modifier'
            local mod_name_pos_prefix = 'modifier_' .. mod_name .. '_mod_'
            local mod_name_neg_prefix = 'modifier_' .. mod_name .. '_mod_neg_'

            -- 为单位增加修正的技能
            local ModifierAbility = unit:FindAbilityByName(ability_name)
            if not ModifierAbility then
                unit:AddAbility(ability_name)
                ModifierAbility = unit:FindAbilityByName(ability_name)
                ModifierAbility:SetLevel(1)
            end

            -- 二进制表
            local bitTable = { 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 }

            -- 循环单位的所有Modifier，如果存在这个Modifier，那么移除之
            local modCount = unit:GetModifierCount()
            for i = 0, modCount do
                for u = 1, #bitTable do
                    local val = bitTable[u]
                    if unit:GetModifierNameByIndex(i) == mod_name_pos_prefix .. val then
                        unit:RemoveModifierByName(mod_name_pos_prefix .. val)
                    end
                    if unit:GetModifierNameByIndex(i) == mod_name_neg_prefix .. val then
                        unit:RemoveModifierByName(mod_name_neg_prefix .. val)
                    end
                end
            end

            -- 计算需要修正的数值
            print("ZhiLi=" .. current_data)
            local to_modify_value = data * math.floor(current_data + 0.01)

            -- 正负数处理
            if to_modify_value > 0 then
                mod_prefix = mod_name_pos_prefix
            else
                mod_prefix = mod_name_neg_prefix
                to_modify_value = 0 - to_modify_value
            end
            -- 如果有很大的数据，大于1023，那么增加N个512先干到512以下
            if to_modify_value > 1023 then
                local out_count = math.floor(to_modify_value / 512)
                for i = 1, out_count do
                    ModifierAbility:ApplyDataDrivenModifier(unit, unit, mod_prefix .. "512", {})
                end
                to_modify_value = to_modify_value - out_count * 512
            end
            -- 循环增加Modifier，最终增加到正确个数的Modifier
            for p = 1, #bitTable do
                local val = bitTable[p]
                local count = math.floor(to_modify_value / val)
                if count >= 1 then
                    ModifierAbility:ApplyDataDrivenModifier(unit, unit, mod_prefix .. val, {})
                    to_modify_value = to_modify_value - val
                end
            end

            -- 为单位移除这个技能
            unit:RemoveAbility(ability_name)

            -- 再记录一次数值
            if mod_name == "health" then current_data = unit:GetStrength() modified_data = unit:GetMaxHealth() end
            if mod_name == "mana" then current_data = unit:GetIntellect() modified_data = unit:GetMaxMana() end
            if mod_name == "atkspeed" then current_data = unit:GetAgility() modified_data = unit:GetAttackSpeed() end
            if mod_name == "armor" then current_data = unit:GetAgility() modified_data = unit:GetPhysicalArmorValue() end

            -- 当然，千万别做什么1点力量增加0.5点智力，0.5点智力再增加1点力量这样的啥事来说我这个是个死循环了
            -- 你放哪里都会死循环的呀！
            unit.__recorder__[mod_name] = current_data
            unit.__recorder__modified_data__[mod_name] = modified_data
        end
        -- 0.2秒后再调用一次
        -- return 0.2
    end
    funUpdata()

    EventManager:register("Event_SxChange", function(tabEvent)
        if nil == unit or unit:IsNull() then
            return true
        end
        if tabEvent.entity ~= unit then
            return
        end
        funUpdata()
        Timers:CreateTimer(0.01, function()
            funUpdata()
        end)
    end)
    -- 0.2)
end