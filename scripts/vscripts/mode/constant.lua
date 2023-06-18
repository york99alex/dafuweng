require("mode/GameMessage")
----
--[[d Constant【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Constant]]
----
print("VERSION : 0.8.44")
TESTHELP = false
TESTHELP_ALLPATH = false		----占领全部地
TESTCARD = false				----快速卡牌
TESTITEM = false				----全图装备
TESTFREE = false				----自由移动
ERRORUPLOAD = true			 ----错误提交

DEBUG = false
function NIL(o) return not DEBUG and nil == o end
function NULL(c) return not DEBUG and (nil == c or c:IsNull()) end

GAME_MODE_ALLPATH = 1		----全地起兵
GAME_MODE_ONEPATH = 2		----单地起兵
GAME_MODE = GAME_MODE_ONEPATH

TypePathState = {
	None = 0,
	Trade = 1, ---- 交易
	Auction = 2, ---- 拍卖
}

TIME_SELECTHERO = TESTHELP and 9999 or 30		----选择英雄时间  /1s
TIME_OPERATOR = TESTHELP and 201 or 201		----回合操作时限  /0.1s
TIME_OPERATOR_DISCONNECT = 51		----回合操作时限（掉线）  /0.1s
TIME_BAOZI_YZ = 100			----豹子加时阈值  /0.1s
TIME_BAOZI_ADD = 50			----豹子加时时值  /0.1s
TIME_SUPPLY_READY = 101	 ----补给操作时限  /0.1s
TIME_SUPPLY_OPRT = 101	  ----补给操作时限  /0.1s
TIME_OUT_DISCONNECT = 300	  ----掉线超时  /1s
PRISON_BAOZI_COUNT = 3		----入狱豹子数
BZ_MAX_LEVEL = 3			----兵卒最大等级
BZ_HUIMO_RATE_Y = TESTHELP and 0.5 or 0.5		 ----远程兵卒回魔率
BZ_HUIMO_RATE_J = 0.4	   ----近战兵卒回魔率
BZ_HUIMO_BEATK_RATE = 0.4   ----兵卒受伤回魔率
TIME_MOVEKASI = 100		 ----寻路卡死检测时间阈值  /0.1s
PATH_TOLL_RATE = 0.5		----过路费率
PATH_TOLL_TP = { 100, 200, 300, 400 }	   ----TP点过路费
AUCTION_ADD_GOLD = 100					  ----拍卖最低加价
AUCTION_BID_TIME = 10					   ----竞拍倒计时时间
INITIAL_GOLD = 3000		 ----初始金币
WAGE_GOLD = 1000		 ----工资金币
WAGE_GOLD_REDUCE = 100   ----每圈工资降低
GLOBAL_SHOP_ROUND = 25		 ----全图购物回合
ROUNT_HERO_HUIXUE_ROTA = 0.15		----英雄每回合回血百分百
ROUNT_BZ_HUIXUE_ROTA = 0		----兵卒每回合回血百分百
GOLD_OUT_PRISON = 300		----出狱金币
SKIN_RANDOM_GOLD = 30		----抽奖消耗

----每等级经验
LEVEL_EXP = {
	[1] = 0,
	[2] = 1,
	[3] = 2,
	[4] = 3,
	[5] = 4,
	[6] = 6,
	[7] = 8,
	[8] = 10,
	[9] = 12,
	[10] = 14,
	[11] = 16,
	[12] = 18,
	[13] = 20,
	[14] = 22,
	[15] = 24,
	[16] = 27,
	[17] = 30,
	[18] = 33,
	[19] = 36,
	[20] = 39,
	[21] = 42,
	[22] = 45,
	[23] = 48,
	[24] = 51,
	[25] = 54
}
----补给回合
SUPPLY_ROUNT = {
	1, 5, 10, 15, 20
}
----每回合补给的开启回合
SUPPLY_ALL_ROUND = 30
----补给品数量
SUPPLY_COUNT = {
	0, 3, 4, 5, 6, 7
}
----自定义队伍
CUSTOM_TEAM = {
	DOTA_TEAM_CUSTOM_1,
	DOTA_TEAM_CUSTOM_2,
	DOTA_TEAM_CUSTOM_3,
	DOTA_TEAM_CUSTOM_4,
	DOTA_TEAM_CUSTOM_5,
	DOTA_TEAM_CUSTOM_6,
}

