local CPlayer = class("CPlayer", CEntity)

function CPlayer.static:ListAPIs()
	return {
		"GetAll",
		"GetSelectedUnits",
	}
end

function CPlayer.static:GetType(func_name, val)
	if val == nil then
		return nil
	end
	local types = {
		["GetSelectedUnits"] = "CNPC",
	}
	return types[func_name] or CEntity.GetType(self, func_name, val)
end

function CPlayer.static:GetAll()
	return self:StaticAPICall("GetAll", Players.GetAll)
end

function CPlayer.static:Count()
	return self:StaticAPICall("Count", Players.Count)
end

function CPlayer.static:Get()
	return self:StaticAPICall("Get", Players.Get)
end

function CPlayer.static:Contains(ent)
	return self:StaticAPICall("Contains", Players.Contains, ent)
end

function CPlayer.static:GetLocal()
	return self:StaticAPICall("GetLocal", Players.GetLocal)
end

function CPlayer.static:GetLocalTeam()
	return self:GetLocal():GetTeamNum()
end

function CPlayer.static:GetLocalID()
	return self:GetLocal():GetPlayerID()
end

function CPlayer.static:SetSelectedUnit(unit)
	return CEngine:RunScript("GameUI.SelectUnit("..tostring(unit:GetIndex())..", false)")
end

function CPlayer.static:DeselectUnit(unit)
	local selected_units = self:GetLocal():GetSelectedUnits()
	local initial_selected = false
	for _, selected_unit in pairs(selected_units) do
		if selected_unit ~= unit then
			if not initial_selected then
				self:SetSelectedUnit(selected_unit)
				initial_selected = true
			else
				self:GetLocal():AddSelectedUnit(selected_unit)
			end
		end
	end
end

_Classes_Inherite({"Player", "Entity"}, CPlayer)

return CPlayer