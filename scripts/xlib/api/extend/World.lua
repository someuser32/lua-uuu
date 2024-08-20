---@param pos Vector
---@return Vector
function World.GetGroundPosition(pos)
	return Vector(pos.x, pos.y, World.GetGroundZ(pos))
end