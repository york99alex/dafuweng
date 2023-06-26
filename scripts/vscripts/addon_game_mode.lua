-- Generated from template
_G.PrecacheItems = {}
require('GMManager')

function Precache(context)
    --[[		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
    --PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phantom_assassin.vsndevts", context )
    --PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts", context )
    --PrecacheUnitByNameSync("bz_pa",context)
    for k, v in pairs(KeyValues.AbilitiesKv) do
        if k ~= "Version" then
            if v.precache then
                for precacheMode, resource in pairs(v.precache) do
                    PrecacheResource(precacheMode, resource, context)
                end
            end
        end
    end
    for k, v in pairs(KeyValues.ItemsKv) do
        if k ~= "Version" then
            if v.precache then
                for precacheMode, resource in pairs(v.precache) do
                    PrecacheResource(precacheMode, resource, context)
                end
            end
        end
    end
    for k, v in pairs(KeyValues.UnitsKv) do
        if k ~= "Version" then
            PrecacheUnitByNameSync(k, context)
        end
    end
    for k, v in pairs(KeyValues.ItemsKv) do
        if k ~= "Version" then
            PrecacheItemByNameSync(k, context)
        end
    end
    for k, v in pairs(KeyValues.SkinsKv) do
        if 'particle' == v.kind then
            for k2, v2 in pairs(v) do
                if k2 ~= "kind" then
                    for k3, v3 in pairs(v2) do
                        table.insert(_G.PrecacheItems, v3.EffectName)
                    end
                end
            end
        elseif 'courier' == v.kind then
            for k2, v2 in pairs(v) do
                if k2 ~= "kind" then
                    table.insert(_G.PrecacheItems, v2.Model)
                    table.insert(_G.PrecacheItems, v2.ModelFlying)
                    table.insert(_G.PrecacheItems, v2.EffectName)
                    table.insert(_G.PrecacheItems, v2.EffectNameFlying)
                end
            end
        end
    end

    _G.PrecacheItems = concat({
        "soundevents/game_sounds.vsndevts"
        , "soundevents/game_sounds_ambient.vsndevts"
        , "soundevents/game_sounds_cny.vsndevts"
        , "soundevents/game_sounds_creeps.vsndevts"
        , "soundevents/soundevents_conquest.vsndevts"
        , "soundevents/game_sounds_greevils.vsndevts"
        , "soundevents/game_sounds_hero_pick.vsndevts"
        , "soundevents/game_sounds_items.vsndevts"
        , "soundevents/game_sounds_roshan_halloween.vsndevts"
        , "soundevents/game_sounds_ui_imported.vsndevts"
        , "soundevents/soundevents_dota.vsndevts"
        , "soundevents/soundevents_dota_ui.vsndevts"
        , "soundevents/soundevents_minigames.vsndevts"
        , "soundevents/soundevents_music_util.vsndevts"
        , "soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts"
        -- , "soundevents/game_sounds_heroes/game_sounds_phantom_assassin.vsndevts"
        , "soundevents/game_sounds_heroes/game_sounds_slardar.vsndevts"
        , "soundevents/game_sounds_heroes/game_sounds_medusa.vsndevts"
        , "soundevents/game_sounds_heroes/game_sounds_shadowshaman.vsndevts"
        , "soundevents/game_sounds_heroes/game_sounds_doombringer.vsndevts"
        , "soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts"
        , "soundevents/game_sounds_heroes/game_sounds_lina.vsndevts"
        , "soundevents/custom_sounds.vsndevts"

        , "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf"
    }, _G.PrecacheItems)

    print("Precache...")

    local t = Table_maxn(_G.PrecacheItems)
    for i = 1, t do
        if string.find(_G.PrecacheItems[i], ".vpcf") then
            PrecacheResource("particle", _G.PrecacheItems[i], context)
        elseif string.find(_G.PrecacheItems[i], ".vsndevts") then
            PrecacheResource("soundfile", _G.PrecacheItems[i], context)
        elseif string.find(_G.PrecacheItems[i], ".vmdl") then
            PrecacheResource("model", _G.PrecacheItems[i], context)
        end
    end
    print("Precache OK")
    _G.PrecacheItems = nil
end

-- Create the game mode when we activate
function Activate()
    --游戏初始化
    GameRules.AddonTemplate = GMManager
    GameRules.AddonTemplate:init()

    _G.ATTACK_EVENTS_DUMMY = CreateModifierThinker(GameRules:GetGameModeEntity(), nil, "modifier_events", nil, Vector(0, 0, 0), DOTA_TEAM_NOTEAM, false)
end

if IsInToolsMode() then
    GameRules:Playtesting_UpdateAddOnKeyValues()
end

--HTTP请求
function SendHTTP(url, callback, fail_callback)
    local str0 = url
    local str1 = ''
    local str2 = ''
    local str3 = ''
    local usercheck = 0
    local x1 = string.find(str0, '@', 1)
    if x1 then
        usercheck = 1
        str1 = string.sub(str0, x1 + 1, -1)
    else
        str1 = str0
    end
    local x2 = string.find(str1, '@', 1)
    if x2 then
        str2 = string.sub(str1, 0, x2 - 1)
    else
        str2 = str1
    end
    local x3 = string.find(str2, '?', 1)
    if x3 then
        str3 = string.sub(str2, 0, x3 - 1)
    else
        str3 = str2
    end
    if usercheck == 1 then
        local usertable = string.split(str3, ',')
        for _, userid in pairs(usertable) do
            if userid then
                if not string.find(GameRules:GetGameModeEntity().steamidlist, userid, 1) and not string.find(GameRules:GetGameModeEntity().steamidlist_heroindex, userid, 1) then
                    return
                end
            end
        end
    end
    local req = CreateHTTPRequestScriptVM('GET', url)
    req:SetHTTPRequestAbsoluteTimeoutMS(20000)

    req:Send(function(res)

        if res.StatusCode ~= 200 or not res.Body then
            if fail_callback ~= nil then
                fail_callback(obj)
            end
            return
        end

        local obj = json.decode(res.Body)
        if callback ~= nil then
            callback(obj)
        end
    end)
end
function prt(t)
    GameRules:SendCustomMessage('' .. t, 0, 0)
end

if GameRules.AddonTemplate then
    print("reload")
    GameRules.AddonTemplate:init(true)
end
_PrintTable = PrintTable
_DeepPrint = DeepPrint
_DeepPrintTable = DeepPrintTable
function PrintTable(...)
    if DEBUG then
        _PrintTable()
    end
end
function DeepPrint(...)
    if DEBUG then
        _DeepPrint()
    end
end
function DeepPrintTable(...)
    if DEBUG then
        _DeepPrintTable()
    end
end