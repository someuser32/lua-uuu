---@class CCourier: CNPC
local CCourier = class("CCourier", CNPC)

---@return string[]
function CCourier.static:ListAPIs()
	return {
		"GetAll",
	}
end

---@return CCourier[]
function CCourier.static:GetAll()
	return self:StaticAPICall("GetAll", Couriers.GetAll)
end

---@return integer
function CCourier.static:Count()
	return self:StaticAPICall("Count", Couriers.Count)
end

---@param ent integer
---@return CCourier?
function CCourier.static:Get(ent)
	return self:StaticAPICall("Get", Couriers.Get, ent)
end

---@param ent CCourier
---@return boolean
function CCourier.static:Contains(ent)
	return self:StaticAPICall("Contains", Couriers.Contains, ent)
end

---@return CPlayer?
function CCourier:GetOwner()
	local owner = self:APICall("RecursiveGetOwner", Entity.RecursiveGetOwner, self)
	if owner == nil then
		return nil
	end
	return CPlayer:new(owner.ent)
end

_Classes_Inherite({"Entity", "NPC", "Courier"}, CCourier)

return CCourier