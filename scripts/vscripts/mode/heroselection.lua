-----@class HeroSelection
if not HeroSelection then
    HeroSelection = {
        m_timeLast = TIME_SELECTHERO,
        m_allHeroName = {},
        m_AllHeroAbility = {},
        m_allSoldierAbility = {},
        m_RandomHeroPlayerID = {},
        m_SelectHeroPlayerID = {},
        m_PlayersSort = {},
    }
end
local this = HeroSelection

function this:init(bReload)
    print("PlayerManager.m_tabPlayers:");
    DeepPrint(PlayerManager.m_tabPlayers);
    local tab = KeyValues.HeroListKv
    -- local tab = KeyValues.HeroAbilityKv
    local SendTab = {};
    DeepPrintTable(tab)
    for k, v in pairs(tab) do
        table.insert(this.m_allHeroName, k)
    end
    DeepPrint(this.m_allHeroName)
    for k, v in pairs(tab) do
        for k1, v1 in pairs(KeyValues.HeroAbilityKv) do
            if k1 == k then
                local HeroAbility = {}
                table.insert(HeroAbility, v1["Ability1"])
                table.insert(HeroAbility, v1["Ability2"])
                this.m_AllHeroAbility[k] = HeroAbility
                print("k1" .. k1)
                print("v1")
                DeepPrint(v1)
                SendTab[k1] = v1;
            end
        end
        for m, n in pairs(KeyValues.SoldierAbilityKv) do
            if HERO_TO_BZ[k] == m then
                local SoldierAbility = {}
                table.insert(SoldierAbility, n["Ability1"])
                this.m_allSoldierAbility[k] = SoldierAbility
            end
        end
    end
    local AbilityTab = {
        tHeroAbilityName = this.m_AllHeroAbility,
        tSoldierAbilityName = this.m_allSoldierAbility
    }
    DeepPrint(AbilityTab)
    print("SendTab=========")
    DeepPrint(SendTab)
    CustomNetTables:SetTableValue("HeroSelection", "HeroList", SendTab)
    CustomNetTables:SetTableValue("HeroSelection", "AbilityName", AbilityTab)
    CustomGameEventManager:RegisterListener("SelectHero", this.SelectHero)
end
---选择英雄和随机英雄
function this:SelectHero(tabData)
    print("6[LUA]:SelectHero:Receive================>>>>>>>>>>>>>>>")
    DeepPrint(tabData)
    local player = PlayerResource:GetPlayer(tabData.nPlayerID)
    local HeroName
    if player ~= nil then
        print("tabData.nPlayerID:" .. tabData.nPlayerID)
        if nil == tabData.sHeroName then   ----接受的包没有英雄名字,说明是随机英雄
            print("PlayerResource:GetSelectedHeroName()=" .. PlayerResource:GetSelectedHeroName(tabData.nPlayerID))
            if PlayerResource:GetSelectedHeroName(tabData.nPlayerID) == "" then
                table.insert(this.m_RandomHeroPlayerID, tabData.nPlayerID)
                print("this.m_RandomHeroPlayerID:")
                DeepPrint(this.m_RandomHeroPlayerID);
                player:MakeRandomHeroSelection()
                print("PlayerResource:GetSelectedHeroName()=" .. PlayerResource:GetSelectedHeroName(tabData.nPlayerID))
                HeroName = PlayerResource:GetSelectedHeroName(tabData.nPlayerID)
                tabData.sHeroName = HeroName
            else
                return
            end
        else----接受的包有英雄名字,说明是选择英雄
            if not this:TableIsExistElement(this.m_allHeroName, tabData.sHeroName) then
                return
            end

            table.insert(this.m_SelectHeroPlayerID, tabData.nPlayerID)
            print("this.m_SelectHeroPlayerID:")
            DeepPrint(this.m_SelectHeroPlayerID);
            HeroName = tabData.sHeroName
        end
        if this:TableIsExistElement(this.m_allHeroName, HeroName) then
            player:SetSelectedHero(HeroName)
            local tab = {
                nPlayerID = tabData.nPlayerID,
                sHeroName = HeroName,
                SelectHeroSuccessOrFailure = 1
            }
            CustomGameEventManager:Send_ServerToAllClients("SelectHero", tab)
            this:TableRemoveElement(this.m_allHeroName, HeroName)
            this:AllPlayerSelectHero()
        end
    end
end
---判断所有玩家是否都选择了英雄
function this:AllPlayerSelectHero()
    for _, oPlayer in pairs(PlayerManager.m_tabPlayers) do
        if "" == PlayerResource:GetSelectedHeroName(oPlayer.m_nPlayerID) then
            return
        end
    end
    ----所有玩家都选完了英雄 
    this.GiveAllPlayersSort()
