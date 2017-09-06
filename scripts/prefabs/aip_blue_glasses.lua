local foldername = KnownModIndex:GetModActualName(TUNING.ZOMBIEJ_ADDTIONAL_PACKAGE)

-- 配置
local dress_uses = GetModConfigData("dress_uses", foldername)
local language = GetModConfigData("language", foldername)

-- 默认参数
local PERISH_MAP = {
	["less"] = 0.5,
	["normal"] = 1,
	["much"] = 2,
}

local LANG_MAP = {
	["english"] = {
		["NAME"] = "Blue Glasses",
		["REC_DESC"] = "Simple and beauti",
		["DESC"] = "I feel knowledge",
	},
	["chinese"] = {
		["NAME"] = "岚色眼镜",
		["REC_DESC"] = "简单而精美",
		["DESC"] = "我有文化我自豪",
	},
}

local LANG = LANG_MAP[language] or LANG_MAP.english

TUNING.AIP_BLUE_GLASSES_FUEL = TUNING.YELLOWAMULET_FUEL * 2 * PERISH_MAP[dress_uses]

-- 文字描述
STRINGS.NAMES.AIP_BLUE_GLASSES = LANG.NAME
STRINGS.RECIPE_DESC.AIP_BLUE_GLASSES = LANG.REC_DESC
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_BLUE_GLASSES = LANG.DESC

-- 配方
local aip_blue_glasses = Recipe("aip_blue_glasses", {Ingredient("steelwool", 1)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO)
aip_blue_glasses.atlas = "images/inventoryimages/aip_blue_glasses.xml"

local tempalte = require("prefabs/aip_dress_template")
return tempalte("aip_blue_glasses", {
	fueled = {
		level = TUNING.AIP_BLUE_GLASSES_FUEL,
	},
	dapperness = TUNING.DAPPERNESS_LARGE,
})