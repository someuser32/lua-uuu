---@class CGameRules: DBase
local CGameRules = class("CGameRules", DBase)

---@return boolean
function CGameRules.static:StaticAPIs()
	return true
end

---@return number
function CGameRules.static:GetIngameTime()
	return self:StaticAPICall("GetGameTime", GameRules.GetGameTime) - self:StaticAPICall("GetGameStartTime", GameRules.GetGameStartTime)
end

_Classes_Inherite({"GameRules"}, CGameRules)

return CGameRules