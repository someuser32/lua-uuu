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
	local localplayer = self:GetLocal()
	if localplayer == nil then
		return Enum.TeamNum.TEAM_NONE
	end
	return localplayer:GetTeamNum()
end

---@return integer
function CPlayer.static:GetLocalID()
	return self:GetLocal():GetPlayerID()
end

---@param unit CNPC
---@return boolean
function CPlayer.static:AddSelectedUnit(unit)
	return self:StaticAPICall("AddSelectedUnit", Player.AddSelectedUnit, self:GetLocal(), unit)
end

---@param unit CNPC | CNPC[]
---@return boolean
function CPlayer.static:SetSelectedUnit(unit)
	if type(unit) == "table" and (unit.IsClass == nil or not unit:IsClass()) then
		if #unit == 0 then
			self:ClearSelectedUnits()
		end
		for _, select_unit in pairs(unit) do
			if _ == 1 then
				self:SetSelectedUnit(select_unit)
			else
				self:AddSelectedUnit(select_unit)
			end
		end
		return true
	end
	self:ClearSelectedUnits()
	return self:AddSelectedUnit(unit)
end

---@param unit CNPC | CNPC[]
---@return nil
function CPlayer.static:DeselectUnit(unit)
	if not self:IsUnitSelected(unit) then return end
	local units = {}
	if type(unit) == "table" and (unit.IsClass and unit:IsClass()) then
		table.insert(units, unit)
	else
		units = unit
	end
	return self:SetSelectedUnit(table.filter(self:GetSelectedUnits(), function(_, selected_unit) return not table.contains(units, selected_unit) end))
end

---@return nil
function CPlayer.static:ClearSelectedUnits()
	return self:StaticAPICall("ClearSelectedUnits", Player.ClearSelectedUnits, self:GetLocal())
end

---@return CNPC[]
function CPlayer.static:GetSelectedUnits()
	return self:StaticAPICall("GetSelectedUnits", Player.GetSelectedUnits, self:GetLocal()) or {}
end

---@param unit CNPC | CNPC[]
---@return boolean
function CPlayer.static:IsUnitSelected(unit)
	local units = {}
	if type(unit) == "table" and (unit.IsClass and unit:IsClass()) then
		table.insert(units, unit)
	else
		units = unit
	end
	for _, selected_unit in pairs(self:GetSelectedUnits()) do
		if table.contains(units, selected_unit) then
			return true
		end
	end
	return false
end

---@return CAbility?
function CPlayer.static:GetActiveAbility()
	return self:StaticAPICall("GetActiveAbility", Player.GetActiveAbility, self:GetLocal())
end

---@return {top_left: [number, number], top_right: [number, number], bottom_left: [number, number], bottom_right: [number, number]}?
function CPlayer:GetTopbarPanelBounds()
	local topbar = CPanorama:GetPanelByPath({"HUDElements", "topbar"})
	if topbar == nil or not topbar:IsVisible() then
		return nil
	end
	local panels = {
		[Enum.TeamNum.TEAM_RADIANT] = "RadiantPlayer%PlayerID%",
		[Enum.TeamNum.TEAM_DIRE] = "DirePlayer%PlayerID%"
	}
	local playerID = self:GetPlayerID()
	local team = self:GetTeamNum()
	local panel_name = string.gsub(panels[team], "%%PlayerID%%", tostring(playerID))
	local topbar_player = topbar:FindChildByPathTraverse({panel_name, "HeroImage"})
	if topbar_player == nil then
		return nil
	end
	local bounds = topbar_player:GetBounds()
	return {
		top_left={team ~= Enum.TeamNum.TEAM_DIRE and bounds["x"] or bounds["x"] + 5, bounds["y"]},
		top_right={team ~= Enum.TeamNum.TEAM_DIRE and bounds["x"] + bounds["w"] - 5 or bounds["x"] + bounds["w"], bounds["y"]},
		bottom_left={team ~= Enum.TeamNum.TEAM_DIRE and bounds["x"] + 5 or bounds["x"], bounds["y"] + bounds["h"]},
		bottom_right={team ~= Enum.TeamNum.TEAM_DIRE and bounds["x"] + bounds["w"] or bounds["x"] + bounds["w"] - 5, bounds["y"] + bounds["h"]},
	}
end

_Classes_Inherite({"Player", "Entity"}, CPlayer)

return CPlayer