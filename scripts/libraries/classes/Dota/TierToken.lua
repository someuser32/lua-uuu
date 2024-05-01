---@class CTierToken: DBase
local CTierToken = class("CTierToken", DBase)

---@return boolean
function CTierToken.static:StaticAPIs()
	return true
end

_Classes_Inherite({"TierToken"}, CTierToken)

return CTierToken