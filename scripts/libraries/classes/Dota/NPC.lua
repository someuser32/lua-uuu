---@enum AbilityExcludeLevel
local ability_exclude_level = {
	[0] = 34,
	[1] = 15,
	[2] = 8
}

---@enum InventoryExcludeLevel
local item_exclude_level = {
	[0] = 15,
	[1] = 8,
	[2] = 5
}

---@class CNPC: CEntity
local CNPC = class("CNPC", CEntity)

---@param func_name string
---@param val any
---@return string[] | any?
function CNPC.static:GetType(func_name, val)
	if val == nil then
		return nil
	end
	local types = {
		["GetItem"] = "CItem",
		["GetModifier"] = "CModifier",
		["GetModifiers"] = "CModifier",
		["GetChannellingAbility"] = "CAbility",
		["GetItemByIndex"] = "CItem",
		["GetAbilityByIndex"] = "CAbility",
		["GetAbilityByActivity"] = "CAbility",
		["GetAbility"] = "CAbility",
	}
	return types[func_name] or CEntity.GetType(self, func_name, val)
end

---@return string[]
function CNPC.static:ListAPIs()
	return {
		"GetAll",
		"InRadius",
		"GetModifiers",
	}
end

---@return CNPC[]
function CNPC.static:GetAll()
	return self:StaticAPICall("GetAll", NPCs.GetAll)
end

---@return integer
function CNPC.static:Count()
	return self:StaticAPICall("Count", NPCs.Count)
end

---@param ent integer
---@return CNPC?
function CNPC.static:Get(ent)
	return self:StaticAPICall("Get", NPCs.Get, ent)
end

---@param ent CNPC
---@return boolean
function CNPC.static:Contains(ent)
	return self:StaticAPICall("Contains", NPCs.Contains, ent)
end

---@param vec Vector
---@param radius number
---@param teamNum Enum.TeamNum
---@param teamType Enum.TeamType
---@return CNPC[]
function CNPC.static:FindInRadius(vec, radius, teamNum, teamType)
	return self:StaticAPICall("InRadius", NPCs.InRadius, vec, radius, teamNum, teamType)
end

---@param entindex integer
---@return CNPC?
function CNPC.static:FromIndex(entindex)
	local ent = CEntity:Get(entindex)
	if ent == nil or not ent:IsEntity() then
		return nil
	end
	return CNPC:new(ent.ent)
end

---@param exclude_level InventoryExcludeLevel?
---@return {integer: CItem}
function CNPC:GetInventory(exclude_level)
	local items = {}
	for i=0, item_exclude_level[exclude_level or 2] do
		local item = self:GetItemByIndex(i)
		if item ~= nil then
			items[i] = item
		end
	end
	return items
end

---@param exclude_level AbilityExcludeLevel?
---@return {integer: CAbility}
function CNPC:GetAbilities(exclude_level)
	local abilities = {}
	for i=0, ability_exclude_level[exclude_level or 0] do
		local ability = self:GetAbilityByIndex(i)
		if abilities ~= nil then
			abilities[i] = ability
		end
	end
	return abilities
end

---@param name string
---@param exclude_level ItemExcludeLevel?
---@param general boolean?
---@return CItem?
function CNPC:GetItemByName(name, exclude_level, general)
	local item = self:GetItem(name)
	if item ~= nil then
		return item
	end
	for i=0, item_exclude_level[exclude_level or 0] do
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

---@param item CItem
---@return integer?
function CNPC:GetItemSlot(item)
	for i=0, 15 do
		local temp_item = self:GetItemByIndex(i)
		if temp_item ~= nil and temp_item.ent == item.ent then
			return i
		end
	end
end

---@param name string
---@param exclude_level ItemExcludeLevel?
---@param general boolean?
---@return CAbility | CItem | nil
function CNPC:GetAbilityOrItemByName(name, exclude_level, general)
	if string.startswith(name, "item_") then
		local item = self:GetItemByName(name, exclude_level, general)
		if item then
			return item
		end
	end
	return self:GetAbility(name)
end

---@return boolean
function CNPC:IsChannellingAbility()
	if self:APIIsChannellingAbility() then
		return true
	end
	for _, item in pairs(self:GetInventory()) do
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

---@return integer
function CNPC:GetLinkenProtects()
	local modifiers = {"modifier_item_sphere_target", "modifier_special_bonus_spell_block"}
	local items = {"item_sphere", "item_mirror_shield"}
	local protects = 0
	for _, modifier_name in pairs(modifiers) do
		if self:HasModifier(modifier_name) then
			if modifier_name == "modifier_spirit_breaker_planar_pocket" then
				if self:HasModifier("modifier_spirit_breaker_planar_pocket_aura") then
					protects = protects - 1
				end
			end
			protects = protects + 1
		end
	end
	for _, item_name in pairs(items) do
		local item = self:GetItemByName(item_name, 2)
		if item ~= nil and item:GetEffectiveCooldown() <= 0 then
			protects = protects + 1
		end
	end
	return protects