----兵卒属性效果
ATTRIBUTE_STRENGTH_HP = 20									---- 力量增加生命值
ATTRIBUTE_STRENGTH_HP_REGEN = 0 							---- 力量增加生命回复值
ATTRIBUTE_STRENGTH_MAGICAL_RESISTANCE = 0.08				---- 力量增加魔法抗性
ATTRIBUTE_STRENGTH_PHYSICAL_DAMAGE_PERCENT = 0				---- 力量增加物理伤害百分比
ATTRIBUTE_AGILITY_ATTACK_SPEED = 1							---- 敏捷增加攻速
ATTRIBUTE_AGILITY_PHYSICAL_ARMOR = 0.16						---- 敏捷增加护甲
ATTRIBUTE_AGILITY_COOLDOWN_REDUCTION_PERCENT = 0			---- 敏捷减少技能冷却百分比
ATTRIBUTE_INTELLIGENCE_MANA = 0 							---- 智力增加魔法值
ATTRIBUTE_INTELLIGENCE_MANA_REGEN = 0   					---- 智力增加魔法回复值
ATTRIBUTE_INTELLIGENCE_MAGICAL_DAMAGE_PERCENT = 0		---- 智力增加魔法伤害百分比
ATTRIBUTE_INTELLIGENCE_SPELL_AMPLIFY_PERCENT = 0.5		---- 智力增加技能增强百分比
ATTRIBUTE_PRIMARY_ATTACK_DAMAGE = 1

----每级兵卒攻城失败金币
GCLD_GOLD = {
	100, 200, 300
}
----攻城兵卒经验
GCLD_EXP = {
	1, 2, 3
}
----每级兵卒等级上限
BZ_LEVELMAX = {
	9, 19, 25
}
-- BZ_OUT_ROUNT = 6		  ----起兵回合
BZ_OUT_ROUNT = DEBUG and 1 or 6		  ----起兵回合
----英雄对应兵卒名
HERO_TO_BZ = {
	npc_dota_hero_phantom_assassin = "bz_pa_1"
	, npc_dota_hero_meepo = "bz_mibo_1"
	, npc_dota_hero_pudge = "bz_tufu_1"
	, npc_dota_hero_lina = "bz_lina_1"
	, npc_dota_hero_zuus = "bz_zuus_1"
	, npc_dota_hero_axe = "bz_axe_1"
	, npc_dota_hero_techies = "bz_techies_1"
	, npc_dota_hero_bloodseeker = "bz_bloodseeker_1"
	, npc_dota_hero_dragon_knight = "bz_dragon_knight_1"
	, npc_dota_hero_undying = "bz_undying_1"
	, npc_dota_hero_life_stealer = "bz_life_stealer_1"
}

----英雄对应横幅旗帜
HERO_TO_BANNER = {
	npc_dota_hero_phantom_assassin = 1
	, npc_dota_hero_meepo = 2
	, npc_dota_hero_pudge = 3
	, npc_dota_hero_lina = 4
	, npc_dota_hero_zuus = 5
	, npc_dota_hero_axe = 6
	, npc_dota_hero_techies = 7
	, npc_dota_hero_bloodseeker = 8
	, npc_dota_hero_dragon_knight = 9
	, npc_dota_hero_undying = 10
	, npc_dota_hero_life_stealer = 10
}

----领地对应价值
PATH_TO_PRICE = {}
if GAME_MODE == GAME_MODE_AllPATH then
	PATH_TO_PRICE[TP_DOMAIN_1] = 200
	PATH_TO_PRICE[TP_DOMAIN_2] = 300
	PATH_TO_PRICE[TP_DOMAIN_3] = 300
	PATH_TO_PRICE[TP_DOMAIN_4] = 350
	PATH_TO_PRICE[TP_DOMAIN_5] = 400
	PATH_TO_PRICE[TP_DOMAIN_6] = 450
	PATH_TO_PRICE[TP_DOMAIN_7] = 500
	PATH_TO_PRICE[TP_DOMAIN_8] = 550
else
	PATH_TO_PRICE[TP_DOMAIN_1] = 300
	PATH_TO_PRICE[TP_DOMAIN_2] = 300
	PATH_TO_PRICE[TP_DOMAIN_3] = 300
	PATH_TO_PRICE[TP_DOMAIN_4] = 300
	PATH_TO_PRICE[TP_DOMAIN_5] = 300
	PATH_TO_PRICE[TP_DOMAIN_6] = 300
	PATH_TO_PRICE[TP_DOMAIN_7] = 300
	PATH_TO_PRICE[TP_DOMAIN_8] = 300
