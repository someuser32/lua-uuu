local LinkenBreaker = class("LinkenBreaker")

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

function LinkenBreaker:CreateUI(whereAt, additional_abilities, exclude_projectiles, exclude_abilities)
	local abilities = {}
	for ability_name, is_projectile in pairs(self.abilities) do
		if (not exclude_projectiles or not is_projectile) and not ((type(exclude_abilities) == "table" and table.contains(exclude_abilities, ability_name)) or (type(exclude_abilities) == "string") and ability_name == exclude_abilities) then
			table.insert(abilities, {ability_name, CAbility:GetAbilityNameIconPath(ability_name), true})
		end
	end
	if type(additional_abilities) == "table" then
		for _, ability_name in pairs(additional_abilities) do
			table.insert(abilities, {ability_name, CAbility:GetAbilityNameIconPath(ability_name), true})
		end
	elseif type(additional_abilities) == "string" then
		table.insert(abilities, {additional_abilities, CAbility:GetAbilityNameIconPath(additional_abilities), true})
	end
	local option = UILib:CreateMultiselect({whereAt, "Linken Breaker"}, "Abilities to break", abilities, false)
	UILib:SetTabIcon({whereAt, "Linken Breaker"}, CAbility:GetAbilityNameIconPath("item_sphere"))
	return option
end

function LinkenBreaker:GetUsableAbilities(hero, enemy, abilities, range_buffer, exceptions)
	local usable_abilities = {}
	local distance = (enemy:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
	for _, ability_name in pairs(abilities) do
		if not ((type(exceptions) == "table" and table.contains(exceptions, ability_name)) or (type(exceptions) == "string") and ability_name == exceptions) then
			local ability = hero:GetAbilityOrItemByName(ability_name)
			if ability ~= nil and ability:IsCastable(hero:GetMana(), false) and ability:GetEffectiveCooldown() <= 0 then
				local cast_range = ability:GetCastRange()
				if cast_range == 0 then
					cast_range = ability:GetRadius() - (range_buffer or 75)
				end
				if cast_range + (range_buffer or 75) >= distance then
					table.insert(usable_abilities, ability)
				end
			end
		end
	end
	return usable_abilities
end

function LinkenBreaker:CanBreakLinken(hero, enemy, option, range_buffer, exceptions)
	local ability = self:GetUsableAbilities(hero, enemy, option:Get(), range_buffer, exceptions)[1]
	return ability ~= nil
end

function LinkenBreaker:CanUseAbility(ability, enemy, option, range_buffer, exceptions)
	if not CAbility:IsTriggersAbsorb(ability:GetName()) then
		return true
	end
	if not enemy.IsLinkensProtected then
		return true
	end
	if not enemy:IsLinkensProtected() and not enemy:IsMirrorProtected() then
		return true
	end
	return self:CanBreakLinken(ability:GetCaster(), enemy, option, range_buffer, exceptions)
end

function LinkenBreaker:BreakLinken(hero, enemy, option, range_buffer, exceptions, callback, max_repeats)
	if not enemy:IsLinkensProtected() and not enemy:IsMirrorProtected() then
		return callback(true)
	end
	local ability = self:GetUsableAbilities(hero, enemy, option:Get(), range_buffer, exceptions)[1]
	if not self:TriggerLinken(ability, enemy) then
		return callback(false)
	end
	local current_repeats = 1
	Timers:CreateTimer(ability:GetCastPoint() * 1.5 + hero:GetTimeToFacePosition(enemy:GetAbsOrigin()) + CNetChannel:GetPingDelay(), function()
		if ability:SecondsSinceLastUse() ~= -1 then
			if enemy:IsLinkensProtected() and not enemy:IsMirrorProtected() then
				self:BreakLinken(hero, enemy, option, range_buffer, exceptions, callback, max_repeats)
				return
			end
			callback(true)
			return
		end
		if current_repeats >= (max_repeats or 3) then
			return callback(false)
		end
		if not self:TriggerLinken(ability, enemy) then
			callback(false)
			return
		end
		current_repeats = current_repeats + 1
		return ability:GetCastPoint() * 1.5 + CNetChannel:GetPingDelay()
	end, self)
end

function LinkenBreaker:TriggerLinken(ability, enemy)
	if not ability then return false end
	local caster = ability:GetCaster()
	if caster:IsChannellingAbility() then
		caster:Stop()
	end
	ability:Cast(enemy)
	return true
end

return LinkenBreaker:new()