end
---给所有选择(随机)英雄的玩家排列先走的顺序
function this:GiveAllPlayersSort()
    local lenght = #this.m_RandomHeroPlayerID;
    for i = 1, lenght do
        local element = this:RandomElement(this.m_RandomHeroPlayerID)
        table.insert(this.m_PlayersSort, element)
        this:TableRemoveElement(this.m_RandomHeroPlayerID, element);
    end
    local lenght = #this.m_SelectHeroPlayerID;
    for i = 1, lenght do
        local element = this:RandomElement(this.m_SelectHeroPlayerID)
        table.insert(this.m_PlayersSort, element)
        this:TableRemoveElement(this.m_SelectHeroPlayerID, element);
    end
    for _, oPlayer in pairs(PlayerManager.m_tabPlayers) do
        oPlayer.m_nOprtOrder = this:GetPlayerIDIndex(oPlayer.m_nPlayerID)
    end
    print("[PlayersSort]:")
    DeepPrint(this.m_PlayersSort)
    CustomNetTables:SetTableValue("HeroSelection", "PlayersSort", this.m_PlayersSort)
end
---获得(this.m_PlayersSort)玩家ID对应的index
function this:GetPlayerIDIndex(PlayerID)
    for k, v in pairs(this.m_PlayersSort) do
        if v == PlayerID then
            return k
        end
    end
    return nil
end
---随机从表中取出一个元素
function this:RandomElement(tab)
    local index = RandomInt(1, #tab)
    local element = tab[index];
    return element;
end
---自动选择英雄(自动随机英雄)
function this:autoSelectHero()
    for _, oPlayer in pairs(PlayerManager.m_tabPlayers) do
        if - 1 == PlayerResource:GetSelectedHeroID(oPlayer.m_nPlayerID) then
            local tab = {
                nPlayerID = oPlayer.m_nPlayerID
            }
            this:SelectHero(tab)
            print("nil oPlayer.m_oCDataPlayer")
        end
    end
end
function this:AbilityName(tabData)
    ----预选英雄
    local SoldierName = HERO_TO_BZ[tabData.sHeroName]
    local HeroAbilityName = {}
    local SoldierAbilityName = {}
    if this:TableIsExistKey(this.m_AllHeroAbility, tabData.sHeroName) then
        local HeroAbility1 = this.m_AllHeroAbility[tabData.sHeroName]["Ability1"]
        local HeroAbility2 = this.m_AllHeroAbility[tabData.sHeroName]["Ability2"]
        table.insert(HeroAbilityName, HeroAbility1)
        table.insert(HeroAbilityName, HeroAbility2)
        print("HeroAbility1:" .. HeroAbility1)
        print("HeroAbility2:" .. HeroAbility2)
    end
    if this:TableIsExistKey(this.m_allSoldierAbility, SoldierName) then
        local SolldierAbility = this.m_allSoldierAbility[SoldierName]["Ability1"]
        table.insert(SoldierAbilityName, SolldierAbility)
        print("SolldierAbility:" .. SolldierAbility)
    end
    local tab = {
        nPlayerID = tabData.nPlayerID,
        sHeroName = tabData.sHeroName,
        tHeroAbilityName = HeroAbilityName,
        tSoldierAbilityName = SoldierAbilityName
    }
    ---- CustomGameEventManager:Send_ServerToPlayer(tabData.nPlayerID, "SelectHero", tab)
    DeepPrint(tab)
    CustomNetTables:SetTableValue("HeroSelection", "AbilityName", tab)
end
---判断表中是否存在该元素
function this:TableIsExistElement(tab, element)
    for k, v in pairs(tab) do
        if v == element then
            return true
        end
    end
    return false
end
---移除表中的元素
function this:TableRemoveElement(tab, element)
    for k, v in pairs(tab) do
        if v == element then
            table.remove(tab, k)
        end
    end
end
--判断表中是否纯在该key
function this:TableIsExistKey(tab, key)
    for k, v in pairs(tab) do
        if k == key then
            return true
        end
    end
    return false
end
function this:UpdateTime()
    Timers:CreateTimer(
    function()
        CustomNetTables:SetTableValue(
        "HeroSelection",
        "Time",
        {
            timeLast = this.m_timeLast
        }
        )
        if this.m_timeLast == 0 then
            this.autoSelectHero()
            return
        end
        this.m_timeLast = this.m_timeLast - 1
        return 1
    end
    )
end
function this:ClearNetTab()
    CustomNetTables:SetTableValue("HeroSelection", "HeroList", nil)
    CustomNetTables:SetTableValue("HeroSelection", "AbilityName", nil)
end
function this:Disconnect(PlayerID)
    local tabData = {
        nPlayerID = PlayerID
    }
    this:SelectHero(tabData);
end