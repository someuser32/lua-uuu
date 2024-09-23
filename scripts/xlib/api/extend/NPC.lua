---@param npc userdata
---@return boolean
function NPC.IsTempestDouble(npc)
	return NPC.HasModifier(npc, "modifier_arc_warden_tempest_double")
end

---@param npc userdata
---@return boolean
function NPC.IsCommandAuraIllusion(npc)
	return NPC.HasModifier(npc, "modifier_vengefulspirit_command_aura_illusion")
end

---@param npc userdata
---@return boolean
function NPC.IsMonkeyClone(npc)
	return NPC.HasModifier(npc, "modifier_monkey_king_fur_army_soldier")
end

---@param npc userdata
---@return boolean
function NPC.IsTrueHero(npc)
	return not NPC.xIsIllusion(npc) and not NPC.IsTempestDouble(npc) and not NPC.IsCommandAuraIllusion(npc) and not NPC.IsMonkeyClone(npc)
end

---@param npc userdata
---@return boolean
function NPC.IsSpiritBear(npc)
	return string.startswith(NPC.GetUnitName(npc), "npc_dota_lone_druid_bear")
end

---@param npc userdata
---@return boolean
function NPC.xIsIllusion(npc)
	return NPC.IsIllusion(npc) and not NPC.IsTempestDouble(npc)
end

---@param npc userdata
---@param ability_name string
---@return boolean
function NPC.HasTalent(npc, ability_name)
	local talent = NPC.GetAbility(npc, ability_name)
	return talent ~= nil and Ability.GetLevel(talent) > 0
end

---@param npc userdata
---@param search Enum.InventorySearch?
---@return {integer: userdata}
function NPC.GetInventory(npc, search)
	local items = {}
	for _, slot in pairs(search or Enum.InventorySearch.INVENTORY) do
		local item = NPC.GetItemByIndex(npc, slot)
		if item ~= nil then
			items[slot] = item
		end
	end
	return items
end

---@param npc userdata
---@param include_all boolean?
---@return {integer: userdata}
function NPC.GetAbilities(npc, include_all)
	local abilities = {}
	for i=0, (include_all and 34 or 8) do
		local ability = NPC.GetAbilityByIndex(npc, i)
		if abilities ~= nil then
			abilities[i] = ability
		end
	end
	return abilities
end

---@param npc userdata
---@param name string
---@param isReal boolean?
---@return userdata?
function NPC.GetAbilityOrItemByName(npc, name, isReal)
	if Ability.IsItemName(name) then
		local item = NPC.GetItem(npc, name, isReal)
		if item then
			return item
		end
	end
	return NPC.GetAbility(npc, name)
end

---@param npc userdata
---@param lotus_pool userdata
---@param queue boolean?
---@param showeffects boolean?
---@param pushtocallback boolean?
---@param executefast boolean?
function NPC.PickupLotus(npc, lotus_pool, queue, showeffects, pushtocallback, executefast)
	local ability = NPC.GetAbility(npc, "ability_pluck_famango")
	if ability == nil then
		return
	end
	return Ability.Cast(ability, lotus_pool, queue, showeffects, pushtocallback, executefast)
end

---@param npc userdata
function NPC.Stop(npc)
	return Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_STOP, nil, nil, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc, false, true, true)
end

---@param npc userdata
---@param position Vector
---@param rangeStart number
---@param rangeStepStart number
---@param rangeStepEnd number
---@param delay number
---@param endCallback function?
---@return number
function NPC.MoveToInterpolated(npc, position, rangeStart, rangeStepStart, rangeStepEnd, delay, endCallback)
	local myPos = Entity.GetAbsOrigin(npc)
	local direction = (position - myPos):Normalized()
	local rangeEnd = (position - myPos):Length2D()
	local i = rangeStart
	return Timers:CreateTimer(0, function()
		NPC.MoveTo(npc, myPos + direction * i)
		i = i + math.random(rangeStepStart, rangeStepEnd)
		if i <= rangeEnd then
			return delay
		end
		if endCallback ~= nil then
			endCallback()
		end
	end)
end

---@param npc userdata
---@return boolean
function NPC.IsChannellingAbilityOrItem(npc)
	if NPC.IsChannellingAbility(npc) then
		return true
	end
	for _, item in pairs(NPC.GetInventory(npc, Enum.InventorySearch.INVENTORY)) do
		if Ability.IsChannelling(item) then
			return true
		end
	end
	return false
end

---@param npc userdata
---@param modifiers string[]
---@return boolean
function NPC.HasAnyModifier(npc, modifiers)
	for _, modifier_name in pairs(modifiers) do
		if NPC.HasModifier(npc, modifier_name) then
			return true
		end
	end
	return false
end

---@param npc userdata
---@return boolean
function NPC.IsInvisible(npc)
	return NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_INVISIBLE)
end

---@param npc userdata
---@param ignore_immune? boolean
---@return boolean
function NPC.IsTrueSight(npc, ignore_immune)
	if not ignore_immune and NPC.IsTrueSightImmune(npc) then
		return false
	end
	return NPC.HasAnyModifier(npc, {"modifier_truesight", "modifier_item_dustofappearance"})
