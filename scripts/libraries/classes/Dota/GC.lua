---@class CGC: DBase
local CGC = class("CGC", DBase)

---@return boolean
function CGC.static:StaticAPIs()
	return true
end

_Classes_Inherite({"GC"}, CGC)

return CGC