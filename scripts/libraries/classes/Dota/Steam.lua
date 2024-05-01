---@class CSteam: DBase
local CSteam = class("CSteam", DBase)

---@return boolean
function CSteam.static:StaticAPIs()
	return true
end

_Classes_Inherite({"Steam"}, CSteam)

return CSteam