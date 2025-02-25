local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- 角标的相关法术 [spellID] = {anchor, {r, g, b}, ALL}
C.CornerBuffs = {
	["PRIEST"] = {
		[194384] = {"TOPRIGHT", {1, 1, .66}},			-- 救赎
		[214206] = {"TOPRIGHT", {1, 1, .66}},			-- 救赎(PvP)
		[41635]  = {"BOTTOMRIGHT", {.2, .7, .2}},		-- 愈合导言
		[193065] = {"BOTTOMRIGHT", {.54, .21, .78}},	-- 忍辱负重
		[139]    = {"TOPLEFT", {.4, .7, .2}},			-- 恢复
		[17]     = {"TOPLEFT", {.7, .7, .7}},			-- 真言术盾
		[47788]  = {"LEFT", {.86, .45, 0}, true},		-- 守护之魂
		[33206]  = {"LEFT", {.47, .35, .74}, true},		-- 痛苦压制
		[6788]  = {"TOP", {.86, .11, .11}, true},		-- 虚弱灵魂
	},
	["DRUID"] = {
		[774]    = {"TOPRIGHT", {.8, .4, .8}},			-- 回春
		[155777] = {"RIGHT", {.6, .4, .8}},				-- 萌芽
		[8936]   = {"LEFT", {.2, .8, .2}},				-- 愈合
		[33763]  = {"TOPLEFT", {.4, .8, .2}},			-- 生命绽放
		[188550] = {"TOPLEFT", {.4, .8, .2}},			-- 生命绽放，橙装
		[48438]  = {"BOTTOMRIGHT", {.8, .4, 0}},		-- 野性成长
		[29166]  = {"TOP", {0, .4, 1}},					-- 激活
		[102351] = {"BOTTOM", {.2, .8, .8}},			-- 结界
		[102352] = {"BOTTOM", {.2, .8, .8}},			-- 结界(HoT)
		[200389] = {"BOTTOM", {1, 1, .4}},				-- 栽培
	},
	["PALADIN"] = {
		[287280]  = {"TOPLEFT", {1, .8, 0}},			-- 圣光闪烁
		[53563]  = {"TOPRIGHT", {.7, .3, .7}},			-- 道标
		[156910] = {"TOPRIGHT", {.7, .3, .7}},			-- 信仰道标
		[200025] = {"TOPRIGHT", {.7, .3, .7}},			-- 美德道标
		[1022]   = {"BOTTOMRIGHT", {.2, .2, 1}, true},	-- 保护
		[1044]   = {"BOTTOMRIGHT", {.89, .45, 0}, true},-- 自由
		[6940]   = {"BOTTOMRIGHT", {.89, .1, .1}, true},-- 牺牲
		[223306] = {"BOTTOM", {.7, .7, .3}},			-- 赋予信仰
		[25771]  = {"TOP", {.86, .11, .11}, true},		-- 自律
	},
	["SHAMAN"] = {
		[61295]  = {"TOPRIGHT", {.2, .8, .8}},			-- 激流
		[974]    = {"BOTTOMRIGHT", {1, .8, 0}},			-- 大地之盾
	},
	["MONK"] = {
		[119611] = {"TOPLEFT", {.3, .8, .6}},			-- 复苏之雾
		[116849] = {"TOP", {.2, .8, .2}, true},			-- 作茧缚命
		[124682] = {"TOPRIGHT", {.8, .8, .25}},			-- 氤氲之雾
		[191840] = {"BOTTOMRIGHT", {.27, .62, .7}},		-- 精华之泉
	},
	["ROGUE"] = {
		[57934]  = {"BOTTOMRIGHT", {.9, .1, .1}},		-- 嫁祸
	},
	["WARRIOR"] = {
		[114030] = {"TOPLEFT", {.2, .2, 1}},			-- 警戒
	},
	["HUNTER"] = {
		[34477]  = {"BOTTOMRIGHT", {.9, .1, .1}},		-- 误导
		[90361]  = {"TOPLEFT", {.4, .8, .2}},			-- 灵魂治愈
	},
	["WARLOCK"] = {
		[20707]  = {"BOTTOMRIGHT", {.8, .4, .8}, true},	-- 灵魂石
	},
	["DEMONHUNTER"] = {},
	["MAGE"] = {},
	["DEATHKNIGHT"] = {},
}

