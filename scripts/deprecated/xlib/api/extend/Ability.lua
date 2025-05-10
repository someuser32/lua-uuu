local invoker_crafts = {
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

---@param name string
---@return boolean
function Ability.IsItemName(name)
	return string.startswith(name, "item_")
end

---@param ability userdata
---@return boolean
function Ability.IsItem(ability)
	return Ability.IsItemName(Ability.GetName(ability))
end

---@param ability userdata
---@param last number?
---@return boolean
function Ability.IsUsed(ability, last)
	last = last or 0.25
	local max_cooldown = Ability.GetCooldownLength(ability)
	local damage_cooldown = Ability.GetDamageCooldown(ability)
	if damage_cooldown > 0 then
		if max_cooldown-damage_cooldown < 0.1 then
			return false
		end
	end
	local last_used = Ability.SecondsSinceLastUse(ability)
	return last_used ~= -1 and last_used < last
end

---@param ability userdata
---@return number
function Ability.GetDamageCooldown(ability)
	local name = Ability.GetName(ability)
	if Item.IsBlinkName(name) then
		return Ability.GetLevelSpecialValueFor(ability, "blink_damage_cooldown")
	end
	return -1
end

---@param name string
---@return string
function Ability.GetAbilityNameIconPath(name)
	local is_item = Ability.IsItemName(name)
	if is_item then
		return "panorama/images/items/"..string.sub(name, #"item_"+1).."_png.vtex_c"
	end
	return "panorama/images/spellicons/"..name.."_png.vtex_c"
end

---@param ability userdata
---@param ... Enum.AbilityBehavior
---@return boolean
function Ability.HasBehavior(ability, ...)
	local behavior = Ability.GetBehavior(ability)
	for _, beh in pairs({...}) do
		if (behavior & beh) == beh then
			return true
		end
	end
	return false
end

---@param ability userdata
---@param ... Enum.TargetTeam
---@return boolean
function Ability.HasTargetTeam(ability, ...)
	local target_team = Ability.GetTargetTeam(ability)
	for _, team in pairs({...}) do
		if (target_team & team) == team then
			return true
		end
	end
	return false
end

---@param ability userdata
---@param ... Enum.TargetFlags
---@return boolean
function Ability.HasFlag(ability, ...)
	local flag = Ability.GetTargetFlags(ability)
	for _, fl in pairs({...}) do
		if (flag & fl) == fl then
			return true
		end
	end
	return false
end

---@param ability userdata
---@param team Enum.TeamNum
---@return boolean
function Ability.CanTargetTeam(ability, team)
	local exceptions = {
		"item_ward_observer",
		"item_ward_sentry",
		"item_ward_dispenser",
	}
	if table.contains(exceptions, Ability.GetName(ability)) then
		return true
	end
	if Ability.HasTargetTeam(ability, Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_BOTH, Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_NONE, Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_CUSTOM) then
		return true
	end
	local localteam = Entity.GetTeamNum(Ability.GetOwner(ability))
	if localteam == team then
		return Ability.HasTargetTeam(ability, Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_FRIENDLY)
	end
	return Ability.HasTargetTeam(ability, Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_ENEMY)
end

---@param ability userdata
---@return number
function Ability.GetEffectiveCastRange(ability)
	local special = {
		["item_seer_stone"] = 0
	}
	local keys = {
		"spear_range",
	}
	local ability_name = Ability.GetName(ability)
	if special[ability_name] ~= nil then
		if type(special[ability_name]) == "function" then
			return special[ability_name]()
		else
			return tonumber(special[ability_name])
		end
	end
	local cast_range = Ability.GetOneOfKVs(ability, keys)
	if cast_range == 0 then
		cast_range = Ability.GetCastRange(ability)
	end
	return cast_range + NPC.GetCastRangeBonus(Ability.GetOwner(ability))
end

---@param ability userdata
---@return number
function Ability.GetRadius(ability)
	return Ability.GetOneOfKVs(ability, {"radius", "whirling_radius"})
end

---@param ability userdata
---@return number
function Ability.GetAOERadius(ability)
	if Ability.HasBehavior(ability, Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_AOE) then
		return Ability.GetOneOfKVs(ability, {"radius", "observer_vision_range_tooltip", "true_sight_range"})
	end
	return 0
end

---@param ability userdata
---@param KVs string[]
---@return number
function Ability.GetOneOfKVs(ability, KVs)
	local ability_keys = KVLib:GetAbilitySpecialKeys(Ability.GetName(ability))
	for _, kv in pairs(KVs) do
		if table.contains(ability_keys, kv) then
			return Ability.GetLevelSpecialValueFor(ability, kv)
		end
	end
	return 0
end

---@param ability userdata
---@param position Vector
---@param queue boolean?
---@param showeffects boolean?
---@param pushtocallback boolean?
---@param executefast boolean?
function Ability.SelectVectorPosition(ability, position, queue, showeffects, pushtocallback, executefast)
	Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION, nil, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, Ability.GetOwner(ability), queue, showeffects, pushtocallback, executefast)
end

---@param ability userdata
---@param target userdata | Vector
---@param queue boolean?
---@param showeffects boolean?
---@param pushtocallback boolean?
---@param executefast boolean?
function Ability.Cast(ability, target, queue, showeffects, pushtocallback, executefast)
	local targetType = target ~= nil and (getmetatable(target) ~= nil and getmetatable(target)["Length2D"] ~= nil and "vector" or "target") or "nil"
	if Ability.IsHidden(ability) then
		-- if ability:CanBeCrafted() then
		-- 	return ability:Craft(function(ability) return ability:Cast(target, queue, showeffects, pushtocallback) end, ability)
		-- end
	end
	if Ability.HasBehavior(ability, Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and targetType == "target" then
		return Player.PrepareUnitOrders(Players.GetLocal(), Entity.IsTree(target) and Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET_TREE or Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET, target, Entity.GetAbsOrigin(target), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, Ability.GetOwner(ability), queue, showeffects, pushtocallback, executefast)
	elseif Ability.HasBehavior(ability, Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_POINT) then
		return Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION, nil, targetType == "vector" and target or Entity.GetAbsOrigin(target), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, Ability.GetOwner(ability), queue, showeffects, pushtocallback, executefast)
	elseif Ability.HasBehavior(ability, Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_TOGGLE) then
		return Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TOGGLE, nil, nil, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, Ability.GetOwner(ability), queue, showeffects, pushtocallback, executefast)
	elseif Ability.HasBehavior(ability, Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
		return Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, nil, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, Ability.GetOwner(ability), queue, showeffects, pushtocallback, executefast)
	end
