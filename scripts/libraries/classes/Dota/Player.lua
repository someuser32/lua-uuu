local CPlayer = class("CPlayer", CEntity)

function CPlayer.static:ListAPIs()
	return {
		"GetAll",
	}
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

_Classes_Inherite({"Player", "Entity"}, CPlayer)

return CPlayer