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
---@return boolean
function CPlayer.static:AddSelectedUnit(unit)
	return CEngine:RunScript("GameUI.SelectUnit("..tostring(unit:GetIndex())..", true)")
	-- return self:StaticAPICall("AddSelectedUnit", Player.AddSelectedUnit, self:GetLocal(), unit)
end

---@param unit CNPC | CNPC[]
---@return boolean
function CPlayer.static:SetSelectedUnit(unit)
	if type(unit) == "table" and (unit.IsClass == nil or not unit:IsClass()) then
		for _, select_unit in pairs(unit) do
			if _ == 1 then
				self:SetSelectedUnit(select_unit)
			else
				self:AddSelectedUnit(select_unit)
			end
		end
		return true
	end
	return CEngine:RunScript("GameUI.SelectUnit("..tostring(unit:GetIndex())..", false)")
end

---@param unit CNPC
---@return nil
function CPlayer.static:DeselectUnit(unit)
	return self:SetSelectedUnit(table.filter(self:GetSelectedUnits(), function(_, selected_unit) return selected_unit ~= unit end))
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