-- 小队框体的技能监控CD [spellID] = duration in seconds
C.PartySpells = {
	[57994]  = 12,	-- 风剪
	[1766]   = 15,	-- 脚踢
	[6552]   = 15,	-- 拳击
	[47528]  = 15,	-- 心灵冰冻
	[96231]  = 15,	-- 责难
	[106839] = 15,	-- 迎头痛击
	[116705] = 15,	-- 切喉手
	[183752] = 15,	-- 瓦解
	[187707] = 15,	-- 压制
	[2139]   = 24,	-- 法术反制
	[119910] = 24,	-- 法术封锁
	[147362] = 24,	-- 反制射击
	[15487]  = 45,	-- 沉默
	[109248] = 45,	-- 束缚射击
	[78675]  = 60,	-- 日光术

	[30283]	 = 45,	-- 暗影之怒
	[8143]	 = 60,	-- 战栗图腾
	[19577]	 = 60,	-- 胁迫
	[102793] = 60,	-- 乌索尔旋风
	[119381] = 60,	-- 扫堂腿
	[179057] = 60,	-- 混乱新星
	[205636] = 60,	-- 树人
	[307865] = 60,  -- 晋升堡垒之矛，格里恩
	[1719]   = 90,  -- 鲁莽
	[102342] = 90,	-- 铁木树皮
	[325886] = 90,  -- 上古余震，法夜
	[10060]  = 120, -- 能量灌注
	[288613] = 120,	-- 百发百中
	[31224]  = 120,	-- 暗影斗篷
	[190319] = 120,	-- 燃烧
	[31884]  = 120,	-- 复仇之怒
	[231895] = 120,	-- 征罚
	[323764] = 120,	-- 万灵之召
	[123904] = 120,	-- 白虎下凡
	[192249] = 150,	-- 风元素
	[198067] = 150, -- 火元素
	[13750]  = 180, -- 冲动
	[186265] = 180,	-- 灵龟守护
	[102560] = 180,	-- 鸟德化身
	[194223] = 180,	-- 超凡之盟
	[204018] = 180,	-- 破咒祝福
	[316958] = 240, -- 红烬圣土，温西尔
	[1022]   = 300,	-- 保护祝福

	[25046]  = 120,	-- 奥术洪流
	[28730]  = 120,
	[50613]  = 120,
	[69179]  = 120,
	[80483]  = 120,
	[129597] = 120,
	[155145] = 120,
	[202719] = 120,
	[232633] = 120,
}

-- 天赋/特质影响下的冷却时间
C.TalentCDFix = {
	[740]	 = 120,	-- 宁静
	[2094]   = 90,	-- 致盲
	[15286]  = 75,	-- 吸血鬼的拥抱
	[15487]  = 30,	-- 沉默
	[22812]  = 40,	-- 树皮术
	[30283]  = 30,	-- 暗影之怒
	[48792]  = 165,	-- 冰封之韧
	[79206]  = 60,	-- 灵魂行者的恩赐
	[102342] = 45,	-- 铁木树皮
	[108199] = 90,	-- 血魔之握
	[109304] = 105,	-- 意气风发
	[116849] = 100,	-- 作茧缚命
	[119381] = 40,	-- 扫堂腿
	[179057] = 40,	-- 混乱新星
}