end

---@return boolean
function CNPC:IsReflectsSpells()
	local modifiers = {"modifier_item_lotus_orb_active", "modifier_antimage_counterspell"}
	return self:IsMirrorProtected() or table.any(table.map(modifiers, function(_, modifier_name) return self:HasModifier(modifier_name) end))
end

---@return boolean
function CNPC:IsAbsorbsSpells()
	local modifiers = {"modifier_antimage_counterspell"}
	return table.any(table.map(modifiers, function(_, modifier_name) return self:HasModifier(modifier_name) end))
end

---@param position Vector
---@param range number
---@param tolerance number
---@return boolean
function CNPC:CanCastToPosition(position, range, tolerance)
	return math.is_vector_between(position, self:GetAbsOrigin(), self:GetAbsOrigin() + self:GetRotation():GetForward() * range, tolerance)
end

---@param vec Vector
---@return number
function CNPC:GetAngleDiffVector(vec)
	return vector.angle_between_vectors(self:GetRotation():GetForward(), (vec - self:GetAbsOrigin()):Normalized())
end

---@param angle number
---@return number
function CNPC:GetTurnTime(angle)
	angle = angle or 180
	return (0.03 * (angle*math.pi/180)) / self:GetTurnRate()
end

---@param position Vector
---@param rangeStart number
---@param rangeStepStart number
---@param rangeStepEnd number
---@param delay number
---@param endCallback function?
---@return integer
function CNPC:MoveToInterpolated(position, rangeStart, rangeStepStart, rangeStepEnd, delay, endCallback)
	local myPos = self:GetAbsOrigin()
	local direction = (position - myPos):Normalized()
	local rangeEnd = (position - myPos):Length2D()
	local ent = self
	local i = rangeStart
	return Timers:CreateTimer(0, function()
		ent:MoveTo(myPos + direction * i)
		i = i + math.random(rangeStepStart, rangeStepEnd)
		if i <= rangeEnd then
			return delay
		end
		if endCallback ~= nil then
			endCallback()
		end
	end)
end

---@param position Vector
---@param queue boolean?
---@param showeffects boolean?
---@param pushtocallback boolean?
---@return nil
function CNPC:MoveTo(position, queue, showeffects, pushtocallback)
	return CPlayer:GetLocal():PrepareUnitOrders(Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, position, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self, (queue ~= nil and {queue} or {false})[1], (showeffects ~= nil and {showeffects} or {false})[1], (pushtocallback ~= nil and {pushtocallback} or {true})[1])
end

---@param position Vector
---@param queue boolean?
---@param showeffects boolean?
---@param pushtocallback boolean?
---@return nil
function CNPC:MoveToDirectional(position, queue, showeffects, pushtocallback)
	return CPlayer:GetLocal():PrepareUnitOrders(Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_DIRECTION, nil, position, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self, (queue ~= nil and {queue} or {false})[1], (showeffects ~= nil and {showeffects} or {false})[1], (pushtocallback ~= nil and {pushtocallback} or {true})[1])
end

---@return nil
function CNPC:Stop()
	return CPlayer:GetLocal():PrepareUnitOrders(Enum.UnitOrder.DOTA_UNIT_ORDER_STOP, nil, nil, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self, false, true, true)
end

---@param lotus_pool CNPC
---@param queue boolean?
---@param showeffects boolean?
---@param pushtocallback boolean?
---@return nil
function CNPC:PickupLotus(lotus_pool, queue, showeffects, pushtocallback)
	local ability = self:GetAbility("ability_pluck_famango")
	if ability == nil then
		return
	end
	return ability:Cast(lotus_pool, (queue ~= nil and {queue} or {false})[1], (showeffects ~= nil and {showeffects} or {false})[1], (pushtocallback ~= nil and {pushtocallback} or {true})[1])
end

---@param position Vector
---@param radius number
---@param local_priority boolean?
---@return CNPC[]
function CNPC:GetControllableUnits(position, radius, local_priority)
	local units = {}
	local local_player = CPlayer:GetLocal()
	local local_player_id = local_player:GetPlayerID()
	for _, unit in pairs(CNPC:FindInRadius(position, radius, CPlayer:GetLocalTeam(), Enum.TeamType.TEAM_FRIEND)) do
		if unit:IsEntity() and unit:IsControllableByPlayer(local_player_id) then
			table.insert(units, unit)
		end
	end
	table.sort(units, function(a, b)
		if local_priority then
			local a_owner = a:RecursiveGetOwner()
			local b_owner = b:RecursiveGetOwner()
			if a_owner ~= b_owner then
				if a_owner == local_player then
					return true
				elseif b_owner == local_player then
					return false
				end
			end
		end
		local a_position = a:GetAbsOrigin()
		local b_position = b:GetAbsOrigin()
		return (position - a_position):Length2D() < (position - b_position):Length2D()
	end)
	return units
