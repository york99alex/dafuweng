# 链接/学习视频：

- [【Dota2】游廊地图制作教程-新手项01期 如何下载游廊地图编辑器和上传地图_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1Qc411J76i/)
- [彩紫睨羽的个人空间_哔哩哔哩_bilibili](https://space.bilibili.com/345688919/video?tid=0&pn=4&keyword=&order=pubdate)
- [Dota 2 创意工坊工具集 - Valve Developer Community (valvesoftware.com)](https://developer.valvesoftware.com/w/index.php?title=Dota_2_Workshop_Tools&uselang=zh)
- [Introduction | ModDota](https://moddota.com/)
  - [API | ModDota](https://moddota.com/api/#!/vscripts)

- 

# 目录



# 编辑器

DLC，Workshop Tools DLC<img src="https://raw.githubusercontent.com/york99alex/Pic4york/main/fix-dir/Typora/typora-user-images/2023/06/18/11-00-54-5254c4d3daf0e32b8b2692f2b1076438-image-20230618110054406-f57761.png" alt="image-20230618110054406" style="zoom:50%;" />



## Tools

- Hammer 地图编辑器
- 

## Hammer

地图编辑器，仅可打开启动项目文件夹下的vmap。

#### 打开地图

快捷键F9 run map打开地图，第一次要build。



## 技能

scripts\npc

==在游戏运行的时候，你能够使用`script_reload`命令来重新载入你的代码。==

- npc_abilities_custom.txt	去定义修改的技能
- npc_heroes_custom.txt  并不是创建新英雄的,而是让你用现有英雄作为模板然后去覆盖和修改,去定义如何修改
- npc_items_custom.txt
- npc_units_custom.txt

[脚本常量 - Valve Developer Community (valvesoftware.com)](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools:zh-cn/Scripting:zh-cn/Constants:zh-cn) 

定义技能的定义类型: 

- 数据驱动类: 继承或者修改已有技能
- Lua脚本类: 在技能定义中调用Lua函数, 可以创造更有趣的技能

```

```





# 附注



## 文件目录/路径

- ..\SteamLibrary\steamapps\common\dota 2 beta
  - \content  编译前文件，地图等资源
    - \dota
      - \maps
        - \dota.vmap  本体地图
    - **==\dota_addons==**   游廊项目文件
      - ..项目名
        - \scripts  技能
          - \npc 
  - \game  编译后文件，lua代码
  - 

## 快捷键

-  Hammer快捷键F9 run map打开地图
-  游戏中 F6 打开前端控制台
-  游戏中 反斜杠`\`  打开VConsole

## 测试/作弊指令

- [常用测试指令 - DotA中文维基 - 灰机wiki (huijiwiki.com)](https://dota.huijiwiki.com/p/140255)
- [【翻译+教程】DotA2 测试/作弊指令大全【dota2吧】_百度贴吧 (baidu.com)](https://tieba.baidu.com/p/2199201677?red_tag=2585701344&see_lz=1)
- 

## 开发插件

- VS插件dota-reborn-code
- 





# bugs

- 玲珑心

- 斧王转

- 斧王买地

- 宙斯蓝量

- 米波层数

  - CLocalize::FindSafe failed to localize: #DOTA_Tooltip_modifier_meepo_ransack_onatk

  开局先获得 洗劫层数buff onatk

  攻击时层数buff加给了 ransack

- 领地buff不可驱散, 目前Key失效暂时注释

  - // "SpellDispellableType"		"SPELL_DISPELLABLE_NO_STRONG"	//是否可驱散





## 修改

- F:\SteamLibrary\steamapps\common\dota 2 beta\game\dota_addons\dafuweng\scripts\vscripts\modifiers\modifier_fix_damage.lua
  - local magicalArmor = self:Script_GetMagicalArmorValue()
- 





