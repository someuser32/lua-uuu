local class = require("lib/middleclass")

local handleFunctions = {
	["userdata"] = function(classObject, methodName, value)
		local classObjects = {
			CAbilities = function(key, val)
				if val == nil then return val end
				return CAbility:new(val)
			end,
			CHeroes = function(key, val)
				if val == nil then return val end
				return CHero:new(val)
			end,
			CNPCs = function(key, val)
				if val == nil then return val end
				return CNPC:new(val)
			end,
			CPlayers = function(key, val)
				if val == nil then return val end
				return CPlayer:new(val)
			end,
			CTrees = function(key, val)
				if val == nil then return val end
				return CTree:new(val)
			end,
			CCouriers = function(key, val)
				if val == nil then return val end
				return CCourier:new(val)
			end,
			CRunes = function(key, val)
				if val == nil then return val end
				return CRune:new(val)
			end,
			CPhysicalItems = function(key, val)
				if val == nil then return val end
				return CPhysicalItem:new(val)
			end,
			CTowers = function(key, val)
				if val == nil then return val end
				return CTower:new(val)
			end,
			CAbility = function(key, val)
				if val == nil then return val end
				if table.contains({"GetOwner"}, key) then
					return CHero:new(val)
				end
			end,
			CEntity = function(key, val)
				if val == nil then return val end
				if table.contains({"GetOwner", "RecursiveGetOwner", "GetHeroesInRadius", "GetUnitsInRadius"}, key) then
					return CHero:new(val)
				elseif table.contains({"GetTreesInRadius"}, key) then
					return CTree:new(val)
				end
			end,
			CItem = function(key, val)
				if val == nil then return val end
				return val
			end,
			CNPC = function(key, val)
				if val == nil then return val end
				if table.contains({"GetItemByIndex", "GetItem"}, key) then
					return CItem:new(val)
				elseif table.contains({"GetAbilityByIndex", "GetAbility"}, key) then
					return CAbility:new(val)
				elseif table.contains({"GetReplicatingOtherHeroModel"}, key) then
					return CHero:new(val)
				-- elseif table.contains({"GetModifiers"}, key) then
				-- 	return CModifier
				end
				return val
			end,
			CHero = function(key, val)
				if val == nil then return val end
				return val
			end,
			CPlayer = function(key, val)
				if val == nil then return val end
				return val
			end,
			CCourier = function(key, val)
				if val == nil then return val end
				return val
			end,
			CPowerTreads = function(key, val)
				if val == nil then return val end
				return val
			end,
			CRune = function(key, val)
				if val == nil then return val end
				return val
			end,
			CBottle = function(key, val)
				if val == nil then return val end
				return val
			end,
			CPhysicalItem = function(key, val)
				if val == nil then return val end
				if table.contains({"GetItem"}, key) then
					return CItem:new(val)
				end
				return val
			end,
			CTower = function(key, val)
				if val == nil then return val end
				if table.contains({"GetAttackTarget"}, key) then
					return CHero:new(val)
				end
				return val
			end,
		}
		if classObjects[classObject.name] == nil then
			return value
		end
		if type(value) == "userdata" then
			return classObjects[classObject.name](methodName, value)
		elseif type(value) == "table" and table.alltypeof(value, "userdata") then
			return table.map(value, function(_, val) return classObjects[classObject.name](methodName, val) end)
		end
		return value
	end
}

local function InheriteFrom(classObject, parentObjects, handleFunction)
	if classObject == nil then return end
	for _, parentObject in pairs(parentObjects) do
		for key, value in pairs(parentObject) do
			if type(value) == "function" then
				-- if classObject["API"..key] == nil then
					classObject["API"..key] = function(self, ...)
						if self.ent == nil then return end
						local args = table.map({...}, function(_, arg) if type(arg) == "table" and arg.ent ~= nil then return arg.ent end return arg end)
						local val = pcall(value, {self.ent, table.unpack(args)}) == true and value(self.ent, table.unpack(args)) or nil
						if val == nil then return nil end
						return handleFunction ~= nil and (handleFunctions[handleFunction] or handleFunction)(classObject, key, val) or val
					end
					if classObject[key] == nil then
						classObject[key] = classObject["API"..key]
					end
				-- end
			end
		end
	end
