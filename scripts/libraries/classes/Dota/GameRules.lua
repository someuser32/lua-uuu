---@class CGameRules: DBase
local CGameRules = class("CGameRules", DBase)

---@return boolean
function CGameRules.static:StaticAPIs()
	return true
end

---@return number
function CGameRules.static:GetIngameTime(include_pregame)
	if self:GetGameState() == Enum.GameState.DOTA_GAMERULES_STATE_PRE_GAME then
		if not include_pregame then
			return 0
		end
		return self:GetGameTime() - self:GetPreGameStartTime()
	end
	return self:GetGameTime() - self:GetGameStartTime()
end

_Classes_Inherite({"GameRules"}, CGameRules)

return CGameRules