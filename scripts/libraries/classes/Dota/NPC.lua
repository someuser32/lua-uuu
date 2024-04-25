local ability_exclude_level = {
	[0] = 34,
	[1] = 15,
	[2] = 8
}

local item_exclude_level = {
	[0] = 15,
	[1] = 8,
	[2] = 5
}

local CNPC = class("CNPC", CEntity)

function CNPC.static:GetType(func_name, val)
	if val == nil then
		return nil
	end
	local types = {
		["GetItem"] = "CItem",
		["GetModifier"] = "CModifier",
		["GetChannellingAbility"] = "CAbility",
		["GetItemByIndex"] = "CItem",
		["GetAbilityByIndex"] = "CAbility",
		["GetAbilityByActivity"] = "CAbility",
		["GetAbility"] = "CAbility",
	}
	return types[func_name] or CEntity.GetType(self, func_name, val)
end

function CNPC.static:ListAPIs()
	return {
		"GetAll",
		"InRadius",
	}
end

function CNPC.static:GetAll()
	return self:StaticAPICall("GetAll", NPCs.GetAll)
end

function CNPC.static:Count()
	return self:StaticAPICall("Count", NPCs.Count)
end

function CNPC.static:Get()
	return self:StaticAPICall("Get", NPCs.Get)
end

function CNPC.static:Contains(ent)
	return self:StaticAPICall("Contains", NPCs.Contains, ent)
end

function CNPC.static:FindInRadius(vec, radius, teamNum, teamType)
	return self:StaticAPICall("InRadius", NPCs.InRadius, vec, radius, teamNum, teamType)
end

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
	for i=0, ability_exclude_level[exclude_level or 0] do
		local ability = self:GetAbilityByIndex(i)
		if abilities ~= nil then
			abilities[i] = ability
		end
	end
	return abilities
end

function CNPC:GetAbilityOrItemByName(name, exclude_level, general)
	if string.startswith(name, "item_") then
		local item = self:GetItemByName(name, exclude_level, general)
		if item then
			return item
		end
	end
	return self:GetAbility(name)
end

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

function CNPC:IsReflectsSpells()
	local modifiers = {"modifier_item_lotus_orb_active", "modifier_antimage_counterspell"}
	return self:IsMirrorProtected() or table.any(table.map(modifiers, function(_, modifier_name) return self:HasModifier(modifier_name) end))
end

function CNPC:IsAbsorbsSpells()
	local modifiers = {"modifier_antimage_counterspell"}
	return table.any(table.map(modifiers, function(_, modifier_name) return self:HasModifier(modifier_name) end))
end

function CNPC:CanCastToPosition(position, range, tolerance)
	return math.is_vector_between(position, self:GetAbsOrigin(), self:GetAbsOrigin() + self:GetRotation():GetForward() * range, tolerance)
end

function CNPC:GetAngleDiffVector(vec)
	return vector.angle_between_vectors(self:GetRotation():GetForward(), (vec - self:GetAbsOrigin()):Normalized())
end

function CNPC:GetTurnTime(angle)
	angle = angle or 180
	return (0.03 * (angle*math.pi/180)) / self:GetTurnRate()
end

function CNPC:MoveToInterpolated(position, rangeStart, rangeStepStart, rangeStepEnd, delay, endCallback)
	local myPos = self:GetAbsOrigin()
	local direction = (position - myPos):Normalized()
	local rangeEnd = (position - myPos):Length2D()
	local player = CPlayer:GetLocal()
	local ent = self
	local i = rangeStart
	Timers:CreateTimer(0, function()
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

function CNPC:MoveTo(position, queue, showeffects, pushtocallback)
	return CPlayer:GetLocal():PrepareUnitOrders(Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, position, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self, (queue ~= nil and {queue} or {false})[1], (showeffects ~= nil and {showeffects} or {false})[1], (pushtocallback ~= nil and {pushtocallback} or {true})[1])
end

function CNPC:MoveToDirectional(position, queue, showeffects, pushtocallback)
	return CPlayer:GetLocal():PrepareUnitOrders(Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_DIRECTION, nil, position, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self, (queue ~= nil and {queue} or {false})[1], (showeffects ~= nil and {showeffects} or {false})[1], (pushtocallback ~= nil and {pushtocallback} or {true})[1])
end

function CNPC:Stop()
	return CPlayer:GetLocal():PrepareUnitOrders(Enum.UnitOrder.DOTA_UNIT_ORDER_STOP, nil, nil, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self, false, true, true)
end

function CNPC:PickupLotus(lotus_pool, queue, showeffects, pushtocallback)
	local ability = self:GetAbility("ability_pluck_famango")
	if ability == nil then
		return
	end
	return ability:Cast(lotus_pool, (queue ~= nil and {queue} or {false})[1], (showeffects ~= nil and {showeffects} or {false})[1], (pushtocallback ~= nil and {pushtocallback} or {true})[1])
end

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

function CNPC:GetUsableSpellAbsorbs()
	local absorb_abilities = {
		["antimage_counterspell"] = true
	}
	local abilities = table.map(absorb_abilities, function(ability_name, _) return self:GetAbilityOrItemByName(ability_name) end)
	return table.values(table.filter(abilities, function(_, ability) return ability ~= nil and ability:CanCast() end))
end

function CNPC:HasTalent(ability_name)
	local talent = self:GetAbility(ability_name)
	return talent ~= nil and talent:GetLevel() > 0
end

function CNPC:GetKV()
	return KVLib:GetUnitKV(self:GetUnitName())
end

function CNPC:HasInventory()
	local kv = self:GetKV()
	if kv == nil then
		return false
	end
	return kv["HasInventory"] == 1
end

function CNPC:IsSpiritBear()
	return string.startswith(self:GetUnitName(), "npc_dota_lone_druid_bear")
end

function CNPC:IsTempestDouble()
	return self:HasModifier("modifier_arc_warden_tempest_double")
end

function CNPC:IsVengefulSpiritIllusion()
	return self:HasModifier("modifier_vengefulspirit_command_aura_illusion")
end

function CNPC:IsTrueSight()
	return self:HasModifier("modifier_truesight") or self:HasModifier("modifier_item_dustofappearance")
end

function CNPC:IsFlyingForPathing()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY)
end

function CNPC:IsFlying()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_FLYING)
end

function CNPC:HasFlying()
	return self:IsFlying() or self:IsFlyingForPathing()
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

function CNPC:IsSpellImmune()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
end

function CNPC:IsDebuffImmune()
	return self:HasState(Enum.ModifierState.MODIFIER_STATE_DEBUFF_IMMUNE)
end

function CNPC:CanPathThroughTrees()
	return self:HasFlying() or self:HasState(Enum.ModifierState.MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES)
end

function CNPC:IsDisabled()
	return self:IsStunned() or self:IsHexed() or self:IsNightmared() or self:IsTaunted() or self:IsFeared()
end

_Classes_Inherite({"Entity", "NPC"}, CNPC)

return CNPC