end

local function StaticInheriteFrom(classObject, parentObjects, handleFunction)
	for _, parentObject in pairs(parentObjects) do
		for key, value in pairs(parentObject) do
			if type(value) == "function" then
				-- if classObject.static["API"..key] == nil then
					classObject.static["API"..key] = function(...)
						local args = table.map({...}, function(_, arg) if type(arg) == "table" and arg.ent ~= nil then return arg.ent end return arg end)
						return handleFunction ~= nil and (handleFunctions[handleFunction] or handleFunction)(classObject, key, value(table.unpack(args))) or value(table.unpack(args))
					end
					if classObject.static[key] == nil then
						classObject.static[key] = classObject.static["API"..key]
					end
				-- ends
			end
		end
	end
end

CBaseEntityList = class("CBaseEntityList")

CAbilities = class("CAbilities", CBaseEntityList)

StaticInheriteFrom(CAbilities, {Abilities}, "userdata")

CHeroes = class("CHeroes", CBaseEntityList)

StaticInheriteFrom(CHeroes, {Heroes}, "userdata")

function CHeroes.static:GetEnemies()
	local localTeam = CPlayer.GetLocalTeam()
	return table.values(table.filter(CHeroes.GetAll(), function(_, hero)
		return localTeam ~= hero:GetTeamNum()
	end))
end

function CHeroes.static:GetEnemiesHeroNames()
	local localTeam = CPlayer.GetLocalTeam()
	local enemyPlayers = table.values(table.filter(CPlayers.GetAll(), function(_, player)
		return localTeam ~= player:GetTeamNum()
	end))
	local enemies = {}
	for _, player in pairs(enemyPlayers) do
		enemies[player:GetPlayerID()] = KVLib:HeroIDToName(player:GetTeamData()["selected_hero_id"])
	end
	return enemies
end

function CHeroes.static:GetAllies()
	local localTeam = CPlayer.GetLocalTeam()
	return table.values(table.filter(CHeroes.GetAll(), function(_, hero)
		return localTeam == hero:GetTeamNum()
	end))
end

function CHeroes.static:GetAlliesHeroNames()
	local localTeam = CPlayer.GetLocalTeam()
	local allyPlayers = table.values(table.filter(CPlayers.GetAll(), function(_, player)
		return localTeam == player:GetTeamNum()
	end))
	local allies = {}
	for _, player in pairs(allyPlayers) do
		allies[player:GetPlayerID()] = KVLib:HeroIDToName(player:GetTeamData()["selected_hero_id"])
	end
	return allies
end

function CHeroes.static:GetAlliesOnly()
	local localHero = CHeroes.GetLocal()
	local localTeam = localHero:GetTeamNum()
	return table.values(table.filter(CHeroes.GetAll(), function(_, hero)
		return localHero ~= hero and localTeam == hero:GetTeamNum()
	end))
end

function CHeroes.static:GetAlliesOnlyHeroNames()
	local localPlayer = CPlayer.GetLocal()
	local localTeam = localPlayer:GetTeamNum()
	local allyPlayers = table.values(table.filter(CPlayers.GetAll(), function(_, player)
		return localPlayer ~= player and localTeam == player:GetTeamNum()
	end))
	local allies = {}
	for _, player in pairs(allyPlayers) do
		allies[player:GetPlayerID()] = KVLib:HeroIDToName(player:GetTeamData()["selected_hero_id"])
	end
	return allies
end

CLinearProjectiles = class("CLinearProjectiles", CBaseEntityList)

StaticInheriteFrom(CLinearProjectiles, {LinearProjectiles}, "userdata")

CNPCs = class("CNPCs", CBaseEntityList)

StaticInheriteFrom(CNPCs, {NPCs}, "userdata")

CPlayers = class("CPlayers", CBaseEntityList)

StaticInheriteFrom(CPlayers, {Players}, "userdata")

