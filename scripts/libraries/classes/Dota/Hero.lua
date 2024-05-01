---@class CHero: CNPC
local CHero = class("CHero", CNPC)

---@return string[]
function CHero.static:ListAPIs()
	return {
		"GetAll",
		"InRadius",
	}
end

---@return CHero[]
function CHero.static:GetAll()
	return self:StaticAPICall("GetAll", Heroes.GetAll)
end

---@return integer
function CHero.static:Count()
	return self:StaticAPICall("Count", Heroes.Count)
end

---@param ent integer
---@return CHero?
function CHero.static:Get(ent)
	return self:StaticAPICall("Get", Heroes.Get, ent)
end

---@param ent CHero
---@return boolean
function CHero.static:Contains(ent)
	return self:StaticAPICall("Contains", Heroes.Contains, ent)
end

---@param vec Vector
---@param radius number
---@param teamNum Enum.TeamNum
---@param teamType Enum.TeamType
---@return CHero[]
function CHero.static:FindInRadius(vec, radius, teamNum, teamType)
	return self:StaticAPICall("InRadius", Heroes.InRadius, vec, radius, teamNum, teamType)
end

---@return CHero?
function CHero.static:GetLocal()
	return self:StaticAPICall("GetLocal", Heroes.GetLocal)
end

---@return CHero[]
function CHero.static:GetEnemies()
	local localTeam = CPlayer:GetLocalTeam()
	return table.values(table.filter(CHero:GetAll(), function(_, hero)
		return localTeam ~= hero:GetTeamNum()
	end))
end

---@return {integer: string}
function CHero.static:GetEnemiesHeroNames()
	local localTeam = CPlayer:GetLocalTeam()
	local enemyPlayers = table.values(table.filter(CPlayer:GetAll(), function(_, player)
		return localTeam ~= player:GetTeamNum()
	end))
	local enemies = {}
	for _, player in pairs(enemyPlayers) do
		enemies[player:GetPlayerID()] = KVLib:HeroIDToName(player:GetTeamData()["selected_hero_id"])
	end
	return enemies
end

---@return CHero[]
function CHero.static:GetAllies()
	local localTeam = CPlayer:GetLocalTeam()
	return table.values(table.filter(CHero:GetAll(), function(_, hero)
		return localTeam == hero:GetTeamNum()
	end))
end

---@return {integer: string}
function CHero.static:GetAlliesHeroNames()
	local localTeam = CPlayer:GetLocalTeam()
	local allyPlayers = table.values(table.filter(CPlayer:GetAll(), function(_, player)
		return localTeam == player:GetTeamNum()
	end))
	local allies = {}
	for _, player in pairs(allyPlayers) do
		allies[player:GetPlayerID()] = KVLib:HeroIDToName(player:GetTeamData()["selected_hero_id"])
	end
	return allies
end

---@return CHero[]
function CHero.static:GetAlliesOnly()
	local localHero = CHero.GetLocal()
	local localTeam = localHero:GetTeamNum()
	return table.values(table.filter(CHero:GetAll(), function(_, hero)
		return localHero ~= hero and localTeam == hero:GetTeamNum()
	end))
end

---@return {integer: string}
function CHero.static:GetAlliesOnlyHeroNames()
	local localPlayer = CPlayer:GetLocal()
	local localTeam = localPlayer:GetTeamNum()
	local allyPlayers = table.values(table.filter(CPlayer:GetAll(), function(_, player)
		return localPlayer ~= player and localTeam == player:GetTeamNum()
	end))
	local allies = {}
	for _, player in pairs(allyPlayers) do
		allies[player:GetPlayerID()] = KVLib:HeroIDToName(player:GetTeamData()["selected_hero_id"])
	end
	return allies
end

_Classes_Inherite({"Entity", "NPC", "Hero"}, CHero)

return CHero