end

---@param can_turn boolean?
---@param cast_ability CAbility?
---@param cast_position Vector?
---@return (CAbility|CItem)[]
function CNPC:GetUsableBKBs(can_turn, cast_ability, cast_position)
	local bkb_abilities = {
		["life_stealer_rage"] = {true, true},
		["juggernaut_blade_fury"] = {true, true},
		["omniknight_martyr"] = {true, true},
		["legion_commander_press_the_attack"] = {function()
			return self:HasTalent("special_bonus_unique_legion_commander_8")
		end, true},
		["lion_mana_drain"] = {function()
			return self:HasShard()
		end, false},
		["dawnbreaker_fire_wreath"] = {function()
			return self:HasShard()
		end, function()
			if can_turn or not cast_position then
				return true
			end
			return math.deg(self:FindRotationAngle(cast_position)) < 15
		end},
		["rattletrap_power_cogs"] = {function()
			return self:HasTalent("special_bonus_unique_clockwerk_6")
		end, function()
			if not cast_ability or not cast_position then
				return true
			end
			return (cast_position - self:GetAbsOrigin()):Length2D() < cast_ability:GetCastRange()
		end},
		["item_black_king_bar"] = {true, true},
	}
	local ability_bkb_abilities = CAbility:GetBKBs(false)
	if #ability_bkb_abilities ~= table.length(bkb_abilities) then
		print("[WARNING] CNPC:GetUsableBKBs and CAbility:GetBKBs has different bkb list!")
	else
		local bkbs = table.keys(bkb_abilities)
		for i=1, #bkbs do
			local bkb1, bkb2 = bkbs[i], ability_bkb_abilities[i]
			if not table.contains(bkbs, bkb2) or not table.contains(ability_bkb_abilities, bkb1) then
				print("[WARNING] CNPC:GetUsableBKBs and CAbility:GetBKBs has different bkb list!")
				break
			end
		end
	end
	bkb_abilities = table.filter(bkb_abilities, function(_, bkb_info)
		if bkb_info[1] ~= nil then
			if type(bkb_info[1]) == "boolean" then
				if not bkb_info[1] then
					return false
				end
			elseif type(bkb_info[1]) == "function" then
				if not bkb_info[1]() then
					return false
				end
			end
		end
		if bkb_info[2] ~= nil and (cast_ability ~= nil or cast_position ~= nil) then
			if type(bkb_info[2]) == "boolean" then
				if not bkb_info[2] then
					return false
				end
			elseif type(bkb_info[2]) == "function" then
				if not bkb_info[2]() then
					return false
				end
			end
		end
		return true
	end)
	local bkbs = table.map(bkb_abilities, function(bkb, _) return self:GetAbilityOrItemByName(bkb) end)
	return table.values(table.filter(bkbs, function(_, bkb) return bkb ~= nil and bkb:CanCast() end))
end

---@return (CAbility|CItem)[]
function CNPC:GetUsableSpellAbsorbs()
	local absorb_abilities = {
		["antimage_counterspell"] = true
	}
	local abilities = table.map(absorb_abilities, function(ability_name, _) return self:GetAbilityOrItemByName(ability_name) end)
	return table.values(table.filter(abilities, function(_, ability) return ability ~= nil and ability:CanCast() end))
end

---@param ability_names string[] | [string, boolean][]
---@param target CNPC
---@param linken_breaker LinkenBreaker
---@param spell_reflect SpellReflect
---@param custom_filter function?
---@return (CAbility|CItem)[]
function CNPC:GetUsableAbilities(ability_names, target, linken_breaker, spell_reflect, custom_filter)
	local distance = (target:GetAbsOrigin() - self:GetAbsOrigin()):Length2D()
	local target_team = target:GetTeamNum()
	local is_ally = target_team == self:GetTeamNum()
	local is_target_bkb = target:IsDebuffImmune()
	local is_target_absorbs = target:IsAbsorbsSpells()
	local usable_abilities = {}
	for _, ability_info in pairs(ability_names) do
		local ability_name = type(ability_info) == "table" and ability_info[1] or ability_info
		local is_pierces_bkb_override = (type(ability_info) == "table" and {ability_info[2]} or {nil})[1]
		local ability = self:GetAbilityOrItemByName(ability_name)
		if ability ~= nil then
			local filter = (custom_filter ~= nil and {custom_filter(ability)} or {nil})[1]
			if filter == 1 then
				table.insert(usable_abilities, ability)
			elseif filter ~= false then
				if ability:CanTargetTeam(target_team) and ability:CanCast() and (is_ally or (not is_target_bkb or (is_pierces_bkb_override ~= nil and {is_pierces_bkb_override} or {ability:PiercesBKB()})[1])) then
					local is_triggers_linken = CAbility:IsTriggersAbsorb(ability_name)
					if is_ally or (not is_triggers_linken or not is_target_absorbs) then
						local cast_range = ability:GetCastRange()
						if cast_range == 0 and ability:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
							cast_range = ability:GetRadius()
						end
						if cast_range == 0 or (cast_range + (ability:GetAOERadius() / 1.5)) >= distance then
							if is_ally or (not is_triggers_linken or LinkenBreaker:CanUseAbility(ability, target, linken_breaker, nil, ability_name)) then
								if is_ally or (not is_triggers_linken or SpellReflect:CanUse(ability, target, spell_reflect[1], spell_reflect[2])) then
									table.insert(usable_abilities, ability)
								end
							end
						end
					end
				end
			end
		end
	end
	return usable_abilities
