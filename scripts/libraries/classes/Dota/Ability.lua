local cancellable_channel_abilities = {
	"windrunner_powershot",
}

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

local silence_abilities = {
	"item_orchid",
	"item_bloodthorn",
	"item_book_of_shadows",
	"skywrath_mage_ancient_seal",
}

local CAbility = class("CAbility", CEntity)

function CAbility.static:GetType(func_name, val)
	if val == nil then
		return nil
	end
	local types = {
		["GetOwner"] = "CNPC",
	}
	return types[func_name] or CEntity.GetType(self, func_name, val)
end

function CAbility.static:ListAPIs()
	return {
		"GetAll",
	}
end

function CAbility.static:GetAll()
	return self:StaticAPICall("GetAll", Abilities.GetAll)
end

function CAbility.static:Count()
	return self:StaticAPICall("Count", Abilities.Count)
end

function CAbility.static:Get()
	return self:StaticAPICall("Get", Abilities.Get)
end

function CAbility.static:Contains(ent)
	return self:StaticAPICall("Contains", Abilities.Contains, ent)
end

function CAbility.static:GetAbilityNameIconPath(name)
	local is_item = self:IsItemName(name)
	if is_item then
		return "panorama/images/items/"..string.sub(name, #"item_"+1).."_png.vtex_c"
	end
	return "panorama/images/spellicons/"..name.."_png.vtex_c"
end

function CAbility.static:IsItemName(name)
	return string.startswith(name, "item_")
end

function CAbility.static:RequiresFullChannelName(name)
	return not table.contains(cancellable_channel_abilities, name)
end

function CAbility.static:GetBKBs(need_use_ability)
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

function CAbility:IsItem()
	return false
end

function CAbility:GetCaster()
	return self:APIGetOwner()
end

function CAbility:GetDrunkenBrawlerState()
	return DrunkenBrawler.GetState(self.ent)
end

function CAbility:GetDamageCooldown()
	if CItem:IsBlink(self:GetName()) then
		return self:GetLevelSpecialValueForFloat("blink_damage_cooldown")
	end
	return -1
end

function CAbility:IsUsed(last)
	last = last or 0.25
	local max_cooldown = self:GetCooldownLength()
	local damage_cooldown = self:GetDamageCooldown()
	if damage_cooldown ~= -1 then
		if max_cooldown-damage_cooldown < 0.1 then
			return false
		end
	end
	local last_used = self:SecondsSinceLastUse()
	return last_used ~= -1 and last_used < last
end

function CAbility:GetNameGeneral()
	local name = self:GetName()
	if CItem:IsBlink(name) then
		return "item_blink"
	elseif CItem:IsDagon(name) then
		return "item_dagon"
	end
	return name
end

function CAbility:GetName(general)
	return general and self:GetNameGeneral() or self:APIGetName()
end

function CAbility:HasBehavior(behavior)
	return (self:GetBehavior() & behavior) == behavior
end

function CAbility:HasFlag(flag)
	return (self:GetTargetFlags() & flag) == flag
end

function CAbility:CanCastToPosition(position, tolerance)
	local caster = self:GetCaster()
	local caster_position = caster:GetAbsOrigin()
	return math.is_vector_between(position, caster_position, caster_position + caster:GetRotation():GetForward() * self:GetCastRange(), tolerance)
end

function CAbility:GetTargetingEntity()
	-- TODO: write function body
end

function CAbility:GetOneOfKVs(KVs)
	local ability_keys = KVLib:GetAbilitySpecialKeys(self:GetName(true))
	for _, kv in pairs(KVs) do
		if table.contains(ability_keys, kv) then
			return self:GetLevelSpecialValueFor(kv)
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
	return self:GetImmunityType() == Enum.ImmunityTypes.SPELL_IMMUNITY_ENEMIES_YES or self:HasFlag(Enum.TargetFlags.DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
end

function CAbility:GetEffectiveCooldown()
	if invoker_crafts[self:GetName()] ~= nil and self:IsHidden() then
		local invoke = self:GetCaster():GetAbility("invoker_invoke")
		if invoke ~= nil then
			return math.max(self:GetCooldown(), invoke:GetCooldown())
		end
	end
	return self:GetCooldown()
end

function CAbility:CanBeCrafted()
	local craft = invoker_crafts[self:GetName()]
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
	local craft = invoker_crafts[self:GetName()]
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
	return Timers:CreateTimer(invoke:GetCooldown(), function(self)
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
	if invoker_crafts[self:GetName()] ~= nil and not self:CanBeCrafted() then
		return 0
	end
	return self:APIGetLevel()
end

function CAbility:SelectVectorPosition(position, queue, showeffects, pushtocallback)
	CPlayer:GetLocal():PrepareUnitOrders(Enum.UnitOrder.DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION, nil, position, self, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self:GetCaster(), queue, showeffects, pushtocallback)
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
		return CPlayer:GetLocal():PrepareUnitOrders(target:IsTree() and Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET_TREE or Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET, target, target:GetAbsOrigin(), self, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self:GetCaster(), queue, showeffects, pushtocallback)
	elseif self:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_POINT) then
		return CPlayer:GetLocal():PrepareUnitOrders(Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION, nil, targetType == "vector" and target or target:GetAbsOrigin(), self, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self:GetCaster(), queue, showeffects, pushtocallback)
	elseif self:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_TOGGLE) then
		return CPlayer:GetLocal():PrepareUnitOrders(Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TOGGLE, nil, nil, self, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self:GetCaster(), queue, showeffects, pushtocallback)
	elseif self:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
		return CPlayer:GetLocal():PrepareUnitOrders(Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, nil, self, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self:GetCaster(), queue, showeffects, pushtocallback)
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

function CAbility:IsSilence()
	return table.contains(silence_abilities, self:GetName(true))
end

function CAbility:CanCast()
	local caster = self:GetCaster()
	return self:GetLevel() > 0 and caster:IsAlive() and not caster:IsDisabled() and not caster:IsSilenced() and self:IsCastable(caster:GetMana(), false) and self:GetEffectiveCooldown() <= 0
end

_Classes_Inherite({"Entity", "Ability"}, CAbility)

return CAbility