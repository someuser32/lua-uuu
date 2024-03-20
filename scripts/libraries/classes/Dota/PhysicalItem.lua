local CPhysicalItem = class("CPhysicalItem", CEntity)

function CPhysicalItem.static:GetType(func_name, val)
	if val == nil then
		return nil
	end
	local types = {
		["GetItem"] = "CItem",
	}
	return types[func_name] or CEntity.GetType(self, func_name, val)
end

function CPhysicalItem.static:ListAPIs()
	return {
		"GetAll",
	}
end

function CPhysicalItem.static:GetAll()
	return self:StaticAPICall("GetAll", PhysicalItems.GetAll)
end

function CPhysicalItem.static:Count()
	return self:StaticAPICall("Count", PhysicalItems.Count)
end

function CPhysicalItem.static:Get()
	return self:StaticAPICall("Get", PhysicalItems.Get)
end

function CPhysicalItem.static:Contains(ent)
	return self:StaticAPICall("Contains", PhysicalItems.Contains, ent)
end

function CPhysicalItem:Pickup(unit)
	return CPlayer:GetLocal():PrepareUnitOrders(Enum.UnitOrder.DOTA_UNIT_ORDER_PICKUP_ITEM, self, self:GetAbsOrigin(), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, unit, false, true, false)
end

_Classes_Inherite({"Entity", "PhysicalItem"}, CPhysicalItem)

return CPhysicalItem