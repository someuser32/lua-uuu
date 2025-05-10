---@class LinkenBreaker
local LinkenBreaker = {
	abilities = {
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
	},
}

---@param parent CMenuGroup | CMenuGearAttachment
---@param gear? boolean
---@param additional_abilities? string[]
---@param exclude_projectiles? boolean
---@param exclude_abilities? string[]
---@param return_parent? boolean
---@return table
function LinkenBreaker:CreateUI(parent, gear, additional_abilities, exclude_projectiles, exclude_abilities, return_parent)
	local modules = {}
	local linken_breaker = parent
	local returned_parent = linken_breaker
	if gear then
		local label = parent:Label("Linken Breaker")
		label:Icon("\u{f13a}")
		linken_breaker = label:Gear("Linken Breaker")
		returned_parent = label
	end
	local abilities = {}
	for ability_name, is_projectile in pairs(self.abilities) do
		if (not exclude_projectiles or not is_projectile) and not table.contains(exclude_abilities, ability_name) then
			table.insert(abilities, {ability_name, Ability.GetAbilityNameIconPath(ability_name), true})
		end
	end
	for _, ability_name in pairs(additional_abilities) do
		table.insert(abilities, {ability_name, Ability.GetAbilityNameIconPath(ability_name), true})
	end
	local abilities_to_break = linken_breaker:MultiSelect("Abilities to break", abilities, false)
	table.insert(modules, abilities_to_break)
	if return_parent then
		table.insert(modules, returned_parent)
	end
	return modules
end

---@param hero userdata
---@param enemy userdata
---@param abilities string[]
---@param range_buffer number
---@param exceptions string[]
---@return userdata[]
function LinkenBreaker:GetUsableAbilities(hero, enemy, abilities, range_buffer, exceptions)
	local usable_abilities = {}
	local distance = (Entity.GetAbsOrigin(enemy) - Entity.GetAbsOrigin(hero)):Length2D()
	for _, ability_name in pairs(abilities) do
		if not table.contains(exceptions, ability_name) then
			local ability = NPC.GetAbilityOrItemByName(hero, ability_name)
			if ability ~= nil and Ability.IsCastable(ability, NPC.GetMana(hero)) and Ability.GetEffectiveCooldown(ability) <= 0 then
				local cast_range = Ability.GetEffectiveCastRange(ability)
				if cast_range == 0 then
					cast_range = Ability.GetRadius(ability) - (range_buffer or 75)
				end
				if cast_range + (range_buffer or 75) >= distance then
					table.insert(usable_abilities, ability)
				end
			end
		end
	end
	return usable_abilities
end

---@param hero userdata
---@param enemy userdata
---@param option CMenuMultiSelect
---@param range_buffer number
---@param exceptions string[]
---@return boolean
function LinkenBreaker:CanBreakLinken(hero, enemy, option, range_buffer, exceptions)
	local ability = self:GetUsableAbilities(hero, enemy, option:ListEnabled(), range_buffer, exceptions)[1]
	return ability ~= nil
end

---@param ability userdata
---@param enemy userdata
---@param option CMenuMultiSelect
---@param range_buffer number
---@param exceptions string[]
---@return boolean
function LinkenBreaker:CanUseAbility(ability, enemy, option, range_buffer, exceptions)
	if not Ability.IsTriggersAbsorb(ability) then
		return true
	end
	if not Entity.IsNPC(enemy) then
		return true
	end
	if not NPC.IsLinkensProtected(enemy) and not NPC.IsMirrorProtected(enemy) then
		return true
	end
	return self:CanBreakLinken(Ability.GetOwner(ability), enemy, option, range_buffer, exceptions)
end


---@param hero userdata
---@param enemy userdata
---@param option CMenuMultiSelect
---@param range_buffer number
---@param exceptions string[]
---@param callback function
---@param max_repeats? number
function LinkenBreaker:BreakLinken(hero, enemy, option, range_buffer, exceptions, callback, max_repeats)
	if not NPC.IsLinkensProtected(enemy) and not NPC.IsMirrorProtected(enemy) then
		return callback(true)
	end
	local ability = self:GetUsableAbilities(hero, enemy, option:ListEnabled(), range_buffer, exceptions)[1]
	if not self:TriggerLinken(ability, enemy) then
		return callback(false)
	end
	local current_repeats = 1
	Timers:CreateTimer(Ability.GetCastPoint(ability) * 1.5 + NPC.GetTimeToFacePosition(hero, Entity.GetAbsOrigin(enemy)) + NetChannel.GetPingDelay(), function()
		if Ability.SecondsSinceLastUse(ability) ~= -1 then
			if NPC.IsLinkensProtected(enemy) and not NPC.IsMirrorProtected(enemy) then
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
		return Ability.GetCastPoint(ability) * 1.5 + NetChannel.GetPingDelay()
	end, self)
end

---@param ability userdata
---@param enemy userdata
---@return boolean
function LinkenBreaker:TriggerLinken(ability, enemy)
	if not ability then return false end
	local caster = Ability.GetOwner(ability)
	if NPC.IsChannellingAbilityOrItem(caster) then
		NPC.Stop(caster)
	end
	Ability.Cast(ability, enemy)
	return true
end

return LinkenBreaker