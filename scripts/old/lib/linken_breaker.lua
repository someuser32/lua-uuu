local class = require("lib/middleclass")

LinkenBreaker = class("LinkenBreaker")

function LinkenBreaker:initialize()
	self.abilities = {
		["item_diffusal_blade"] = false,
		["item_force_staff"] = false,
		["item_rod_of_atos"] = true,
		["item_heavens_halberd"] = false,
		["item_orchid"] = false,
		["item_bloodthorn"] = false,
		["item_hurricane_pike"] = false,
		["item_cyclone"] = false,
		["item_harpoon"] = false,
		["item_disperser"] = false,
		["item_wind_waker"] = false,
		["item_nullifier"] = true,
		["item_ethereal_blade"] = true,
		["item_dagon"] = false,
		["item_abyssal_blade"] = false,
		["item_sheepstick"] = false,
	}
end

function LinkenBreaker:create_option(whereAt, name, additional_abilities, exclude_projectiles, exclude_abilities)
	local abilities = {}
	for ability_name, is_projectile in pairs(self.abilities) do
		if (not exclude_projectiles or not is_projectile) and not ((type(exclude_abilities) == "table" and table.contains(exclude_abilities, ability_name)) or (type(exclude_abilities) == "string") and ability_name == exclude_abilities) then
			table.insert(abilities, {ability_name, string.startswith(ability_name, "item_") and "panorama/images/items/"..string.sub(ability_name, 6).."_png.vtex_c" or "panorama/images/spellicons/"..ability_name.."_png.vtex_c", true})
		end
	end
	if type(additional_abilities) == "table" then
		for _, ability_name in pairs(additional_abilities) do
			table.insert(abilities, {ability_name, string.startswith(ability_name, "item_") and "panorama/images/items/"..string.sub(ability_name, 6).."_png.vtex_c" or "panorama/images/spellicons/"..ability_name.."_png.vtex_c", true})
		end
	end
	local option = UI_LIB:create_multiselect(table.combine(whereAt, "Linken Breaker"), name or "Items to use:", abilities, false)
	UI_LIB:set_tab_icon(table.combine(whereAt, "Linken Breaker"), "panorama/images/items/sphere_png.vtex_c")
	return option
end

function LinkenBreaker:get_usable_abilities(hero, enemy, abilities, additional_radius, exceptions)
	local usable_abilities = {}
	local distance = (enemy:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
	for _, ability_name in pairs(abilities) do
		if not ((type(exceptions) == "table" and table.contains(exceptions, ability_name)) or (type(exceptions) == "string") and ability_name == exceptions) then
			local ability = string.startswith(ability_name, "item_") and hero:GetItemByName(ability_name, 2, true) or hero:GetAbility(ability_name)
			if ability ~= nil and ability:IsCastable(hero:GetMana(), false) and ability:GetEffectiveCooldown() <= 0 then
				local cast_range = ability:GetCastRange()
				if cast_range + (additional_radius or 125) >= distance then
					table.insert(usable_abilities, ability)
				end
			end
		end
	end
	return usable_abilities
end

function LinkenBreaker:can_break_linken(hero, enemy, option, additional_radius, exceptions)
	local ability = self:get_usable_abilities(hero, enemy, option:get_value(), additional_radius, exceptions)[1]
	return ability ~= nil
end

function LinkenBreaker:can_use(hero, enemy, option, additional_radius, exceptions)
	if not enemy:IsLinkensProtected() and not enemy:IsMirrorProtected() then
		return true
	end
	return self:can_break_linken(hero, enemy, option, additional_radius, exceptions)
end

function LinkenBreaker:break_linken(hero, enemy, option, additional_radius, exceptions, callback, max_repeats)
	if not enemy:IsLinkensProtected() and not enemy:IsMirrorProtected() then
		return callback(true)
	end
	local ability = self:get_usable_abilities(hero, enemy, option:get_value(), additional_radius, exceptions)[1]
	if not self:trigger_linken(ability, enemy) then
		return callback(false)
	end
	local current_repeats = 1
	timer.Barebones(ability:GetCastPoint() * 1.5 + hero:GetTimeToFacePosition(enemy:GetAbsOrigin()) + GetPingDelay(), function(self)
		if ability:SecondsSinceLastUse() ~= -1 then
			if enemy:IsLinkensProtected() and not enemy:IsMirrorProtected() then
				self:break_linken(hero, enemy, option, additional_radius, exceptions, callback, max_repeats)
				return
			end
			callback(true)
			return
		end
		if current_repeats >= (max_repeats or 3) then
			return callback(false)
		end
		if not self:trigger_linken(ability, enemy) then
			callback(false)
			return
		end
		current_repeats = current_repeats + 1
		return ability:GetCastPoint() * 1.5 + GetPingDelay()
	end, self)
end

function LinkenBreaker:trigger_linken(ability, enemy)
	if not ability then return false end
	ability:Cast(enemy)
	return true
end

return LinkenBreaker:new()