CTargetProjectiles = class("CTargetProjectiles", CBaseEntityList)

StaticInheriteFrom(CTargetProjectiles, {TargetProjectiles}, "userdata")

CTrees = class("CTrees", CBaseEntityList)

StaticInheriteFrom(CTrees, {Trees}, "userdata")

CCouriers = class("CCouriers", CBaseEntityList)

StaticInheriteFrom(CCouriers, {Couriers}, "userdata")

CRunes = class("CRunes", CBaseEntityList)

StaticInheriteFrom(CRunes, {Runes}, "userdata")

CPhysicalItems = class("CPhysicalItems", CBaseEntityList)

StaticInheriteFrom(CPhysicalItems, {PhysicalItems}, "userdata")

CTowers = class("CTowers", CBaseEntityList)

StaticInheriteFrom(CTowers, {Towers}, "userdata")

CBaseEntity = class("CBaseEntity")

function CBaseEntity:initialize(ent, ...)
	self.ent = ent
	for key, value in pairs({...}) do
		self[key] = value
	end
end

function CBaseEntity:__eq(ent2)
	return self.ent == ent2.ent
end

CAbility = class("CAbility", CBaseEntity)

InheriteFrom(CAbility, {Ability}, "userdata")

CAbility.invoker_crafts = {
	["invoker_cold_snap"] = "qqq",
	["invoker_ghost_walk"] = "qqw",
	["invoker_ice_wall"] = "qqe",
	["invoker_deafening_blast"] = "qwe",
	["invoker_tornado"] = "wwq",
	["invoker_emp"] = "www",
	["invoker_alacrity"] = "wwe",
	["invoker_forge_spirit"] = "eeq",
	["invoker_chaos_meteor"] = "eew",
	["invoker_sun_strike"] = "eee",
}

function CAbility:GetCaster()
	return self:APIGetOwner()
end

function CAbility:IsItem()
	return false
end

function CAbility:CanCast()
	local caster = self:GetCaster()
	return self:GetLevel() > 0 and caster:IsAlive() and not caster:IsDisabled() and not caster:IsSilenced() and self:IsCastable(caster:GetMana(), false) and self:GetEffectiveCooldown() <= 0
end

function CAbility.static:IsBlinkName()
	return table.contains({"item_blink", "item_arcane_blink", "item_overwhelming_blink", "item_swift_blink"}, self)
end

function CAbility.static:IsDagonName()
	return table.contains({"item_dagon", "item_dagon_2", "item_dagon_3", "item_dagon_4", "item_dagon_5"}, self)
end

function CAbility:IsBlink()
	return CAbility.IsBlinkName(self:GetName())
end

function CAbility:IsDagon()
	return CAbility.IsDagonName(self:GetName())
end

function CAbility:GetName(general)
	if not general then
		return self:APIGetName()
	end
	if self:IsBlink() then
		return "item_blink"
	elseif self:IsDagon() then
		return "item_dagon"
	end
	return self:APIGetName()
end

function CAbility:HasBehavior(behavior)
	return (self:GetBehavior() & behavior) == behavior
end

function CAbility:CanCastToPosition(position, tolerance)
	return self:GetCaster():CanCastToPosition(position, self:GetCastRange(), tolerance)
end

function CAbility:GetOneOfKVs(KVs)
	local ability_keys = KVLib:GetAbilitySpecialKeys(self:GetName(true))
	for _, kv in pairs(KVs) do
		if table.contains(ability_keys, kv) then
			return self:GetLevelSpecialValueFor(key)
		end
	end
	return 0
end

function CAbility:GetRadius()
	return self:GetOneOfKVs({"radius", "whirling_radius"})
end

function CAbility:GetAOERadius()
	return self:GetOneOfKVs({"radius"})
end

function CAbility:GetChannelTime()
	return self:GetLevelSpecialValueForFloat("AbilityChannelTime")
end

function CAbility:GetAffectedCastRange()
	return self:GetCastRange() + self:GetAOERadius()
end

