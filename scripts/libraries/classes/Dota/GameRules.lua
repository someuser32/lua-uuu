local CGameRules = class("CGameRules", DBase)

function CGameRules.static:StaticAPIs()
	return true
end

function CGameRules.static:GetIngameTime()
	return self:StaticAPICall("GetGameTime", GameRules.GetGameTime) - self:StaticAPICall("GetGameStartTime", GameRules.GetGameStartTime)
end

_Classes_Inherite({"GameRules"}, CGameRules)

return CGameRules