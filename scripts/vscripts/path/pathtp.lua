--[[d Class【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Class]]
----
----TP传送点路径
if nil == PathTP then
    PathTP = class({
        m_eCity = nil				----建筑点实体
        , m_eBanner = nil           ----横幅旗帜实体
        , m_nPrice = nil			----价值
        , m_nOwnerID = nil			----领主玩家ID
    }, nil, Path)
end
----
--[[d API【【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】API]]
----
----构造函数
function PathTP:constructor(e)
    self.__base__.constructor(self, e)

    self.m_eCity = Entities:FindByName(nil, "city_" .. self.m_nID)
    self.m_eBanner = Entities:FindByName(nil, "banner_" .. self.m_nID)
    print("self.m_eBanner.GetClassname()",self.m_eBanner:GetClassname())
    self:setBanner()

    self.m_nPrice = PATH_TO_PRICE[self.m_typePath]
end

----触发路径
function PathTP:onPath(oPlayer, ...)
    self.__base__.onPath(self, oPlayer, ...)

    if nil == self.m_nOwnerID then
        ----无主之地,发送安营扎寨操作
        local tabOprt = {}
        tabOprt.nPlayerID = oPlayer.m_nPlayerID
        tabOprt.typeOprt = TypeOprt.TO_AYZZ
        tabOprt.typePath = self.m_typePath
        tabOprt.nPathID = self.m_nID

        GMManager:autoOprt(tabOprt.typeOprt, oPlayer)    ----操作前处理上一个（如果有的话）
        GMManager:sendOprt(tabOprt)
    elseif oPlayer.m_nPlayerID == self.m_nOwnerID then
        ----己方TP点,给传送卡牌
        local card = CardFactory:create(TCard_MAGIC_TP, oPlayer.m_nPlayerID)
        if card then
            oPlayer:setCardAdd(card)
        end

        ----己方TP点,发送传送操作
        -- if 2 <= #oPlayer.m_tabMyPath[self.m_typePath] then
        --     local tabOprt = {}
        --     tabOprt.nPlayerID = oPlayer.m_nPlayerID
        --     tabOprt.typeOprt = TO_TP
        --     tabOprt.typePath = self.m_typePath
        --     tabOprt.nPathID = self.m_nID
        --     tabOprt.json = {}
        --     local tabAllTP = PathManager:getPathByType(TP_TP)
        --     for i = #tabAllTP, 1, -1 do
        --         tabOprt.json[tabAllTP[i].m_nID] = tabAllTP[i].m_nOwnerID or -1
        --     end
        --     tabOprt.json = json.encode(tabOprt.json)
        --     GMManager:autoOprt(tabOprt.typeOprt, oPlayer)    ----操作前处理上一个（如果有的话）
        --     GMManager:sendOprt(tabOprt)
        --     EventManager:register("Event_CurPathChange", function(tEvent)
        --         if tEvent.player == oPlayer and self ~= oPlayer.m_pathCur then
        --             GMManager:autoOprt(TO_TP, oPlayer)
        --         end
        --     end)
        -- end
    else
        ----敌方TP点,交过路费
        local oPlayerOW = PlayerManager:getPlayer(self.m_nOwnerID)
        ----领主未进监狱
        if 0 == bit.band(PS_InPrison, oPlayerOW.m_typeState) then
            local nGold = PATH_TOLL_TP[#oPlayerOW.m_tabMyPath[self.m_typePath]]
            oPlayer:giveGold(nGold, oPlayerOW)
            GMManager:showGold(oPlayerOW, nGold)
            GMManager:showGold(oPlayer, -nGold)
            ----给钱音效
            EmitGlobalSound("Custom.Gold.Sell")
        end
    end
end

----设置横幅旗帜
function PathTP:setBanner(strHeroName)
    if nil == strHeroName then
        self.m_eBanner:SetOrigin(self.m_eCity:GetOrigin() - Vector(0, 0, 1000))
    else
        self.m_eBanner:SetOrigin(self.m_eCity:GetOrigin())
        self.m_eBanner:SetSkin(HERO_TO_BANNER[strHeroName])
    end
end

----设置领主
function PathTP:setOwner(oPlayer)
    if nil == oPlayer then
        self:setState(TypePathState.None)
        self:setBanner()
        self.m_nOwnerID = nil
    else
        ----占领音效
        EmitGlobalSound("Custom.AYZZ")

        self:setBanner(oPlayer.m_eHero:GetUnitName())
        self.m_nOwnerID = oPlayer.m_nPlayerID
    end
end

----传送
function PathTP:TP(oPlayer)

    ----特效
    SkinManager:setSink(TSink_TP, oPlayer.m_eHero, self.m_entity)
    EmitSoundOn("Custom.TP.Begin", oPlayer.m_eHero)

    ----传送动作2.5秒
    -- local typeState = GMManager.m_typeState
    -- GMManager:setState(GS_Wait)
    self._YieldStateCO = GSManager:yieldState()
    GSManager:setState(GS_Wait)
    oPlayer.m_eHero:StartGesture(ACT_DOTA_TELEPORT)
    Timers:CreateTimer(2.5, function()
        ----传送
        StopSoundOn("Custom.TP.Begin", oPlayer.m_eHero)
        EmitSoundOn("Custom.TP.End", oPlayer.m_eHero)

        oPlayer.m_eHero:RemoveGesture(ACT_DOTA_TELEPORT)
        oPlayer.m_eHero:StartGesture(ACT_DOTA_TELEPORT_END)

        if 0 < bit.band(PS_InPrison, oPlayer.m_typeState) then
            return
        end
        ---- oPlayer.m_eHero:RemoveGesture(ACT_DOTA_TELEPORT_END)
        oPlayer:blinkToPath(self)
        -- if GS_Wait == GMManager.m_typeState then
        --     GMManager:setState(typeState)
        -- end
        GSManager:resumeState(self._YieldStateCO)
    end)
end