function CAbility:PiercesBKB()
	local pierces_bkb = {
		"item_abyssal_blade"
	}
	return self:GetImmunityType() == Enum.ImmunityTypes.SPELL_IMMUNITY_ENEMIES_YES or table.contains(pierces_bkb, self:GetName())
end

function CAbility:IsUsed(last)
	last = last or 0.25
	local max_cooldown = self:GetCooldownLength()
	local last_used = self:SecondsSinceLastUse()
	if table.contains({"item_blink", "item_overwhelming_blink", "item_swift_blink", "item_arcane_blink"}, self:GetName()) then
		if max_cooldown < 4 then
			return false
		end
	end
	return last_used ~= -1 and last_used < last
end

function CAbility:GetEffectiveCooldown()
	if CAbility.invoker_crafts[self:GetName()] ~= nil and self:IsHidden() then
		local invoke = self:GetCaster():GetAbility("invoker_invoke")
		if invoke ~= nil then
			return math.max(self:GetCooldown(), invoke:GetCooldown())
		end
	end
	return self:GetCooldown()
end

function CAbility:CanBeCrafted()
	local craft = CAbility.invoker_crafts[self:GetName()]
	if craft == nil then return false end
	if not self:IsHidden() then return true end
	local caster = self:GetCaster()
	local quas = caster:GetAbility("invoker_quas")
	local wex = caster:GetAbility("invoker_wex")
	local exort = caster:GetAbility("invoker_exort")
	local has_quas = quas:GetLevel() > 0
	local has_wex = wex:GetLevel() > 0
	local has_exort = exort:GetLevel() > 0
	for _, sphere in pairs(string.split(craft, "")) do
		if sphere == "q" and not has_quas then
			return false
		elseif sphere == "w" and not has_wex then
			return false
		elseif sphere == "e" and not has_exort then
			return false
		end
	end
	return true
end

function CAbility:Craft(callback, context)
	local craft = CAbility.invoker_crafts[self:GetName()]
	if craft ~= nil and not self:IsHidden() then
		if context ~= nil then
			callback(context, true)
		else
			callback(true)
		end
		return
	end
	local caster = self:GetCaster()
	local invoke = caster:GetAbility("invoker_invoke")
	if invoke == nil then
		if context ~= nil then
			callback(context, false)
		else
			callback(false)
		end
		return
	end
	local quas = caster:GetAbility("invoker_quas")
	local wex = caster:GetAbility("invoker_wex")
	local exort = caster:GetAbility("invoker_exort")
	if quas == nil or wex == nil or exort == nil then
		if context ~= nil then
			callback(context, false)
		else
			callback(false)
		end
	end
	local i = 1
	craft = string.split(craft, "")
	return timer.Barebones(invoke:GetCooldown(), function(self)
		if craft[i] == nil then
			invoke:Cast()
			if context ~= nil then
				callback(context, true)
			else
				callback(true)
			end
			return
		end
		if craft[i] == "q" then
			quas:Cast()
		elseif craft[i] == "w" then
			wex:Cast()
		elseif craft[i] == "e" then
			exort:Cast()
		end
		i = i + 1
		return 0.005
	end, self)
end

function CAbility:GetLevel()
	local craft = CAbility.invoker_crafts[self:GetName()]
	if craft ~= nil and not self:CanBeCrafted() then
		return 0
	end
	return self:APIGetLevel()
end

function CAbility:Cast(target, queue, showeffects, pushtocallback)
	local targetType = target ~= nil and ((target.Length2D ~= nil and target.Dot2D ~= nil and target.ToAngle ~= nil) and "vector" or "target") or "nil"
	local caster = self:GetCaster()
	if self:IsHidden() then
		if self:CanBeCrafted() then
			return self:Craft(function(self) return self:Cast(target, queue, showeffects, pushtocallback) end, self)
		end
	end
	if self:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and targetType == "target" then
		return Player.PrepareUnitOrders(CPlayer.GetLocal().ent, target:IsTree() and Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET_TREE or Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET, target.ent, target:GetAbsOrigin(), self.ent, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self:GetCaster().ent, false, true, false)
	elseif self:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_POINT) then
		return Player.PrepareUnitOrders(CPlayer.GetLocal().ent, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION, nil, targetType == "vector" and target or target:GetAbsOrigin(), self.ent, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self:GetCaster().ent, false, true, false)
	elseif self:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_TOGGLE) then
		return Player.PrepareUnitOrders(CPlayer.GetLocal().ent, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TOGGLE, nil, nil, self.ent, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self:GetCaster().ent, false, true, false)
	elseif self:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
		return Player.PrepareUnitOrders(CPlayer.GetLocal().ent, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, nil, self.ent, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self:GetCaster().ent, false, true, false)
	end