-- Party watcher spells db
C.PartySpellsDB = {
	["DEATHKNIGHT"] = {
		[42650] = 480, -- 大军
		[47528] = 15, -- 心灵冰冻
		[47568] = 105, -- 符文武器增效
		[48707] = 60, -- 反魔法护罩
		[48792] = 180, -- 冰封之韧
		[49028] = 60, -- 符文刃舞
		[51052] = 120, -- 反魔法领域
		[55233] = 90, -- 吸血鬼之血
		[108199] = 120, -- 血魔之握
		[114556] = 240, -- 炼狱
		[194844] = 60, -- 白骨风暴
		[221562] = 45, -- 窒息
		[275699] = 75, -- 天启
		[279302] = 120, -- 冰霜巨龙之怒
		[327574] = 120, -- 牺牲契约
		[315443] = 120, -- 憎恶附肢，通灵
		[324631] = 120, -- 血肉铸造，通灵
		[312202] = 60, -- 失格者之梏，格里恩
		[311648] = 60, -- 云集之雾，温西尔
	},
	["DEMONHUNTER"] = {
		[179057] = 60, -- 混乱新星
		[183752] = 15, -- 瓦解
		[188501] = 15, -- 幽灵视觉
		[196555] = 180, -- 虚空行走
		[196718] = 180, -- 黑暗
		[198589] = 60, -- 疾影
		[202137] = 60, -- 沉默咒符
		[204021] = 60, -- 烈火烙印
		[207684] = 90, -- 悲苦咒符
		[278326] = 10, -- 吞噬魔法
		[306830] = 60, -- 极乐赦令，格里恩
		[329554] = 120, -- 燃焰饲魂，通灵
		[317009] = 60, -- 罪孽烙印，温西尔
		[323639] = 90, -- 恶魔追击，法夜
	},
	["DRUID"] = {
		[99] = 30, -- 夺魂咆哮
		[740] = 180, -- 宁静
		[2782] = 8, -- 清除腐蚀
		[5211] = 60, -- 蛮力猛击
		[22812] = 60, -- 树皮术
		[78675] = 60, -- 日光术
		[88423] = 8, -- 自然之愈
		[61336] = 180, -- 生存本能
		[77761] = 120, -- 豹奔
		[33891] = 180, -- 大树化身
		[194223] = 180, -- 超凡之盟
		[102560] = 180, -- 鸟德化身
		[102558] = 180, -- 熊化身
		[102543] = 180, -- 猫化身
		[102359] = 30, -- 群缠
		[106839] = 15, -- 迎头痛击
		[132469] = 30, -- 台风
		[102793] = 60, -- 乌索尔旋风
		[201664] = 30, -- 挫志怒吼
		[102342] = 90, -- 铁木树皮
		[108238] = 90, -- 甘霖
		[29166] = 180, -- 激活
		[202246] = 25, -- 蛮力冲锋
		[205636] = 60, -- 树人
		[325727] = 25, -- 畸变蜂群，通灵
		[323764] = 120, -- 万灵之召，法夜
		[338142] = 60, -- 自省强化，格里恩
		[323546] = 180, -- 饕餮狂乱，温西尔
	},
	["HUNTER"] = {
		[5384] = 30, -- 假死
		[19574] = 90, -- 狂野怒火
		[19801] = 10, -- 宁神射击
		[19577] = 60, -- 胁迫
		[34477] = 30, -- 误导
		[147362] = 24, -- 反制射击
		[187707] = 15, -- 压制
		[187650] = 25, -- 冰冻陷阱
		[187698] = 25, -- 焦油陷阱
		[186387] = 30, -- 爆裂射击
		[162488] = 30, -- 精钢陷阱
		[186265] = 180, -- 龟壳
		[109304] = 120, -- 意气风发
		[186289] = 90, -- 雄鹰守护
		[193530] = 120, -- 野性守护
		[266779] = 120, -- 协同进攻
		[260402] = 60, -- 二连发
		[201430] = 120, -- 群兽奔腾
		[288613] = 120, -- 百发百中
		[186257] = 180, -- 猎豹守护
		[109248] = 45, -- 束缚射击
		[199483] = 60, -- 伪装
		[325028] = 45, -- 死亡飞轮，通灵
		[324149] = 30, -- 劫掠射击，温西尔
		[308491] = 60, -- 共鸣箭，格里恩
		[328231] = 120, -- 野性之魂，法夜
	},
	["MAGE"] = {
		[66] = 300, -- 隐形术
		[475] = 8, -- 驱诅咒
		[2139] = 24, -- 法术反制
		[12042] = 120, -- 奥术强化
		[12472] = 180, -- 冰冷血脉
		[31661] = 18, -- 龙息术
		[45438] = 240, -- 冰箱
		[86949] = 300, -- 春哥
		[55342] = 120, -- 镜像
		[113724] = 18, -- 冰霜之环
		[110960] = 120, -- 强隐
		[198111] = 45, -- 时光护盾
		[190319] = 120, -- 燃烧
		[198100] = 30, -- 偷
		[198144] = 60, -- 寒冰形态
		[108978] = 60, -- 操控时间
		[342245] = 60, -- 操控时间
		[324220] = 180, -- 死亡飞轮，通灵
		[314793] = 90, -- 劫掠射击，温西尔
		[307443] = 30, -- 共鸣箭，格里恩
		[314791] = 60, -- 野性之魂，法夜
	},
	["MONK"] = {
		[116705] = 15,	-- 切喉手
		[115450] = 8, -- 清创生血
		[218164] = 8, -- 清创生血
		[202335] = 45, -- 醉上加醉
		[119381] = 60, -- 扫堂腿
		[115078] = 30, -- 分筋错骨
		[198898] = 30, -- 赤精之歌
		[116844] = 45, -- 平心之环
		[116849] = 120, -- 作茧缚命
		[122470] = 90, -- 业报之触
		[202162] = 45, -- 斗转星移
		[115399] = 120, -- 玄牛酒
		[122278] = 120, -- 躯不坏
		[122783] = 90, -- 散魔攻
		[325153] = 60, -- 爆炸酒桶
		[115203] = 360, -- 壮胆酒
		[243435] = 180, -- 壮胆酒
		[132578] = 180, -- 玄牛下凡
		[119996] = 45, -- 魂体双分
		[115176] = 300, -- 禅悟冥想
		[115310] = 180, -- 还魂术
		[115288] = 60, -- 豪能酒
		[123904] = 120, -- 白虎下凡
		[322118] = 180, -- 青龙下凡
		[325197] = 180, -- 朱鹤下凡
		[137639] = 90, -- 风火雷电
		[152173] = 90, -- 屏气凝神
		[322109] = 180, -- 轮回之触
		[209584] = 45, -- 禅意聚神茶
		[197908] = 90, -- 法力茶
		[115546] = 8, -- 嚎镇八方
		[116841] = 30, -- 迅如猛虎
		[325216] = 60, -- 骨尘酒，通灵
		[327104] = 30, -- 妖魂踏，法夜
		[326860] = 180, -- 陨落僧众，温西尔
		[310454] = 120, -- 精序兵戈，格里恩
	},
	["PALADIN"] = {
		[498] = 60, -- 圣佑术
		[633] = 600, -- 圣疗术
		[642] = 300, -- 圣盾术
		[853] = 60, -- 制裁之锤
		[1022] = 300, -- 保护祝福
		[1044] = 25, -- 自由祝福
		[4987] = 8, -- 清洁术
		[6940] = 120, -- 牺牲祝福
		[10326] = 15, -- 超度邪恶
		[20066] = 15, -- 忏悔
		[31821] = 180, -- 光环掌握
		[31850] = 120, -- 炽热防御者
		[31884] = 120, -- 复仇之怒
		[31935] = 15, -- 复仇者之盾
		[62124] = 8, -- 清算之手
		[86659] = 300, -- 远古列王守卫
		[96231] = 15, -- 责难
		[184662] = 120, -- 复仇之盾
		[216331] = 120, -- 复仇十字军
		[231895] = 120, -- 征伐
		[105809] = 180, -- 神圣复仇者
		[114158] = 60, -- 圣光之锤
		[152262] = 45, -- 炽天使
		[255937] = 45, -- 灰烬觉醒
		[327193] = 90, -- 光荣时刻
		[210256] = 45, -- 庇护祝福
		[190784] = 45, -- 神圣马驹
		[183218] = 30, -- 妨害之手
		[213644] = 8, -- 清毒术
		[115750] = 90, -- 盲目之光
		[199452] = 120, -- 无尽牺牲
		[204018] = 180, -- 破咒祝福
		[205191] = 60, -- 以眼还眼
		[215652] = 45, -- 美德之盾
		[228049] = 180, -- 被遗忘的女王护卫
		[343527] = 60, -- 处决宣判
		[343721] = 60, -- 最终清算
		[316958] = 240, -- 红烬圣土，温西尔
		[328278] = 45, -- 四级祝福，法夜
		[304971] = 60, -- 圣洁鸣钟，格里恩
		[328204] = 30, -- 征服者之锤，通灵
	},
	["PRIEST"] = {
		[527] = 8, -- 纯净术
		[586] = 30, -- 渐隐术
		[2050] = 60, -- 圣言术：静
		[8122] = 60, -- 心灵尖啸
		[10060] = 120, -- 能量灌注
		[15286] = 120, -- 吸血鬼拥抱
		[15487]  = 45,	-- 沉默
		[19236] = 90, -- 绝望祷言
		[20711] = 600, -- 救赎之魂
		[32375] = 45, -- 群体驱散
		[33206] = 180, -- 痛苦压制
		[47536] = 90, -- 全神贯注
		[47585] = 120, -- 消散
		[47788] = 180, -- 守护之魂
		[62618] = 180, -- 真言术：障
		[64044] = 45, -- 心灵惊骇
		[64843] = 180, -- 神圣赞美诗
		[64901] = 300, -- 希望象征
		[73325] = 90, -- 信仰飞跃
		[88625] = 60, -- 圣言术：罚
		[316262] = 90, -- 思维窃取
		[109964] = 60, -- 灵魂护壳
		[319952] = 90, -- 疯入膏肓
		[228260] = 90, -- 虚空爆发
		[213610] = 30, -- 神圣守卫
		[289657] = 45, -- 圣言术：聚
		[200183] = 120, -- 神圣化身
		[246287] = 90, -- 福音
		[265202] = 720, -- 圣言术：赎
		[215982] = 180, -- 救赎者之魂
		[108968] = 300, -- 虚空转移
		[328530] = 60, -- 神圣晋升
		[205369] = 30, -- 心灵炸弹
		[204263] = 45, -- 闪光立场
		[213602] = 45, -- 强化渐隐术
		[197268] = 60, -- 希望之光
		[213634] = 8, -- 净化疾病
		[327661] = 90, -- 法夜守护者，法夜
		[323673] = 45, -- 控心术，温西尔
		[324724] = 60, -- 邪恶新星，通灵
		[325013] = 180, -- 晋升者之赐，格里恩
	},
	["ROGUE"] = {
		[408] = 20, -- 肾击
		[1766] = 15, -- 脚踢
		[1856] = 120, -- 消失
		[1966] = 15, -- 佯攻
		[2094] = 120, -- 致盲
		[2983] = 60, -- 疾跑
		[5277] = 120, -- 闪避
		[13750] = 180, -- 冲动
		[13877] = 30, -- 剑刃乱舞
		[31224] = 120, -- 暗影斗篷
		[31230] = 360, -- 装死
		[36554] = 30, -- 暗影步
		[51690] = 120, -- 影舞步
		[57934] = 30, -- 嫁祸
		[79140] = 120, -- 宿敌
		[114018] = 360, -- 潜伏帷幕
		[185311] = 30, -- 猩红之瓶
		[198529] = 120, -- 掠夺护甲
		[315508] = 45, -- 命运骨骰
		[121471] = 180, -- 暗影之刃
		[277925] = 60, -- 袖剑旋风
		[212182] = 180, -- 烟雾弹
		[207777] = 45, -- 卸除武装
		[323547] = 45, -- 申斥回响，格里恩
		[323654] = 25, -- 狂热鞭笞，温西尔
		[328305] = 90, -- 败血刃伤，法夜
		[328547] = 30, -- 锯齿骨刺，通灵
	},
	["SHAMAN"] = {
		[16191] = 180, -- 法力之潮
		[51514] = 20, -- 妖术
		[51533] = 120, -- 野性狼魂
		[57994] = 12, -- 风剪
		[58875] = 60, -- 幽魂步
		[79206] = 120, -- 灵魂行者恩赐
		[98008] = 180, -- 灵魂链接
		[108271] = 90, -- 星界转移
		[108280] = 180, -- 治疗之潮
		[191634] = 60, -- 风暴守护者
		[192058] = 50, -- 电能
		[192249] = 150, -- 风元素
		[198067] = 150, -- 火元素
		[198103] = 300, -- 土元素
		[320674] = 90, -- 收割链，温西尔
		[328923] = 120, -- 法夜输灵，法夜
		[326059] = 45, -- 始源之潮，通灵
		[324386] = 60, -- 暮钟图腾，格里恩
	},
	["WARLOCK"] = {
		[1122] = 180, -- 召唤地狱火
		[5484] = 40, -- 恐惧嚎叫
		[6789] = 45, -- 死亡缠绕
		[30283]	 = 45, -- 暗影之怒
		[48020] = 30, -- 法阵
		[108416] = 60, -- 黑暗契约
		[113942] = 90, -- 恶魔传送门
		[104773] = 180, -- 不灭决心
		[201996] = 90, -- 召唤眼魔
		[212459] = 90, -- 召唤邪能领主
		[152108] = 30, -- 大灾变
		[113858] = 120, -- 黑暗灵魂：动荡
		[113860] = 120, -- 黑暗灵魂：哀难
		[119905] = 24, -- 恶魔掌控：灼烧驱魔
		[119910] = 24, -- 恶魔掌控：法术封锁
		[267171] = 60, -- 恶魔力量
		[267217] = 180, -- 虚空传送门
		[205180] = 180, -- 召唤黑眼
		[265187] = 90, -- 召唤恶魔暴君
		[221703] = 60, -- 施法之环
		[212295] = 45, -- 虚空守卫
		[200546] = 45, -- 浩劫灾祸
		[119898] = 24, -- 恶魔掌控
		[212623] = 15, -- 烧灼驱魔
		[111898] = 120, -- 魔典：恶魔卫士
		[325289] = 45, -- 屠戮箭，通灵
		[321792] = 60, -- 灾祸降临，温西尔
		[312321] = 40, -- 碎魂奉纳，格里恩
		[325640] = 60, -- 灵魂腐化，法夜
	},
	["WARRIOR"] = {
		[355] = 8, -- 嘲讽
		[871] = 240, -- 盾墙
		[1160] = 45, -- 挫志怒吼
		[1161] = 240, -- 挑战怒吼
		[1719] = 90, -- 鲁莽
		[3411] = 30, -- 援护
		[5246] = 90, -- 破胆怒吼
		[6544] = 45, -- 英勇飞跃
		[6552] = 15, -- 拳击
		[12323] = 30, -- 刺耳怒吼
		[12975] = 180, -- 破釜沉舟
		[18499] = 60, -- 狂暴之怒
		[23920] = 25, -- 法术反射
		[46924] = 60, -- 剑刃风暴
		[46968] = 40, -- 震荡波
		[64382] = 180, -- 碎裂投掷
		[97462] = 180, -- 集结呐喊
		[107570] = 30, -- 风暴之锤
		[213871] = 15, -- 护卫
		[118038] = 120, -- 剑在人在
		[184364] = 120, -- 狂怒回复
		[107574] = 90, -- 天神下凡
		[227847] = 90, -- 剑刃风暴
		[152277] = 45, -- 破坏者
		[228920] = 45, -- 破坏者
		[262228] = 60, -- 致命平静
		[118000] = 30, -- 巨龙怒吼
		[236320] = 90, -- 战旗
		[317320] = 6, -- 判罪，温西尔
		[325886] = 90, -- 上古余震，法夜
		[307865] = 60, -- 晋升堡垒之矛，格里恩
		[324143] = 180, -- 征服者战旗，通灵
	},
}

