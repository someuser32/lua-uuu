---@class CTree: CEntity
local CTree = class("CTree", CEntity)

---@return string[]
function CTree.static:ListAPIs()
	return {
		"GetAll",
		"InRadius",
	}
end

---@return CTree[]
function CTree.static:GetAll()
	return self:StaticAPICall("GetAll", Trees.GetAll)
end

---@return integer
function CTree.static:Count()
	return self:StaticAPICall("Count", Trees.Count)
end

---@param ent integer
---@return integer
function CTree.static:Get(ent)
	return self:StaticAPICall("Get", Trees.Get, ent)
end

---@param ent CTree
---@return boolean
function CTree.static:Contains(ent)
	return self:StaticAPICall("Contains", Trees.Contains, ent)
end

---@param vec Vector
---@param radius number
---@param active boolean?
---@return CTree[]
function CTree.static:FindInRadius(vec, radius, active)
	return self:StaticAPICall("InRadius", Trees.InRadius, vec, radius, active)
end

_Classes_Inherite({"Entity", "Tree"}, CTree)

return CTree