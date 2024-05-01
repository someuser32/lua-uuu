---@class CFogOfWar: DBase
local CFogOfWar = class("CFogOfWar", DBase)

---@return boolean
function CFogOfWar.static:StaticAPIs()
	return true
end

_Classes_Inherite({"FogOfWar"}, CFogOfWar)

return CFogOfWar