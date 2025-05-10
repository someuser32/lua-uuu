---@return Enum.TeamNum
function Players.GetLocalTeam()
	return Entity.GetTeamNum(Players.GetLocal())
end