end

function CAbility:GetCastRange()
	local special = {
	}
	local keys = {
		"spear_range",
	}
	local ability_name = self:GetName()
	if special[ability_name] ~= nil then
		if type(special[ability_name]) == "function" then
			return special[ability_name]()
		else
			return tonumber(special[ability_name])
		end
	end
	local cast_range = self:GetOneOfKVs(keys)
	return cast_range ~= 0 and cast_range or self:APIGetCastRange()
end

function CAbility:GetProjectileSpeed(target)
	local targetType = target ~= nil and ((target.Length2D ~= nil and target.Dot2D ~= nil and target.ToAngle ~= nil) and "vector" or "target") or "nil"
	local special = {
		["ice_shaman_incendiary_bomb"] = 1000,
		["dark_willow_bedlam"] = 1400,
		["brewmaster_cinder_brew"] = 1600,
		["omniknight_hammer_of_purity"] = 1200,
		["tinker_warp_grenade"] = 1900,
		["warpine_raider_seed_shot"] = 1000,
		["earthshaker_echo_slam"] = 600,
		["beastmaster_hawk_dive"] = function(self)
			if targetType == "vector" then
				return (target - self:GetCaster():GetAbsOrigin()):Length2D()/0.4
			elseif targetType == "target" then
				return (target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()/0.4
			end
			return self:GetCastRange()/0.4
		end,
		["item_paintball"] = 1500,
		["item_gungir"] = 1900,
		["item_rod_of_atos"] = 1900,
	}
	local keys = {
		"projectile_speed",
		"missile_speed",
		"goo_speed",
		"chaos_bolt_speed",
		"net_speed",
		"fling_movespeed",
		"dagger_speed",
		"lance_speed",
		"bolt_speed",
		"magic_missile_speed",
		"arrow_speed",
		"wraith_speed_base",
		"charge_speed",
		"initial_speed",
		"snowball_speed",
		"move_speed",
		"speed",
	}
	local ability_name = self:GetName()
	if special[ability_name] ~= nil then
		if type(special[ability_name]) == "function" then
			return special[ability_name](self)
		else
			return tonumber(special[ability_name])
		end
	end
	return self:GetOneOfKVs(keys)
end

function CAbility:IsLinearProjectile()
	if self:GetProjectileSpeed() == 0 then
		return false
	end
	return self:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_DIRECTIONAL) or self:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_POINT)
end

function CAbility:IsTrackingProjectile()
	if self:GetProjectileSpeed() == 0 then
		return false
	end
	return self:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) or self:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_NO_TARGET)
end

CEntity = class("CEntity", CBaseEntity)

InheriteFrom(CEntity, {Entity}, "userdata")

function CEntity:IsTree()
	return self:IsTempTree() or self:IsMapTree()
end

function CEntity:IsMapTree()
	return self:GetClassName() == "C_DOTA_MapTree"
end

function CEntity:IsTempTree()
	return self:GetClassName() == "C_DOTA_TempTree"
end

CItem = class("CItem", CAbility)

InheriteFrom(CItem, {Item}, "userdata")

function CItem:IsItem()
	return true
end

function CItem:CanCast()
	local caster = self:GetCaster()
	return caster:IsAlive() and not caster:IsDisabled() and not caster:IsMuted() and self:IsCastable(caster:GetMana(), false) and self:GetEffectiveCooldown() <= 0
end

function CItem:GetItemSlot()
	local caster = self:GetCaster()
	for i=0, 15 do
		local temp_item = caster:GetItemByIndex(i)
		if temp_item.ent == self.ent then
			return i
		end
	end
	return nil