end

---@param ability_name string
---@return boolean
function CNPC:HasTalent(ability_name)
	local talent = self:GetAbility(ability_name)
	return talent ~= nil and talent:GetLevel() > 0
end

---@return table
function CNPC:GetKV()
	return KVLib:GetUnitKV(self:GetUnitName())
end

---@return boolean
function CNPC:HasInventory()
	local kv = self:GetKV()
	if kv == nil then
		return false
	end
	return kv["HasInventory"] == 1
end

---@return boolean
function CNPC:IsSpiritBear()
	return string.startswith(self:GetUnitName(), "npc_dota_lone_druid_bear")
end

---@return boolean
function CNPC:IsTempestDouble()
	return self:HasModifier("modifier_arc_warden_tempest_double")
end

---@return boolean
function CNPC:IsVengefulSpiritIllusion()
	return self:HasModifier("modifier_vengefulspirit_command_aura_illusion")
end

---@param modifiers string[]
---@return boolean
function CNPC:HasAnyModifier(modifiers)
	for _, modifier_name in pairs(modifiers) do
		if self:HasModifier(modifier_name) then
			return true
		end
	end
	return false
end

---@return boolean
function CNPC:IsTrueSight()
	return self:HasAnyModifier({"modifier_truesight", "modifier_item_dustofappearance"})
end

---@return boolean
function CNPC:IsTrueSightImmune()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_TRUESIGHT_IMMUNE) or self:HasAnyModifier({"modifier_smoke_of_deceit", "modifier_phantom_assassin_blur_active", "modifier_slark_depth_shroud", "modifier_slark_shadow_dance", "modifier_invisible_truesight_immune"})
end

---@return boolean
function CNPC:IsFlyingForPathing()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY)
end

---@return boolean
function CNPC:IsFlying()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_FLYING)
end

---@return boolean
function CNPC:HasFlying()
	return self:IsFlying() or self:IsFlyingForPathing()
end

---@return boolean
function CNPC:IsInvisible()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_INVISIBLE)
end

---@return boolean
function CNPC:IsHexed()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_HEXED)
end

---@return boolean
function CNPC:IsMuted()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_MUTED)
end

---@return boolean
function CNPC:IsNightmared()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_NIGHTMARED)
end

---@return boolean
function CNPC:IsTaunted()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_TAUNTED)
end

---@return boolean
function CNPC:IsFeared()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_FEARED)
end

---@return boolean
function CNPC:IsSpellImmune()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
end

---@return boolean
function CNPC:IsDebuffImmune()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_DEBUFF_IMMUNE)
end

---@return boolean
function CNPC:CanPathThroughTrees()
	return self:HasFlying() or self:HasState(Enum.ModifierState.MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES)
end

---@return number
function CNPC:GetInvisibilityTime()
	return self:GetModifierProperty(Enum.ModifierFunction.MODIFIER_PROPERTY_INVISIBILITY_LEVEL)
end

---@return CAbility | CItem | nil
function CNPC:GetInvisibilityTimeSource()
	local modifier = self:GetModifiers(Enum.ModifierFunction.MODIFIER_PROPERTY_INVISIBILITY_LEVEL)[1]
	if modifier == nil then
		return nil
	end
	return modifier:GetAbility()
end

---@return boolean
function CNPC:IsDisabled()
	return self:IsStunned() or self:IsHexed() or self:IsNightmared() or self:IsTaunted() or self:IsFeared()
end

---@return boolean
function CNPC:IsLotusPool()
	return self:GetClassName() == "C_DOTA_BaseNPC_MangoTree"
end

_Classes_Inherite({"Entity", "NPC"}, CNPC)

return CNPC