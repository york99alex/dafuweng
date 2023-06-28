# 目录







# 什么是策划

- 英雄的设计
  1. 以DOTA2地图的特点和机制为基础来设计
  2. 要有自己的设计理念和目标
  3. 策划英雄要有同比,对比
- 装备的设计
  1. 使用原有的DOTA2装备
  2. 修改原有的DOTA2装备
  3. 策划全新的装备(需要匹配DOTA2机制和特点)
- 地图的世界观
- 英雄的故事背景
- 角色的原画,模型,特效等(可以先用文字描述)
- 本地化文件



# 英雄设计

- 特点
- 定位
- 结合特点和定位设计技能
- 技能数值和属性等就类似填表
- 数值/平衡问题

## 容易遇到的问题/陷阱

- 使用时机/CD时间
- 是否同质化
- 连招配合
- 平衡性,连招平衡性
- 双方英雄之间的技能交互
- 新的英雄定位不明确可能回导致原本的英雄失去使用价值





# 编辑器

DLC，Workshop Tools DLC

<img src="https://raw.githubusercontent.com/york99alex/Pic4york/main/fix-dir/Typora/typora-user-images/2023/06/18/11-00-54-5254c4d3daf0e32b8b2692f2b1076438-image-20230618110054406-f57761.png" alt="image-20230618110054406" style="zoom:50%;" />



## Tools

- Hammer 地图编辑器
- 

## Hammer

地图编辑器，仅可打开启动项目文件夹下的vmap。

### 打开地图

快捷键F9 run map打开地图，第一次要build。

### 笔刷法编辑地图

