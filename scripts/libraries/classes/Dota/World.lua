local CWorld = class("CWorld", DBase)

function CWorld.static:StaticAPIs()
	return true
end

function CWorld.static:GetGroundPosition(position)
	return Vector(position:GetX(), position:GetY(), self:GetGroundZ(position))
end

_Classes_Inherite({"World"}, CWorld)

return CWorld