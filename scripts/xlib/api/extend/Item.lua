---@param name string
---@return boolean
function Item.IsBlinkName(name)
	return table.contains({"item_blink", "item_overwhelming_blink", "item_swift_blink", "item_arcane_blink"}, name)
end

---@param item userdata
---@return boolean
function Item.IsBlink(item)
	return Item.IsBlinkName(Ability.GetName(item))
end

---@param name string
---@return boolean
function Item.IsDagonName(name)
	return table.contains({"item_dagon", "item_dagon_2", "item_dagon_3", "item_dagon_4", "item_dagon_5"}, name)
end

---@param item userdata
---@return boolean
function Item.IsDagon(item)
	return Item.IsDagonName(Ability.GetName(item))
end

---@param item userdata
---@return integer?
function Item.GetSlot(item)
	local owner = Ability.GetOwner(item)
	for _, slot in pairs(Enum.InventorySearch.INVENTORY_STASH) do
		local temp_item = NPC.GetItemByIndex(owner, slot)
		if temp_item ~= nil and temp_item == item then
			return slot
		end
	end
end

---@param item userdata
---@return userdata?
function Item.GetContainer(item)
	for _, container in pairs(PhysicalItems.GetAll()) do
		if PhysicalItem.GetItem(container) == item then
			return container
		end
	end
end

---@param name string
---@return userdata?
function Item.IsNeutralItemName(name)
	return KVLib:IsItemNeutral(name)
end

---@param item userdata
---@return userdata?
function Item.IsNeutralItem(item)
	return Item.IsNeutralItemName(Ability.GetName(item))
end