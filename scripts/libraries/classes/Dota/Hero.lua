local CHero = class("CHero", CNPC)

function CHero.static:ListAPIs()
	return {
		"GetAll",
		"InRadius",
	}
end

function CHero.static:GetAll()
	return self:StaticAPICall("GetAll", Heroes.GetAll)
end

function CHero.static:Count()
	return self:StaticAPICall("Count", Heroes.Count)
end

function CHero.static:Get()
	return self:StaticAPICall("Get", Heroes.Get)
end

function CHero.static:Contains(ent)
	return self:StaticAPICall("Contains", Heroes.Contains, ent)
end

function CHero.static:FindInRadius(vec, radius, teamNum, teamType)
	return self:StaticAPICall("InRadius", Heroes.InRadius, vec, radius, teamNum, teamType)
end

function CHero.static:GetLocal()
	return self:StaticAPICall("GetLocal", Heroes.GetLocal)
end

function CHero.static:GetEnemies()
	local localTeam = CPlayer:GetLocalTeam()
	return table.values(table.filter(CHero:GetAll(), function(_, hero)
		return localTeam ~= hero:GetTeamNum()
	end))
end

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

function CHero.static:GetAllies()
	local localTeam = CPlayer:GetLocalTeam()
	return table.values(table.filter(CHero:GetAll(), function(_, hero)
		return localTeam == hero:GetTeamNum()
	end))
end

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

function CHero.static:GetAlliesOnly()
	local localHero = CHero.GetLocal()
	local localTeam = localHero:GetTeamNum()
	return table.values(table.filter(CHero:GetAll(), function(_, hero)
		return localHero ~= hero and localTeam == hero:GetTeamNum()
	end))
end

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