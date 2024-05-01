---@class CPhysicalItem: CEntity
local CPhysicalItem = class("CPhysicalItem", CEntity)

---@param func_name string
---@param val any
---@return string[] | any?
function CPhysicalItem.static:GetType(func_name, val)
	if val == nil then
		return nil
	end
	local types = {
		["GetItem"] = "CItem",
	}
	return types[func_name] or CEntity.GetType(self, func_name, val)
end

---@return string[]
function CPhysicalItem.static:ListAPIs()
	return {
		"GetAll",
	}
end

---@return CPhysicalItem[]
function CPhysicalItem.static:GetAll()
	return self:StaticAPICall("GetAll", PhysicalItems.GetAll)
end

---@return integer
function CPhysicalItem.static:Count()
	return self:StaticAPICall("Count", PhysicalItems.Count)
end

---@param ent integer
---@return CPhysicalItem?
function CPhysicalItem.static:Get(ent)
	return self:StaticAPICall("Get", PhysicalItems.Get, ent)
end

---@param ent CPhysicalItem
---@return boolean
function CPhysicalItem.static:Contains(ent)
	return self:StaticAPICall("Contains", PhysicalItems.Contains, ent)
end

---@param unit CNPC
---@return nil
function CPhysicalItem:Pickup(unit)
	return CPlayer:GetLocal():PrepareUnitOrders(Enum.UnitOrder.DOTA_UNIT_ORDER_PICKUP_ITEM, self, self:GetAbsOrigin(), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, unit, false, true, false)
end

_Classes_Inherite({"Entity", "PhysicalItem"}, CPhysicalItem)

return CPhysicalItem