---@class CTower: CNPC
local CTower = class("CTower", CNPC)

---@param func_name string
---@param val any
---@return string[] | any?
function CTower.static:GetType(func_name, val)
	if val == nil then
		return nil
	end
	local types = {
		["GetAttackTarget"] = "CNPC",
	}
	return types[func_name] or CNPC.GetType(self, func_name, val)
end

---@return string[]
function CTower.static:ListAPIs()
	return {
		"GetAll",
		"InRadius",
	}
end

---@return CTower[]
function CTower.static:GetAll()
	return self:StaticAPICall("GetAll", Towers.GetAll)
end

---@return integer
function CTower.static:Count()
	return self:StaticAPICall("Count", Towers.Count)
end

---@param ent integer
---@return CTower?
function CTower.static:Get()
	return self:StaticAPICall("Get", Towers.Get)
end

---@param ent CTower
---@return boolean
function CTower.static:Contains(ent)
	return self:StaticAPICall("Contains", Towers.Contains, ent)
end

---@param vec Vector
---@param radius number
---@param teamNum Enum.TeamNum
---@param teamType Enum.TeamType
---@return CTower[]
function CTower.static:FindInRadius(vec, radius, teamNum, teamType)
	return self:StaticAPICall("InRadius", Towers.InRadius, vec, radius, teamNum, teamType)
end

_Classes_Inherite({"Entity", "NPC", "Tower"}, CTower)

return CTower