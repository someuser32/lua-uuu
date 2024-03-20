local CItem = class("CItem", CAbility)

function CItem.static:StaticAPIs()
	return {
		"GetStockCount",
	}
end

function CItem.static:IsBlink(item_name)
	return table.contains({"item_blink", "item_overwhelming_blink", "item_swift_blink", "item_arcane_blink"}, item_name)
end

function CItem.static:IsDagon(item_name)
	return table.contains({"item_dagon", "item_dagon_2", "item_dagon_3", "item_dagon_4", "item_dagon_5"}, item_name)
end

function CItem:IsItem()
	return true
end

function CItem:GetBottleRuneType()
	return Bottle.GetRuneType(self.ent)
end

function CItem:GetPowerTreadsStat()
	return PowerTreads.GetStats(self.ent)
end

function CItem:GetVambraceStat()
	return Vambrace.GetStats(self.ent)
end

function CItem:CanCast()
	local caster = self:GetCaster()
	return caster:IsAlive() and not caster:IsDisabled() and not caster:IsMuted() and self:IsCastable(caster:GetMana(), false) and self:GetEffectiveCooldown() <= 0
end

function CItem:GetItemSlot()
	local caster = self:GetCaster()
	for i=0, 15 do
		local temp_item = caster:GetItemByIndex(i)
		if temp_item.ent == self.ent then
			return i
		end
	end
	return nil
end

function CItem:GetContainer()
	for _, container in pairs(CPhysicalItem:GetAll()) do
		if container:GetItem() == self.ent then
			return container
		end
	end
end

function CItem:Drop(position)
	local caster = self:GetCaster()
	CPlayer:GetLocal():PrepareUnitOrders(Enum.UnitOrder.DOTA_UNIT_ORDER_DROP_ITEM, self, position or caster:GetAbsOrigin(), self, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, caster, false, true, true)
end

_Classes_Inherite({"Entity", "Ability", "Item"}, CItem)

return CItem