local CTree = class("CTree", CEntity)

function CTree.static:ListAPIs()
	return {
		"GetAll",
		"InRadius",
	}
end

function CTree.static:GetAll()
	return self:StaticAPICall("GetAll", Trees.GetAll)
end

function CTree.static:Count()
	return self:StaticAPICall("Count", Trees.Count)
end

function CTree.static:Get()
	return self:StaticAPICall("Get", Trees.Get)
end

function CTree.static:Contains(ent)
	return self:StaticAPICall("Contains", Trees.Contains, ent)
end

function CTree.static:FindInRadius(vec, radius, active)
	return self:StaticAPICall("InRadius", Trees.InRadius, vec, radius, active)
end

_Classes_Inherite({"Entity", "Tree"}, CTree)

return CTree