end
PATH_TO_PRICE[TP_TP] = 200

----地图拐角点
PATH_VERTEX = { 1, 11, 21, 31 }

---- 回合提示
RoundTip = {
	[GLOBAL_SHOP_ROUND] = "global_shop",
	[BZ_OUT_ROUNT] = "bz_out",
}

----
--[[d EventID【【【【【【【【【【【【【【【【【【【【【【【【【【【【【】】】】】】】】】】】】】】】】】】】】】】】】】】】】】】Constant]]----
----自定义事件：
----Event_GameStart				   ----游戏开始
----Event_UpdateRound				 ----游戏回合更新
----Event_BeAtk					   ----单位被攻击
----Event_Atk						 ----单位攻击
----Event_OnDamage					----单位受伤
----Event_Move						----单位移动
----Event_MoveEnd					 ----单位移动结束
----Event_BZCreate					----兵卒创建
----Event_BZDestroy				   ----兵卒销毁
----Event_BZHuiMo					 ----兵卒回魔
----Event_BZManaFull				  ----兵卒魔法充盈
----Event_BZCanAtk					----兵卒可攻击
----Event_BZCantAtk				   ----兵卒不可攻击
----Event_BZLevel					 ----兵卒升级
----Event_PlayerRoundBefore		   ----玩家开始回合之前
----Event_PlayerRoundBegin			----玩家开始回合
----Event_PlayerRoundFinished		 ----玩家结束回合
----Event_PlayerMove				  ----玩家开始移动
----Event_PlayerMoveEnd			   ----玩家结束移动
----Event_PassingPath				 ----玩家英雄路过到某路径
----Event_OnPath					  ----玩家英雄触发某路径
----Event_LeavePath				   ----玩家英雄离开某路径
----Event_CurPathChange			   ----玩家当前路径变更
----Event_JoinPath					----玩家停住某路径
----Event_SxChange					----玩家英雄属性变更
----Event_RootedDisable			   ----玩家禁止移动解除
----Event_HeroHuiMoByRound			----玩家英雄回魔（每轮回复的魔法）
----Event_ItemHuiXueByRound		   ----玩家英雄回血（每轮回复的血量）
----Event_Roll						----玩家roll点
----Event_RollContinue				----玩家再一次roll点
----Event_PathOwChange				----路径领主变更
----Event_PathBuffDel				 ----领地技能移除
----Event_AtkMoster				   ----单位打野
----Event_AtkMosterEnd				----单位打野结束
----Event_GCLDReady				   ----触发攻城略地
----Event_GCLD						----攻城略地
----Event_GCLDEnd					 ----攻城略地结束
----Event_PrisonOut				   ----出狱
----Event_RollBaoZiJudge			  ----ROLL点豹子判断
----Event_LastCDChange				----剩余CD改变
----Event_PlayerInvis				 ----玩家隐身
----Event_PlayerInvisEnd			  ----玩家隐身结束
----Event_FinalBattle				 ----终局决战
----Event_PlayerDie				   ----玩家死亡
----Event_ActionStop				  ----玩家行为中断（打野，攻城等行为）
----Event_WageGold					----获得工资
----Event_Abandoned				   ----玩家放弃比赛
----Event_EndGame					 ----玩家结束比赛
----
----Event_OrderMoveToPos			  ----玩家发起移动订单
----
----Event_ItemMove					----物品移动
----Event_ItemAdd					 ----物品获取
----Event_ItemDel					 ----物品失去
----Event_ItemBuy					 ----物品购买
----Event_ItemSell					----物品出售
----Event_ItemGive					----物品给予
----Event_ItemLock					----物品锁定
----Event_ItemSplit				   ----物品拆分
----Event_ItemValid				   ----物品生效
----Event_ItemInvalid				 ----物品失效
----
----Event_Service_AllData			 ----全部服务数据
----Event_Service_UseSkin			 ----玩家使用皮肤
----Event_UseSkinChange			   ----使用皮肤不更改
----Event_Service_PlayerData		  ----玩家数据
----Event_Service_PlayerAllItems	  ----玩家库存
