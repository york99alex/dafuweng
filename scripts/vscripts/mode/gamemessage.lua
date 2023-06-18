----游戏状态
GS_None = 0
GS_Begin = 1
GS_Wait = 2
GS_WaitOperator = 3
GS_Move = 4
GS_Finished = 5
GS_DeathClearing = 6
GS_Supply = 7           ----补给阶段
GS_ReadyStart = 8       ----准备开始
GS_End = 9

----操作类型
TypeOprt = {
    TO_Finish = 0       ----结束回合
    , TO_Roll = 1         ----roll点
    , TO_AYZZ = 2         ----安营扎寨
    , TO_GCLD = 3         ----攻城略地
    , TO_TP = 4           ----传送
    , TO_PRISON_OUT = 5   ----出狱
    , TO_AUCTION = 6
    , TO_DeathClearing = 7 ----死亡清算
    , TO_Supply = 8       ----补给轮抽
    , TO_AtkMonster = 9   ----打野
    , TO_RandomCard = 10  ----随机补给卡牌
    , TO_Free = 1000      ----以下为自由操作
    , TO_ZBMM = 1001      ----招兵买马
    , TO_YJXR = 1002      ----养精蓄锐
    , TO_XJGT = 1003      ----解甲归田
    , TO_TREASURE = 1004  ----秘藏探索
    , TO_TRADE = 1005     ----交易
    , TO_TRADE_BE = 1006      ----被交易
    , TO_SendAuction = 1007   ----发起拍卖
    , TO_BidAuction = 1008    ----竞价拍卖
    , TO_FinishAuction = 1009 ----竞拍结束
    , TO_UseCard = 1010       ----使用卡牌
    , TO_MultTrade = 1011     ----屏蔽交易玩家
}

----路径类型
TP_NONE = 0  ----无
TP_START = 1  ----起点
TP_TREASURE = 2  ----宝藏
TP_TP = 3  ----TP点
TP_RUNE = 4  ----神符
TP_UNKNOWN = 5  ----未知事件
TP_AUCTION = 6  ----拍卖行
TP_PRISON = 7  ----监狱
TP_ROSHAN = 8  ----肉山
TP_MONSTER_1 = 9  ----小野
TP_MONSTER_2 = 10  ----大野
TP_MONSTER_3 = 11  ----远古野
TP_DOMAIN_1 = 12  ----领地1号 天辉
TP_DOMAIN_2 = 13  ----领地2号 河道
TP_DOMAIN_3 = 14  ----领地3号 蛇沼
TP_DOMAIN_4 = 15  ----领地4号 夜魇
TP_DOMAIN_5 = 16  ----领地5号 龙谷
TP_DOMAIN_6 = 17  ----领地6号 鵰巢
TP_DOMAIN_7 = 18  ----领地7号 圣所
TP_DOMAIN_8 = 19  ----领地8号
TP_DOMAIN_End = 1000  ----领地结束
TP_STEPS = 1001   ----台阶
TP_SHOP_SIDE = 1002   ----边路商店
TP_SHOP_SECRET = 1003   ----神秘商店

----玩家状态
PS_None = 0
PS_Moving = 1               ----移动中
PS_AtkBZ = 2                ----兵卒可攻击
PS_AtkHero = 4              ----英雄可攻击
PS_MagicImmune = 8          ----魔免
PS_PhysicalImmune = 16      ----物免
PS_AbilityImmune = 32       ----技能免疫
PS_Rooted = 64              ----禁止移动
PS_Trading = 128            ----交易中
PS_Die = 256                ----死亡
PS_InPrison = 512           ----入狱
PS_AtkMonster = 1024        ----刷野
PS_Pass = 2048              ----跳过回合(被眩晕，睡眠等)
PS_Invis = 4096             ----隐身

----皮肤类型
TSink_TP = 1                ----TP特效
TSINK_FOOTPRINT = 2         ----足迹特效
TSINK_COURIER = 3           ----信使特效
TSink_END = 4

----皮肤品质
TSkinLevel_1 = 1            ----普通
TSkinLevel_2 = 2            ----稀有
TSkinLevel_3 = 4            ----神话
TSkinLevel_4 = 8            ----不休

