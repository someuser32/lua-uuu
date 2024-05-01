---@class CRune: CEntity
local CRune = class("CRune", CEntity)

---@return string[]
function CRune.static:ListAPIs()
	return {
		"GetAll",
	}
end

---@return CRune[]
function CRune.static:GetAll()
	return self:StaticAPICall("GetAll", Runes.GetAll)
end

---@return integer
function CRune.static:Count()
	return self:StaticAPICall("Count", Runes.Count)
end

---@param ent integer
---@return CRune?
function CRune.static:Get(ent)
	return self:StaticAPICall("Get", Runes.Get, ent)
end

---@param ent CRune
---@return boolean
function CRune.static:Contains(ent)
	return self:StaticAPICall("Contains", Runes.Contains, ent)
end

_Classes_Inherite({"Entity", "Rune"}, CRune)

return CRune