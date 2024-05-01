---@class CWorld: DBase
local CWorld = class("CWorld", DBase)

---@return boolean
function CWorld.static:StaticAPIs()
	return true
end

---@param position Vector
---@return Vector
function CWorld.static:GetGroundPosition(position)
	return Vector(position.x, position.y, self:GetGroundZ(position))
end

_Classes_Inherite({"World"}, CWorld)

return CWorld