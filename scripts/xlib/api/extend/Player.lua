---@return Enum.TeamNum
function Player.GetLocalTeam()
	return Entity.GetTeamNum(Players.GetLocal())
end