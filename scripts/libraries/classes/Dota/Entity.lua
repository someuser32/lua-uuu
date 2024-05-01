---@class CEntity: DBase
local CEntity = class("CEntity", DBase)

---@return string[]
function CEntity.static:StaticAPIs()
	return {
		"Get",
	}
end

---@return string[]
function CEntity.static:ListAPIs()
	return {
		"GetHeroesInRadius",
		"GetUnitsInRadius",
		"GetTreesInRadius",
		"GetTempTreesInRadius",
	}
end

---@param func_name string
---@param val any
---@return string[] | any?
function CEntity.static:GetType(func_name, val)
	if val == nil then
		return nil
	end
	local types = {
		["GetHeroesInRadius"] = "CHero",
		["GetUnitsInRadius"] = "CNPC",
		["GetTreesInRadius"] = "CTree",
		["GetTempTreesInRadius"] = "CTree",
	}
	return types[func_name] or DBase.GetType(self, func_name, val)
end

---@return boolean
function CEntity:IsTree()
	return self:IsTempTree() or self:IsMapTree()
end

---@return boolean
function CEntity:IsMapTree()
	return self:GetClassName() == "C_DOTA_MapTree"
end

---@return boolean
function CEntity:IsTempTree()
	return self:GetClassName() == "C_DOTA_TempTree"
end

_Classes_Inherite({"Entity"}, CEntity)

return CEntity