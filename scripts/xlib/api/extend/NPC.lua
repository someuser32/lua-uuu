---@param npc userdata npc to check
---@return boolean
NPC.IsTempestDouble = function(npc)
	return NPC.HasModifier(npc, "modifier_arc_warden_tempest_double")
end

---@param npc userdata npc to check
---@return boolean
NPC.IsCommandAuraIllusion = function(npc)
	return NPC.HasModifier(npc, "modifier_vengefulspirit_command_aura_illusion")
end

---@param npc userdata npc to check
---@return boolean
NPC.IsMonkeyClone = function(npc)
	return NPC.HasModifier(npc, "modifier_monkey_king_fur_army_soldier")
end

---@param npc userdata npc to check
---@return boolean
NPC.IsTrueHero = function(npc)
	return not NPC.IsIllusion(npc) and not NPC.IsTempestDouble(npc) and not NPC.IsCommandAuraIllusion(npc) and not NPC.IsMonkeyClone(npc)
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
---@return nil
function NPC.PickupLotus(npc, lotus_pool, queue, showeffects, pushtocallback, executefast)
	local ability = NPC.GetAbility(npc, "ability_pluck_famango")
	if ability == nil then
		return
	end
	return Ability.Cast(ability, lotus_pool, queue, showeffects, pushtocallback, executefast)
end