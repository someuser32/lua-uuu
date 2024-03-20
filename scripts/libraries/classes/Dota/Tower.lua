local CTower = class("CTower", CNPC)

function CTower.static:GetType(func_name, val)
	if val == nil then
		return nil
	end
	local types = {
		["GetAttackTarget"] = "CNPC",
	}
	return types[func_name] or CNPC.GetType(self, func_name, val)
end

function CTower.static:ListAPIs()
	return {
		"GetAll",
		"InRadius",
	}
end

function CTower.static:GetAll()
	return self:StaticAPICall("GetAll", Towers.GetAll)
end

function CTower.static:Count()
	return self:StaticAPICall("Count", Towers.Count)
end

function CTower.static:Get()
	return self:StaticAPICall("Get", Towers.Get)
end

function CTower.static:Contains(ent)
	return self:StaticAPICall("Contains", Towers.Contains, ent)
end

function CTower.static:FindInRadius(vec, radius, teamNum, teamType)
	return self:StaticAPICall("InRadius", Towers.InRadius, vec, radius, teamNum, teamType)
end

_Classes_Inherite({"Entity", "NPC", "Tower"}, CTower)

return CTower