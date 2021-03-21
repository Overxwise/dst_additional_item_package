local _G = GLOBAL

-- 开发模式
local dev_mode = _G.aipGetModConfig("dev_mode") == "enabled"

-- 额外食物
local additional_food = _G.aipGetModConfig("additional_food") == "open"

------------------------------------ 贪婪观察者 ------------------------------------
-- 暗影跟随者
function ShadowFollowerPrefabPostInit(inst)
	if not _G.TheWorld.ismastersim then
		return
	end

	if not inst.components.shadow_follower then
		inst:AddComponent("shadow_follower")
	end
end

AddPrefabPostInit("dragonfly", function(inst) ShadowFollowerPrefabPostInit(inst) end) -- 龙蝇
AddPrefabPostInit("deerclops", function(inst) ShadowFollowerPrefabPostInit(inst) end) -- 鹿角怪
AddPrefabPostInit("bearger", function(inst) ShadowFollowerPrefabPostInit(inst) end) -- 熊獾
AddPrefabPostInit("moose", function(inst) ShadowFollowerPrefabPostInit(inst) end) -- 麋鹿鹅
AddPrefabPostInit("beequeen", function(inst) ShadowFollowerPrefabPostInit(inst) end) -- 蜂后
AddPrefabPostInit("klaus", function(inst) ShadowFollowerPrefabPostInit(inst) end) -- 克劳斯
AddPrefabPostInit("klaus_sack", function(inst) ShadowFollowerPrefabPostInit(inst) end) -- 克劳斯袋子
AddPrefabPostInit("antlion", function(inst) ShadowFollowerPrefabPostInit(inst) end) -- 蚁狮
AddPrefabPostInit("toadstool", function(inst) ShadowFollowerPrefabPostInit(inst) end) -- 蟾蜍王
AddPrefabPostInit("toadstool_dark", function(inst) ShadowFollowerPrefabPostInit(inst) end) -- 苦难蟾蜍王
AddPrefabPostInit("crabking", function(inst) ShadowFollowerPrefabPostInit(inst) end) -- 帝王蟹
AddPrefabPostInit("hermithouse", function(inst) ShadowFollowerPrefabPostInit(inst) end) -- 隐士之家
AddPrefabPostInit("malbatross", function(inst) ShadowFollowerPrefabPostInit(inst) end) -- 邪天翁

-- ------------------------------------- 豆酱权杖 -------------------------------------
-- GLOBAL.LOCKTYPE.AIP_DOU_OPAL = "aip_dou_opal"

local birds = { "crow", "robin", "robin_winter", "canary", "quagmire_pigeon", "puffin" }
for i, name in ipairs(birds) do
	AddPrefabPostInit(name, function(inst)
		if inst.components.periodicspawner ~= nil then
			-- 因为我们占用了一点概率，因而稍微加快一点生成间隔
			inst.components.periodicspawner.randtime = inst.components.periodicspawner.randtime * 0.95

			local originPrefab = inst.components.periodicspawner.prefab

			-- 鸟儿掉落物如果是种子则有 2% 概率改成树叶笔记
			inst.components.periodicspawner.prefab = function(inst)
				local prefab = originPrefab
				if type(originPrefab) == "function" then
					prefab = originPrefab(inst)
				end

				if prefab == "seeds" and math.random() <= .02 then
					return "aip_leaf_note"
				end

				return prefab
			end
		end
	end)
end

------------------------------------------ 活木 ------------------------------------------
AddPrefabPostInit("livinglog", function(inst)
	-- 添加燃料类型
	inst:AddTag("LIVINGLOG_fuel")
end)

------------------------------------------ 金块 ------------------------------------------
local function canActOnGold(inst, doer, target)
	return target.prefab == "aip_xinyue_hoe"
end

local function onDoGoldTargetAction(inst, doer, target)
	-- 充满
	if target.components.fueled ~= nil then
		target.components.fueled:DoDelta(target.components.fueled.maxfuel, doer)
		inst:Remove()
	end
end

AddPrefabPostInit("goldnugget", function(inst)
	-- 燃料注入
	inst:AddComponent("aipc_action_client")
	inst.components.aipc_action_client.canActOn = canActOnGold

	if not _G.TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("aipc_action")
	inst.components.aipc_action.onDoTargetAction = onDoGoldTargetAction
end)

------------------------------------------ 干草 ------------------------------------------
AddPrefabPostInit("grass", function(inst)
	if not _G.TheWorld.ismastersim then
		return inst
	end

	-- 开启食物时就可以动态草变小麦
	if additional_food then
		if inst.components.pickable ~= nil then
			local oriPickedFn = inst.components.pickable.onpickedfn

			inst.components.pickable.onpickedfn = function(inst, picker, ...)
				oriPickedFn(inst, picker, ...)

				local PROBABILITY = dev_mode and 1 or 0.01

				-- 满足一定概率则生成一个小麦
				if math.random() <= PROBABILITY then
					local wheat = _G.aipReplacePrefab(inst, "aip_wheat")
					wheat.components.pickable:MakeEmpty()
				end
			end
		end
	end
end)


if additional_food and (_G.TheNet:GetIsServer() or _G.TheNet:IsDedicated()) then
	AddPrefabPostInit("world", function (inst)
		inst:WatchWorldState("season", function ()
			for i, player in ipairs(_G.AllPlayers) do
				if not player:HasTag("playerghost") and player.entity:IsVisible() then
					local pos = _G.aipGetSpawnPoint(player:GetPosition())
					local sunflower = _G.SpawnPrefab("aip_sunflower")
					sunflower.Transform:SetPosition(pos.x, pos.y, pos.z)
					break
				end
			end
		end)
	end)
end