end

---@param npc userdata
---@return boolean
function NPC.IsTrueSightImmune(npc)
	return NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_TRUESIGHT_IMMUNE) or NPC.HasAnyModifier(npc, {"modifier_smoke_of_deceit", "modifier_phantom_assassin_blur_active", "modifier_slark_depth_shroud", "modifier_slark_shadow_dance", "modifier_invisible_truesight_immune"})
end

---@param npc userdata
---@return boolean
function NPC.IsFlyingForPathing(npc)
	return NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY)
end

---@param npc userdata
---@return boolean
function NPC.IsFlying(npc)
	return NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_FLYING)
end

---@param npc userdata
---@return boolean
function NPC.HasFlying(npc)
	return NPC.IsFlying(npc) or NPC.IsFlyingForPathing(npc)
end

---@param npc userdata
---@return boolean
function NPC.IsHexed(npc)
	return NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_HEXED)
end

---@param npc userdata
---@return boolean
function NPC.IsMuted(npc)
	return NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MUTED)
end

---@param npc userdata
---@return boolean
function NPC.IsNightmared(npc)
	return NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_NIGHTMARED)
end

---@param npc userdata
---@return boolean
function NPC.IsTaunted(npc)
	return NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_TAUNTED)
end

---@param npc userdata
---@return boolean
function NPC.IsFeared(npc)
	return NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_FEARED)
end

---@param npc userdata
---@return boolean
function NPC.IsSpellImmune(npc)
	return NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
end

---@param npc userdata
---@return boolean
function NPC.IsDebuffImmune(npc)
	return NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_DEBUFF_IMMUNE)
end

---@param npc userdata
---@return boolean
function NPC.CanPathThroughTrees(npc)
	return NPC.HasFlying(npc) or NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES)
end

---@param npc userdata
---@return number
function NPC.GetInvisibilityTime(npc)
	return NPC.GetModifierProperty(npc, Enum.ModifierFunction.MODIFIER_PROPERTY_INVISIBILITY_LEVEL)
end

---@param npc userdata
---@return boolean
function NPC.IsDisabled(npc)
	return NPC.IsStunned(npc) or NPC.IsHexed(npc) or NPC.IsNightmared(npc) or NPC.IsTaunted(npc) or NPC.IsFeared(npc)
end

---@param npc userdata
---@return boolean
function NPC.IsAbsorbsSpells(npc)
	return NPC.HasAnyModifier(npc, {"modifier_antimage_counterspell"})
end