end

function CItem:GetContainer()
	for _, container in pairs(CPhysicalItems.GetAll()) do
		if container:GetItem() == self.ent then
			return container
		end
	end
end


function CItem:Drop(position)
	local caster = self:GetCaster()
	Player.PrepareUnitOrders(CPlayer.GetLocal().ent, Enum.UnitOrder.DOTA_UNIT_ORDER_DROP_ITEM, self.ent, position or caster:GetAbsOrigin(), self.ent, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, caster.ent, false, true, true)
end

CNPC = class("CNPC", CEntity)

InheriteFrom(CNPC, {NPC}, "userdata")

function CNPC:GetItems()
	local items = {}
	for i=0, 15 do
		local item = self:GetItemByIndex(i)
		if item ~= nil then
			items[i] = item
		end
	end
	return items
end

function CNPC:GetInventoryItems()
	local items = {}
	for i=0, 5 do
		local item = self:GetItemByIndex(i)
		if item ~= nil then
			items[i] = item
		end
	end
	return items
end

function CNPC:GetItemByName(name, exclude_level, general)
	local item = self:GetItem(name)
	if item ~= nil then
		return item
	end
	local exclude_levels = {
		[0] = 15,
		[1] = 8,
		[2] = 5
	}
	for i=0, exclude_levels[exclude_level] or exclude_levels[0] do
		item = self:GetItemByIndex(i)
		if item ~= nil and item:GetName(general) == name then
			return item
		end
	end
	local tp = self:GetItemByIndex(15)
	if tp ~= nil and tp:GetName(general) == name then
		return tp
	end
	local neutral = self:GetItemByIndex(16)
	if neutral ~= nil and neutral:GetName(general) == name then
		return neutral
	end
end

function CNPC:GetItemSlot(item)
	for i=0, 15 do
		local temp_item = self:GetItemByIndex(i)
		if temp_item ~= nil and temp_item.ent == item.ent then
			return i
		end
	end
end

function CNPC:GetAbilities(exclude_level)
	local abilities = {}
	local exclude_levels = {
		[0] = 31,
		[1] = 15,
		[2] = 8
	}
	for i=0, exclude_levels[exclude_level or 0] do
		local ability = self:GetAbilityByIndex(i)
		if abilities ~= nil then
			abilities[i] = ability
		end
	end
	return abilities
end

function CNPC:IsChannellingAbility()
	if self:APIIsChannellingAbility() then
		return true
	end
	for _, item in pairs(self:GetInventoryItems()) do
		if item:IsChannelling() then
			return true
		end
	end
	local tp = self:GetItemByIndex(15)
	if tp ~= nil then
		if tp:IsChannelling() then
			return true
		end
	end
	local neutral = self:GetItemByIndex(16)
	if neutral ~= nil then
		if neutral:IsChannelling() then
			return true
		end
	end
	return false
end

function CNPC:IsTrueSight()
	return self:HasModifier("modifier_truesight")
end

function CNPC:IsInvisible()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_INVISIBLE)
end

function CNPC:IsHexed()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_HEXED)
end

function CNPC:IsMuted()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_MUTED)
end

function CNPC:IsNightmared()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_NIGHTMARED)
end

function CNPC:IsTaunted()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_TAUNTED)
end

function CNPC:IsFeared()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_FEARED)
end

function CNPC:IsReflectsSpells()
	local modifiers = {"modifier_item_lotus_orb_active", "modifier_antimage_counterspell"}
	return self:IsMirrorProtected() or table.any(table.map(modifiers, function(_, modifier_name) return self:HasModifier(modifier_name) end))
end

function CNPC:IsAbsorbsSpells()
	local modifiers = {"modifier_antimage_counterspell"}
	return table.any(table.map(modifiers, function(_, modifier_name) return self:HasModifier(modifier_name) end))
end

function CNPC:CanCastToPosition(position, range, tolerance)
	return positionIsBetween(position, self:GetAbsOrigin(), self:GetAbsOrigin() + self:GetRotation():GetForward() * range, tolerance)