[笔刷法制作地形|dota2 rpg AMHC -](http://www.dota2rpg.com/forum.php?mod=viewthread&tid=1853&extra=page%3D1)



## VConsole2

控制台, 游戏窗口按 `\` 打开

- 单独新窗口过滤信息:
  <img src="https://raw.githubusercontent.com/york99alex/Pic4york/main/fix-dir/Typora/typora-user-images/2023/06/27/18-35-09-c03d77452a9188c4729113181ecec6d5-image-20230627183509476-3bac9d.png" alt="image-20230627183509476" style="zoom:50%;" />
- Filter搜索左侧Channel
- Search搜索右侧Log
- Command命令:
  - clear清屏
  - script_reload是重新载入lua代码
  - dota_launch_custom_game [项目名] [地图名] 启动项目进入游戏
  - 


## 技能

scripts\npc

==在游戏运行的时候，你能够使用`script_reload`命令来重新载入你的代码。==

- npc_abilities_custom.txt	去定义修改的技能
- npc_heroes_custom.txt  并不是创建新英雄的,而是让你用现有英雄作为模板然后去覆盖和修改,去定义如何修改
- npc_items_custom.txt
- npc_units_custom.txt

[脚本常量 - Valve Developer Community (valvesoftware.com)](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools:zh-cn/Scripting:zh-cn/Constants:zh-cn) 

### 技能的制作类型

- 数据驱动类: 
  KV文件(key-value) 继承或者修改已有技能	`"BaseClass"	  "ability_datadriven"`
  特点: 编写快速(配合[KV编辑器](http://www.dota2rpg.com/forum.php?mod=viewthread&tid=3727&extra=page%3D1)更方便), 但是灵活性相比其他两种不足, 同时会受本体变化而影响
- 数据驱动与Lua代码并行
  将部分数据驱动的内容通过lua来实现
- Lua脚本类: 在技能定义中调用Lua函数, 可以创造更有趣的技能
  代码量较大, 但逻辑更清晰更灵活
  可以通过地图中重载代码,快速调试技能 `script_reload` 

### KV编辑技能

- **技能图标	AbilityTextureName**
  图标的文件存放路径: game\dota_addons\项目名\resource\flash3\images\spellicons下面

  V值为文件前缀,不加后缀,可以在spellicons下有自定义子文件, 例如 `\my\head` 就是\spellicons\my文件夹下的head.png

  对应 npc_abilities_custom.txt 文件中技能定义时的 `AbilityTextureName` KV值

  - 处理图片
    要求128*128像素, png格式

- **技能行为	AbilityBehavior**

  - 可读性较好, 注意AOE技能一般配合点目标等使用
    ![image-20230627171736175](https://raw.githubusercontent.com/york99alex/Pic4york/main/fix-dir/Typora/typora-user-images/2023/06/27/17-17-36-1d979b1fee54a59b606b0f7992ef58d8-image-20230627171736175-e60f3c.png)

- 最大等级 MaxLevel
  dota2 默认5级

- 需求等级 RequiredLevel
  大富翁里是10级

- 施法前摇 AbilityCastPoint

- 施法动作 AbilityCastAnimation

  - 查看施法动作的方法:
    在资源管理器Asset Browser中查找model
    <img src="https://raw.githubusercontent.com/york99alex/Pic4york/main/fix-dir/Typora/typora-user-images/2023/06/27/17-23-12-3a7181e4017beec0986bb5dfeda0dd6e-image-20230627172312570-d82354.png" alt="image-20230627172312570" style="zoom:50%;" />
    然后过滤你想查看的英雄,名字+.vmdl才是英雄模型,其他都是饰品等,例如我查看puck
    <img src="https://raw.githubusercontent.com/york99alex/Pic4york/main/fix-dir/Typora/typora-user-images/2023/06/27/17-24-21-6c1c6360ced7f012537d739a22355da7-image-20230627172421778-c658a7.png" alt="image-20230627172421778" style="zoom:50%;" />
    在右侧Compiled Preview Outliner下的Animation Sequences中就是动画序列
    <img src="https://raw.githubusercontent.com/york99alex/Pic4york/main/fix-dir/Typora/typora-user-images/2023/06/27/17-32-05-829bb76dc21aeca302aea364221b7d2b-image-20230627173205295-bd5645.png" alt="image-20230627173205295" style="zoom: 33%;" />
    **后面全大写的灰色字段就是要在AbilityCastAnimation填写的V值**
  - 也可以在SpellLibraryLua里通过这个[vscripts](https://github.com/vulkantsk/SpellLibraryLua/tree/master/game/SpellLibraryLua/scripts/vscripts)查看, 在英雄名文件夹下找技能名然后查看方法StartGesture(ACT_DOTA_CAST_ABILITY_3)里的字段

### 事件

事件类型就是触发条件

操作就是触发条件后做什么

- Target: 
  - None
  - CASTER
  - TARGET
  - POINT
  - ATTACKER
  - UNIT
  - [Group Units]  可以按范围或脚本等

#### 特效

触发某些事件时能选择添加特效KV信息

- FireEffect 等事件可以触发特效时会有
  - EffectName 特效文件.vpcf
    查看特效文件, 同上使用资源管理器查看模型
    ![image-20230627174533506](https://raw.githubusercontent.com/york99alex/Pic4york/main/fix-dir/Typora/typora-user-images/2023/06/27/17-45-33-2b1bf8c045efee651add424b299dbeeb-image-20230627174533506-ca0de9.png)
    然后查看右键选择 copy path即可
    <img src="https://raw.githubusercontent.com/york99alex/Pic4york/main/fix-dir/Typora/typora-user-images/2023/06/27/17-52-39-dabaecdea5ef41018d04b7f4ec0cccd0-image-20230627175239396-6bda80.png" alt="image-20230627175239396" style="zoom: 50%;" />
- FireSound 触发声音特效
  - EffectName  声音文件
    通过这个仓库查看[vscripts](https://github.com/vulkantsk/SpellLibraryLua/tree/master/game/SpellLibraryLua/scripts/vscripts), 在英雄名文件夹下找技能名然后查看方法EmitSound("Hero_Axe.CounterHelix")里的字段
- SourceAttachment  特效附着点,可以理解为特效从哪里发出
  - 也是在资源管理器Model里查看Attachments
    <img src="https://raw.githubusercontent.com/york99alex/Pic4york/main/fix-dir/Typora/typora-user-images/2023/06/27/17-56-51-76bff684fb10be538d3317942f7e3369-image-20230627175651930-2ce3f8.png" alt="image-20230627175651930" style="zoom: 80%;" />
    填写KV值时改为全大写同时加上前缀例如:
    DOTA_PROJECTILE_ATTACHMENT_ATTACK1

一个特效往往由多个子特效组成.
视觉特效文件右下角有P的表示Parent为父类特效,包含所有子类特效; 右小角为C的表示Children,是最子级的特效. 点击其图标可以看到继承树, 点击继承树中的格子可以跳到该特效.
导入特效时一般导入父级特效

<img src="https://raw.githubusercontent.com/york99alex/Pic4york/main/fix-dir/Typora/typora-user-images/2023/06/27/17-47-59-7b30d7568602b2c882c4d64747039278-image-20230627174759456-d8607b.png" alt="image-20230627174759456" style="zoom:67%;" />



### 修饰器

修饰器在事件里调用, 修饰器可以理解成buff, 可以添加增益,减益,特效等.

修饰器也能添加特效和事件.

修饰器可以定义为可见的和不可见.



# Lua

DOTA中只是用了Lua语言的一部分特点.

在DOTA2中Lua的特点:

- 灵活性远高于数据驱动类
- 可以在地图中快速重载
- 缺点,代码量大

数据类型:

- nil
- boolean

- number
- string
- table可以是数组array也可以是map键值对

function：c或lua编写的代码

require(“hello”) --引用hello.lua，默认同目录

lua中.点号是其某个属性/函数，:冒号是调用函数。

- self是本身
  https://zhuanlan.zhihu.com/p/115159195?utm_id=0 



LinkLuaModifier 可在技能定义处绑定修饰器



## Lua技能

在技能定义的BaseClass中填写V值为 ability_lua
 ScriptFile根目录在项目文件夹\vscripts下, 例如:

```kv
"LuaAbility_phantom_strike"
{
	"BaseClass"					"ability_lua"
	"ScriptFile"				"Ability\phantom_assassin\LuaAbility_phantom_strike"
```

就是在<img src="https://raw.githubusercontent.com/york99alex/Pic4york/main/fix-dir/Typora/typora-user-images/2023/06/27/18-45-26-c24568ab2a1d15c5fd5d9223b672114e-image-20230627184526763-3c4301.png" alt="image-20230627184526763" style="zoom: 67%;" />**不用写文件后缀**

那么正式开始lua编写技能, lua技能一般先**创建一个lua类**, 用于定义技能的行为和属性, 类的定义通常会包含技能的各种方法和技能执行时的逻辑等.

```lua
test_lua_ability = class ({})
-- 大富翁里斧王的战斗饥渴文件最开始是这样的:
require("Ability/LuaAbility")

if nil == LuaAbility_axe_battle_hunger then
    LuaAbility_axe_battle_hunger = class({}, nil, LuaAbility)
    LinkLuaModifier("modifier_luaAbility_axe_battle_hunger", "Ability/axe/LuaAbility_axe_battle_hunger.lua", LUA_MODIFIER_MOTION_NONE)
    if PrecacheItems then
        table.insert(PrecacheItems, "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf")
    end
end
```





## 常用函数

- print
- LinkLuaModifier  将lua定义的修饰器与关联的类链接起来
  - ( className, fileName, LuaModifierType) 三个参数
    - LuaModifierType 运动类型, 由以下五个常量
      - LUA_MODIFIER_MOTION_NONE	0	没有运动效果
        LUA_MODIFIER_MOTION_HORIZONTAL	1	在水平方向上移动
        LUA_MODIFIER_MOTION_VERTICAL	2	在垂直方向上移动
        LUA_MODIFIER_MOTION_BOTH	3	在水平和垂直上都移动
        LUA_MODIFIER_INVALID	4	
      - 





# 本地化

addon_schinese.txt 是本地化文件，可以修改技能描述等。
 Lore是传记描述
 Note是技能补充描述 Note0 Note1按住alt时技能额外显示的内容
 npc_abilities_custom.txt中定义特殊值，再在本地化文件中用%%调用



# 附注

## 链接/学习视频：

- [【Dota2】游廊地图制作教程-新手项01期 如何下载游廊地图编辑器和上传地图_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1Qc411J76i/)
- [彩紫睨羽的个人空间_哔哩哔哩_bilibili](https://space.bilibili.com/345688919/video?tid=0&pn=4&keyword=&order=pubdate)
- [Dota 2 创意工坊工具集 - Valve Developer Community (valvesoftware.com)](https://developer.valvesoftware.com/w/index.php?title=Dota_2_Workshop_Tools&uselang=zh)
- [Introduction | ModDota](https://moddota.com/)
  - [API | ModDota](https://moddota.com/api/#!/vscripts)

- 一些定义DOTA函数的仓库
   https://github.com/ModDota/API/blob/master/examples/vscript/declarations/dota-api.d.ts

- DOTA2技能Lua库 https://github.com/vulkantsk/SpellLibraryLua

## ==文件目录/路径==

- ..\SteamLibrary\steamapps\common\dota 2 beta 本体目录
  - ==\content==  编译前文件，地图等资源
    - \dota
      - \maps
        - \dota.vmap  本体地图
    - **==\dota_addons==**   游廊项目文件
      - ..项目名
        - maps 默认, .vmap文件
        - materials 默认 模型贴图
        - particles 默认, 特效.vpcf文件
        - panorama (自己创建) UI文件,使用编写html页面的方式来编写(自己创建)
        - models (自己创建) 存放自己的模型文件 .vmdl文件
        - sounds (自己创建) 存放声音文件
    
  - ==\game==  编译后文件，lua代码
    
    - **==\dota_addons==**   游廊项目文件
      
      - ..项目名
        - maps, materials, models, particles不用管,是之前content下编译后的文件
        
        - \scripts  技能
          - \npc	存放技能,英雄,单位的KV文件
            - \herolist.txt	设置选人启用的英雄
            
              ```txt
              "CustomHeroList"
              {
                  "npc_dota_hero_phantom_assassin" "-1"
                  "npc_dota_hero_meepo" "-1"
                  "npc_dota_hero_pudge" "-1"
                  "npc_dota_hero_lina" "-1"
              }
              ```
            
              默认为0不显示,1为可选, -1?
            
          - \vscripts  存放lua语言编写的文件
          
          - \shops  文件夹设置商店物品(可通过npc下修改)
          
        - \resource 
          - \addon_schinese.txt  本地化中文文件
          - \flash3  图标等内容
            - \images
              - \spellicons 技能图标

## 快捷键

-  Hammer快捷键F9 run map打开地图
-  游戏中 F6 打开前端控制台
-  游戏中 反斜杠`\`  打开VConsole

## 测试/作弊指令

- [常用测试指令 - DotA中文维基 - 灰机wiki (huijiwiki.com)](https://dota.huijiwiki.com/p/140255)
- [【翻译+教程】DotA2 测试/作弊指令大全【dota2吧】_百度贴吧 (baidu.com)](https://tieba.baidu.com/p/2199201677?red_tag=2585701344&see_lz=1)
- 

## 开发工具

- VS插件dota-reborn-code
- [矩阵编辑器入门指南|dota2 rpg AMHC -](http://www.dota2rpg.com/forum.php?mod=viewthread&tid=3727&extra=page%3D1)
- 





# bugs

- ~~玲珑心~~ 描述有问题但,生效
  <img src="https://raw.githubusercontent.com/york99alex/Pic4york/main/fix-dir/Typora/typora-user-images/2023/06/26/17-10-45-1cf7fbb14ae5ff1b6ab7f09c73fe3f20-image-20230626171044998-edfb4a.png" alt="image-20230626171044998" style="zoom: 50%;" />

- ~~斧王转~~

- ~~宙斯蓝量~~

- ~~米波层数~~

  - CLocalize::FindSafe failed to localize: #DOTA_Tooltip_modifier_meepo_ransack_onatk

  开局先获得 洗劫层数buff onatk

  攻击时层数buff加给了 ransack

- ~~蛇谷绑人生效~~

- 所有数据驱动调用的GetSpecialValueFor得不到数值, 可以通过local数组配合获取技能等级GetLevel()

  - 大概修好了

- ~~米波洗劫技能描述~~

- ~~斧王螺旋技能描述~~

- 经验共享问题和数值问题

- ~~装备额外回血~~

- ~~装备额外蓝量~~

- ~~装备额外回蓝~~

- 某种未知原因导致无法弹窗等操作,买不了地攻不了城

- 结束清算有问题





## 修改

- F:\SteamLibrary\steamapps\common\dota 2 beta\game\dota_addons\dafuweng\scripts\vscripts\modifiers\modifier_fix_damage.lua
  - local magicalArmor = self:Script_GetMagicalArmorValue()
  
-   测试开局野怪

  ​	nNum1 = 2
  ​	nNum2 = 4
  
- 





