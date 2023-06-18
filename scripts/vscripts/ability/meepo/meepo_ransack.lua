----技能：洗劫    英雄：米波
function onAblt_meepo_ransack(keys)
    local oPlayer = PlayerManager:getPlayerByHeroName("npc_dota_hero_meepo")
    if nil == oPlayer then
        return
    end

    print("===============")
    print("keys:",keys)
    print("oPlayer:",oPlayer)
    print("oPlayer.m_eHero:",oPlayer.m_eHero)
    print("===============")

    function containsString(array, searchString)
        for i, value in ipairs(array) do
            if value:GetName() == searchString then
                return i
            end
        end
        return 0
    end

    ----叠加buff
    local oBuff = oPlayer.m_eHero:FindAllModifiers()
    print("===============")
    print("oBuff:",oBuff)
    for i, value in ipairs(oBuff) do
        print(i,value:GetName())
    end
    print("===============")
    print("contain:",containsString(oBuff, "modifier_meepo_ransack"))
    local oIndex = containsString(oBuff, "modifier_meepo_ransack")
    if oIndex == 0 then
        local oAblt = oPlayer.m_eHero:FindAbilityByName(keys.ability:GetAbilityName())
        if not oAblt then
            oAblt = keys.ability
        end
        oBuff = oAblt:ApplyDataDrivenModifier(oPlayer.m_eHero, oPlayer.m_eHero, "modifier_meepo_ransack", {})
        oBuff:SetStackCount(1)
    else
        local nAdd = keys.ability:GetSpecialValueFor("addsh") + oBuff[oIndex]:GetStackCount()
        print("===============")
        print("oldgetstack",oBuff[oIndex]:GetStackCount())
        print("newsetstack",nAdd)
        print("===============")
        oBuff[oIndex]:SetStackCount(nAdd+1)
    end
end