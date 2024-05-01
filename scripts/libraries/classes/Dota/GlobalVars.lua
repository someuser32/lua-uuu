---@class CGlobalVars: DBase
local CGlobalVars = class("CGlobalVars", DBase)

---@return boolean
function CGlobalVars.static:StaticAPIs()
	return true
end

_Classes_Inherite({"GlobalVars"}, CGlobalVars)

return CGlobalVars