---@param include_pregame boolean?
---@return number
function GameRules.GetIngameTime(include_pregame)
	if GameRules.GetGameState() == Enum.GameState.DOTA_GAMERULES_STATE_PRE_GAME then
		if not include_pregame then
			return 0
		end
		return GameRules.GetGameTime() - GameRules.GetPreGameStartTime()
	end
	return GameRules.GetGameTime() - GameRules.GetGameStartTime()
end