-- 团队框体职业相关Buffs
local list = {
	["ALL"] = {			-- 全职业
		[642] = true,		-- 圣盾术
		[871] = true,		-- 盾墙
		[1022] = true,		-- 保护祝福
		[1044] = true,		-- 自由祝福
		[6940] = true, 		-- 牺牲祝福
		[10060] = true,		-- 能量灌注
		[22812] = true,		-- 树皮术
		[61336] = true,		-- 生存本能
		[27827] = true,		-- 救赎之魂
		[31224] = true,		-- 暗影斗篷
		[33206] = true,		-- 痛苦压制
		[45438] = true,		-- 冰箱
		[47585] = true,		-- 消散
		[47788] = true,		-- 守护之魂
		[48792] = true,		-- 冰封之韧
		[86659] = true,		-- 远古列王守卫
		[102342] = true,	-- 铁木树皮
		[102558] = true,	-- 熊化身
		[104773] = true,	-- 不灭决心
		[108271] = true,	-- 星界转移
		[110909] = true,	-- 操控时间
		[115203] = true,	-- 壮胆酒
		[116849] = true,	-- 作茧缚命
		[118038] = true,	-- 剑在人在
		[160029] = true,	-- 正在复活
		[186265] = true,	-- 灵龟守护
		[196555] = true,	-- 虚空行走
		[204018] = true,	-- 破咒祝福
		[204150] = true,	-- 圣光护盾
		[264735] = true,	-- 优胜劣汰
		[281195] = true,	-- 优胜劣汰
	},
	["WARNING"] = {
		[87023] = true,		-- 灸灼
		[95809] = true,		-- 疯狂
		[123981] = true,	-- 永劫不复
		[209261] = true,	-- 未被污染的邪能
	},
}

module:AddClassSpells(list)