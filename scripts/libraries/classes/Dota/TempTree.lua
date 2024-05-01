---@class CTempTree: CEntity
local CTempTree = class("CTempTree", CEntity)

---@return string[]
function CTempTree.static:ListAPIs()
	return {
		"GetAll",
		"InRadius",
	}
end

---@return CTempTree[]
function CTempTree.static:GetAll()
	return self:StaticAPICall("GetAll", TempTrees.GetAll)
end

---@return integer
function CTempTree.static:Count()
	return self:StaticAPICall("Count", TempTrees.Count)
end

---@param ent integer
---@return CTempTree?
function CTempTree.static:Get(ent)
	return self:StaticAPICall("Get", TempTrees.Get, ent)
end

---@param ent CTempTree
---@return boolean
function CTempTree.static:Contains(ent)
	return self:StaticAPICall("Contains", TempTrees.Contains, ent)
end

---@param vec Vector
---@param radius number
---@return CTempTree[]
function CTempTree.static:FindInRadius(vec, radius)
	return self:StaticAPICall("InRadius", TempTrees.InRadius, vec, radius)
end

_Classes_Inherite({"Entity"}, CTempTree)

return CTempTree