----游戏记录类型
TGameRecord_Roll = 0        ----roll点
TGameRecord_AYZZ = 1        ----安营扎寨
TGameRecord_GCLD = 2        ----攻城略地
TGameRecord_YJXR = 3        ----养精蓄锐
TGameRecord_OnRune = 4      ----激活神符
TGameRecord_Treasure = 5    ----秘藏探索
TGameRecord_TP = 6          ----TP传送
TGameRecord_Trede = 7       ----交易
TGameRecord_InPrison = 8    ----进监狱(踩入)
TGameRecord_OutPrisonByGold = 9     ----出监狱(买活)
TGameRecord_OutPrisonByRoll = 10    ----出监狱(豹子)
TGameRecord_InPrisonByRoll = 11      ----进监狱(豹子)
TGameRecord_GoldDel = 12            ----扣钱
TGameRecord_GoldAdd = 13            ----加钱
TGameRecord_SendAuction = 14        ----发起拍卖
TGameRecord_BidAuction = 15         ----竞价
TGameRecord_FinishAuction = 16      ----完成拍卖
TGameRecord_XJ = 17                 ----解甲归田
TGameRecord_ChangeGold_Move = 18    ----移动时的金钱变化
TGameRecord_AtkMonster = 19     ----刷野战利品统计
TGameRecord_GCLD_Fail = 20      ----攻城略地失败
TGameRecord_GCLD_Win = 21       ----攻城略地成功
TGameRecord_OUTBZ = 22          ----起兵
TGameRecord_UseCard = 23        ----使用卡牌
TGameRecord_UseCardTarget = 24  ----使用卡牌（对目标）
TGameRecord_NoAuction = 25  ----无人竞拍
TGameRecord_DisconnetOutTime = 26  ----掉线超时
TGameRecord_InPrisonByStart = 27  ----地狱使者，开局入狱
TGameRecord_String = 1000       ----纯文本记录

----秘藏类型
TTreasure_Gold = 1          ----金币
TTreasure_Item = 2          ----装备
TTreasure_END = 3
---- TTreasure_Path = 3          ----领地
----卡牌类型
TCard_NONE = 0                              ----无
TCard_ITEM_arcane_boots = 1                 ----奥术鞋
TCard_ITEM_refresher = 2                    ----刷新球
TCard_ITEM_orchid = 3                       ----紫苑
TCard_ITEM_nullifier = 4                    ----否决
TCard_ITEM_blink = 5                        ----闪烁匕首
TCard_ITEM_crimson_guard = 6                ----赤红甲
TCard_ITEM_blade_mail = 7                   ----刃甲
TCard_ITEM_black_king_bar = 8               ----bkb 黑皇杖
TCard_HERO_LINA_laguna_blade = 10000        ----神灭斩
TCard_HERO_AXE_berserkers_call = 10001      ----狂战士之吼
TCard_HERO_ZUUS_thundergods_wrath = 10002   ----雷神之怒
TCard_HERO_PHANTOM_strike = 10003           ----恩赐解脱
TCard_HERO_MEEPO_summon_image = 10004       ----分则能成
TCard_MONSTER_small_hunting_ground = 10005          ----小型狩猎场
TCard_MONSTER_large_hunting_ground = 10006          ----大型狩猎场
TCard_MONSTER_ancient_forbidden_land = 10007        ----远古禁地
TCard_MONSTER_brush_field = 10008                   ----拉野
TCard_MAGIC_TP = 20000                      ----传送
TCard_MAGIC_Card_Steal = 20001              ----窃取
TCard_MAGIC_Swap = 20002                    ----移形换位
TCard_MAGIC_ReversePolarity = 20003         ----两级反转
TCard_MAGIC_Glimpse = 20004                 ----恶念瞥视
TCard_MAGIC_InfernalBlade = 20005           ----阎刃
TCard_MAGIC_Bottle = 20006                  ----魔瓶
TCard_MAGIC_BottleDouble = 20007            ----魔瓶（双倍神符）
TCard_MAGIC_BottleHaste = 20008             ----魔瓶（加速神符）
TCard_MAGIC_BottleIllusion = 20009          ----魔瓶（幻象神符）
TCard_MAGIC_BottleInvisibility = 20010      ----魔瓶（隐身神符）
TCard_MAGIC_BottleRegeneration = 20011      ----魔瓶（回复神符）
TCard_MAGIC_BottleBounty = 20012           ----魔瓶（赏金神符）
TCard_MAGIC_BottleArcane = 20013           ----魔瓶（奥术神符）
TCard_BUFF_Bloodrage = 30000                ----血怒
TCard_BUFF_TakeAim = 30001                  ----瞄准

----卡牌种类
CardKind_Item = 1   ----物品牌
CardKind_Magic = 2   ----法术牌
CardKind_Buff = 3   ----增幅牌

----卡牌施法类型
TCardCast_Nil = 1           ----无目标
TCardCast_Pos = 2           ----地点目标
TCardCast_Target = 4        ----单位目标

----购物状态
TBuyItem_None = 0           ----不能购买
TBuyItem_Side = 1           ----可够边路商店物品
TBuyItem_Secret = 2         ----可够神秘商店物品
TBuyItem_SideAndSecret = 3  ----可够边路和神秘商店物品