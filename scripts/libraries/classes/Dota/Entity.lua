local CEntity = class("CEntity", DBase)

function CEntity.static:StaticAPIs()
	return {
		"Get",
	}
end

function CEntity.static:ListAPIs()
	return {
		"GetHeroesInRadius",
		"GetUnitsInRadius",
		"GetTreesInRadius",
		"GetTempTreesInRadius",
	}
end

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

function CEntity:IsTree()
	return self:IsTempTree() or self:IsMapTree()
end

function CEntity:IsMapTree()
	return self:GetClassName() == "C_DOTA_MapTree"
end

function CEntity:IsTempTree()
	return self:GetClassName() == "C_DOTA_TempTree"
end

_Classes_Inherite({"Entity"}, CEntity)

return CEntity