end

function CNPC:GetTurnTime(angle)
	angle = angle or 180
	return (0.03 * (angle*math.pi/180)) / self:GetTurnRate()
end

function CNPC:GetTurnTimeToPosition(vec)
	return self:GetTurnTime(self:GetAngleToVector(vec))
end

function CNPC:GetTurnTimeToNPC(npc)
	return self:GetTurnTimeToPosition(npc:GetAbsOrigin())
end

function CNPC:IsDisabled()
	return self:IsStunned() or self:IsHexed() or self:IsNightmared() or self:IsTaunted() or self:IsFeared()
end

function CNPC:GetAngleToVector(vec)
	local selfpos = self:GetAbsOrigin()
	local v1 = self:GetRotation():GetForward()
	local v2 = (vec - selfpos):Normalized()
	return AngleBetweenVectors(v1, v2, true)
end

function CNPC:GetAngleToNPC(npc)
	return self:GetAngleToVector(npc:GetAbsOrigin())
end

function CNPC:MoveToInterpolated(position, rangeStart, rangeStepStart, rangeStepEnd, delay, endCallback)
	local myPos = self:GetAbsOrigin()
	local direction = (position - myPos):Normalized()
	local rangeEnd = (position - myPos):Length2D()
	local player = CPlayer.GetLocal().ent
	local ent = self.ent
	local i = 0
	timer.Barebones(0, function()
		Player.PrepareUnitOrders(player, Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, myPos + direction * i, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, ent, false, true, true)
		i = i + math.random(rangeStepStart, rangeStepEnd)
		if i <= rangeEnd then
			return delay
		end
		if endCallback ~= nil then
			endCallback()
		end
	end)
end

function CNPC:Stop()
	return Player.PrepareUnitOrders(CPlayer.GetLocal().ent, Enum.UnitOrder.DOTA_UNIT_ORDER_STOP, nil, nil, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self.ent, false, true, true)
end

function CNPC:IsSpellImmune()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
end

function CNPC:IsDebuffImmune()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_DEBUFF_IMMUNE)
end

CHero = class("CHero", CNPC)

InheriteFrom(CHero, {Hero}, "userdata")

function CHero.static:GetLocal()
	return CHeroes.APIGetLocal()
end

function CHero.static:GetLocalTeam()
	local localHero = CHeroes.APIGetLocal()
	if not localHero then
		return 5
	end
	return localHero:APIGetTeamNum()
end

function CHero.static:GetLocalName()
	local localHero = CHeroes.APIGetLocal()
	if not localHero then
		return ""
	end
	return localHero:APIGetUnitName()
end

CPlayer = class("CPlayer", CEntity)

InheriteFrom(CPlayer, {Player}, "userdata")

function CPlayer.static:GetLocal()
	return CPlayers.APIGetLocal()
end

function CPlayer.static:GetLocalTeam()
	return CPlayers.APIGetLocal():APIGetTeamNum()
end

CTree = class("CTree", CEntity)

InheriteFrom(CTree, {Tree}, "userdata")

CCourier = class("CCourier", CNPC)

InheriteFrom(CCourier, {Courier}, "userdata")

CPowerTreads = class("CPowerTreads", CItem)

InheriteFrom(CPowerTreads, {PowerTreads}, "userdata")

CRune = class("CRune", CBaseEntity)

InheriteFrom(CRune, {Rune}, "userdata")

CBottle = class("CBottle", CItem)

InheriteFrom(CBottle, {Bottle}, "userdata")

CPhysicalItem = class("CPhysicalItem", CEntity)

function CPhysicalItem:Pickup(unit)
	return Player.PrepareUnitOrders(CPlayer.GetLocal().ent, Enum.UnitOrder.DOTA_UNIT_ORDER_PICKUP_ITEM, self.ent, self:GetAbsOrigin(), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, unit.ent, false, true, false)
end

InheriteFrom(CPhysicalItem, {PhysicalItem}, "userdata")

CTower = class("CTower", CNPC)

InheriteFrom(CTower, {Tower}, "userdata")