---@param npc userdata
---@param ability_names string[] | [string, number, boolean][]
---@param target userdata
---@param linken_breaker table | function?
---@param spell_reflect table | function?
---@param custom_filter function?
---@return userdata[]
function NPC.GetUsableAbilities(npc, ability_names, target, linken_breaker, spell_reflect, custom_filter)
	local distance = (Entity.GetAbsOrigin(target) - Entity.GetAbsOrigin(npc)):Length2D()
	local target_team = Entity.GetTeamNum(target)
	local is_ally = target_team == Entity.GetTeamNum(npc)
	local is_target_bkb = (Entity.IsNPC(target) and {NPC.IsDebuffImmune(npc)} or {false})[1]
	local is_target_absorbs = (Entity.IsNPC(target) and {NPC.IsAbsorbsSpells(npc)} or {false})[1]
	local usable_abilities = {}
	for _, ability_info in pairs(ability_names) do
		local ability_name = type(ability_info) == "table" and ability_info[1] or ability_info
		local range_buffer = type(ability_info) == "table" and ability_info[2] or 0
		local is_pierces_bkb_override = (type(ability_info) == "table" and {ability_info[3]} or {nil})[1]
		local ability = NPC.GetAbilityOrItemByName(npc, ability_name)
		if ability ~= nil and Ability.CanBeCasted(ability) then
			local filter = (custom_filter ~= nil and {custom_filter(ability)} or {nil})[1]
			if filter == 1 then
				table.insert(usable_abilities, ability)
			elseif filter ~= false then
				if Ability.CanTargetTeam(ability, target_team) and (is_ally or (not is_target_bkb or (is_pierces_bkb_override ~= nil and {is_pierces_bkb_override} or {Ability.PiercesBKB(ability)})[1])) then
					local is_triggers_linken = Ability.IsTriggersAbsorb(ability)
					if is_ally or (not is_triggers_linken or not is_target_absorbs) then
						local cast_range = Ability.GetEffectiveCastRange(ability)
						if cast_range ~= 0 then
							cast_range = cast_range + range_buffer
						else
							if Ability.HasBehavior(ability, Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
								cast_range = Ability.GetRadius(ability)
							end
						end
						if cast_range == 0 or (cast_range + (Ability.GetAOERadius(ability) / 1.5)) >= distance then
							local ability_linken_breaker = (type(linken_breaker) == "function" and {linken_breaker(ability)} or {linken_breaker})[1]
							if is_ally or (not ability_linken_breaker or not is_triggers_linken or LinkenBreaker:CanUseAbility(ability, target, ability_linken_breaker, nil, ability_name)) then
								local ability_spell_reflect = (type(spell_reflect) == "function" and {spell_reflect(ability)} or {spell_reflect})[1]
								if is_ally or (not ability_spell_reflect or not is_triggers_linken or SpellReflect:CanUse(ability, target, ability_spell_reflect[1], ability_spell_reflect[2], ability_spell_reflect[3])) then
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

---@param npc userdata
---@return number
function NPC.GetLinkenProtects(npc)
	local modifiers = {"modifier_item_sphere_target", "modifier_special_bonus_spell_block"}
	local items = {"item_sphere", "item_mirror_shield"}
	local protects = 0
	for _, modifier_name in pairs(modifiers) do
		if NPC.HasModifier(npc, modifier_name) then
			if modifier_name == "modifier_spirit_breaker_planar_pocket" then
				if NPC.HasModifier(npc, "modifier_spirit_breaker_planar_pocket_aura") then
					protects = protects - 1
				end
			end
			protects = protects + 1
		end
	end
	for _, item_name in pairs(items) do
		local item = NPC.GetItem(npc, item_name, true)
		if item ~= nil and Ability.GetEffectiveCooldown(item) <= 0 then
			protects = protects + 1
		end
	end
	return protects
end

---@param npc userdata
---@param can_turn boolean?
---@param cast_ability userdata?
---@param cast_position Vector?
---@return userdata[]
function NPC.GetUsableBKBs(npc, can_turn, cast_ability, cast_position)
	local bkb_abilities = {
		["life_stealer_rage"] = {true, true},
		["juggernaut_blade_fury"] = {true, true},
		["omniknight_martyr"] = {true, true},
		["legion_commander_press_the_attack"] = {function()
			return NPC.HasTalent(npc, "special_bonus_unique_legion_commander_8")
		end, true},
		["lion_mana_drain"] = {function()
			return NPC.HasShard(npc)
		end, false},
		["dawnbreaker_fire_wreath"] = {function()
			return NPC.HasShard(npc)
		end, function()
			if can_turn or not cast_position then
				return true
			end
			return math.deg(NPC.FindRotationAngle(npc, cast_position)) < 15
		end},
		["rattletrap_power_cogs"] = {function()
			return NPC.HasTalent(npc, "special_bonus_unique_clockwerk_6")
		end, function()
			if not cast_ability or not cast_position then
				return true
			end
			return (cast_position - Entity.GetAbsOrigin(npc)):Length2D() < Ability.GetEffectiveCastRange(cast_ability)
		end},
		["item_black_king_bar"] = {true, true},
	}
	local ability_bkb_abilities = Ability.GetBKBs(false)
	if #ability_bkb_abilities ~= table.length(bkb_abilities) then
		print("[WARNING] NPC.GetUsableBKBs and Ability.GetBKBs has different bkb list!")
	else
		local bkbs = table.keys(bkb_abilities)
		for i=1, #bkbs do
			local bkb1, bkb2 = bkbs[i], ability_bkb_abilities[i]
			if not table.contains(bkbs, bkb2) or not table.contains(ability_bkb_abilities, bkb1) then
				print("[WARNING] NPC.GetUsableBKBs and Ability.GetBKBs has different bkb list!")
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
	local bkbs = table.map(bkb_abilities, function(bkb, _) return NPC.GetAbilityOrItemByName(npc, bkb) end)
	return table.values(table.filter(bkbs, function(_, bkb) return bkb ~= nil and Ability.CanBeCasted(bkb) end))
end

---@param npc userdata
---@return userdata[]
function NPC.GetUsableSpellAbsorbs(npc)
	local absorb_abilities = {
		["antimage_counterspell"] = true,
	}
	local abilities = table.map(absorb_abilities, function(ability_name, _) return NPC.GetAbilityOrItemByName(npc, ability_name) end)
	return table.values(table.filter(abilities, function(_, ability) return ability ~= nil and Ability.CanBeCasted(ability) end))
end

---@param position Vector
---@param radius number
---@param local_priority boolean?
---@param include_illusions boolean?
---@return userdata[]
function NPC.GetControllableUnits(position, radius, local_priority, include_illusions)
	local units = {}
	local local_player = Players.GetLocal()
	local local_player_id = Player.GetPlayerID(local_player)
	for _, unit in pairs(NPCs.InRadius(position, radius, Entity.GetTeamNum(local_player), Enum.TeamType.TEAM_FRIEND)) do
		if Entity.IsEntity(unit) and Entity.IsControllableByPlayer(unit, local_player_id) and (include_illusions or not NPC.xIsIllusion(unit)) then
			table.insert(units, unit)
		end
	end
	table.sort(units, function(a, b)
		if local_priority then
			local a_owner = Entity.RecursiveGetOwner(a)
			local b_owner = Entity.RecursiveGetOwner(b)
			if a_owner ~= b_owner then
				if a_owner == local_player then
					return true
				elseif b_owner == local_player then
					return false
				end
			end
		end
		local a_position = Entity.GetAbsOrigin(a)
		local b_position = Entity.GetAbsOrigin(b)
		return (position - a_position):Length2D() < (position - b_position):Length2D()
	end)
	return units
end