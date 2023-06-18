require('Path/Path')
require('Path/PathsDomain/PathDomain')
require('Path/PathsDomain/PathDomain_2')
require('Path/PathsDomain/PathDomain_6')
require('Path/PathsDomain/PathDomain_7')
require('Path/PathTP')
require('Path/PathTreasure')
require('Path/PathRune')
require('Path/PathPrison')
require('Path/PathMonster')
require('Path/PathSteps')
require('Path/PathStart')
require('Path/PathShop')

--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----路径工厂
PathFactory = {
}

----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
function PathFactory:create(e)

    local typePath = e:GetIntAttr('PathType')

    ----对应类型的子类
    if TP_DOMAIN_1 <= typePath and TP_DOMAIN_End > typePath then
        if TP_DOMAIN_2 == typePath then
            return PathDomain_2(e)
        elseif TP_DOMAIN_6 == typePath then
            return PathDomain_6(e)
        elseif TP_DOMAIN_7 == typePath then
            return PathDomain_7(e)
        end
        return PathDomain(e)
    elseif TP_TP == typePath then
        return PathTP(e)
    elseif TP_TREASURE == typePath then
        return PathTreasure(e)
    elseif TP_RUNE == typePath then
        return PathRune(e)
    elseif TP_PRISON == typePath then
        return PathPrison(e)
    elseif TP_STEPS == typePath then
        return PathSteps(e)
    elseif TP_START == typePath then
        return PathStart(e)
    elseif TP_MONSTER_1 == typePath or TP_MONSTER_2 == typePath or TP_MONSTER_3 == typePath then
        return PathMonster(e)
    elseif TP_SHOP_SIDE == typePath or TP_SHOP_SECRET == typePath then
        return PathShop(e)
    else
        return Path(e)
    end
end