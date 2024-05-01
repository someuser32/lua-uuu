---@class CHTTP: DBase
local CHTTP = class("CHTTP", DBase)

---@return boolean
function CHTTP.static:StaticAPIs()
	return true
end

_Classes_Inherite({"HTTP"}, CHTTP)

return CHTTP