end

---@param ability userdata
---@return boolean
function Ability.CanBeCasted(ability)
	local caster = Ability.GetOwner(ability)
	return Ability.IsCastable(ability, NPC.GetMana(caster)) and Ability.GetEffectiveCooldown(ability) <= 0 and Entity.IsAlive(caster) and not NPC.IsDisabled(caster) and not NPC.IsSilenced(caster)
end

---@param ability userdata
---@return boolean
function Ability.PiercesBKB(ability, is_ally)
	local exceptions = {
		"item_ward_observer",
		"item_ward_sentry",
		"item_ward_dispencer",
		"item_seer_stone",
		"item_gungir",
		"item_dust",
	}
	local immunity_type = Ability.GetImmunityType(ability)
	if not is_ally then
		return immunity_type ~= Enum.ImmunityTypes.SPELL_IMMUNITY_ALLIES_NO
	end
	return immunity_type == Enum.ImmunityTypes.SPELL_IMMUNITY_ENEMIES_YES or Ability.HasFlag(ability, Enum.TargetFlags.DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES) or table.contains(exceptions, Ability.GetName(ability))
end

---@param name string
---@return boolean
function Ability.RequiresFullChannelName(name)
	return not table.contains({
		"windrunner_powershot",
	}, name)
end

---@param ability userdata
---@return boolean
function Ability.RequiresFullChannel(ability)
	return Ability.RequiresFullChannelName(Ability.GetName(ability))
end

---@param name string
---@return boolean
function Ability.IsTriggersAbsorbName(name)
	if table.contains({
		"item_medallion_of_courage",
		"item_spirit_vessel",
		"item_urn_of_shadows",
		"lion_impale",
		"sandking_burrowstrike",
	}, name) then return false end
	if Ability.IsItemName(name) and Item.IsNeutralItemName(name) then return false end
	local behavior = KVLib:GetAbilityBehavior(name)
	return (behavior & Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) == Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

---@param ability userdata
---@return boolean
function Ability.IsTriggersAbsorb(ability)
	return Ability.IsTriggersAbsorbName(Ability.GetName(ability))
end

---@param name string
---@return boolean
function Ability.IsTriggersReflectName(name)
	if table.contains({
		"item_medallion_of_courage",
		"item_urn_of_shadows",
		"item_spirit_vessel",
		"morphling_replicate",
		"rubick_spell_steal",
		"grimstroke_soulbind",
		"spectre_spectral_dagger",
		"tiny_tree_toss",
	}, name) then return false end
	if Ability.IsItemName(name) and Item.IsNeutralItemName(name) then return false end
	local behavior = KVLib:GetAbilityBehavior(name)
	return (behavior & Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) == Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

---@param ability userdata
---@return boolean
function Ability.IsTriggersReflect(ability)
	return Ability.IsTriggersReflectName(Ability.GetName(ability))
end

---@param need_use_ability boolean?
---@return string[]
function Ability.GetBKBs(need_use_ability)
	local bkb_abilities = {
		{"life_stealer_rage", true},
		{"juggernaut_blade_fury", true},
		{"omniknight_martyr", true},
		{"legion_commander_press_the_attack", true},
		{"lion_mana_drain", false},
		{"dawnbreaker_fire_wreath", true},
		{"rattletrap_power_cogs", true},
		{"item_black_king_bar", true},
	}
	return table.map(table.filter(bkb_abilities, function(_, bkb_info) return not need_use_ability or bkb_info[2] end), function(_, bkb_info) return bkb_info[1] end)
end

---@param ability userdata
---@return number
function Ability.GetEffectiveCooldown(ability)
	if invoker_crafts[Ability.GetName(ability)] ~= nil and Ability.IsHidden(ability) then
		local invoke = NPC.GetAbility(Ability.GetOwner(ability), "invoker_invoke")
		if invoke ~= nil then
			return math.max(Ability.GetCooldown(ability), Ability.GetCooldown(invoke))
		end
	end
	return Ability.GetCooldown(ability)
end