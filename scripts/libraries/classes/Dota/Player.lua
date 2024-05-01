---@class CPlayer: CEntity
local CPlayer = class("CPlayer", CEntity)

---@return string[]
function CPlayer.static:ListAPIs()
	return {
		"GetAll",
		"GetSelectedUnits",
	}
end

---@param func_name string
---@param val any
---@return string[] | any?
function CPlayer.static:GetType(func_name, val)
	if val == nil then
		return nil
	end
	local types = {
		["GetSelectedUnits"] = "CNPC",
		["GetActiveAbility"] = "CAbility",
	}
	return types[func_name] or CEntity.GetType(self, func_name, val)
end

---@return CPlayer[]
function CPlayer.static:GetAll()
	return self:StaticAPICall("GetAll", Players.GetAll)
end

---@return integer
function CPlayer.static:Count()
	return self:StaticAPICall("Count", Players.Count)
end

---@param ent integer
---@return CPlayer?
function CPlayer.static:Get(ent)
	return self:StaticAPICall("Get", Players.Get, ent)
end

---@param ent CPlayer
---@return boolean
function CPlayer.static:Contains(ent)
	return self:StaticAPICall("Contains", Players.Contains, ent)
end

---@return CPlayer?
function CPlayer.static:GetLocal()
	return self:StaticAPICall("GetLocal", Players.GetLocal)
end

---@return Enum.TeamNum
function CPlayer.static:GetLocalTeam()
	return self:GetLocal():GetTeamNum()
end

---@return integer
function CPlayer.static:GetLocalID()
	return self:GetLocal():GetPlayerID()
end

---@param unit CNPC
---@return nil
function CPlayer.static:AddSelectedUnit(unit)
	return self:StaticAPICall("AddSelectedUnit", Player.AddSelectedUnit, self:GetLocal(), unit)
end

---@param unit CNPC | CNPC[]
---@return boolean
function CPlayer.static:SetSelectedUnit(unit)
	if unit.ent == nil and type(unit) == "table" then
		self:SetSelectedUnit(unit[1])
		for _, select_unit in pairs(unit) do
			self:AddSelectedUnit(select_unit)
		end
		return
	end
	return CEngine:RunScript("GameUI.SelectUnit("..tostring(unit:GetIndex())..", false)")
end

---@param unit CNPC
---@return nil
function CPlayer.static:DeselectUnit(unit)
	local selected_units = self:GetSelectedUnits()
	local initial_selected = false
	for _, selected_unit in pairs(selected_units) do
		if selected_unit ~= unit then
			if not initial_selected then
				self:SetSelectedUnit(selected_unit)
				initial_selected = true
			else
				self:AddSelectedUnit(selected_unit)
			end
		end
	end
end

---@return CNPC[]
function CPlayer.static:GetSelectedUnits()
	return self:StaticAPICall("GetSelectedUnits", Player.GetSelectedUnits, self:GetLocal())
end

---@return CAbility?
function CPlayer.static:GetActiveAbility()
	return self:StaticAPICall("GetActiveAbility", Player.GetActiveAbility, self:GetLocal())
end

_Classes_Inherite({"Player", "Entity"}, CPlayer)

return CPlayer