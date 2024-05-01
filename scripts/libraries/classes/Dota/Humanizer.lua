---@class CHumanizer: DBase
local CHumanizer = class("CHumanizer", DBase)

---@return boolean
function CHumanizer.static:StaticAPIs()
	return true
end

---@param position Vector
---@param fast boolean?
---@return nil
function CHumanizer.static:MoveCursorTo(position, fast)
	return CPlayer:GetLocal():PrepareUnitOrders(Enum.UnitOrder.DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION, nil, position, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, nil, false, false, true, fast)
end

_Classes_Inherite({"Humanizer"}, CHumanizer)

return CHumanizer