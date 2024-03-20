local CRune = class("CRune", CEntity)

function CRune.static:ListAPIs()
	return {
		"GetAll",
	}
end

function CRune.static:GetAll()
	return self:StaticAPICall("GetAll", Runes.GetAll)
end

function CRune.static:Count()
	return self:StaticAPICall("Count", Runes.Count)
end

function CRune.static:Get()
	return self:StaticAPICall("Get", Runes.Get)
end

function CRune.static:Contains(ent)
	return self:StaticAPICall("Contains", Runes.Contains, ent)
end

_Classes_Inherite({"Entity", "Rune"}, CRune)

return CRune