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
---@param target userdata | Vector
---@param queue boolean?
---@param showeffects boolean?
---@param pushtocallback boolean?
---@param executefast boolean?
---@return nil
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