local CTempTree = class("CTempTree", CEntity)

function CTempTree.static:ListAPIs()
	return {
		"GetAll",
		"InRadius",
	}
end

function CTempTree.static:GetAll()
	return self:StaticAPICall("GetAll", TempTrees.GetAll)
end

function CTempTree.static:Count()
	return self:StaticAPICall("Count", TempTrees.Count)
end

function CTempTree.static:Get()
	return self:StaticAPICall("Get", TempTrees.Get)
end

function CTempTree.static:Contains(ent)
	return self:StaticAPICall("Contains", TempTrees.Contains, ent)
end

function CTempTree.static:FindInRadius(vec, radius)
	return self:StaticAPICall("InRadius", TempTrees.InRadius, vec, radius)
end

_Classes_Inherite({"Entity"}, CTempTree)

return CTempTree